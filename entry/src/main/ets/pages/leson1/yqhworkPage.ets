@Entry
@Component
struct YqhworkPage {
  @State message: string = 'Hello World';

  build() {
   Stack(){
    Image($r('app.media.ic_launcher_background'))
     Column(){
      Row(){
        Text('精制博学，学以致用')
          .fontSize(30)
          .width(40)
        Text('厚积薄发，智行天下')
          .fontSize(16)
          .width(18)
          .textAlign(TextAlign.End)
      }
     }
   }

  }
}