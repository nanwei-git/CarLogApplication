// 新增反馈（M7，接口 4.9.2）：≤100 字校验，提交成功后置脏标记并回列表
import { promptAction } from '@kit.ArkUI'
import { COLORS, BG_GRADIENT } from '../../common/style/Style'
import { YqhGlassCard } from '../../common/ui/yqhGlassCard'
import { YqhButton } from '../../common/ui/yqhButton'
import { addFeedback } from '../../common/api/feedback'
import { IResult } from '../../common/model/IResult'
import { FEEDBACK_MAX, TOAST_MS } from '../../common/constants/Constants'

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
          this.toast('提交成功')
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
        YqhGlassCard({ pad: 20 }) {
          Column({ space: 12 }) {
            Text('新增反馈')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.ink)
            TextArea({ placeholder: '请输入您的意见或问题（不超过 100 字）', text: this.content })
              .width('100%')
              .height(140)
              .backgroundColor('rgba(255,255,255,0.75)')
              .borderRadius(10)
              .maxLength(FEEDBACK_MAX)
              .onChange((v: string) => {
                this.content = v
              })
            Row() {
              Text('')
              Text(this.content.length + '/' + FEEDBACK_MAX)
                .fontSize(12)
                .fontColor(this.content.length > FEEDBACK_MAX ? COLORS.danger : COLORS.inkSub)
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
            YqhButton({
              text: this.submitting ? '提交中…' : '提交反馈',
              primary: true,
              btnEnabled: !this.submitting,
              onBtnClick: () => {
                this.submit()
              }
            })
            YqhButton({
              text: '取消',
              primary: false,
              onBtnClick: () => {
                this.navPathStack.pop()
              }
            })
          }
        }
      }
      .width('100%')
      .height('100%')
      .padding(24)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .linearGradient(BG_GRADIENT)
  }
}
