// 注册页（M2）：两次密码一致校验、必填校验、调用 getRegister（账号已存在由服务器 msg 提示）
import { router, promptAction } from '@kit.ArkUI'
import { COLORS, BG_GRADIENT } from '../common/style/Style'
import { YqhGlassCard } from '../views/yqhGlassCard'
import { YqhButton } from '../views/yqhButton'
import { getRegister } from '../viewmodel/auth'
import { IResult } from '../model/IResult'
import { RegisterReq } from '../model/ApiReq'

@Entry
@Component
struct YqhRegister {
  @State username: string = ''
  @State password: string = ''
  @State confirm: string = ''
  @State agree: boolean = false

  @Styles
  inputStyle() {
    .width('100%')
    .height(48)
    .borderRadius(24)
    .border({ width: 1, color: COLORS.line })
    .backgroundColor(COLORS.card)
    .padding({ left: 16, right: 16 })
  }

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

  build() {
    Stack() {
      Column() {
        // 顶部标题（左对齐）
        Column({ space: 6 }) {
          Text('注册账号')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.ink)
          Text('创建您的车主账号')
            .fontSize(15)
            .fontColor(COLORS.inkSub)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ top: 48, bottom: 28 })

        YqhGlassCard({ pad: 20 }) {
          Column({ space: 14 }) {
            TextInput({ placeholder: '请输入用户名', text: this.username })
              .inputStyle()
              .onChange((v: string) => {
                this.username = v
              })
            TextInput({ placeholder: '请输入密码', text: this.password })
              .inputStyle()
              .type(InputType.Password)
              .onChange((v: string) => {
                this.password = v
              })
            TextInput({ placeholder: '请再次输入密码', text: this.confirm })
              .inputStyle()
              .type(InputType.Password)
              .onChange((v: string) => {
                this.confirm = v
              })

            YqhButton({ text: '注册', onBtnClick: () => this.doRegister() })

            Row() {
              Text('已有账号？')
                .fontColor(COLORS.inkSub)
                .fontSize(14)
              Text('登录')
                .fontColor(COLORS.accent)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .onClick(() => {
                  router.replaceUrl({ url: 'pages/yqhLogin' })
                })
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')

            Row({ space: 6 }) {
              Checkbox()
                .select(this.agree)
                .width(16)
                .height(16)
                .onChange((v: boolean) => {
                  this.agree = v
                })
              Text('我已阅读并同意《用户协议》《隐私政策》')
                .fontSize(12)
                .fontColor(COLORS.inkSub)
            }
            .width('100%')
            .margin({ top: 4 })
          }
        }
      }
      .width('100%')
      .height('100%')
      .padding(24)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .linearGradient(BG_GRADIENT)
  }
}
