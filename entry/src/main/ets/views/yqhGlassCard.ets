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
    .borderRadius(16)
    .shadow({ radius: 10, color: 'rgba(31,35,41,0.08)', offsetX: 0, offsetY: 3 })
    .padding(this.pad)
  }
}
