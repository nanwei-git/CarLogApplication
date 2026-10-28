// 登录页（M2）：账号密码 → getLogin 存 token → getUserInfo 判 carVin → 绑车或首页；401 处理
import { router, promptAction } from '@kit.ArkUI'
import { COLORS, BG_GRADIENT } from '../../common/style/Style'
import { YqhGlassCard } from '../../common/ui/yqhGlassCard'
import { getLogin, getUserInfo } from '../../common/api/auth'
import {
  setIsLogin,
  setToken,
  setUserName,
  setUserId,
  setCarVin,
  setCarId,
  setAvatar
} from '../../common/utils/StorageUtils'
import { IResult } from '../../common/model/IResult'
import { UserInfoBean } from '../../common/model/UserInfoBean'

@Entry
@Component
struct YqhLogin {
  @State username: string = ''
  @State password: string = ''

  aboutToAppear(): void {
    // 注册页返回时回填用户名
    const p = router.getParams()
    if (p && (p as Record<string, string>)['username']) {
      this.username = (p as Record<string, string>)['username']
    }
  }

  private doLogin(): void {
    if (this.username === '' || this.password === '') {
      promptAction.showToast({ message: '用户名或密码不能为空', duration: 2000 })
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
              if (info.carVin === '' || info.carVin === null) {
                router.replaceUrl({ url: 'pages/yqhcar/yqhBindCar' })
              } else {
                router.replaceUrl({ url: 'pages/yqhcar/yqhIndex' })
              }
            })
            .catch(() => {
              // 取用户信息失败：稳妥起见进首页
              router.replaceUrl({ url: 'pages/yqhcar/yqhIndex' })
            })
        } else if (res.code === 401) {
          promptAction.showToast({ message: '用户名或密码错误', duration: 2000 })
        } else {
          promptAction.showToast({ message: res.msg || '登录失败', duration: 2000 })
        }
      })
      .catch((err: Error) => {
        promptAction.showToast({ message: '网络异常，请稍后重试', duration: 2000 })
        console.error('login error: ' + JSON.stringify(err))
      })
  }

  build() {
    Stack() {
      Column() {
        YqhGlassCard({ pad: 24 }) {
          Column({ space: 16 }) {
            Text('登录')
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
            Button('登录')
              .width('100%')
              .height(44)
              .borderRadius(22)
              .backgroundColor(COLORS.accent)
              .fontColor('#FFFFFF')
              .onClick(() => this.doLogin())
            Button('注册账号')
              .width('100%')
              .height(44)
              .borderRadius(22)
              .backgroundColor(COLORS.card)
              .fontColor(COLORS.ink)
              .onClick(() => {
                router.pushUrl({ url: 'pages/yqhcar/yqhRegister' })
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
