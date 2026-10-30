// 反馈详情（M7，接口 4.9.3）：头像 + 昵称 + 时间 + 正文 + 官方回复
// 原型对齐：标题「反馈详情」；顶部头像 + 昵称 + 时间；下方正文
import { promptAction } from '@kit.ArkUI'
import { COLORS, BG_GRADIENT } from '../common/style/Style'
import { YqhGlassCard } from '../views/yqhGlassCard'
import { getFeedbackDetail } from '../viewmodel/feedback'
import { Feedback } from '../model/FeedBackBean'
import { TOAST_MS } from '../common/constants/Constants'

@Component
export struct YqhFeedbackDetail {
  @Consume('navPathStack') navPathStack: NavPathStack
  @Prop feedbackId: string = '' // 不可命名为 id，与 CustomComponent 基类冲突
  @State item: Feedback = new Feedback()
  @State loading: boolean = true

  aboutToAppear(): void {
    getFeedbackDetail(this.feedbackId)
      .then((item: Feedback) => {
        this.item = item
        this.loading = false
      })
      .catch(() => {
        this.loading = false
        promptAction.showToast({ message: '反馈详情获取失败，请稍后重试', duration: TOAST_MS })
      })
  }

  private avatarText(): string {
    if (this.item.nickName === '' || this.item.nickName === undefined) {
      return '友'
    }
    return this.item.nickName.substring(0, 1)
  }

  build() {
    Stack() {
      Column() {
        if (this.loading) {
          LoadingProgress()
            .width(28)
            .height(28)
            .color(COLORS.accent)
        } else {
          YqhGlassCard({ pad: 20 }) {
            Column({ space: 16 }) {
              // 头像 + 昵称 + 时间
              Row({ space: 12 }) {
                Stack() {
                  Circle({ width: 48, height: 48 })
                    .fill(COLORS.card)
                    .stroke(COLORS.line)
                    .strokeWidth(1)
                  Text(this.avatarText())
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(COLORS.accentDeep)
                }
                Column({ space: 2 }) {
                  Text(this.item.nickName === '' ? '匿名车友' : this.item.nickName)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(COLORS.ink)
                  Text(this.item.createTime)
                    .fontSize(12)
                    .fontColor(COLORS.inkSub)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')

              Text(this.item.content === '' ? '暂无内容' : this.item.content)
                .fontSize(15)
                .fontColor(COLORS.ink)
                .width('100%')

              // 官方回复
              Column({ space: 6 }) {
                Text('官方回复')
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(COLORS.accentDeep)
                  .width('100%')
                Text(this.item.reply === '' ? '暂无回复，请耐心等待' : this.item.reply)
                  .fontSize(14)
                  .fontColor(COLORS.ink)
                  .width('100%')
              }
              .width('100%')
              .padding(12)
              .borderRadius(12)
              .backgroundColor('#F5F6F8')
            }
          }
        }
      }
      .width('100%')
      .height('100%')
      .padding(24)
    }
    .width('100%')
    .height('100%')
    .linearGradient(BG_GRADIENT)
  }
}
