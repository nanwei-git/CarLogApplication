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

export const COLORS: AppColors = {
  bg0: '#FDF6DC', // 奶油黄（顶部）
  bg1: '#E9F5DA', // 浅黄绿
  bg2: '#C8F0E4', // 薄荷
  bg3: '#BFF0EC', // 浅青（底部）
  card: 'rgba(255,255,255,0.82)', // 半透明白卡
  line: 'rgba(255,255,255,0.65)', // 细白描边
  ink: '#2F4F49', // 正文（深墨绿，保证浅底对比度）
  inkSub: '#6E8B85', // 次级文字
  accent: '#3FB9A2', // 薄荷主色（按钮/未选中点缀）
  accentDeep: '#2E9E8A', // 强调/选中/按压
  highlight: '#F6E7A9', // 奶油黄高亮（优惠标签等）
  danger: '#E58A8A' // 删除/警示
}

// 纵向线性渐变背景（奶油黄 → 薄荷青）
export const BG_GRADIENT: LinearGradient = {
  direction: GradientDirection.Bottom,
  colors: [
    [COLORS.bg0, 0.0] as [string, number],
    [COLORS.bg1, 0.35] as [string, number],
    [COLORS.bg2, 0.7] as [string, number],
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
