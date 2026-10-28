import { router } from '@kit.ArkUI'

@Component
export struct MineCom {
  // 从 AppStorage 读取登录页保存的用户信息
  // @StorageProp：只读单向同步，AppStorage 中变化时 UI 自动更新
  @StorageProp('userName') userName: string = '未登录'
  @StorageProp('realname') realname: string = ''
  @StorageProp('studentId') studentId: string = ''

  build() {
    Column() {
      // 1、头像和用户信息区域
      Column({ space: 10 }) {
        // 用户头像（圆形）
        Image($r('app.media.neu'))
          .width(80)
          .height(80)
          .borderRadius(40)
          .margin({ top: 30 })
        // 用户名
        Text(this.userName)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ top: 10 })
        // 姓名 | 学号
        Text('姓名：' + this.realname)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ top: 4 })
        Text('学号：' + this.studentId)
          .fontSize(14)
          .fontColor('#999999')
          .margin({ bottom: 20 })
      }
      .width('100%')
      .height(220)
      .backgroundColor('#F5F5F5')
      .alignItems(HorizontalAlign.Center)

      // 2、分割线
      Divider()
        .color('#E0E0E0')
        .strokeWidth(1)
        .width('100%')

      // 3、功能菜单列表
      Column({ space: 0 }) {
        // 菜单项：我的资料
        Row() {
          Text('我的资料').fontSize(16).fontColor('#333333')
          Blank() // 弹性空白，将箭头推到右侧
          Text('>').fontSize(16).fontColor('#CCCCCC')
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/leson5/MyProfilePage' })
        })
        Divider().color('#F0F0F0').strokeWidth(1)

        // 菜单项：字体设置
        Row() {
          Text('字体设置').fontSize(16).fontColor('#333333')
          Blank()
          Text('>').fontSize(16).fontColor('#CCCCCC')
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/leson5/FontSizeSetting' })
        })
        Divider().color('#F0F0F0').strokeWidth(1)

        // 菜单项：关于我们
        Row() {
          Text('关于我们').fontSize(16).fontColor('#333333')
          Blank()
          Text('>').fontSize(16).fontColor('#CCCCCC')
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })
        .onClick(() => {
          router.pushUrl({ url: 'pages/leson5/MyAboutPage' })
        })
        Divider().color('#F0F0F0').strokeWidth(1)

        // 菜单项：退出登录
        Row() {
          Text('退出登录').fontSize(16).fontColor('#FF0000')
        }
        .width('100%')
        .height(56)
        .padding({ left: 20, right: 20 })
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          // 清空 AppStorage 中的用户信息（同步清除持久化）
          AppStorage.setOrCreate('userName', '')
          AppStorage.setOrCreate('realname', '')
          AppStorage.setOrCreate('studentId', '')
          // 返回登录页面：使用 replaceUrl，避免返回“我的”页面
          router.replaceUrl({ url: 'pages/leson5/MyLoginPage' })
        })
      }
      .backgroundColor(Color.White)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
