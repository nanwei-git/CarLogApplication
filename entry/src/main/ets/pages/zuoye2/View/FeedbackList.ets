// 反馈列表页（玻璃拟态风格）
// 作用：用 List + ForEach 渲染反馈条目玻璃卡片，点击通过 Navigation 路由参数跳转到详情页
import { Feedback, FeedbackStatus } from './Feedback';
import { COLORS } from './Style';
import { GlassCard } from './GlassCard';

@Component
export struct FeedbackList {
  // 与根页面共享的反馈数据（新增反馈后会同步刷新）
  @Link list: Feedback[];
  // 复用根页面提供的路由栈
  @Consume('navPathStack') navPathStack: NavPathStack;

  // 状态色彩映射
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
  FeedbackCard(item: Feedback) {
    GlassCard({ radius: 18, cardPadding: 18 }) {
      Row({ space: 14 }) {
        // 左侧冷色发光竖条
        Column()
          .width(4)
          .height(46)
          .borderRadius(4)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [[COLORS.cyanL, 0.0], [COLORS.purple, 1.0]] as [[string, number], [string, number]]
          })
          .shadow({ radius: 8, color: COLORS.purple, offsetX: 0, offsetY: 0 })

        Column({ space: 8 }) {
          Text(item.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.ink)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(item.summary)
            .fontSize(13)
            .fontColor(COLORS.ink2)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .lineHeight(18)

          Row({ space: 10 }) {
            // 胶囊状态徽章（带发光点）
            Row({ space: 6 }) {
              Circle({ width: 7, height: 7 })
                .fill(this.statusColor(item.status))
                .shadow({ radius: 6, color: this.statusColor(item.status), offsetX: 0, offsetY: 0 })
              Text(item.status)
                .fontSize(11)
                .fontColor(COLORS.ink2)
            }
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .borderRadius(999)
            .border({ width: 1, color: COLORS.line })

            Text(item.time)
              .fontSize(11)
              .fontColor(COLORS.ink3)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Text('›')
          .fontSize(22)
          .fontColor(COLORS.ink3)
      }
      .width('100%')
    }
  }

  build() {
    Column({ space: 16 }) {
      // 顶部标题栏 + 新增反馈入口
      Row({ space: 12 }) {
        // 渐变发光标题条
        Column()
          .width(4)
          .height(34)
          .borderRadius(4)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [[COLORS.cyanL, 0.0], [COLORS.pink, 1.0]] as [[string, number], [string, number]]
          })
          .shadow({ radius: 10, color: COLORS.pink, offsetX: 0, offsetY: 0 })

        Column({ space: 4 }) {
          Text('我的反馈')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.ink)
          Text(`共 ${this.list.length} 条记录`)
            .fontSize(12)
            .fontColor(COLORS.ink3)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Button('+ 新增')
          .fontSize(14)
          .fontColor(COLORS.ink)
          .height(38)
          .padding({ left: 16, right: 16 })
          .borderRadius(999)
          .border({ width: 1, color: COLORS.line })
          .backgroundColor('rgba(255,255,255,0.06)')
          .onClick(() => {
            this.navPathStack.pushPath({ name: 'AddFeedback' });
          })
      }
      .width('100%')

      if (this.list.length === 0) {
        Column() {
          Text('暂无反馈，点击右上角“新增”提交第一条')
            .fontSize(14)
            .fontColor(COLORS.ink3)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 14 }) {
          ForEach(
            this.list,
            (item: Feedback) => {
              ListItem() {
                this.FeedbackCard(item)
              }
              .onClick(() => {
                // 通过路由参数把整条数据对象传递给详情页
                this.navPathStack.pushPath({ name: 'FeedbackDetail', param: item });
              })
            },
            (item: Feedback) => item.id.toString()
          )
        }
        .width('100%')
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.None)
      }
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor(COLORS.bg)
  }
}
