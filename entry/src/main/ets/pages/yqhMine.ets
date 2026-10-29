// 我的（M8a）：个人信息 / 换绑车辆 / 设置 / 退出登录（清状态）
// 读取 StorageUtils 持久化的 userName / carVin / fontScale / darkMode（KT10）
import { router, promptAction } from '@kit.ArkUI'
import { palette, bgGradient } from '../common/style/Style'
import { YqhGlassCard } from '../views/yqhGlassCard'
import { YqhButton } from '../views/yqhButton'
import { clearSession } from '../common/utils/StorageUtils'

@Component
export struct YqhMine {
  @Consume('navPathStack') navPathStack: NavPathStack
  @StorageProp('userName') userName: string = ''
  @StorageProp('carVin') carVin: string = ''
  @StorageProp('fontScale') fontScale: number = 1.0
  @StorageProp('darkMode') dark: boolean = false

  // 字母圆形头像占位（零美术资产）
  private avatarText(): string {
    if (this.userName === '') {
      return '杨'
    }
    return this.userName.substring(0, 1)
  }

  private confirmLogout(): void {
    AlertDialog.show({
      title: '退出登录',
      message: '退出后将清除本地登录状态，确定退出吗？',
      autoCancel: true,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        fontColor: palette(this.dark).inkSub,
        action: () => {
        }
      },
      secondaryButton: {
        value: '退出',
        fontColor: palette(this.dark).danger,
        action: () => {
          clearSession()
          router.replaceUrl({ url: 'pages/yqhLogin' })
        }
      }
    })
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 14 }) {
          YqhGlassCard({ pad: 20 }) {
            Row({ space: 14 }) {
              Stack() {
                Circle({ width: 56, height: 56 })
                  .fill(palette(this.dark).card)
                  .stroke(palette(this.dark).line)
                  .strokeWidth(1)
                Text(this.avatarText())
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(palette(this.dark).accentDeep)
              }
              Column({ space: 4 }) {
                Text(this.userName === '' ? '未登录' : this.userName)
                  .fontSize(18 * this.fontScale)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(palette(this.dark).ink)
                Text('VIN ' + (this.carVin === '' ? '未绑定' : this.carVin))
                  .fontSize(12 * this.fontScale)
                  .fontColor(palette(this.dark).inkSub)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
          }

          YqhGlassCard({ pad: 8 }) {
            Column() {
              Row() {
                Column({ space: 2 }) {
                  Text('换绑车辆')
                    .fontSize(14 * this.fontScale)
                    .fontColor(palette(this.dark).ink)
                  Text('更换绑定的车架号')
                    .fontSize(11 * this.fontScale)
                    .fontColor(palette(this.dark).inkSub)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                Text('›')
                  .fontSize(20)
                  .fontColor(palette(this.dark).inkSub)
              }
              .width('100%')
              .height(52)
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/yqhBindCar', params: { from: 'mine' } })
              })

              Row() {
                Column({ space: 2 }) {
                  Text('设置')
                    .fontSize(14 * this.fontScale)
                    .fontColor(palette(this.dark).ink)
                  Text('字号与主题')
                    .fontSize(11 * this.fontScale)
                    .fontColor(palette(this.dark).inkSub)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                Text('›')
                  .fontSize(20)
                  .fontColor(palette(this.dark).inkSub)
              }
              .width('100%')
              .height(52)
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                this.navPathStack.pushPath({ name: 'Settings' })
              })

              Row() {
                Column({ space: 2 }) {
                  Text('车主商城')
                    .fontSize(14 * this.fontScale)
                    .fontColor(palette(this.dark).ink)
                  Text('商品 · 优惠 · 收藏 · 评价')
                    .fontSize(11 * this.fontScale)
                    .fontColor(palette(this.dark).inkSub)
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                Text('›')
                  .fontSize(20)
                  .fontColor(palette(this.dark).inkSub)
              }
              .width('100%')
              .height(52)
              .padding({ left: 12, right: 12 })
              .onClick(() => {
                this.navPathStack.pushPath({ name: 'Mall' })
              })
            }
          }

          YqhButton({
            text: '退出登录',
            primary: false,
            onBtnClick: () => {
              this.confirmLogout()
            }
          })
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .linearGradient(bgGradient(this.dark))
  }
}
