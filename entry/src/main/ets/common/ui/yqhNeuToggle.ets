// 通用 UI 组件（Dark Neumorphism）：凹陷行 + 原生开关
// 用法：YqhNeuToggle({ label: '空调', checked: true, onToggleChange: (v) => {...} })
import { neu } from '../style/Style'
import { NEU_BLUR_SM, NEU_DISTANCE_SM, NEU_RADIUS_SM } from '../constants/Constants'

@Preview
@Component
export struct YqhNeuToggle {
  @StorageProp('darkMode') dark: boolean = true
  @Prop label: string = ''
  @Prop sub: string = '' // 副标题（状态说明），可空
  @Prop icon: string = '' // 前置图标字符（系统符号 / emoji）
  @Prop checked: boolean = false
  onToggleChange: (v: boolean) => void = (v: boolean) => {}

  build() {
    Row() {
      if (this.icon !== '') {
        Text(this.icon)
          .fontSize(20)
          .fontColor(neu(this.dark).ink)
          .margin({ right: 10 })
      }
      Column({ space: 2 }) {
        Text(this.label)
          .fontSize(14)
          .fontColor(neu(this.dark).ink)
        if (this.sub !== '') {
          Text(this.sub)
            .fontSize(11)
            .fontColor(neu(this.dark).inkSub)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: this.checked })
        .selectedColor(neu(this.dark).accent)
        .onChange((v: boolean) => {
          this.onToggleChange(v)
        })
    }
    .width('100%')
    .height(56) // 触控目标 ≥44vp
    .padding({ left: 16, right: 16 })
    .borderRadius(NEU_RADIUS_SM)
    .backgroundColor(neu(this.dark).surfaceSunken)
    .border({ width: 1, color: neu(this.dark).line })
    .shadow({
      radius: NEU_BLUR_SM,
      color: neu(this.dark).shadowDark,
      offsetX: NEU_DISTANCE_SM,
      offsetY: NEU_DISTANCE_SM
    })
  }
}
