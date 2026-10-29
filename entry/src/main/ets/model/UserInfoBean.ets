// 用户信息（含嵌套 user）；字段与 SPEC 一致，具体以真服务器返回为准
export class User {
  userId: string = ''
  userName: string = ''
  nickName: string = ''
  avatar: string = ''
  phonenumber: string = ''
}

export class UserInfoBean {
  carVin: string = ''
  carId: string = ''
  user: User = new User()
}
