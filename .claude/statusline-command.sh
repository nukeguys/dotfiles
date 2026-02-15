#!/bin/bash

# Read JSON input from Claude Code
input=$(cat)

# Colors
blue='\033[38;5;75m'
orange='\033[38;5;208m'
purple='\033[38;5;141m'
green='\033[38;5;114m'
yellow='\033[38;5;220m'
red='\033[38;5;203m'
grey='\033[38;5;240m'
cyan='\033[38;5;81m'
reset='\033[0m'

# Icon set selection: nerd (default), unicode, none
# Set via: export CLAUDE_STATUSLINE_ICONS=unicode
ICON_SET="${CLAUDE_STATUSLINE_ICONS:-nerd}"

case "$ICON_SET" in
  unicode)
    icon_folder='📁'
    icon_branch='⎇'
    icon_model='🤖'
    icon_context='📊'
    icon_style='✏️'
    icon_mcp='🔌'
    icon_block='🔥'
    ;;
  none)
    icon_folder=''
    icon_branch=''
    icon_model=''
    icon_context=''
    icon_style=''
    icon_mcp=''
    icon_block=''
    ;;
  *)  # nerd (default)
    icon_folder='󰉋'
    icon_branch=''
    icon_model='󰘦'
    icon_context=''
    icon_style='󰦨'
    icon_mcp='󰌘'
    icon_block='󰔟'
    ;;
esac

# ccusage blocks cache settings
CCUSAGE_CACHE_FILE="/tmp/ccusage-blocks-cache.json"
CCUSAGE_CACHE_TTL="${CCUSAGE_CACHE_TTL:-30}"

get_ccusage_blocks() {
  # Check if cache file exists and is fresh
  if [ -f "$CCUSAGE_CACHE_FILE" ]; then
    cache_age=$(( $(date +%s) - $(stat -f %m "$CCUSAGE_CACHE_FILE" 2>/dev/null || echo 0) ))
    if [ "$cache_age" -lt "$CCUSAGE_CACHE_TTL" ]; then
      cat "$CCUSAGE_CACHE_FILE"
      return 0
    fi
  fi

  # Fetch fresh data
  local result
  result=$(bunx ccusage blocks --active --json --offline 2>/dev/null)
  if [ $? -eq 0 ] && [ -n "$result" ]; then
    echo "$result" > "$CCUSAGE_CACHE_FILE"
    echo "$result"
    return 0
  fi

  # Fallback: return stale cache if available
  if [ -f "$CCUSAGE_CACHE_FILE" ]; then
    cat "$CCUSAGE_CACHE_FILE"
    return 0
  fi

  return 1
}

# Get all data from JSON in a single jq call
eval "$(echo "$input" | jq -r '
  @sh "cwd=\(.workspace.current_dir // empty)",
  @sh "model=\(.model.display_name // empty)",
  @sh "input_tokens=\(.context_window.total_input_tokens // 0)",
  @sh "output_tokens=\(.context_window.total_output_tokens // 0)",
  @sh "context_size=\(.context_window.context_window_size // 200000)",
  @sh "used_pct=\(.context_window.used_percentage // 0)",
  @sh "output_style=\(.output_style.name // empty)"
')"

# Fallback for cwd
if [ -z "$cwd" ] || [ "$cwd" = "null" ]; then
  cwd=$(pwd)
fi

# Directory name
dir_name=$(basename "$cwd")

# Build output
output="${blue}${icon_folder} ${dir_name}${reset}"

# Git info
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

  # Detached HEAD
  if [ "$branch" = "HEAD" ]; then
    commit=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    branch="@${commit}"
  fi

  git_status="${branch}"

  # Dirty status
  if ! git -C "$cwd" --no-optional-locks diff --quiet 2>/dev/null || \
     ! git -C "$cwd" --no-optional-locks diff --cached --quiet 2>/dev/null || \
     [ -n "$(git -C "$cwd" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null)" ]; then
    git_status="${git_status}*"
  fi

  # Ahead/behind
  upstream=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref @{upstream} 2>/dev/null)
  if [ -n "$upstream" ]; then
    ahead=$(git -C "$cwd" --no-optional-locks rev-list --count @{upstream}..HEAD 2>/dev/null)
    behind=$(git -C "$cwd" --no-optional-locks rev-list --count HEAD..@{upstream} 2>/dev/null)

    if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
      git_status="${git_status} ⇣⇡"
    elif [ "$behind" -gt 0 ]; then
      git_status="${git_status} ⇣"
    elif [ "$ahead" -gt 0 ]; then
      git_status="${git_status} ⇡"
    fi
  fi

  output="${output} ${grey}│${reset} ${orange}${icon_branch} ${git_status}${reset}"
fi

# Model
if [ -n "$model" ] && [ "$model" != "null" ]; then
  output="${output} ${grey}│${reset} ${purple}${icon_model} ${model}${reset}"
fi

# MCP server count (global enabled - project disabled)
mcp_config="$HOME/.claude.json"
if [ -f "$mcp_config" ]; then
  mcp_count=$(jq --arg project "$cwd" '
    ([.mcpServers | to_entries[] | select(.value.disabled != true)] | length) -
    ([.projects[$project].disabledMcpServers // [] | .[] ] | length)
  ' "$mcp_config" 2>/dev/null)
  if [ -n "$mcp_count" ] && [ "$mcp_count" -gt 0 ] 2>/dev/null; then
    output="${output} ${grey}│${reset} ${green}${icon_mcp} ${mcp_count} MCP Active${reset}"
  fi
fi

# Output style
if [ -n "$output_style" ] && [ "$output_style" != "null" ]; then
  if [ -n "$icon_style" ]; then
    output="${output} ${grey}│${reset} ${cyan}${icon_style} ${output_style}${reset}"
  else
    output="${output} ${grey}│${reset} ${cyan}${output_style}${reset}"
  fi
fi

# Context usage with color based on percentage
if [ "$context_size" -gt 0 ] 2>/dev/null; then
  input_k=$((input_tokens / 1000))
  output_k=$((output_tokens / 1000))
  context_k=$((context_size / 1000))
  pct=${used_pct%.*}  # Remove decimal part

  # Color based on usage percentage
  if [ "$pct" -ge 80 ]; then
    ctx_color="$red"
  elif [ "$pct" -ge 50 ]; then
    ctx_color="$yellow"
  else
    ctx_color="$green"
  fi

  output="${output} ${grey}│${reset} ${ctx_color}${icon_context} ${input_k}k↓ ${output_k}k↑ (${pct}%)${reset}"
fi

# ccusage block info (session time remaining & token usage)
block_json=$(get_ccusage_blocks 2>/dev/null)
if [ -n "$block_json" ]; then
  # Extract active block info
  eval "$(echo "$block_json" | jq -r '
    (.blocks // [])[] | select(.isActive == true) |
    @sh "block_end_time=\(.endTime // empty)",
    @sh "block_is_active=true"
  ' 2>/dev/null)"

  if [ "$block_is_active" = "true" ] && [ -n "$block_end_time" ]; then
    # Calculate remaining time (endTime is UTC with Z suffix)
    clean_end_time=$(echo "$block_end_time" | sed 's/\.[0-9]*Z$//' | sed 's/Z$//')
    end_epoch=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$clean_end_time" +%s 2>/dev/null)
    now_epoch=$(date +%s)

    if [ -n "$end_epoch" ]; then
      remaining=$((end_epoch - now_epoch))
      if [ "$remaining" -gt 0 ]; then
        remain_h=$((remaining / 3600))
        remain_m=$(( (remaining % 3600) / 60 ))

        # Format remaining time
        if [ "$remain_h" -gt 0 ]; then
          remain_str="${remain_h}h ${remain_m}m"
        else
          remain_str="${remain_m}m"
        fi

        # Color based on remaining time
        if [ "$remaining" -ge 7200 ]; then
          block_color="$green"
        elif [ "$remaining" -ge 3600 ]; then
          block_color="$yellow"
        else
          block_color="$red"
        fi

        if [ -n "$icon_block" ]; then
          output="${output} ${grey}│${reset} ${block_color}${icon_block} ${remain_str} left${reset}"
        else
          output="${output} ${grey}│${reset} ${block_color}${remain_str} left${reset}"
        fi
      fi
    fi
  fi
fi

printf "%b" "$output"
