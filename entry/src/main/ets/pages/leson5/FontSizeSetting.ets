import { router } from '@kit.ArkUI'

// 字体设置页（菜单“字体设置”跳转的占位页）
@Entry
@Component
struct FontSizeSetting {
  @State fontSize: number = 16

  build() {
    Column({ space: 20 }) {
      Text('字体设置')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40 })
      Text('预览文字 Preview Text')
        .fontSize(this.fontSize)
      Slider({ value: this.fontSize, min: 12, max: 32, step: 1 })
        .width('80%')
        .onChange((val: number) => {
          this.fontSize = val
        })
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
