// 本地 mock（USE_MOCK=true 时启用）；字段与真接口返回一致，便于离线验收 UI
import { IResult } from '../model/IResult'
import { UserInfoBean } from '../model/UserInfoBean'
import { RegisterReq } from '../model/ApiReq'
import { CarInfoBean } from '../model/CarInfoBean'
import { CarStat } from '../model/CarStateBean'
import { CarStateChange } from '../model/ApiReq'
import { Feedback, FeedBackListBean } from '../model/FeedBackBean'
import {
  SWITCH_ON,
  SWITCH_OFF,
  TEMP_DEFAULT,
  MOCK_CAR_ID,
  FEEDBACK_UNREAD,
  FEEDBACK_READ,
  DEL_NORMAL
} from '../constants/Constants'

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

// 车辆移动（接口 4.8）
export function mockMoveCar(direction: string): Promise<IResult> {
  return new Promise<IResult>((resolve) => {
    resolve({ code: 200, msg: 'mock 移动指令已下发：' + direction })
  })
}

// ========== 反馈（接口 4.9.1–4.9.4）==========
let mockFeedbacks: Feedback[] = []

function initFeedbacks(): void {
  mockFeedbacks = []
  for (let i: number = 1; i <= 12; i++) {
    const f: Feedback = new Feedback()
    f.id = i.toString()
    f.userId = '1'
    f.userName = 'yqh'
    f.nickName = '杨庆鸿'
    f.content = '第 ' + i + ' 条反馈：车机在低温启动时响应较慢，希望优化。'
    f.status = i % 2 === 0 ? FEEDBACK_READ : FEEDBACK_UNREAD
    f.delFlag = DEL_NORMAL
    f.createTime = '2026-10-' + (i < 10 ? '0' + i : i.toString()) + ' 10:00'
    f.reply = i % 3 === 0 ? '感谢反馈，工程师已跟进处理。' : ''
    mockFeedbacks.push(f)
  }
}

export function mockGetFeedbackList(pageNum: number, pageSize: number): Promise<FeedBackListBean> {
  return new Promise<FeedBackListBean>((resolve) => {
    if (mockFeedbacks.length === 0) {
      initFeedbacks()
    }
    const bean: FeedBackListBean = new FeedBackListBean()
    bean.code = 200
    bean.total = mockFeedbacks.length
    const start: number = (pageNum - 1) * pageSize
    for (let i: number = start; i < start + pageSize && i < mockFeedbacks.length; i++) {
      bean.rows.push(mockFeedbacks[i])
    }
    resolve(bean)
  })
}

export function mockAddFeedback(content: string): Promise<IResult> {
  return new Promise<IResult>((resolve) => {
    if (mockFeedbacks.length === 0) {
      initFeedbacks()
    }
    const f: Feedback = new Feedback()
    f.id = (mockFeedbacks.length + 1).toString() + '-' + Date.now().toString()
    f.userId = '1'
    f.userName = 'yqh'
    f.nickName = '杨庆鸿'
    f.content = content
    f.status = FEEDBACK_UNREAD
    f.delFlag = DEL_NORMAL
    f.createTime = '2026-10-28 12:00'
    f.reply = ''
    mockFeedbacks.unshift(f)
    resolve({ code: 200, msg: 'mock 反馈提交成功' })
  })
}

export function mockGetFeedbackDetail(id: string): Promise<Feedback> {
  return new Promise<Feedback>((resolve) => {
    for (let i: number = 0; i < mockFeedbacks.length; i++) {
      if (mockFeedbacks[i].id === id) {
        resolve(mockFeedbacks[i])
        return
      }
    }
    resolve(new Feedback())
  })
}

export function mockDeleteFeedback(id: string): Promise<IResult> {
  return new Promise<IResult>((resolve) => {
    const next: Feedback[] = []
    for (let i: number = 0; i < mockFeedbacks.length; i++) {
      if (mockFeedbacks[i].id !== id) {
        next.push(mockFeedbacks[i])
      }
    }
    mockFeedbacks = next
    resolve({ code: 200, msg: 'mock 删除成功' })
  })
}
