import { promptAction } from '@kit.ArkUI'

@Entry
@Component

struct Login {

title:string="资源复用平台"
  subtitle:string="精勤博学，学以致用。厚积薄发，智行天下"
 usename:string=""
  password:string=""
  build() {
    Column({space:20}) {
      Column({ space: 10 }) {
        Image($r('app.media.neu')).width(100)
        Text(this.title)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
        Text(this.subtitle)
          .fontSize(16)

      }.backgroundColor(Color.Green)
      .width('100%').height(200)

      Column() {
        TextInput({ placeholder: '请输入用户名' })
          .borderRadius(5)
          .backgroundColor(Color.White)
          .onChange((valoe) => {
            this.usename = valoe
          })
        TextInput({ placeholder: '请输入密码' }).borderRadius(5)
          .backgroundColor(Color.White)
          .onChange((valoe) => {
            this.password = valoe
          })
          .type(InputType.Password)
        Row() {
          Text("自动登录").fontSize(12).fontColor('#36D')
          Text("忘记密码").fontSize(12).fontColor('#36D')
        }.width('100%').justifyContent(FlexAlign.SpaceBetween)
      }.backgroundColor(Color.Pink).width('90%').height(120)

      Column() {
        Button("登录")
          .width('100%')
          .fontColor(Color.White)
          .onClick(()=>{
            if (this.usename === ''|| this.password === ''){
              promptAction.openToast({
                message: '用户名或密码不能为空',
                duration: 2000
              })
            }
            else {
              promptAction.openToast({
                message: '调用接口将用户名密码发送到后台：'+this.usename+'&'+this.password
              })
            }
          })
        Text('注册')
          .width('100%')
          .fontColor('#3366DD')
          .textAlign(TextAlign.Center)
      }.backgroundColor(Color.Green)
      .height(80)
      .width('80%')
    }
  }
}