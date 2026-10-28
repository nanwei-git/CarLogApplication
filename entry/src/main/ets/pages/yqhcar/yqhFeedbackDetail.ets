// 反馈详情（M7，接口 4.9.3）：反馈内容 + 官方回复
import { promptAction } from '@kit.ArkUI'
import { COLORS, BG_GRADIENT } from '../../common/style/Style'
import { YqhGlassCard } from '../../common/ui/yqhGlassCard'
import { getFeedbackDetail } from '../../common/api/feedback'
import { Feedback } from '../../common/model/FeedBackBean'
import { TOAST_MS, FEEDBACK_UNREAD } from '../../common/constants/Constants'

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
            Column({ space: 12 }) {
              Row() {
                Text(this.item.status === FEEDBACK_UNREAD ? '未读' : '已读')
                  .fontSize(12)
                  .fontColor(COLORS.inkSub)
                Text(this.item.createTime)
                  .fontSize(12)
                  .fontColor(COLORS.inkSub)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              Text(this.item.content === '' ? '暂无内容' : this.item.content)
                .fontSize(15)
                .fontColor(COLORS.ink)
                .width('100%')
              Text('提交人：' + (this.item.nickName === '' ? '--' : this.item.nickName))
                .fontSize(12)
                .fontColor(COLORS.inkSub)
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
              .backgroundColor('rgba(255,255,255,0.55)')
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
