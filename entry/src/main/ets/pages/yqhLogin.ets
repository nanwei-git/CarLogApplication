// 登录页（M2）：账号密码 → getLogin 存 token → getUserInfo 判 carVin → 绑车或首页；401 内联红字
import { router, promptAction } from '@kit.ArkUI'
import { COLORS, BG_GRADIENT } from '../common/style/Style'
import { YqhGlassCard } from '../views/yqhGlassCard'
import { YqhButton } from '../views/yqhButton'
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

  @Styles
  inputStyle() {
    .width('100%')
    .height(48)
    .borderRadius(24)
    .border({ width: 1, color: COLORS.line })
    .backgroundColor(COLORS.card)
    .padding({ left: 16, right: 16 })
  }

  build() {
    Stack() {
      Column() {
        // 顶部标题（左对齐）
        Column({ space: 6 }) {
          Text('账号密码登录')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.ink)
          Text('欢迎使用 车主APP！')
            .fontSize(15)
            .fontColor(COLORS.inkSub)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ top: 48, bottom: 28 })

        YqhGlassCard({ pad: 20 }) {
          Column({ space: 14 }) {
            TextInput({ placeholder: '请输入账号', text: this.username })
              .inputStyle()
              .onChange((v: string) => {
                this.username = v
                this.showError = false
              })
            if (this.showError) {
              Text(this.errorMsg)
                .fontSize(12)
                .fontColor(COLORS.danger)
                .width('100%')
                .textAlign(TextAlign.Start)
            }
            TextInput({ placeholder: '请输入密码', text: this.password })
              .inputStyle()
              .type(InputType.Password)
              .onChange((v: string) => {
                this.password = v
                this.showError = false
              })
            Row() {
              Blank()
              Text('忘记密码?')
                .fontSize(13)
                .fontColor(COLORS.accent)
                .onClick(() => {
                  promptAction.showToast({ message: '请联系管理员重置密码', duration: 2000 })
                })
            }
            .width('100%')

            YqhButton({ text: '登录', onBtnClick: () => this.doLogin() })

            Row() {
              Text('还没有账号？')
                .fontColor(COLORS.inkSub)
                .fontSize(14)
              Text('注册')
                .fontColor(COLORS.accent)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .onClick(() => {
                  router.pushUrl({ url: 'pages/yqhRegister' })
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
