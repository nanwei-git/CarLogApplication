// 注册页（M2，Dark Neumorphism）：凹陷输入框 + 拟态卡片 + 主色发光按钮
// 逻辑不变：两次密码一致校验、必填校验、调用 getRegister（账号已存在由服务器 msg 提示）
import { router, promptAction } from '@kit.ArkUI'
import { neu, neuBg } from '../common/style/Style'
import { YqhNeuCard } from '../common/ui/yqhNeuCard'
import { YqhNeuRing } from '../common/ui/yqhNeuRing'
import { YqhNeuButton } from '../common/ui/yqhNeuButton'
import { getRegister } from '../viewmodel/auth'
import { IResult } from '../model/IResult'
import { RegisterReq } from '../model/ApiReq'

@Entry
@Component
struct YqhRegister {
  @StorageProp('darkMode') dark: boolean = true
  @State username: string = ''
  @State password: string = ''
  @State confirm: string = ''
  @State agree: boolean = false

  private doRegister(): void {
    if (this.username === '' || this.password === '' || this.confirm === '') {
      promptAction.showToast({ message: '请完整填写注册信息', duration: 2000 })
      return
    }
    if (this.password !== this.confirm) {
      promptAction.showToast({ message: '两次密码不一致', duration: 2000 })
      return
    }
    if (!this.agree) {
      promptAction.showToast({ message: '请先阅读并同意用户协议', duration: 2000 })
      return
    }
    const req: RegisterReq = {
      nickName: this.username,
      userName: this.username,
      phonenumber: '',
      sex: '0',
      avatar: '',
      password: this.password,
      roleIds: ['2'],
      birthDate: '',
      state: '0'
    }
    getRegister(req)
      .then((res: IResult) => {
        if (res.code === 200 || res.code === 0) {
          promptAction.showToast({ message: '注册成功', duration: 2000 })
          router.replaceUrl({ url: 'pages/yqhLogin', params: { username: this.username } })
        } else {
          // 账号已存在 / 其他错误：直接提示服务器返回信息
          promptAction.showToast({ message: res.msg || '注册失败', duration: 2000 })
        }
      })
      .catch((err: Error) => {
        promptAction.showToast({ message: '网络异常，请稍后重试', duration: 2000 })
        console.error('register error: ' + JSON.stringify(err))
      })
  }

  // 凹陷式输入框（新拟态：内嵌感）
  @Builder
  inputRow(placeholder: string, value: string, isPassword: boolean, onChange: (v: string) => void) {
    TextInput({ placeholder: placeholder, text: value })
      .width('100%')
      .height(50)
      .borderRadius(25)
      .padding({ left: 18, right: 18 })
      .backgroundColor(neu(this.dark).surfaceSunken)
      .fontColor(neu(this.dark).ink)
      .placeholderColor(neu(this.dark).inkSub)
      .caretColor(neu(this.dark).accent)
      .fontSize(15)
      .border({ width: 1, color: neu(this.dark).line })
      .type(isPassword ? InputType.Password : InputType.Normal)
      .onChange(onChange)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 18 }) {
          Column() {
            YqhNeuRing({ value: 100, diameter: 92, stroke: 6 }) {
              Text('🚗')
                .fontSize(36)
            }
          }
          .margin({ top: 40 })

          Column({ space: 6 }) {
            Text('注册账号')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(neu(this.dark).ink)
            Text('创建您的车主账号')
              .fontSize(14)
              .fontColor(neu(this.dark).inkSub)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          YqhNeuCard({ pad: 20 }) {
            Column({ space: 14 }) {
              this.inputRow('请输入用户名', this.username, false, (v: string) => {
                this.username = v
              })
              this.inputRow('请输入密码', this.password, true, (v: string) => {
                this.password = v
              })
              this.inputRow('请再次输入密码', this.confirm, true, (v: string) => {
                this.confirm = v
              })

              YqhNeuButton({ text: '注册', onBtnClick: () => this.doRegister() })

              Row() {
                Text('已有账号？')
                  .fontColor(neu(this.dark).inkSub)
                  .fontSize(14)
                Text('登录')
                  .fontColor(neu(this.dark).accent)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .onClick(() => {
                    router.replaceUrl({ url: 'pages/yqhLogin' })
                  })
              }
              .justifyContent(FlexAlign.Center)
              .width('100%')

              Row({ space: 8 }) {
                Checkbox()
                  .select(this.agree)
                  .selectedColor(neu(this.dark).accent)
                  .width(18)
                  .height(18)
                  .onChange((v: boolean) => {
                    this.agree = v
                  })
                Text('我已阅读并同意《用户协议》《隐私政策》')
                  .fontSize(12)
                  .fontColor(neu(this.dark).inkSub)
              }
              .width('100%')
              .margin({ top: 4 })
            }
          }
        }
        .width('100%')
        .padding({ left: 24, right: 24, bottom: 40 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .linearGradient(neuBg(this.dark))
  }
}
