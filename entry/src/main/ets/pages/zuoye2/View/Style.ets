// 设计令牌（Design Token）—— 暗色科技风 · 玻璃拟态 · 冷色（蓝/紫/青）渐变
// 与 UI_STYLE_GUIDE.md 保持一致，供反馈模块各页面统一引用

interface ColorToken {
  bg: string;
  ink: string;
  ink2: string;
  ink3: string;
  line: string;
  blue: string;
  blueL: string;
  purple: string;
  purpleL: string;
  pink: string;
  cyan: string;
  cyanL: string;
  success: string;
  warn: string;
  danger: string;
}

export const COLORS: ColorToken = {
  // 背景
  bg: '#05060d',
  // 文字层级
  ink: '#eef2fb',
  ink2: 'rgba(238,242,251,0.66)',
  ink3: 'rgba(238,242,251,0.40)',
  // 玻璃边框
  line: 'rgba(255,255,255,0.14)',
  // 强调色（三色渐变家族）
  blue: '#60a5fa',
  blueL: '#8fc4ff',
  purple: '#a78bfa',
  purpleL: '#c9b3ff',
  pink: '#ff9ad8',
  cyan: '#2dd4bf',
  cyanL: '#7ce7ff',
  // 功能色
  success: 'rgba(94,242,160,0.85)',
  warn: '#ffb4b4',
  danger: '#ff6b6b'
};

// 玻璃面板背景渐变（linear-gradient 155deg, 半透白）
export const GLASS_GRADIENT: LinearGradient = {
  direction: GradientDirection.RightBottom,
  colors: [
    ['rgba(255,255,255,0.12)', 0.0] as [string, number],
    ['rgba(255,255,255,0.045)', 0.55] as [string, number],
    ['rgba(255,255,255,0.065)', 1.0] as [string, number]
  ]
};

// 主按钮激活态渐变（青 → 粉紫）
export const ACCENT_GRADIENT: LinearGradient = {
  direction: GradientDirection.RightBottom,
  colors: [
    [COLORS.cyanL, 0.0] as [string, number],
    [COLORS.purple, 0.55] as [string, number],
    [COLORS.pink, 1.0] as [string, number]
  ]
};
