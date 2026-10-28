export class LoginModel {
  msg: string
  code: number
  token: string

  constructor(msg: string, code: number, token: string) {
    this.msg = msg
    this.code = code
    this.token = token
  }
}