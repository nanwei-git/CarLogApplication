import { ResourceData } from "./Data/ResourceData"
import { excellentList as ExcellentList } from "./Data/ExcellentData"

@Preview
@Component
export struct ExcellentArea {
  //精品资源数据
  @State excellentList: ResourceData[] = ExcellentList

  build() {
    Column() {
      Text('精品课程')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .width('98%')
      //   使用列表组件实现左图右文
      List() {
        // 每个ListItem都是左图右文
        ForEach(this.excellentList, (item: ResourceData) => {
          ListItem() {
            //子组件是左图右文,再次封装子组件，使用相对布局实现
            ExcellentItem({ item })
          }
        })
      }
      .width('98%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }.backgroundColor(Color.Yellow)
    .width('98%')
    .layoutWeight(1)
  }
}

@Component
struct ExcellentItem {
  @Prop item: ResourceData

  build() {
    RelativeContainer() {
      // 左图
      Image(this.item.imgSrc)
        .height(64)
        .width(108)
        .objectFit(ImageFit.Cover)
        .borderRadius(16)
        .id('image')
        .alignRules({
          'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
          'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
        })
      // 右侧标题 + 描述（左图右文）
      Column() {
        Text(this.item.title)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.item.description)
          .fontSize(12)
          .fontColor('#6B6B6B')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .id('content')
      .alignRules({
        'left': { 'anchor': 'image', 'align': HorizontalAlign.End },
        'right': { 'anchor': '__container__', 'align': HorizontalAlign.End },
        'center': { 'anchor': '__container__', 'align': VerticalAlign.Center }
      })
      .padding({ left: 10 })
    }.height(88)
    .margin({ top: 8, right: 16, left: 16, bottom: 8 })
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .clip(true)
  }
}
