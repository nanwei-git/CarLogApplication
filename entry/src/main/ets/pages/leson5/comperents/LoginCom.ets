// 封装的页头组件：标题 + 副标题 + 平台图标（从注册页抽取，供页面引用）
@Component
export struct LoginCom {
  title: string = "资源复用平台"
  subtitle: string = "精勤博学，学以致用。厚积薄发，智行天下"

  build() {
    Column({ space: 8 }) {
      Image($r('app.media.neu'))
        .width(70)
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
      Text(this.subtitle)
        .fontSize(12)
        .fontColor('#999999')
    }.width('100%')
  }
}
