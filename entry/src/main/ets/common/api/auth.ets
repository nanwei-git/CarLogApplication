// 认证相关接口函数（登录/注册/用户信息/绑车）
import { post } from '../utils/RequestUtil'
import { ApiPath, USE_MOCK } from '../constants/HttpApi'
import { IResult } from '../model/IResult'
import { UserInfoBean } from '../model/UserInfoBean'
import { RegisterReq } from '../model/ApiReq'
import { mockLogin, mockGetUserInfo, mockRegister, mockBindCar } from '../utils/MockData'

export function getLogin(username: string, password: string): Promise<IResult> {
  if (USE_MOCK) {
    return mockLogin(username, password)
  }
  return post(ApiPath.login, { username, password })
}

export function getRegister(req: RegisterReq): Promise<IResult> {
  if (USE_MOCK) {
    return mockRegister(req)
  }
  return post(ApiPath.register, req)
}

export function getUserInfo(): Promise<UserInfoBean> {
  if (USE_MOCK) {
    return mockGetUserInfo()
  }
  return post(ApiPath.userInfo, {}).then((res: IResult) => res.data as UserInfoBean)
}

export function bindCarByVin(carVin: string): Promise<IResult> {
  if (USE_MOCK) {
    return mockBindCar(carVin)
  }
  return post(ApiPath.bindCar, { carVin })
}
