// 通用 UI 组件（封存复用）：半透明玻璃卡
// 用法：yqhGlassCard({ pad: 16 }) { Column(){ ... } }
import { COLORS } from '../common/style/Style'

@Component
export struct YqhGlassCard {
  @Prop pad: number = 16
  @Builder defaultContent() {}
  @BuilderParam content: () => void = this.defaultContent

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
