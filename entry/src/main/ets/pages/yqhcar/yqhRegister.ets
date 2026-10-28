// 注册页（M2）：两次密码一致校验、必填校验、调用 getRegister（账号已存在由服务器 msg 提示）
import { router, promptAction } from '@kit.ArkUI'
import { COLORS, BG_GRADIENT } from '../../common/style/Style'
import { YqhGlassCard } from '../../common/ui/yqhGlassCard'
import { getRegister } from '../../common/api/auth'
import { IResult } from '../../common/model/IResult'
import { RegisterReq } from '../../common/model/ApiReq'

@Entry
@Component
struct YqhRegister {
  @State username: string = ''
  @State password: string = ''
  @State confirm: string = ''

  private doRegister(): void {
    if (this.username === '' || this.password === '' || this.confirm === '') {
      promptAction.showToast({ message: '请完整填写注册信息', duration: 2000 })
      return
    }
    if (this.password !== this.confirm) {
      promptAction.showToast({ message: '两次密码不一致', duration: 2000 })
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
          router.replaceUrl({ url: 'pages/yqhcar/yqhLogin', params: { username: this.username } })
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
        YqhGlassCard({ pad: 24 }) {
          Column({ space: 16 }) {
            Text('注册')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.ink)
            TextInput({ placeholder: '请输入用户名', text: this.username })
              .width('100%')
              .height(44)
              .backgroundColor(COLORS.card)
              .borderRadius(10)
              .onChange((v: string) => {
                this.username = v
              })
            TextInput({ placeholder: '请输入密码', text: this.password })
              .width('100%')
              .height(44)
              .backgroundColor(COLORS.card)
              .borderRadius(10)
              .type(InputType.Password)
              .onChange((v: string) => {
                this.password = v
              })
            TextInput({ placeholder: '请再次输入密码', text: this.confirm })
              .width('100%')
              .height(44)
              .backgroundColor(COLORS.card)
              .borderRadius(10)
              .type(InputType.Password)
              .onChange((v: string) => {
                this.confirm = v
              })
            Button('注册')
              .width('100%')
              .height(44)
              .borderRadius(22)
              .backgroundColor(COLORS.accent)
              .fontColor('#FFFFFF')
              .onClick(() => this.doRegister())
            Button('返回登录')
              .width('100%')
              .height(44)
              .borderRadius(22)
              .backgroundColor(COLORS.card)
              .fontColor(COLORS.ink)
              .onClick(() => {
                router.back()
              })
          }
        }
        .width('100%')
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
