// 统一返回结构（与既有 LoginModel 一致：code / msg / token / data）
export interface IResult {
  code: number
  msg: string
  token?: string
  data?: ESObject
}
