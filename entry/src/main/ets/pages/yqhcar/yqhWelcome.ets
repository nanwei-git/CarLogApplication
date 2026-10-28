// 欢迎页（M1）：色卡浅色渐变背景，3s 后按是否已登录自动跳登录页或首页。
import { router } from '@kit.ArkUI'
import { COLORS, BG_GRADIENT } from '../../common/style/Style'
import { getIsLogin } from '../../common/utils/StorageUtils'
import { YqhGlassCard } from '../../common/ui/yqhGlassCard'

@Entry
@Component
struct YqhWelcome {
  private timer: number = -1

  aboutToAppear(): void {
    // 3s 后按登录态分流（与实验指导书"欢迎页自动跳转"流程一致）
    this.timer = setTimeout(() => {
      if (getIsLogin()) {
        router.replaceUrl({ url: 'pages/yqhcar/yqhIndex' })
      } else {
        router.replaceUrl({ url: 'pages/yqhcar/yqhLogin' })
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
      Column() {
        YqhGlassCard({ pad: 28 }) {
          Column({ space: 18 }) {
            // 字母圆形头像占位（零美术资产，替代图片头像）
            Stack() {
              Circle({ width: 96, height: 96 })
                .fill(COLORS.card)
                .stroke(COLORS.line)
                .strokeWidth(1)
              Text('杨')
                .fontSize(40)
                .fontWeight(FontWeight.Bold)
                .fontColor(COLORS.accentDeep)
            }
            Text('杨庆鸿的车主App')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.ink)
            Text('智慧出行 · 远程控车')
              .fontSize(15)
              .fontColor(COLORS.inkSub)
          }
          .justifyContent(FlexAlign.Center)
        }
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
