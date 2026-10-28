import { RecommendArea } from "../HomeCom/RecommendArea"
import { SwipeArea } from "../HomeCom/SwipeArea"

@Preview
@Entry
@Component
export struct HomYqh {
  build() {
    Column({ space: 10 }) {
      //1.轮播图
      SwipeArea()
      //2.推荐课程区域
      RecommendArea()
      //3.精品课程区域
      Column() {
        Text('精品课程')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .width('98%')
        Column() {
          Row() {
          }
        }
      }.backgroundColor(Color.Yellow)
      .width('98%')
      .layoutWeight(1)
    }.width('100%')
    .height('100%')
    .backgroundColor('#d3d3d3')
  }
}
