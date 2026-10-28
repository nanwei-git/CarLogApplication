// 玻璃拟态卡片容器：半透白渐变 + 1px 白边 + 大圆角 + 柔和外阴影
import { COLORS, GLASS_GRADIENT } from './Style';

@Component
export struct GlassCard {
  @Prop radius: number = 18;
  @Prop cardPadding: number = 20;
  @BuilderParam content: () => void;

  build() {
    Column() {
      this.content()
    }
    .width('100%')
    .padding(this.cardPadding)
    .borderRadius(this.radius)
    .border({ width: 1, color: COLORS.line })
    .linearGradient(GLASS_GRADIENT)
    .shadow({ radius: 26, color: 'rgba(0,0,0,0.55)', offsetX: 0, offsetY: 12 })
  }
}
