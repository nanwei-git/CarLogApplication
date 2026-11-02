// 通用 UI 组件（Dark Neumorphism）：拟态卡片，凸起 / 凹陷两态
// 原理：卡片与页面同色，外层右下暗影 + 内层左上亮边 = 体积感。
// 用法：YqhNeuCard({ pad: 20 }) { Column(){ ... } }
import { neu } from '../style/Style'
import { NEU_BLUR, NEU_DISTANCE, NEU_RADIUS } from '../constants/Constants'

@Preview
@Component
export struct YqhNeuCard {
  @StorageProp('darkMode') dark: boolean = true
  @Prop pad: number = 20
  @Prop radius: number = NEU_RADIUS
  @Prop sunken: boolean = false // true 凹陷（按下态 / 内嵌信息区）
  @Prop blurRadius: number = NEU_BLUR
  @Prop distance: number = NEU_DISTANCE
  @Builder defaultContent() {}
  @BuilderParam content: () => void = this.defaultContent

  // 面色：凹陷用更暗的surfaceSunken，凸起用基底色
  private faceColor(): string {
    return this.sunken ? neu(this.dark).surfaceSunken : neu(this.dark).surface
  }

  build() {
    Column() {
      Column() {
        this.content()
      }
      .width('100%')
      .padding(this.pad)
      .borderRadius(this.radius)
      .backgroundColor(this.faceColor())
      // 内层：左上亮边
      .shadow({
        radius: this.blurRadius,
        color: neu(this.dark).shadowLight,
        offsetX: -this.distance,
        offsetY: -this.distance
      })
    }
    .width('100%')
    .borderRadius(this.radius)
    .backgroundColor(this.faceColor())
    .border({ width: 1, color: neu(this.dark).line })
    // 外层：右下暗影
    .shadow({
      radius: this.blurRadius,
      color: neu(this.dark).shadowDark,
      offsetX: this.distance,
      offsetY: this.distance
    })
  }
}
