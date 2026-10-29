// 欢迎页（M1）：纯黑底 + bg_start 发光车 + 一行标语；3s 后按登录态分流。
import { router } from '@kit.ArkUI'
import { getIsLogin } from '../common/utils/StorageUtils'

@Entry
@Component
struct YqhWelcome {
  private timer: number = -1

  aboutToAppear(): void {
    // 3s 后按登录态分流（与实验指导书"欢迎页自动跳转"流程一致）
    this.timer = setTimeout(() => {
      if (getIsLogin()) {
        router.replaceUrl({ url: 'pages/yqhIndex' })
      } else {
        router.replaceUrl({ url: 'pages/yqhLogin' })
      }
    }, 3000)
  }

  aboutToDisappear(): void {
    if (this.timer !== -1) {
      clearTimeout(this.timer)
      this.timer = -1
    }
  }

  build() {
    Stack() {
      // 发光车底图（纯黑背景承托）
      Image($r('app.media.bg_start'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
      // 底部标语
      Column() {
        Text('轻松驾驭·快乐出行')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .shadow({ radius: 6, color: '#000000', offsetX: 0, offsetY: 1 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .padding({ bottom: 90 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }
}
