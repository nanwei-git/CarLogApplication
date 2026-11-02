// 通用 UI 组件（Dark Neumorphism）：圆形图标按钮（Tesla 风快捷控制）
// 常态 = 拟态凸起；按下 = 凹陷 + 微缩；激活 = 主色实心 + 主色发光。
// 用法：YqhNeuCircleButton({ icon: '🔒', label: '锁车', diameter: 64, active: true, onBtnClick: () => {...} })
import { neu } from '../style/Style'
import { NEU_BLUR_GLOW, NEU_BLUR_SM, NEU_DISTANCE_SM } from '../constants/Constants'

@Preview
@Component
export struct YqhNeuCircleButton {
  @StorageProp('darkMode') dark: boolean = true
  @Prop icon: string = '' // 图标字符（系统符号 / emoji，零美术资产）
  @Prop imageSrc: ResourceStr = '' // 可选图片图标（不为空时优先于 icon）
  @Prop label: string = ''
  @Prop active: boolean = false
  @Prop diameter: number = 64
  @Prop activeColor: string = '' // 空则取主题主色
  @Prop glowColor: string = '' // 空则取主题柔光
  @State pressed: boolean = false
  onBtnClick: () => void = () => {}
  onBtnTouch: (e: TouchEvent) => void = (e: TouchEvent) => {}

  private fillColor(): string {
    if (this.active) {
      return this.activeColor === '' ? neu(this.dark).accent : this.activeColor
    }
    return this.pressed ? neu(this.dark).surfaceSunken : neu(this.dark).surface
  }

  private glow(): string {
    return this.glowColor === '' ? neu(this.dark).accentSoft : this.glowColor
  }

  private iconColor(): string {
    return this.active ? '#FFFFFF' : neu(this.dark).ink
  }

  build() {
    Column({ space: 8 }) {
      Column() {
        Column() {
          if (this.imageSrc !== '') {
            Image(this.imageSrc)
              .width(Math.round(this.diameter * 0.4))
              .height(Math.round(this.diameter * 0.4))
          } else {
            Text(this.icon)
              .fontSize(Math.round(this.diameter * 0.36))
              .fontColor(this.iconColor())
          }
        }
        .width(this.diameter)
        .height(this.diameter)
        .borderRadius(this.diameter / 2)
        .backgroundColor(this.fillColor())
        .justifyContent(FlexAlign.Center)
        // 内层：左上亮边
        .shadow({
          radius: NEU_BLUR_SM,
          color: neu(this.dark).shadowLight,
          offsetX: -NEU_DISTANCE_SM,
          offsetY: -NEU_DISTANCE_SM
        })
      }
      .width(this.diameter)
      .height(this.diameter)
      .borderRadius(this.diameter / 2)
      .backgroundColor(this.fillColor())
      .justifyContent(FlexAlign.Center)
      .border({ width: 1, color: neu(this.dark).line })
      // 外层：常态右下暗影，激活时改为主色发光
      .shadow(this.active
        ? { radius: NEU_BLUR_GLOW, color: this.glow(), offsetX: 0, offsetY: 0 }
        : {
            radius: NEU_BLUR_SM,
            color: neu(this.dark).shadowDark,
            offsetX: NEU_DISTANCE_SM,
            offsetY: NEU_DISTANCE_SM
          })
      .scale({ x: this.pressed ? 0.94 : 1, y: this.pressed ? 0.94 : 1 })
      .animation({ duration: 120, curve: Curve.EaseOut })
      .onTouch((e: TouchEvent) => {
        if (e.type === TouchType.Down) {
          this.pressed = true
        } else if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
          this.pressed = false
        }
        this.onBtnTouch(e)
      })
      .onClick(() => {
        this.onBtnClick()
      })
      if (this.label !== '') {
        Text(this.label)
          .fontSize(12)
          .fontColor(this.active ? neu(this.dark).ink : neu(this.dark).inkSub)
      }
    }
  }
}
