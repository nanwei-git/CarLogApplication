// 认证相关接口函数（登录/注册/用户信息/绑车）—— 直连真服务器（C2）
// 说明：登录/注册链路始终走真实 HTTP（RequestUtil.post → http://121.36.14.143:10001），
// 不再依赖本地 mock；其余业务（车辆/反馈）仍在 USE_MOCK 下走 mock，互不影响。
import { post } from '../common/utils/RequestUtil'
import { ApiPath } from '../common/constants/HttpApi'
import { IResult } from '../model/IResult'
import { UserInfoBean } from '../model/UserInfoBean'
import { RegisterReq, LoginReq, BindReq, EmptyReq } from '../model/ApiReq'

export function getLogin(username: string, password: string): Promise<IResult> {
  const req: LoginReq = { username: username, password: password }
  return post(ApiPath.login, req)
}

export function getRegister(req: RegisterReq): Promise<IResult> {
  return post(ApiPath.register, req)
}

export function getUserInfo(): Promise<UserInfoBean> {
  return post(ApiPath.userInfo, new EmptyReq()).then((res: IResult) => res.data as UserInfoBean)
}

export function bindCarByVin(carVin: string): Promise<IResult> {
  const req: BindReq = { carVin: carVin }
  return post(ApiPath.bindCar, req)
}
