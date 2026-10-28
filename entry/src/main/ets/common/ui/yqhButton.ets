// 通用 UI 组件（封存复用）：主/次按钮，薄荷主色，零业务数据
// 用法：YqhButton({ text: '绑定车辆', primary: true, onBtnClick: () => {...} })
import { COLORS } from '../style/Style'

@Component
export struct YqhButton {
  @Prop text: string = ''
  @Prop primary: boolean = true // true 薄荷主色；false 半透明次色
  @Prop btnHeight: number = 44 // 触控目标 ≥44vp（无障碍）
  @Prop radius: number = 22
  @Prop btnEnabled: boolean = true // 注意：不可命名为 enabled，与 CustomComponent 基类冲突
  onBtnClick: () => void = () => {}

  build() {
    Button(this.text)
      .width('100%')
      .height(this.btnHeight)
      .borderRadius(this.radius)
      .enabled(this.btnEnabled)
      .backgroundColor(this.primary ? COLORS.accent : COLORS.card)
      .fontColor(this.primary ? '#FFFFFF' : COLORS.ink)
      .border({ width: 1, color: COLORS.line })
      .onClick(() => {
        this.onBtnClick()
      })
  }
}
