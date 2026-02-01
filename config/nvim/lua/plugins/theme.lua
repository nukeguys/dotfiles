return {
  -- 테마 플러그인 설치
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- 다른 플러그인보다 먼저 로드되도록 설정
    opts = {
      flavour = "mocha", -- latte, frappe, macchiato, mocha 중 선택 가능
      transparent_background = true, -- 터미널 배경 투명도 유지 여부
    },
  },
}
