// 认证相关接口函数（登录/注册/用户信息/绑车）—— 直连真服务器（C2）
// 依据《鸿蒙智能座舱系统接口文档V1.1》：登录 POST /app/login；注册 POST /system/user/register；
// 用户信息 GET /getInfo（字段在响应顶层，无 data 包裹）；绑车 POST /cockpit/info/bindCarVin
import { post, get } from '../common/utils/RequestUtil'
import { ApiPath } from '../common/constants/HttpApi'
import { IResult } from '../model/IResult'
import { UserInfoBean, User } from '../model/UserInfoBean'
import { RegisterReq, LoginReq, BindReq } from '../model/ApiReq'

export function getLogin(username: string, password: string): Promise<IResult> {
  const req: LoginReq = { username: username, password: password }
  return post(ApiPath.login, req)
}

export function getRegister(req: RegisterReq): Promise<IResult> {
  return post(ApiPath.register, req)
}

// 4.3 获取用户信息（GET /getInfo）：响应顶层含 carVin / carId / user
export function getUserInfo(): Promise<UserInfoBean> {
  return get(ApiPath.userInfo).then((res: IResult) => {
    const d: ESObject = res as ESObject
    const ui: UserInfoBean = new UserInfoBean()
    ui.carVin = (d['carVin'] as string) ?? ''
    ui.carId = (d['carId'] as string) ?? ''
    const u: ESObject = (d['user'] as ESObject) ?? {}
    const user: User = new User()
    user.userId = (u['userId'] as string) ?? ''
    user.userName = (u['userName'] as string) ?? ''
    user.nickName = (u['nickName'] as string) ?? ''
    user.avatar = (u['avatar'] as string) ?? ''
    user.phonenumber = (u['phonenumber'] as string) ?? ''
    ui.user = user
    return ui
  })
}

export function bindCarByVin(carVin: string): Promise<IResult> {
  const req: BindReq = { carVin: carVin }
  return post(ApiPath.bindCar, req)
}
