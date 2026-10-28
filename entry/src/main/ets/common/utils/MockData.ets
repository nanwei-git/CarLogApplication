// 本地 mock（USE_MOCK=true 时启用）；字段与真接口返回一致，便于离线验收 UI
import { IResult } from '../model/IResult'
import { UserInfoBean } from '../model/UserInfoBean'
import { RegisterReq } from '../model/ApiReq'
import { CarInfoBean } from '../model/CarInfoBean'
import { CarStat } from '../model/CarStateBean'
import { CarStateChange } from '../model/ApiReq'
import { SWITCH_ON, SWITCH_OFF, TEMP_DEFAULT, MOCK_CAR_ID } from '../constants/Constants'

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

// ========== 车辆状态（接口 4.6/4.7）==========
// 模块级保留一份状态，验收"操作 → 服务器变更 → 回写刷新"闭环
let mockCarStat: CarStat = new CarStat()

function copyStat(src: CarStat): CarStat {
  const c: CarStat = new CarStat()
  c.carId = src.carId
  c.carVin = src.carVin
  c.door = src.door
  c.light = src.light
  c.temperature = src.temperature
  c.windLevel = src.windLevel
  c.circulate = src.circulate
  c.setTemp = src.setTemp
  c.acBtn = src.acBtn
  c.clearFog = src.clearFog
  c.fanState = src.fanState
  return c
}

export function mockGetCarState(): Promise<CarStat> {
  return new Promise<CarStat>((resolve) => {
    if (mockCarStat.setTemp === '') {
      // 首次给一组合理初值
      mockCarStat.carId = MOCK_CAR_ID
      mockCarStat.setTemp = TEMP_DEFAULT.toString()
      mockCarStat.temperature = '26'
      mockCarStat.acBtn = SWITCH_ON
      mockCarStat.circulate = SWITCH_OFF
      mockCarStat.clearFog = SWITCH_OFF
      mockCarStat.fanState = SWITCH_ON
      mockCarStat.door = SWITCH_OFF
      mockCarStat.light = SWITCH_OFF
      mockCarStat.windLevel = '2'
    }
    resolve(copyStat(mockCarStat)) // 返回副本，避免 @State 同引用不刷新
  })
}

export function mockChangeCarState(req: CarStateChange): Promise<IResult> {
  return new Promise<IResult>((resolve) => {
    if (req.acBtn !== undefined) {
      mockCarStat.acBtn = req.acBtn
    }
    if (req.circulate !== undefined) {
      mockCarStat.circulate = req.circulate
    }
    if (req.clearFog !== undefined) {
      mockCarStat.clearFog = req.clearFog
    }
    if (req.setTemp !== undefined) {
      mockCarStat.setTemp = req.setTemp
    }
    if (req.door !== undefined) {
      mockCarStat.door = req.door
    }
    if (req.light !== undefined) {
      mockCarStat.light = req.light
    }
    if (req.windLevel !== undefined) {
      mockCarStat.windLevel = req.windLevel
    }
    if (req.fanState !== undefined) {
      mockCarStat.fanState = req.fanState
    }
    resolve({ code: 200, msg: 'mock 状态更新成功' })
  })
}
