@Preview
@Component
export struct LoginCom {
  title: string = "资源复用平台"
  subtitle: string = "精勤博学，学以致用。厚积薄发，智行天下"

  build() {
    Column({ space: 20 }) {
      Column({ space: 10 }) {
        Image($r('app.media.neu')).width(100)
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Text(this.subtitle)
          .fontSize(16)

      }.backgroundColor(Color.Green)
      .width('100%').height(200)
    }
  }
}