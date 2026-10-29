// 设计令牌（取自用户色卡：奶油黄 → 薄荷青，覆盖先前暗色玻璃风）
// 全工程统一引用，保证主题一致。

interface AppColors {
  bg0: string
  bg1: string
  bg2: string
  bg3: string
  card: string
  line: string
  ink: string
  inkSub: string
  accent: string
  accentDeep: string
  highlight: string
  danger: string
}

// 设计令牌（P1 对齐原型：极淡青白底 + 纯白卡 + 青绿主色 + 青→蓝渐变按钮）
export const COLORS: AppColors = {
  bg0: '#E7F6F8', // 极淡青白（顶部）
  bg1: '#F1FAFB', // 浅青
  bg2: '#FAFEFE', // 近白
  bg3: '#FFFFFF', // 纯白（底部）
  card: '#FFFFFF', // 纯白卡
  line: '#E6EAF0', // 浅灰描边（输入框/分隔）
  ink: '#1F2329', // 主文字
  inkSub: '#9AA3A8', // 次文字
  accent: '#4FC9C4', // 青绿主色（选中/图标）
  accentDeep: '#3A8DFF', // 渐变末端（青→蓝）
  highlight: '#E3F7F5', // 青绿浅色高亮（选中态底）
  danger: '#E54545' // 错误/警示（登录红字）
}

// 纵向线性渐变背景（极淡青白 → 纯白）
export const BG_GRADIENT: LinearGradient = {
  direction: GradientDirection.Bottom,
  colors: [
    [COLORS.bg0, 0.0] as [string, number],
    [COLORS.bg1, 0.4] as [string, number],
    [COLORS.bg2, 0.75] as [string, number],
    [COLORS.bg3, 1.0] as [string, number]
  ]
}

// 深色令牌（设置页"深色主题"开关用，KT10 持久化）
export const COLORS_DARK: AppColors = {
  bg0: '#0F1F1C',
  bg1: '#14302A',
  bg2: '#123B36',
  bg3: '#0E3A38',
  card: 'rgba(255,255,255,0.10)',
  line: 'rgba(255,255,255,0.18)',
  ink: '#E8F5F1',
  inkSub: '#9FBDB6',
  accent: '#3FB9A2',
  accentDeep: '#59D3BD',
  highlight: '#F6E7A9',
  danger: '#E58A8A'
}

export const BG_GRADIENT_DARK: LinearGradient = {
  direction: GradientDirection.Bottom,
  colors: [
    [COLORS_DARK.bg0, 0.0] as [string, number],
    [COLORS_DARK.bg1, 0.35] as [string, number],
    [COLORS_DARK.bg2, 0.7] as [string, number],
    [COLORS_DARK.bg3, 1.0] as [string, number]
  ]
}

// 主题选择：true 深色 / false 浅色（用户色卡）
export function palette(dark: boolean): AppColors {
  return dark ? COLORS_DARK : COLORS
}

export function bgGradient(dark: boolean): LinearGradient {
  return dark ? BG_GRADIENT_DARK : BG_GRADIENT
}
