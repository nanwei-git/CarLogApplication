// 反馈详情（M7，接口 4.9.3）：凹陷头像 + 昵称 + 时间 + 正文 + 官方回复（凹陷卡）
import { promptAction } from '@kit.ArkUI'
import { neu, neuBg } from '../common/style/Style'
import { YqhNeuCard } from '../common/ui/yqhNeuCard'
import { getFeedbackDetail } from '../viewmodel/feedback'
import { Feedback } from '../model/FeedBackBean'
import { TOAST_MS } from '../common/constants/Constants'

@Component
export struct YqhFeedbackDetail {
  @Consume('navPathStack') navPathStack: NavPathStack
  @StorageProp('darkMode') dark: boolean = true
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
            .width(32)
            .height(32)
            .color(neu(this.dark).accent)
        } else {
          YqhNeuCard({ pad: 20 }) {
            Column({ space: 16 }) {
              // 头像 + 昵称 + 时间
              Row({ space: 12 }) {
                Column() {
                  Text(this.avatarText())
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(neu(this.dark).accent)
                }
                .width(48)
                .height(48)
                .borderRadius(24)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(neu(this.dark).surfaceSunken)
                .border({ width: 1, color: neu(this.dark).line })
                Column({ space: 2 }) {
                  Text(this.item.nickName === '' ? '匿名车友' : this.item.nickName)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(neu(this.dark).ink)
                  Text(this.item.createTime)
                    .fontSize(12)
                    .fontColor(neu(this.dark).inkSub)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
              }
              .width('100%')

              Text(this.item.content === '' ? '暂无内容' : this.item.content)
                .fontSize(15)
                .fontColor(neu(this.dark).ink)
                .width('100%')

              // 官方回复（凹陷内嵌区）
              YqhNeuCard({ pad: 14, sunken: true, radius: 16 }) {
                Column({ space: 6 }) {
                  Text('官方回复')
                    .fontSize(13)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(neu(this.dark).accent)
                    .width('100%')
                  Text(this.item.reply === '' ? '暂无回复，请耐心等待' : this.item.reply)
                    .fontSize(14)
                    .fontColor(neu(this.dark).ink)
                    .width('100%')
                }
              }
            }
          }
        }
      }
      .width('100%')
      .height('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .linearGradient(neuBg(this.dark))
  }
}
