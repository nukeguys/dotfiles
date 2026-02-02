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
    icon_cost='💰'
    icon_style='✏️'
    ;;
  none)
    icon_folder=''
    icon_branch=''
    icon_model=''
    icon_context=''
    icon_cost=''
    icon_style=''
    ;;
  *)  # nerd (default)
    icon_folder='󰉋'
    icon_branch=''
    icon_model='󰘦'
    icon_context=''
    icon_cost='󰄀'
    icon_style='󰦨'
    ;;
esac

# Get all data from JSON in a single jq call
eval "$(echo "$input" | jq -r '
  @sh "cwd=\(.workspace.current_dir // empty)",
  @sh "model=\(.model.display_name // empty)",
  @sh "input_tokens=\(.context_window.total_input_tokens // 0)",
  @sh "output_tokens=\(.context_window.total_output_tokens // 0)",
  @sh "context_size=\(.context_window.context_window_size // 200000)",
  @sh "used_pct=\(.context_window.used_percentage // 0)",
  @sh "cost=\(.cost.total_cost_usd // 0)",
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

# Cost with color based on amount
if [ -n "$cost" ] && [ "$cost" != "null" ] && [ "$cost" != "0" ]; then
  cost_fmt=$(printf "%.2f" "$cost" 2>/dev/null || echo "0.00")

  # Color based on cost (thresholds: $0.50, $2.00)
  cost_cents=$(printf "%.0f" "$(echo "$cost * 100" | bc 2>/dev/null || echo "0")")
  if [ "$cost_cents" -ge 200 ]; then
    cost_color="$red"
  elif [ "$cost_cents" -ge 50 ]; then
    cost_color="$orange"
  else
    cost_color="$yellow"
  fi

  if [ -n "$icon_cost" ]; then
    output="${output} ${grey}│${reset} ${cost_color}${icon_cost} \$${cost_fmt}${reset}"
  else
    output="${output} ${grey}│${reset} ${cost_color}\$${cost_fmt}${reset}"
  fi
fi

printf "%b" "$output"
