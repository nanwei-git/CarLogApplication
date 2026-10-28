// 新增反馈页（进阶实验，玻璃拟态风格）
// 作用：收集用户输入，生成 Feedback 对象并通过回调写回列表页数据
import { Feedback, FeedbackStatus } from './Feedback';
import { COLORS, ACCENT_GRADIENT } from './Style';
import { GlassCard } from './GlassCard';

@Component
export struct AddFeedback {
  // 保存回调，由根页面注入，负责把新数据加入列表并关闭当前页
  onSave: (item: Feedback) => void = () => {};

  @State title: string = '';
  @State content: string = '';
  @State status: FeedbackStatus = FeedbackStatus.Pending;
  @State nextId: number = 5;

  private now(): string {
    const d = new Date();
    const p = (n: number) => (n < 10 ? `0${n}` : `${n}`);
    return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}`;
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        GlassCard({ radius: 20, cardPadding: 22 }) {
          Column({ space: 14 }) {
            Column()
              .width(38)
              .height(4)
              .borderRadius(4)
              .linearGradient({
                direction: GradientDirection.Right,
                colors: [[COLORS.cyanL, 0.0], [COLORS.purple, 0.5], [COLORS.pink, 1.0]] as [[string, number], [string, number], [string, number]]
              })
              .shadow({ radius: 10, color: COLORS.purple, offsetX: 0, offsetY: 0 })

            Text('提交新反馈')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.ink)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }

        GlassCard({ radius: 20, cardPadding: 20 }) {
          Column({ space: 18 }) {
            Column({ space: 8 }) {
              Text('标题')
                .fontSize(13)
                .fontColor(COLORS.ink3)
              TextInput({ placeholder: '请输入反馈标题', text: this.title })
                .height(46)
                .fontColor(COLORS.ink)
                .placeholderColor(COLORS.ink3)
                .backgroundColor('rgba(255,255,255,0.05)')
                .border({ width: 1, color: COLORS.line })
                .borderRadius(12)
                .onChange((v: string) => {
                  this.title = v;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)

            Column({ space: 8 }) {
              Text('详细描述')
                .fontSize(13)
                .fontColor(COLORS.ink3)
              TextArea({ placeholder: '请描述你遇到的问题...', text: this.content })
                .height(150)
                .fontColor(COLORS.ink)
                .placeholderColor(COLORS.ink3)
                .backgroundColor('rgba(255,255,255,0.05)')
                .border({ width: 1, color: COLORS.line })
                .borderRadius(12)
                .onChange((v: string) => {
                  this.content = v;
                })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }

        // 主按钮：青→粉紫激活态渐变
        Button('提交反馈')
          .width('100%')
          .height(50)
          .fontSize(16)
          .fontColor(COLORS.ink)
          .fontWeight(FontWeight.Medium)
          .linearGradient(ACCENT_GRADIENT)
          .borderRadius(14)
          .shadow({ radius: 22, color: 'rgba(124,231,255,0.35)', offsetX: 0, offsetY: 8 })
          .enabled(this.title.length > 0 && this.content.length > 0)
          .opacity(this.title.length > 0 && this.content.length > 0 ? 1 : 0.4)
          .onClick(() => {
            const summary = this.content.length > 24 ? this.content.substring(0, 24) + '...' : this.content;
            const item = new Feedback(this.nextId, this.title, this.now(), summary, this.content, this.status);
            this.onSave(item);
          })

        Text('（标题与描述均不为空时可提交）')
          .fontSize(11)
          .fontColor(COLORS.ink3)
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(COLORS.bg)
  }
}
