import { router } from '@kit.ArkUI'

// 关于我们页：显示开发者姓名与学号
@Entry
@Component
struct MyAboutPage {
  build() {
    Column({ space: 20 }) {
      Text('关于我们')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })
      Text('开发者：杨庆鸿')
        .fontSize(18)
      Text('学号：509')
        .fontSize(18)
      Text('HarmonyOS 课程作业 · leson5')
        .fontSize(14)
        .fontColor('#999999')
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
