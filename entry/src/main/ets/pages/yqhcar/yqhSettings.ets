// 设置（M8a，KT10）：字号三档 + 深色主题，全部走 PersistentStorage 持久化
import { palette, bgGradient } from '../../common/style/Style'
import { YqhGlassCard } from '../../common/ui/yqhGlassCard'
import { YqhButton } from '../../common/ui/yqhButton'
import { setFontScale, setDarkMode } from '../../common/utils/StorageUtils'
import { FONT_SMALL, FONT_NORMAL, FONT_LARGE } from '../../common/constants/Constants'

@Component
export struct YqhSettings {
  @Consume('navPathStack') navPathStack: NavPathStack
  @StorageLink('fontScale') fontScale: number = 1.0
  @StorageLink('darkMode') dark: boolean = false

  @Builder
  scaleBtn(title: string, value: number) {
    Button(title)
      .width(72)
      .height(36)
      .borderRadius(18)
      .fontSize(14 * this.fontScale)
      .backgroundColor(this.fontScale === value ? palette(this.dark).accent : 'rgba(255,255,255,0.6)')
      .fontColor(this.fontScale === value ? '#FFFFFF' : palette(this.dark).ink)
      .onClick(() => {
        this.fontScale = value
        setFontScale(value)
      })
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 14 }) {
          YqhGlassCard({ pad: 20 }) {
            Column({ space: 12 }) {
              Text('字号')
                .fontSize(15 * this.fontScale)
                .fontWeight(FontWeight.Bold)
                .fontColor(palette(this.dark).ink)
                .width('100%')
              Row({ space: 10 }) {
                this.scaleBtn('小', FONT_SMALL)
                this.scaleBtn('标准', FONT_NORMAL)
                this.scaleBtn('大', FONT_LARGE)
              }
              .width('100%')
            }
          }

          YqhGlassCard({ pad: 20 }) {
            Row() {
              Column({ space: 2 }) {
                Text('深色主题')
                  .fontSize(14 * this.fontScale)
                  .fontColor(palette(this.dark).ink)
                Text('关闭则使用奶油黄→薄荷青色卡')
                  .fontSize(11 * this.fontScale)
                  .fontColor(palette(this.dark).inkSub)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.dark })
                .selectedColor(palette(this.dark).accent)
                .onChange((v: boolean) => {
                  this.dark = v
                  setDarkMode(v)
                })
            }
            .width('100%')
            .height(48)
          }

          YqhGlassCard({ pad: 20 }) {
            Column({ space: 6 }) {
              Text('预览效果')
                .fontSize(12 * this.fontScale)
                .fontColor(palette(this.dark).inkSub)
                .width('100%')
              Text('杨庆鸿的车主App · 智慧出行')
                .fontSize(16 * this.fontScale)
                .fontColor(palette(this.dark).ink)
                .width('100%')
            }
          }

          YqhButton({
            text: '返回',
            primary: false,
            onBtnClick: () => {
              this.navPathStack.pop()
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
