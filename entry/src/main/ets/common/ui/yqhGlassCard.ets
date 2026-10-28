// 通用 UI 组件（封存复用）：半透明玻璃卡
// 用法：yqhGlassCard({ pad: 16 }) { Column(){ ... } }
import { COLORS } from '../style/Style'

@Component
export struct YqhGlassCard {
  @BuilderParam content: () => void = () => {}
  @Prop pad: number = 16

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .backgroundColor(COLORS.card)
    .borderRadius(18)
    .border({ width: 1, color: COLORS.line })
    .padding(this.pad)
  }
}
