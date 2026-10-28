import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct SignupUI {
  @State _username: string = ''
  @State _password: string = ''
  @State _phone: string = ''
  @State _email: string = ''
  @State _role: number = 0
  @State _showPwd: boolean = false

  build() {
    Column({ space: 8 }) {
      //1.灰色卡片：页头 + 表单 + 身份 + 按钮
      Column({ space: 14 }) {
        SignupHeader()

        SignupModule({
          username: $_username,
          password: $_password,
          phone: $_phone,
          email: $_email,
          showPwd: $_showPwd
        })

        SignupRole({ role: $_role })

        SignupButton({
          username: $_username,
          password: $_password,
          phone: $_phone,
          email: $_email,
          role: $_role
        })
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .backgroundColor('#F1F3F5')
      .borderRadius(12)
      .padding({ left: 14, right: 14, top: 24, bottom: 24 })
      .justifyContent(FlexAlign.Center)
    }
  }
}

@Component
struct SignupHeader {
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

@Component
struct SignupModule {
  @Link username: string
  @Link password: string
  @Link phone: string
  @Link email: string
  @Link showPwd: boolean

  build() {
    Column() {
      //1.用户名
      TextInput({ text: this.username, placeholder: '请输入用户名' })
        .width('100%')
        .height(42)
        .fontSize(14)
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .padding({ left: 10, right: 10 })
        .onChange((valoe) => {
          this.username = valoe
        })

      Divider().width('100%').strokeWidth(1).color('#F0F0F0')

      //2.密码（右侧眼睛切换明文/密文）
      Row() {
        TextInput({ text: this.password, placeholder: '请输入密码' })
          .layoutWeight(1)
          .height(42)
          .fontSize(14)
          .backgroundColor(Color.Transparent)
          .borderRadius(0)
          .padding({ left: 10, right: 4 })
          .type(this.showPwd ? InputType.Normal : InputType.Password)
          .onChange((valoe) => {
            this.password = valoe
          })
        Text(this.showPwd ? '👁' : '')
          .fontSize(16)
          .margin({ right: 10 })
          .onClick(() => {
            this.showPwd = !this.showPwd
          })
      }.width('100%')

      Divider().width('100%').strokeWidth(1).color('#F0F0F0')

      //3.手机号
      TextInput({ text: this.phone, placeholder: '请输入手机号' })
        .width('100%')
        .height(42)
        .fontSize(14)
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .padding({ left: 10, right: 10 })
        .type(InputType.PhoneNumber)
        .onChange((valoe) => {
          this.phone = valoe
        })

      Divider().width('100%').strokeWidth(1).color('#F0F0F0')

      //4.邮箱
      TextInput({ text: this.email, placeholder: '请输入邮箱' })
        .width('100%')
        .height(42)
        .fontSize(14)
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .padding({ left: 10, right: 10 })
        .type(InputType.Email)
        .onChange((valoe) => {
          this.email = valoe
        })
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(10)
    .padding({ left: 4, right: 4 })
  }
}

@Component
struct SignupRole {
  @Link role: number

  build() {
    Row({ space: 28 }) {
      Row({ space: 4 }) {
        Radio({ value: 'student', group: 'roleGroup' })
          .checked(this.role === 0)

          .onChange((checked: boolean) => {
            if (checked) {
              this.role = 0
            }
          })
        Text('学生').fontSize(14)
      }
      Row({ space: 4 }) {
        Radio({ value: 'teacher', group: 'roleGroup' })
          .checked(this.role === 1)

          .onChange((checked: boolean) => {
            if (checked) {
              this.role = 1
            }
          })
        Text('教师').fontSize(14)
      }
    }.width('100%').justifyContent(FlexAlign.Center)
  }
}

@Component
struct SignupButton {
  @Link username: string
  @Link password: string
  @Link phone: string
  @Link email: string
  @Link role: number

  build() {
    Column({ space: 10 }) {
      Button('注册')
        .width('100%')
        .height(42)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#007DFF')
        .borderRadius(21)
        .onClick(() => {
          if (this.username === '' || this.password === '' || this.phone === '' || this.email === '') {
            promptAction.openToast({
              message: '请完整填写注册信息',
              duration: 2000
            })
          } else {
            const roleText = this.role === 0 ? '学生' : '教师'
            promptAction.openToast({
              message: '调用注册接口：' + this.username + '&' + this.phone + '&' + this.email + '&' + roleText
            })
          }
        })

      Button('返回登录')
        .width('100%')
        .height(42)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor('#007DFF')
        .borderRadius(21)
        .onClick(() => {
          promptAction.openToast({
            message: '返回登录页面',
            duration: 2000
          })
        })
    }.width('100%')
  }
}
