// 设置（M8a，KT10，Dark Neumorphism）：字号三档 + 深色拟态主题，全部走 PersistentStorage 持久化
import { neu, neuBg } from '../common/style/Style'
import { YqhNeuCard } from '../common/ui/yqhNeuCard'
import { YqhNeuButton } from '../common/ui/yqhNeuButton'
import { YqhNeuChip } from '../common/ui/yqhNeuChip'
import { setFontScale, setDarkMode } from '../common/utils/StorageUtils'
import { FONT_SMALL, FONT_NORMAL, FONT_LARGE, NEU_BLUR_SM, NEU_DISTANCE_SM } from '../common/constants/Constants'

@Component
export struct YqhSettings {
  @Consume('navPathStack') navPathStack: NavPathStack
  @StorageLink('fontScale') fontScale: number = 1.0
  @StorageLink('darkMode') dark: boolean = true

  // 字号档位按钮：选中 = 凹陷 + 主色
  @Builder
  scaleBtn(title: string, value: number) {
    Column() {
      Text(title)
        .fontSize(14 * this.fontScale)
        .fontColor(this.fontScale === value ? neu(this.dark).accent : neu(this.dark).inkSub)
    }
    .width(72)
    .height(44)
    .borderRadius(22)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.fontScale === value
      ? neu(this.dark).surfaceSunken
      : neu(this.dark).surface)
    .border({ width: 1, color: neu(this.dark).line })
    .shadow({
      radius: NEU_BLUR_SM,
      color: neu(this.dark).shadowDark,
      offsetX: NEU_DISTANCE_SM,
      offsetY: NEU_DISTANCE_SM
    })
    .onClick(() => {
      this.fontScale = value
      setFontScale(value)
    })
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 14 }) {
          YqhNeuCard({ pad: 20 }) {
            Column({ space: 12 }) {
              Text('字号')
                .fontSize(15 * this.fontScale)
                .fontWeight(FontWeight.Bold)
                .fontColor(neu(this.dark).ink)
                .width('100%')
              Row({ space: 10 }) {
                this.scaleBtn('小', FONT_SMALL)
                this.scaleBtn('标准', FONT_NORMAL)
                this.scaleBtn('大', FONT_LARGE)
              }
              .width('100%')
            }
          }

          YqhNeuCard({ pad: 20 }) {
            Row() {
              Column({ space: 2 }) {
                Text('深色拟态主题')
                  .fontSize(14 * this.fontScale)
                  .fontColor(neu(this.dark).ink)
                Text(this.dark ? 'Dark Neumorphism · 特斯拉风' : '浅色拟态')
                  .fontSize(11 * this.fontScale)
                  .fontColor(neu(this.dark).inkSub)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.dark })
                .selectedColor(neu(this.dark).accent)
                .onChange((v: boolean) => {
                  this.dark = v
                  setDarkMode(v)
                })
            }
            .width('100%')
            .height(52)
          }

          YqhNeuCard({ pad: 20, sunken: true }) {
            Column({ space: 8 }) {
              Text('预览效果')
                .fontSize(12 * this.fontScale)
                .fontColor(neu(this.dark).inkSub)
                .width('100%')
              Text('杨庆鸿的车主App · 智慧出行')
                .fontSize(16 * this.fontScale)
                .fontColor(neu(this.dark).ink)
                .width('100%')
              Row({ space: 8 }) {
                YqhNeuChip({ text: '深色拟态', tone: 'accent' })
                YqhNeuChip({ text: '字号 ' + this.fontScale.toFixed(2), tone: 'ok' })
              }
              .width('100%')
            }
          }

          YqhNeuCard({ pad: 16 }) {
            Column({ space: 6 }) {
              Text('关于 / 素材来源')
                .fontSize(14 * this.fontScale)
                .fontWeight(FontWeight.Bold)
                .fontColor(neu(this.dark).ink)
                .width('100%')
              Text('车辆图：小米 SU7，来源 Wikimedia Commons（作者 Wikisympathisant，CC BY-SA 4.0）')
                .fontSize(11 * this.fontScale)
                .fontColor(neu(this.dark).inkSub)
                .width('100%')
              Text('控制图标：锁 Open Clipart（公有领域）；灯泡 Simple Icons（CC0）')
                .fontSize(11 * this.fontScale)
                .fontColor(neu(this.dark).inkSub)
                .width('100%')
              Text('UI 风格：Dark Neumorphism（深色拟态），零美术资产，全部由 ArkUI 绘制')
                .fontSize(11 * this.fontScale)
                .fontColor(neu(this.dark).inkSub)
                .width('100%')
            }
          }

          YqhNeuButton({
            text: '返回',
            primary: false,
            onBtnClick: () => {
              this.navPathStack.pop()
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
