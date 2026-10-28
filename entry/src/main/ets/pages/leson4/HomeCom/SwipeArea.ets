@Preview
@Component
export struct SwipeArea{
  @State BannerPic:ResourceStr[] = [
    $r('app.media.banner_pic0'),
    $r('app.media.banner_pic2'),
    $r('app.media.banner_pic3'),
    $r('app.media.banner_pic4'),
    $r('app.media.banner_pic5'),
  ]
  build() {
    Swiper(){
      ForEach(this.BannerPic,(val:ResourceStr)=>{
        Image(val)
          .width('100%')
          .height('100%')
      })
    }.backgroundColor(Color.Pink)
    .width('98%')
    .height(200)
    .borderRadius(15)
  }
}
