// 我的（M8a）：个人信息 / 绑定车辆 / 我的反馈 / 设置 / 退出登录（清状态）
// 原型对齐：圆形大头像 + 昵称 + 生日；白卡三行（绑定车辆 / 我的反馈 / 设置，圆形彩色图标 + 副标题 + >）；底部胶囊「退出登录」
import { router, promptAction } from '@kit.ArkUI'
import { palette, bgGradient, COLORS } from '../common/style/Style'
import { YqhGlassCard } from '../views/yqhGlassCard'
import { YqhButton } from '../views/yqhButton'
import { clearSession } from '../common/utils/StorageUtils'

@Component
export struct YqhMine {
  @Consume('navPathStack') navPathStack: NavPathStack
  @StorageProp('userName') userName: string = ''
  @StorageProp('carVin') carVin: string = ''
  @StorageProp('birthDate') birthday: string = ''
  @StorageProp('fontScale') fontScale: number = 1.0
  @StorageProp('darkMode') dark: boolean = false

  // 字母圆形头像占位（零美术资产）
  private avatarText(): string {
    if (this.userName === '' || this.userName === undefined) {
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

  // 菜单行：圆形彩色图标 + 标题 + 副标题 + >
  @Builder
  menuRow(icon: string, color: string, title: string, sub: string, onClick: () => void) {
    Row() {
      Stack() {
        Circle({ width: 40, height: 40 })
          .fill(color)
        Text(icon)
          .fontSize(20)
      }
      .width(40)
      .height(40)
      Column({ space: 2 }) {
        Text(title)
          .fontSize(14 * this.fontScale)
          .fontColor(palette(this.dark).ink)
        Text(sub)
          .fontSize(11 * this.fontScale)
          .fontColor(palette(this.dark).inkSub)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
      Text('›')
        .fontSize(20)
        .fontColor(palette(this.dark).inkSub)
    }
    .width('100%')
    .height(56)
    .padding({ left: 12, right: 12 })
    .onClick(onClick)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 14 }) {
          // 个人信息卡：大头像 + 昵称 + 生日
          YqhGlassCard({ pad: 20 }) {
            Row({ space: 16 }) {
              Stack() {
                Circle({ width: 76, height: 76 })
                  .fill(palette(this.dark).card)
                  .stroke(palette(this.dark).line)
                  .strokeWidth(1)
                Text(this.avatarText())
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(palette(this.dark).accentDeep)
              }
              Column({ space: 4 }) {
                Text(this.userName === '' ? '未登录' : this.userName)
                  .fontSize(20 * this.fontScale)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(palette(this.dark).ink)
                Text('生日 ' + (this.birthday === '' ? '未设置' : this.birthday))
                  .fontSize(13 * this.fontScale)
                  .fontColor(palette(this.dark).inkSub)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
          }

          // 功能入口三行
          YqhGlassCard({ pad: 8 }) {
            Column() {
              this.menuRow('🚗', '#FFB74D', '绑定车辆', '更换绑定的车架号', () => {
                router.pushUrl({ url: 'pages/yqhBindCar', params: { from: 'mine' } })
              })
              this.menuRow('💬', '#4FC9C4', '我的反馈', '查看我提交的反馈', () => {
                this.navPathStack.pushPath({ name: 'FeedbackList' })
              })
              this.menuRow('⚙️', '#9AA3A8', '设置', '字号与主题', () => {
                this.navPathStack.pushPath({ name: 'Settings' })
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
