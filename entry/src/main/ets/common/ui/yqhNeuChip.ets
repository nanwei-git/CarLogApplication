// 通用 UI 组件（Dark Neumorphism）：状态徽标（凹陷小胶囊）
// tone：'' 默认 / 'accent' / 'ok' / 'warn' / 'danger'
// 用法：YqhNeuChip({ text: '已读', tone: 'ok' })
import { neu } from '../style/Style'

@Preview
@Component
export struct YqhNeuChip {
  @StorageProp('darkMode') dark: boolean = true
  @Prop text: string = ''
  @Prop tone: string = ''

  private toneColor(): string {
    if (this.tone === 'accent') {
      return neu(this.dark).accent
    }
    if (this.tone === 'ok') {
      return neu(this.dark).ok
    }
    if (this.tone === 'warn') {
      return neu(this.dark).warn
    }
    if (this.tone === 'danger') {
      return neu(this.dark).danger
    }
    return neu(this.dark).inkSub
  }

  build() {
    Text(this.text)
      .fontSize(11)
      .fontColor(this.toneColor())
      .padding({ left: 10, right: 10, top: 4, bottom: 4 })
      .borderRadius(10)
      .backgroundColor(neu(this.dark).surfaceSunken)
      .border({ width: 1, color: neu(this.dark).line })
  }
}
