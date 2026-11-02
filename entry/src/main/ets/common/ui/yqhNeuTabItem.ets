// 通用 UI 组件（Dark Neumorphism）：底部 Tab 项
// 选中 = 凹陷 + 主色图标 + 主色柔光；未选中 = 凸起。
// 用法：YqhNeuTabItem({ icon: '🏠', title: '首页', active: true })
import { neu } from '../style/Style'
import { NEU_BLUR_SM, NEU_DISTANCE_SM } from '../constants/Constants'

@Preview
@Component
export struct YqhNeuTabItem {
  @StorageProp('darkMode') dark: boolean = true
  @Prop icon: string = '' // 图标字符（系统符号 / emoji）
  @Prop title: string = ''
  @Prop active: boolean = false

  build() {
    Column({ space: 2 }) {
      Text(this.icon)
        .fontSize(20)
        .fontColor(this.active ? neu(this.dark).accent : neu(this.dark).inkSub)
      Text(this.title)
        .fontSize(10)
        .fontColor(this.active ? neu(this.dark).ink : neu(this.dark).inkSub)
    }
    .width(64)
    .height(54)
    .borderRadius(18)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.active ? neu(this.dark).surfaceSunken : neu(this.dark).surface)
    .border({ width: 1, color: neu(this.dark).line })
    .shadow(this.active
      ? { radius: NEU_BLUR_SM, color: neu(this.dark).accentSoft, offsetX: 0, offsetY: 0 }
      : {
          radius: NEU_BLUR_SM,
          color: neu(this.dark).shadowDark,
          offsetX: NEU_DISTANCE_SM,
          offsetY: NEU_DISTANCE_SM
        })
  }
}
