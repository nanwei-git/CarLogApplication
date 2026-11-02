// 新增反馈（M7，接口 4.9.2）：≤100 字校验，提交成功后置脏标记并回列表
// 视觉：Dark Neumorphism —— 凹陷输入区 + 拟态卡片 + 主色发光按钮
import { promptAction } from '@kit.ArkUI'
import { neu, neuBg } from '../common/style/Style'
import { YqhNeuCard } from '../common/ui/yqhNeuCard'
import { YqhNeuButton } from '../common/ui/yqhNeuButton'
import { addFeedback } from '../viewmodel/feedback'
import { IResult } from '../model/IResult'
import { FEEDBACK_MAX, TOAST_MS } from '../common/constants/Constants'

@Component
export struct YqhFeedbackAdd {
  @Consume('navPathStack') navPathStack: NavPathStack
  @StorageProp('darkMode') dark: boolean = true
  @State content: string = ''
  @State submitting: boolean = false

  private toast(msg: string): void {
    promptAction.showToast({ message: msg, duration: TOAST_MS })
  }

  private submit(): void {
    const c: string = this.content.trim()
    if (c === '') {
      this.toast('请输入反馈内容')
      return
    }
    if (c.length > FEEDBACK_MAX) {
      this.toast('反馈内容不能超过 ' + FEEDBACK_MAX + ' 字')
      return
    }
    this.submitting = true
    addFeedback(c)
      .then((res: IResult) => {
        this.submitting = false
        if (res.code === 200 || res.code === 0) {
          this.toast('意见反馈成功')
          AppStorage.setOrCreate('feedbackDirty', true) // 通知列表刷新
          this.navPathStack.pop()
        } else {
          this.toast(res.msg || '提交失败')
        }
      })
      .catch(() => {
        this.submitting = false
        this.toast('网络异常，请稍后重试')
      })
  }

  build() {
    Stack() {
      Column() {
        Text('反馈建议')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(neu(this.dark).ink)
          .width('100%')
          .padding({ left: 16, bottom: 12 })
        Scroll() {
          Column({ space: 16 }) {
            YqhNeuCard({ pad: 16 }) {
              Column({ space: 10 }) {
                TextArea({ placeholder: '请输入您的反馈建议（100字以内）', text: this.content })
                  .width('100%')
                  .height(160)
                  .backgroundColor(neu(this.dark).surfaceSunken)
                  .fontColor(neu(this.dark).ink)
                  .placeholderColor(neu(this.dark).inkSub)
                  .caretColor(neu(this.dark).accent)
                  .fontSize(15)
                  .borderRadius(16)
                  .padding(12)
                  .maxLength(FEEDBACK_MAX)
                  .onChange((v: string) => {
                    this.content = v
                  })
                Row() {
                  Blank()
                  Text(this.content.length + '/' + FEEDBACK_MAX)
                    .fontSize(12)
                    .fontColor(this.content.length > FEEDBACK_MAX
                      ? neu(this.dark).danger
                      : neu(this.dark).inkSub)
                }
                .width('100%')
              }
            }
            YqhNeuButton({
              text: this.submitting ? '提交中…' : '提交',
              primary: true,
              btnEnabled: !this.submitting,
              onBtnClick: () => {
                this.submit()
              }
            })
          }
          .width('100%')
          .padding(16)
        }
        .width('100%')
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .linearGradient(neuBg(this.dark))
  }
}
