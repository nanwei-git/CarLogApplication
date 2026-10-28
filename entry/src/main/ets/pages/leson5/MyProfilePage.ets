import { router } from '@kit.ArkUI'

// 我的资料页（菜单“我的资料”跳转的占位页）
@Entry
@Component
struct MyProfilePage {
  // 只读接收 AppStorage 中的用户信息
  @StorageProp('userName') userName: string = '未登录'

  build() {
    Column({ space: 20 }) {
      Text('我的资料')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })
      Text('当前用户：' + this.userName)
        .fontSize(16)
      Button('返回')
        .width('60%')
        .onClick(() => {
          router.back()
        })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
  }
}
