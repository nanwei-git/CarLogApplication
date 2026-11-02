// 登录页（M2，Dark Neumorphism）：凹陷输入框 + 拟态卡片 + 主色发光按钮
// 逻辑不变：账号密码 → getLogin 存 token → getUserInfo 判 carVin → 绑车或首页；401 内联红字
import { router, promptAction } from '@kit.ArkUI'
import { neu, neuBg } from '../common/style/Style'
import { YqhNeuCard } from '../common/ui/yqhNeuCard'
import { YqhNeuRing } from '../common/ui/yqhNeuRing'
import { YqhNeuButton } from '../common/ui/yqhNeuButton'
import { getLogin, getUserInfo } from '../viewmodel/auth'
import {
  setIsLogin,
  setToken,
  setUserName,
  setUserId,
  setCarVin,
  setCarId,
  setAvatar
} from '../common/utils/StorageUtils'
import { IResult } from '../model/IResult'
import { UserInfoBean } from '../model/UserInfoBean'

@Entry
@Component
struct YqhLogin {
  @StorageProp('darkMode') dark: boolean = true
  @State username: string = ''
  @State password: string = ''
  @State agree: boolean = false
  @State showError: boolean = false
  @State errorMsg: string = ''

  aboutToAppear(): void {
    // 注册页返回时回填用户名
    const p = router.getParams()
    if (p && (p as Record<string, string>)['username']) {
      this.username = (p as Record<string, string>)['username']
    }
  }

  private doLogin(): void {
    this.showError = false
    if (this.username === '' || this.password === '') {
      promptAction.showToast({ message: '用户名或密码不能为空', duration: 2000 })
      return
    }
    if (!this.agree) {
      promptAction.showToast({ message: '请先阅读并同意用户协议', duration: 2000 })
      return
    }
    getLogin(this.username, this.password)
      .then((res: IResult) => {
        if (res.code === 200 || res.code === 0) {
          // 存 token 与登录态
          setToken(res.token ?? '')
          setIsLogin(true)
          setUserName(this.username)
          // 取用户信息，按 carVin 分流（C3：单判 carVin）
          getUserInfo()
            .then((info: UserInfoBean) => {
              setUserId(info.user.userId)
              setUserName(info.user.userName || this.username)
              setCarVin(info.carVin)
              setCarId(info.carId)
              setAvatar(info.user.avatar)
              if (info.carVin === '') {
                router.replaceUrl({ url: 'pages/yqhBindCar' })
              } else {
                router.replaceUrl({ url: 'pages/yqhIndex' })
              }
            })
            .catch(() => {
              // 取用户信息失败：稳妥起见进首页
              router.replaceUrl({ url: 'pages/yqhIndex' })
            })
        } else if (res.code === 401) {
          this.showError = true
          this.errorMsg = '用户名或密码错误'
        } else {
          promptAction.showToast({ message: res.msg || '登录失败', duration: 2000 })
        }
      })
      .catch((err: Error) => {
        promptAction.showToast({ message: '网络异常，请稍后重试', duration: 2000 })
        console.error('login error: ' + JSON.stringify(err))
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
          // 品牌环（拟态）
          Column() {
            YqhNeuRing({ value: 100, diameter: 92, stroke: 6 }) {
              Text('🚗')
                .fontSize(36)
            }
          }
          .margin({ top: 40 })

          // 标题
          Column({ space: 6 }) {
            Text('账号密码登录')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(neu(this.dark).ink)
            Text('欢迎使用 车主APP！')
              .fontSize(14)
              .fontColor(neu(this.dark).inkSub)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')

          YqhNeuCard({ pad: 20 }) {
            Column({ space: 14 }) {
              this.inputRow('请输入账号', this.username, false, (v: string) => {
                this.username = v
                this.showError = false
              })
              if (this.showError) {
                Text(this.errorMsg)
                  .fontSize(12)
                  .fontColor(neu(this.dark).danger)
                  .width('100%')
                  .textAlign(TextAlign.Start)
              }
              this.inputRow('请输入密码', this.password, true, (v: string) => {
                this.password = v
                this.showError = false
              })
              Row() {
                Blank()
                Text('忘记密码?')
                  .fontSize(13)
                  .fontColor(neu(this.dark).accent)
                  .onClick(() => {
                    promptAction.showToast({ message: '请联系管理员重置密码', duration: 2000 })
                  })
              }
              .width('100%')

              YqhNeuButton({ text: '登录', onBtnClick: () => this.doLogin() })

              Row() {
                Text('还没有账号？')
                  .fontColor(neu(this.dark).inkSub)
                  .fontSize(14)
                Text('注册')
                  .fontColor(neu(this.dark).accent)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .onClick(() => {
                    router.pushUrl({ url: 'pages/yqhRegister' })
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
