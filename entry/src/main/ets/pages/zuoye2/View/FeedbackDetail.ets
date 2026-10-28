// 反馈详情页（玻璃拟态风格）
// 作用：接收列表页经路由栈传递的 Feedback 对象，展示完整反馈内容
import { Feedback, FeedbackStatus } from './Feedback';
import { COLORS } from './Style';
import { GlassCard } from './GlassCard';

@Component
export struct FeedbackDetail {
  // 由路由参数注入的完整反馈数据
  @Prop item: Feedback = new Feedback(0, '', '', '', '', FeedbackStatus.Pending);

  // 状态呼吸发光动画
  @State glow: number = 1;
  private timer: number = 0;

  aboutToAppear() {
    this.timer = setInterval(() => {
      this.glow = this.glow === 1 ? 0.35 : 1;
    }, 2400);
  }

  aboutToDisappear() {
    clearInterval(this.timer);
  }

  private statusColor(status: FeedbackStatus): string {
    switch (status) {
      case FeedbackStatus.Pending:
        return COLORS.cyanL;
      case FeedbackStatus.Processing:
        return COLORS.blue;
      case FeedbackStatus.Resolved:
        return COLORS.success;
      default:
        return COLORS.ink3;
    }
  }

  @Builder
  infoRow(label: string, value: string) {
    Row({ space: 8 }) {
      Text(label)
        .fontSize(13)
        .fontColor(COLORS.ink3)
        .width(72)
      Text(value)
        .fontSize(15)
        .fontColor(COLORS.ink2)
        .layoutWeight(1)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        GlassCard({ radius: 20, cardPadding: 22 }) {
          Column({ space: 14 }) {
            // 渐变发光标题条 + 标题
            Column()
              .width(38)
              .height(4)
              .borderRadius(4)
              .linearGradient({
                direction: GradientDirection.Right,
                colors: [[COLORS.cyanL, 0.0], [COLORS.purple, 0.5], [COLORS.pink, 1.0]] as [[string, number], [string, number], [string, number]]
              })
              .shadow({ radius: 10, color: COLORS.purple, offsetX: 0, offsetY: 0 })

            Text(this.item.title)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.ink)

            Row({ space: 12 }) {
              // 呼吸发光状态点
              Circle({ width: 10, height: 10 })
                .fill(this.statusColor(this.item.status))
                .opacity(this.glow)
                .animation({ duration: 2400, curve: Curve.EaseInOut, iterations: -1, playMode: PlayMode.Alternate })
                .shadow({ radius: 10, color: this.statusColor(this.item.status), offsetX: 0, offsetY: 0 })

              Text(this.item.status)
                .fontSize(13)
                .fontColor(COLORS.ink2)

              Text(`编号 #${this.item.id}`)
                .fontSize(12)
                .fontColor(COLORS.ink3)
                .layoutWeight(1)
                .textAlign(TextAlign.End)
            }
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }

        GlassCard({ radius: 20, cardPadding: 22 }) {
          Column({ space: 16 }) {
            this.infoRow('提交时间', this.item.time)
            this.infoRow('摘要', this.item.summary)

            Column({ space: 6 }) {
              Text('详细描述')
                .fontSize(14)
                .fontColor(COLORS.ink3)
              Text(this.item.content)
                .fontSize(16)
                .fontColor(COLORS.ink)
                .lineHeight(24)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.bg)
  }
}
