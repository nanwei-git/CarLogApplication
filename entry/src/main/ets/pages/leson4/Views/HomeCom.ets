import { SwipeArea } from "../HomeCom/SwipeArea"
import { RecommendArea } from "../HomeCom/RecommendArea"
import { ExcellentArea } from "../HomeCom/ExcellentArea"

@Preview
@Component
export struct HomeCom{

  build() {
    Column({space:10}){
      // 1、轮廓图
      SwipeArea()
      // 2、推荐课程区域
      RecommendArea()
      // 3、精品课程区域
      ExcellentArea()
    }.width('100%')
    .height('100%')
    .backgroundColor('#d3d3d3')
  }
}
