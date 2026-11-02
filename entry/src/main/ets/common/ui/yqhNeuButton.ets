// 通用 UI 组件（Dark Neumorphism）：主 / 次按钮，零业务数据
// 主按钮 = 特斯拉红渐变 + 主色柔光；次按钮 = 拟态凸起胶囊。
// 用法：YqhNeuButton({ text: '绑定车辆', primary: true, onBtnClick: () => {...} })
import { neu } from '../style/Style'
import { NEU_BLUR, NEU_BLUR_GLOW, NEU_DISTANCE_SM } from '../constants/Constants'

@Preview
@Component
export struct YqhNeuButton {
  @StorageProp('darkMode') dark: boolean = true
  @Prop text: string = ''
  @Prop primary: boolean = true
  @Prop btnHeight: number = 48
  @Prop radius: number = 24
  @Prop btnEnabled: boolean = true // 不可命名为 enabled，与 CustomComponent 基类冲突
  @State pressed: boolean = false
  onBtnClick: () => void = () => {}

  build() {
    Button(this.text)
      .width('100%')
      .height(this.btnHeight)
      .borderRadius(this.radius)
      .enabled(this.btnEnabled)
      .fontSize(16)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.primary ? '#FFFFFF' : neu(this.dark).ink)
      .linearGradient(this.primary
        ? {
            direction: GradientDirection.Right,
            colors: [
              [neu(this.dark).accent, 0.0],
              [neu(this.dark).accentDeep, 1.0]
            ] as [ResourceColor, number][]
          }
        : undefined)
      .backgroundColor(this.primary ? Color.Transparent : neu(this.dark).surface)
      .shadow(this.primary
        ? { radius: NEU_BLUR_GLOW, color: neu(this.dark).accentSoft, offsetX: 0, offsetY: 2 }
        : {
            radius: NEU_BLUR,
            color: neu(this.dark).shadowDark,
            offsetX: NEU_DISTANCE_SM,
            offsetY: NEU_DISTANCE_SM
          })
      .border(this.primary ? undefined : { width: 1, color: neu(this.dark).line })
      // 按压微缩，克制动效
      .scale({ x: this.pressed ? 0.97 : 1, y: this.pressed ? 0.97 : 1 })
      .animation({ duration: 120, curve: Curve.EaseOut })
      .onTouch((e: TouchEvent) => {
        if (e.type === TouchType.Down) {
          this.pressed = true
        } else if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
          this.pressed = false
        }
      })
      .onClick(() => {
        this.onBtnClick()
      })
  }
}
