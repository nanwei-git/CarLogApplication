// 本地 mock（USE_MOCK=true 时启用）；字段与真接口返回一致，便于离线验收 UI
import { IResult } from '../model/IResult'
import { UserInfoBean } from '../model/UserInfoBean'
import { RegisterReq } from '../model/ApiReq'

export function mockLogin(username: string, password: string): Promise<IResult> {
  return new Promise<IResult>((resolve) => {
    resolve({ code: 200, msg: 'mock 登录成功', token: 'mock-token-' + username })
  })
}

export function mockGetUserInfo(): Promise<UserInfoBean> {
  return new Promise<UserInfoBean>((resolve) => {
    const u = new UserInfoBean()
    u.carVin = '' // mock：默认无车 → 走绑车；可改为非空测试直进首页
    u.carId = ''
    u.user.userName = 'mockUser'
    resolve(u)
  })
}

export function mockRegister(req: RegisterReq): Promise<IResult> {
  return new Promise<IResult>((resolve) => {
    resolve({ code: 200, msg: 'mock 注册成功' })
  })
}

export function mockBindCar(carVin: string): Promise<IResult> {
  return new Promise<IResult>((resolve) => {
    resolve({ code: 200, msg: 'mock 绑车成功' })
  })
}
