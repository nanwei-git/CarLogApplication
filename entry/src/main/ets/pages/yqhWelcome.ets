// 欢迎页（M1，Dark Neumorphism）：暗底 + 拟态品牌环 + 标语；3s 后按登录态分流。
import { router } from '@kit.ArkUI'
import { neu, neuBg } from '../common/style/Style'
import { YqhNeuRing } from '../common/ui/yqhNeuRing'
import { getIsLogin } from '../common/utils/StorageUtils'

@Entry
@Component
struct YqhWelcome {
  @StorageProp('darkMode') dark: boolean = true
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
      // 车辆底图（暗底承托，降低透明度避免抢视觉）
      Image($r('app.media.bg_start'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .opacity(0.5)

      Column({ space: 28 }) {
        // 拟态品牌环
        YqhNeuRing({ value: 100, diameter: 168, stroke: 8 }) {
          Text('🚗')
            .fontSize(66)
        }
        Column({ space: 6 }) {
          Text('轻松驾驭·快乐出行')
            .fontSize(20)
            .fontWeight(FontWeight.Medium)
            .fontColor(neu(this.dark).ink)
          Text('杨庆鸿的车主App')
            .fontSize(12)
            .fontColor(neu(this.dark).inkSub)
        }
      }
    }
    .width('100%')
    .height('100%')
    .linearGradient(neuBg(this.dark))
  }
}
