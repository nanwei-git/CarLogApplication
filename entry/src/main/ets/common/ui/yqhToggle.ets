// 通用 UI 组件（封存复用）：带标题的开关行，薄荷主色
// 用法：YqhToggle({ label: '空调', checked: true, onToggleChange: (v) => {...} })
import { COLORS } from '../style/Style'

@Component
export struct YqhToggle {
  @Prop label: string = ''
  @Prop sub: string = '' // 副标题（状态说明），可空
  @Prop checked: boolean = false
  onToggleChange: (v: boolean) => void = (v: boolean) => {}

  build() {
    Row() {
      Column({ space: 2 }) {
        Text(this.label)
          .fontSize(14)
          .fontColor(COLORS.ink)
        if (this.sub !== '') {
          Text(this.sub)
            .fontSize(11)
            .fontColor(COLORS.inkSub)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: this.checked })
        .selectedColor(COLORS.accent)
        .onChange((v: boolean) => {
          this.onToggleChange(v)
        })
    }
    .width('100%')
    .height(44) // 触控目标 ≥44vp
    .padding({ left: 12, right: 12 })
    .borderRadius(12)
    .backgroundColor('rgba(255,255,255,0.55)')
  }
}
