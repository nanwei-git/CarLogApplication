import { LoginCom } from './comperents/LoginCom'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct LoginYqhEncapPage {
  @State _username: string = 'admin'
  @State _password: string = '123456'
  build() {
    Column({space: 20}) {
      LoginCom()
      //1.图文显示页面
      LoginModule({ username: this._username, password: this._password })
      //2.输入显示
      Text(this._username+this._password)
        .backgroundColor(Color.Red)
      //3.按钮
      LoginButton({ usename: this._username, password: this._password })
    }.backgroundColor('#d3d3d3')
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceAround)
  }
}

@Component
struct LoginButton {
  @Link usename: string
  @Link password: string
  build() {
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

@Component
struct LoginModule {
  @Link username: string
  @Link password: string
  build() {
    Column({ space: 10 }) {
      Column() {
        TextInput({ placeholder: '请输入用户名' })
          .borderRadius(5)
          .backgroundColor(Color.White)
          .onChange((valoe) => {
            this.username = valoe
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
    }.backgroundColor(Color.Green)
    .width('100%').height(200)
  }
}
