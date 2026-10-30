// 新增反馈（M7，接口 4.9.2）：≤100 字校验，提交成功后置脏标记并回列表
// 原型对齐：标题「反馈建议」+ 白卡 TextArea（占位 请输入您的反馈建议（100字以内））+ 底部胶囊「提交」+ toast「意见反馈成功」
import { promptAction } from '@kit.ArkUI'
import { COLORS, BG_GRADIENT } from '../common/style/Style'
import { YqhGlassCard } from '../views/yqhGlassCard'
import { YqhButton } from '../views/yqhButton'
import { addFeedback } from '../viewmodel/feedback'
import { IResult } from '../model/IResult'
import { FEEDBACK_MAX, TOAST_MS } from '../common/constants/Constants'

@Component
export struct YqhFeedbackAdd {
  @Consume('navPathStack') navPathStack: NavPathStack
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
          .fontColor(COLORS.ink)
          .width('100%')
          .padding({ left: 16, bottom: 12 })
        Scroll() {
          Column({ space: 16 }) {
            YqhGlassCard({ pad: 16 }) {
              Column({ space: 10 }) {
                TextArea({ placeholder: '请输入您的反馈建议（100字以内）', text: this.content })
                  .width('100%')
                  .height(160)
                  .backgroundColor('#F5F6F8')
                  .borderRadius(12)
                  .maxLength(FEEDBACK_MAX)
                  .onChange((v: string) => {
                    this.content = v
                  })
                Row() {
                  Blank()
                  Text(this.content.length + '/' + FEEDBACK_MAX)
                    .fontSize(12)
                    .fontColor(this.content.length > FEEDBACK_MAX ? COLORS.danger : COLORS.inkSub)
                }
                .width('100%')
              }
            }
            YqhButton({
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
    .linearGradient(BG_GRADIENT)
  }
}
