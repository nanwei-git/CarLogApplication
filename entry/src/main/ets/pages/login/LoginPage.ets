import { http } from '@kit.NetworkKit'
import { LoginUrl } from './common/constart/HttpApi'
import { LoginModel } from './common/constart/mode/loginmodel'


@Entry
@Component
struct CyyHttpPage {
  username='zzq1234'
  password='666666'
  // 登录的网络请求
  getLogin(name: string, pwd: string): Promise<LoginModel> {
    return new Promise((resolve, reject) => {
      //   1、创建Http请求
      let httpRequest = http.createHttp()
      //   2、发送请求
      httpRequest.request(LoginUrl, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify({ username: name, password: pwd })
      }, (err, data) => {
        // 请求结束后销毁实例，避免内存泄漏
        httpRequest.destroy()
        if (err) {
          reject(err)
          return
        }
        if (data.responseCode === http.ResponseCode.OK) {
          const res = JSON.parse(data.result as string) as LoginModel
          resolve(res)
        } else {
          reject(new Error('responseCode: ' + data.responseCode))
        }
      })
    })
  }

  build() {
    Column({space:10}){
      //  1、图文显示区域
      Column(){

      }.backgroundColor(Color.Pink)
      .width('100%')
      .height(200)
      //   2、输入框区域
      Column({space:10}){
        TextInput({placeholder:'请输入用户名',text:this.username})
          .borderRadius(5)
          .backgroundColor(Color.White)
          .onChange((val)=>{
            this.username = val
          })
        TextInput({text:this.password})
          .borderRadius(5)
          .backgroundColor(Color.White)
          .type(InputType.Password)
          .onChange((val)=>{
            this.password = val
          })

      }.backgroundColor(Color.White)
      .height(120)
      .width('90%')
      //   3、按钮区域
      Button("登录").width('100%')
        .fontColor(Color.White)
        .onClick(()=>{
          if(this.username === '' || this.password === ''){
            console.log("用户名或密码不能为空")
          }
          else{
            this.getLogin(this.username, this.password)
              .then((res: LoginModel) => {
                if (res.code === 200 || res.code === 0) {
                  console.log('登录成功: ' + res.msg + ', token=' + res.token)
                } else {
                  console.log('登录失败: ' + res.msg)
                }
              })
              .catch((err: Error) => {
                console.log('请求异常: ' + JSON.stringify(err))
              })
          }
        })

    }

  }
}