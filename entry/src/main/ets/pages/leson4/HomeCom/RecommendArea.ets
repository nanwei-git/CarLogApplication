import { ResourceData } from "./Data/ResourceData"
import { recommendList as RecommendList } from "./Data/RecommendData"

@Component
export struct RecommendArea{
  //推荐课程数据
  @State recommendList: ResourceData[] = RecommendList

  build() {
    Column(){
      Text('推荐课程').fontSize(16)
        .fontWeight(FontWeight.Bold)
        .width('100%')
      Grid(){
        ForEach(this.recommendList,(yqh:ResourceData)=>{
          GridItem(){
            Column(){
              //1、图片
              Image(yqh.imgSrc)
                .width('100%')
                .height(96)
                .borderRadius({topLeft:16, topRight:16})
                .objectFit(ImageFit.Cover)
              // 2、标题
              Text(yqh.title)
                .fontSize(14)
                .height(14)
                .textOverflow({overflow:TextOverflow.Ellipsis})
              // 3、描述
              Text(yqh.description)
                .fontSize(12)
                .height(32)
                .textOverflow({overflow:TextOverflow.Ellipsis})
                .maxLines(2)
            }
          }.width(160)
          .height(160)
          .borderRadius(16)
          .backgroundColor(Color.White)
        })
      }.width('100%')
      .rowsTemplate('1fr')
      .height(169)
      .columnsGap(8)
      .padding({top:2,left:16,right:16})
      .scrollBar(BarState.Off)
    }.backgroundColor(Color.Green)
    .width('98%')
    .height(190)
  }
}
