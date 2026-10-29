// 通用 UI 组件（封存复用）：主/次按钮，薄荷主色，零业务数据
// 用法：YqhButton({ text: '绑定车辆', primary: true, onBtnClick: () => {...} })
import { COLORS } from '../common/style/Style'

@Component
export struct YqhButton {
  @Prop text: string = ''
  @Prop primary: boolean = true // true 青→蓝渐变主按钮；false 白卡次按钮
  @Prop btnHeight: number = 48 // 原型通栏胶囊高 48
  @Prop radius: number = 24 // 胶囊圆角
  @Prop btnEnabled: boolean = true // 注意：不可命名为 enabled，与 CustomComponent 基类冲突
  onBtnClick: () => void = () => {}

  build() {
    Button(this.text)
      .width('100%')
      .height(this.btnHeight)
      .borderRadius(this.radius)
      .enabled(this.btnEnabled)
      .fontColor(this.primary ? '#FFFFFF' : COLORS.ink)
      .linearGradient(this.primary
        ? { direction: GradientDirection.Right, colors: [[COLORS.accent, 0.0], [COLORS.accentDeep, 1.0]] as [ResourceColor, number][] }
        : undefined)
      .backgroundColor(this.primary ? undefined : COLORS.card)
      .border(this.primary ? undefined : { width: 1, color: COLORS.line })
      .onClick(() => {
        this.onBtnClick()
      })
  }
}
