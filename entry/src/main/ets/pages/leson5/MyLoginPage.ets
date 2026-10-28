import { promptAction, router } from '@kit.ArkUI'

// 定义路由参数传递的数据类型
class UserInfo {
  _userName: string = ''
}

// 持久化：将 userName / realname / studentId 关联到磁盘，重启后自动回填
PersistentStorage.persistProp('userName', '')
PersistentStorage.persistProp('realname', '')
PersistentStorage.persistProp('studentId', '')

@Entry
@Component
struct MyLoginPage {
  title: string = '资源复用平台'
  subtitle: string = '精简博学，学以致用.厚积博发，智行天下'
  username: string = ''
  password: string = ''

  aboutToAppear(): void {
    console.log("生命周期函数aboutToAppear")
    // 1、接收注册页面通过路由参数返回的用户名
    if (router.getParams()) {
      console.log("注册页面传递过来的参数：", JSON.stringify(router.getParams()))
      this.username = (router.getParams() as UserInfo)._userName
    }
    // 2、回填：从 AppStorage 读取已持久化的用户名（重启后依然存在）
    const savedName = AppStorage.get('userName') as string
    if (savedName) {
      this.username = savedName
    }
  }

  build() {
    Column({ space: 20 }) {
      // 1、图文显示区域
      Column({ space: 10 }) {
        Image($r('app.media.neu')).width(100)
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Text(this.subtitle).fontSize(16)
      }
      .backgroundColor(Color.Pink)
      .width('100%')
      .height(200)
      // 2、输入框区域 高度120 宽度90%
      Column({ space: 10 }) {
        TextInput({ placeholder: '请输入用户名', text: this.username })
          .borderRadius(5).backgroundColor(Color.White)
          .onChange((v) => {
            this.username = v
            promptAction.openToast({
              message: "用户名：" + this.username,
              duration: 2000
            })
          })
        TextInput({ placeholder: '请输入密码' })
          .borderRadius(5).backgroundColor(Color.White)
          .type(InputType.Password)
          .onChange((v) => {
            this.password = v
            promptAction.openToast({
              message: "密码：" + this.password,
              duration: 2000
            })
          })
        Row() {
          Text("自动登录")
          Text("忘记密码")
        }.justifyContent(FlexAlign.SpaceBetween).width('100%')
      }.height(120)
      .width('90%')
      .backgroundColor(Color.Yellow)
      // 3、按钮区域 高度80 宽度80%
      Column() {
        Button('登录')
          .width('100%')
          .onClick(() => {
            if (this.username === '' || this.password === '') {
              promptAction.openToast({
                message: "用户名或密码不能为空",
                duration: 2000
              })
            } else {
              promptAction.openToast({
                message: "调用接口发送登录请求:" + this.username
              })
              // 个性化：将用户信息写入 AppStorage（姓名/学号），“我的”页面会读取
              AppStorage.setOrCreate('userName', this.username)
              AppStorage.setOrCreate('realname', '杨庆鸿')
              AppStorage.setOrCreate('studentId', '509')
              router.pushUrl({
                url: 'pages/leson5/IndexPage'
              })
            }
          })
        Text('注册')
          .width('100%')
          .textAlign(TextAlign.Center)
          .backgroundColor(Color.White)
          .fontColor('#36d')
          .onClick(() => {
            router.pushUrl({
              url: 'pages/leson5/MyRegisterPage'
            })
          })
      }.height(80).backgroundColor(Color.Orange).width('80%')
    }
    .width('100%')
    .height('100%').justifyContent(FlexAlign.SpaceAround)
    .backgroundColor("#3D3D3D")
  }
}
