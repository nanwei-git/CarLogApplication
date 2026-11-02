// 通用 UI 组件（Dark Neumorphism）：环形表盘（电量环 / 温度旋钮共用）
// 外壳拟态凸起，轨道为凹陷色，中心内容由业务传入。
// 用法：YqhNeuRing({ value: 78, diameter: 176 }) { Text('78%') }
import { neu } from '../style/Style'
import { NEU_BLUR, NEU_BLUR_SM, NEU_DISTANCE } from '../constants/Constants'

@Preview
@Component
export struct YqhNeuRing {
  @StorageProp('darkMode') dark: boolean = true
  @Prop value: number = 0 // 0-100
  @Prop diameter: number = 176
  @Prop stroke: number = 14
  @Prop ringColor: string = '' // 空则取主题主色
  @Builder defaultCenter() {}
  @BuilderParam center: () => void = this.defaultCenter

  private arcColor(): string {
    return this.ringColor === '' ? neu(this.dark).accent : this.ringColor
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.Center }) {
        Progress({ value: this.value, total: 100, type: ProgressType.Ring })
          .width(this.diameter)
          .height(this.diameter)
          .style({ strokeWidth: this.stroke })
          .color(this.arcColor())
          .backgroundColor(neu(this.dark).surface)
        this.center()
      }
      .width(this.diameter)
      .height(this.diameter)
      .borderRadius(this.diameter / 2)
      .backgroundColor(neu(this.dark).surface)
      // 内层：左上亮边
      .shadow({
        radius: NEU_BLUR_SM,
        color: neu(this.dark).shadowLight,
        offsetX: -NEU_DISTANCE,
        offsetY: -NEU_DISTANCE
      })
    }
    .width(this.diameter)
    .height(this.diameter)
    .borderRadius(this.diameter / 2)
    .backgroundColor(neu(this.dark).surface)
    .border({ width: 1, color: neu(this.dark).line })
    // 外层：右下暗影
    .shadow({
      radius: NEU_BLUR,
      color: neu(this.dark).shadowDark,
      offsetX: NEU_DISTANCE,
      offsetY: NEU_DISTANCE
    })
  }
}
