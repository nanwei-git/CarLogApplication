// 登录页（M1 占位骨架，M2 完善账号密码登录 / 注册入口 / 401 处理）
import { router } from '@kit.ArkUI'
import { COLORS, BG_GRADIENT } from '../../common/style/Style'
import { YqhGlassCard } from '../../common/ui/yqhGlassCard'

@Entry
@Component
struct YqhLogin {
  build() {
    Stack() {
      Column() {
        YqhGlassCard({ pad: 24 }) {
          Column({ space: 14 }) {
            Text('登录')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.ink)
            Text('（M2 完善：账号密码登录 / 注册入口）')
              .fontSize(14)
              .fontColor(COLORS.inkSub)
            Button('临时进入首页')
              .width('100%')
              .backgroundColor(COLORS.accent)
              .fontColor('#FFFFFF')
              .onClick(() => {
                router.replaceUrl({ url: 'pages/yqhcar/yqhIndex' })
              })
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
