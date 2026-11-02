// 我的（M8a，Dark Neumorphism）：凹陷头像 + 拟态卡片 + 菜单行 + 退出登录（清状态）
import { router, promptAction } from '@kit.ArkUI'
import { neu, neuBg } from '../common/style/Style'
import { YqhNeuCard } from '../common/ui/yqhNeuCard'
import { YqhNeuButton } from '../common/ui/yqhNeuButton'
import { YqhNeuChip } from '../common/ui/yqhNeuChip'
import { clearSession } from '../common/utils/StorageUtils'
import { NEU_BLUR_SM, NEU_DISTANCE_SM } from '../common/constants/Constants'

@Component
export struct YqhMine {
  @Consume('navPathStack') navPathStack: NavPathStack
  @StorageProp('userName') userName: string = ''
  @StorageProp('carVin') carVin: string = ''
  @StorageProp('birthDate') birthday: string = ''
  @StorageProp('fontScale') fontScale: number = 1.0
  @StorageProp('darkMode') dark: boolean = true

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
        fontColor: neu(this.dark).inkSub,
        action: () => {
        }
      },
      secondaryButton: {
        value: '退出',
        fontColor: neu(this.dark).danger,
        action: () => {
          clearSession()
          router.replaceUrl({ url: 'pages/yqhLogin' })
        }
      }
    })
  }

  // 菜单行：拟态圆形图标 + 标题 + 副标题 + ›
  @Builder
  menuRow(icon: string, title: string, sub: string, onClick: () => void) {
    Row() {
      Column() {
        Text(icon)
          .fontSize(20)
      }
      .width(44)
      .height(44)
      .borderRadius(22)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(neu(this.dark).surface)
      .border({ width: 1, color: neu(this.dark).line })
      .shadow({
        radius: NEU_BLUR_SM,
        color: neu(this.dark).shadowDark,
        offsetX: NEU_DISTANCE_SM,
        offsetY: NEU_DISTANCE_SM
      })
      Column({ space: 2 }) {
        Text(title)
          .fontSize(14 * this.fontScale)
          .fontColor(neu(this.dark).ink)
        Text(sub)
          .fontSize(11 * this.fontScale)
          .fontColor(neu(this.dark).inkSub)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 12 })
      Text('›')
        .fontSize(20)
        .fontColor(neu(this.dark).inkSub)
    }
    .width('100%')
    .height(60)
    .padding({ left: 10, right: 12 })
    .onClick(onClick)
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 14 }) {
          // 个人信息卡：凹陷头像 + 昵称
          YqhNeuCard({ pad: 20 }) {
            Row({ space: 16 }) {
              Column() {
                Text(this.avatarText())
                  .fontSize(30)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(neu(this.dark).accent)
              }
              .width(76)
              .height(76)
              .borderRadius(38)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(neu(this.dark).surfaceSunken)
              .border({ width: 1, color: neu(this.dark).line })
              Column({ space: 4 }) {
                Text(this.userName === '' ? '未登录' : this.userName)
                  .fontSize(19 * this.fontScale)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(neu(this.dark).ink)
                Text('生日 ' + (this.birthday === '' ? '未设置' : this.birthday))
                  .fontSize(12 * this.fontScale)
                  .fontColor(neu(this.dark).inkSub)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
          }

          // 车辆信息条
          YqhNeuCard({ pad: 16, sunken: true }) {
            Row() {
              Text('已绑定 VIN')
                .fontSize(13)
                .fontColor(neu(this.dark).inkSub)
              Blank()
              YqhNeuChip({ text: this.carVin === '' ? '未绑定' : this.carVin, tone: 'accent' })
            }
            .width('100%')
          }

          // 功能入口三行
          YqhNeuCard({ pad: 10 }) {
            Column() {
              this.menuRow('🚗', '绑定车辆', '更换绑定的车架号', () => {
                router.pushUrl({ url: 'pages/yqhBindCar', params: { from: 'mine' } })
              })
              this.menuRow('💬', '我的反馈', '查看我提交的反馈', () => {
                this.navPathStack.pushPath({ name: 'FeedbackList' })
              })
              this.menuRow('⚙️', '设置', '字号与主题', () => {
                this.navPathStack.pushPath({ name: 'Settings' })
              })
            }
          }

          YqhNeuButton({
            text: '退出登录',
            primary: false,
            onBtnClick: () => {
              this.confirmLogout()
            }
          })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 24 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .linearGradient(neuBg(this.dark))
  }
}
