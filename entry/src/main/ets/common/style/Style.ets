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

// ============ Dark Neumorphism（深色拟态 · 特斯拉风，车主 App 主视觉）============
// 新拟态要点：卡片与背景同色，靠"左上亮边 + 右下暗影"双层投影造出体积感。
// 深色 = 特斯拉风近黑底；浅色 = 同结构浅灰底（设置页可切换，KT10 持久化）。

interface NeuColors {
  bg0: string
  bg1: string
  bg2: string
  bg3: string
  surface: string // 拟态基底（卡片与背景同色）
  surfaceRaised: string // 内圈高光面
  surfaceSunken: string // 凹陷面（按下态 / 进度轨道）
  line: string
  track: string // 进度环轨道
  ink: string
  inkSub: string
  accent: string // 特斯拉红
  accentDeep: string
  accentSoft: string // 主色柔光（激活态发光阴影）
  ok: string
  warn: string
  danger: string
  shadowDark: string // 右下暗影
  shadowLight: string // 左上亮边
}

// 深色拟态（默认主题）
export const NEU_DARK: NeuColors = {
  bg0: '#23272C',
  bg1: '#1F2327',
  bg2: '#1C1F23',
  bg3: '#191C20',
  surface: '#22262B',
  surfaceRaised: '#282D33',
  surfaceSunken: '#181B1F',
  line: 'rgba(255,255,255,0.06)',
  track: '#171A1E',
  ink: '#EAEEF3',
  inkSub: '#8B949F',
  accent: '#E82127',
  accentDeep: '#FF6A6A',
  accentSoft: 'rgba(232,33,39,0.30)',
  ok: '#3DDC97',
  warn: '#F5C451',
  danger: '#E5484D',
  shadowDark: 'rgba(0,0,0,0.70)',
  shadowLight: 'rgba(255,255,255,0.055)'
}

// 浅色拟态（设置页关闭"深色拟态"时的同结构浅色版）
export const NEU_LIGHT: NeuColors = {
  bg0: '#EAEEF4',
  bg1: '#F0F3F8',
  bg2: '#F6F8FC',
  bg3: '#FAFBFE',
  surface: '#E9ECF2',
  surfaceRaised: '#F2F4F9',
  surfaceSunken: '#DCE0E8',
  line: 'rgba(255,255,255,0.85)',
  track: '#DADEE6',
  ink: '#22262B',
  inkSub: '#7C8695',
  accent: '#E82127',
  accentDeep: '#FF6A6A',
  accentSoft: 'rgba(232,33,39,0.22)',
  ok: '#1FA97A',
  warn: '#D9962B',
  danger: '#D93B45',
  shadowDark: 'rgba(163,177,198,0.55)',
  shadowLight: 'rgba(255,255,255,0.90)'
}

// 拟态令牌取值：true 深色拟态 / false 浅色拟态
export function neu(dark: boolean): NeuColors {
  return dark ? NEU_DARK : NEU_LIGHT
}

// 拟态纵向渐变背景（页面根容器统一使用）
export function neuBg(dark: boolean): LinearGradient {
  const c: NeuColors = neu(dark)
  return {
    direction: GradientDirection.Bottom,
    colors: [
      [c.bg0, 0.0] as [string, number],
      [c.bg1, 0.35] as [string, number],
      [c.bg2, 0.7] as [string, number],
      [c.bg3, 1.0] as [string, number]
    ]
  }
}

// 主题选择（兼容既有页面）：true 深色拟态 / false 用户色卡
export function palette(dark: boolean): AppColors {
  return dark ? COLORS_DARK : COLORS
}

export function bgGradient(dark: boolean): LinearGradient {
  return dark ? BG_GRADIENT_DARK : BG_GRADIENT
}
