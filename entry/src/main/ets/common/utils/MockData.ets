// 本地 mock（USE_MOCK=true 时启用）；字段与真接口返回一致，便于离线验收 UI
import { IResult } from '../model/IResult'
import { UserInfoBean } from '../model/UserInfoBean'
import { RegisterReq } from '../model/ApiReq'
import { CarInfoBean } from '../model/CarInfoBean'

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

// 车辆信息（接口 4.5）：与真接口字段一致，便于离线验收 UI
export function mockGetCarInfo(): Promise<CarInfoBean> {
  return new Promise<CarInfoBean>((resolve) => {
    const bean: CarInfoBean = new CarInfoBean()
    bean.id = '1'
    bean.carName = '小米SU7'
    bean.brand = '小米'
    bean.carVin = '00661718330'
    bean.batteryPower.power = '62.5'
    bean.batteryPower.percent = 78
    bean.enduranceMileage = '520'
    bean.batteryCapacity = '73.6'
    bean.nominalVoltage = '400'
    bean.horsePower = '299'
    bean.maxPower = '220'
    bean.maxTorque = '400'
    bean.carSize = '4997×1963×1455'
    bean.wheelBase = '3000'
    bean.totalTripNum = 128
    bean.totalTripMile = '8632'
    bean.createYm = '2026-10'
    resolve(bean)
  })
}
