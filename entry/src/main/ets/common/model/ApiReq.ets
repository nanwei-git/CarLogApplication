// 请求体类型（与 SPEC 一致）
export interface LoginReq {
  username: string
  password: string
}

export interface RegisterReq {
  nickName: string
  userName: string
  phonenumber: string
  sex: string
  avatar: string
  password: string
  roleIds: string[]
  birthDate: string
  state: string
}

export interface BindReq {
  carVin: string
}

// 无参请求体（如 /app/user/info），避免无类型对象字面量
export class EmptyReq {
}
