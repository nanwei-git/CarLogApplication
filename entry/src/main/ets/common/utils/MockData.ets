// 本地 mock（USE_MOCK=true 时启用）；字段与真接口返回一致，便于离线验收 UI
import { IResult } from '../../model/IResult'
import { UserInfoBean } from '../../model/UserInfoBean'
import { RegisterReq } from '../../model/ApiReq'
import { CarInfoBean } from '../../model/CarInfoBean'
import { CarStat } from '../../model/CarStateBean'
import { CarStateChange } from '../../model/ApiReq'
import { OperationLog } from '../../model/CarLogBean'
import { Feedback, FeedBackListBean } from '../../model/FeedBackBean'
import { MallProduct, Review } from '../../model/MallBean'
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

// 车辆操作日志（首页「信息」页）：以 SU7 视角预置若干条本地记录
export function mockGetCarLogs(): Promise<OperationLog[]> {
  return new Promise<OperationLog[]>((resolve) => {
    const logs: OperationLog[] = []
    const add = (id: string, title: string, desc: string, time: string): void => {
      const log: OperationLog = new OperationLog()
      log.id = id
      log.title = title
      log.desc = desc
      log.time = time
      logs.push(log)
    }
    add('8', '车辆启动', '完成系统自检，电量 78%', '2026-10-28 08:12')
    add('7', '车门上锁', '四门及尾门已上锁', '2026-10-28 08:11')
    add('6', '近光灯开启', '夜间模式已开启', '2026-10-27 19:40')
    add('5', '空调启动', '设定温度 26℃，制冷模式', '2026-10-27 19:38')
    add('4', '车辆前移', '低速前进约 2.3 m', '2026-10-27 18:05')
    add('3', '绑定车辆', '已绑定 VIN 00661718330', '2026-10-26 21:30')
    add('2', '空调关闭', '空调系统已关闭', '2026-10-26 12:10')
    add('1', '车辆移动', '向右微调车位', '2026-10-25 17:22')
    resolve(logs)
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

// ========== 车主商城（自定义功能 C4）==========
let mockMalls: MallProduct[] = []

function addReview(p: MallProduct, user: string, rating: number, content: string, time: string): void {
  const r: Review = new Review()
  r.user = user
  r.rating = rating
  r.content = content
  r.time = time
  p.reviews.push(r)
}

function initMalls(): void {
  mockMalls = []
  const p1: MallProduct = new MallProduct()
  p1.id = '1'
  p1.name = '车载智能香薰（薄荷青）'
  p1.price = 129
  p1.originalPrice = 169
  p1.discount = '满 199 减 30'
  p1.desc = '专属香型，适配出风口，续航 60 天，随车启停。'
  p1.sales = 862
  p1.tag = '车主专享'
  addReview(p1, '车友_小李', 5, '味道清爽不刺鼻，装上去很搭内饰。', '2026-10-02')
  addReview(p1, '车友_阿May', 4, '香味持久，就是替换芯略贵。', '2026-10-11')
  mockMalls.push(p1)

  const p2: MallProduct = new MallProduct()
  p2.id = '2'
  p2.name = 'TPE 全包围脚垫'
  p2.price = 299
  p2.originalPrice = 399
  p2.discount = '限时 7.5 折'
  p2.desc = '环保无异味，专车定制版型，易清洗不积水。'
  p2.sales = 1240
  p2.tag = '热卖'
  addReview(p2, '车友_老王', 5, '版型贴合，边缘不翘，值得。', '2026-09-28')
  mockMalls.push(p2)

  const p3: MallProduct = new MallProduct()
  p3.id = '3'
  p3.name = '车载无线充电支架'
  p3.price = 89
  p3.originalPrice = 119
  p3.discount = '新人立减 10'
  p3.desc = '15W 快充，重力联动夹紧，单手取放。'
  p3.sales = 2033
  p3.tag = '爆款'
  addReview(p3, '车友_阿俊', 4, '充电稳定，夏天略微发热。', '2026-10-05')
  addReview(p3, '车友_娜娜', 5, '导航时充电很方便，不挡视线。', '2026-10-19')
  mockMalls.push(p3)

  const p4: MallProduct = new MallProduct()
  p4.id = '4'
  p4.name = '后备箱收纳箱（折叠）'
  p4.price = 69
  p4.originalPrice = 99
  p4.discount = '两件 8 折'
  p4.desc = '40L 大容量，防滑底部，不用时可折叠收纳。'
  p4.sales = 517
  p4.tag = '实用'
  addReview(p4, '车友_大刘', 4, '容量够大，折叠后不占地方。', '2026-10-08')
  mockMalls.push(p4)

  const p5: MallProduct = new MallProduct()
  p5.id = '5'
  p5.name = '高清行车记录仪'
  p5.price = 459
  p5.originalPrice = 599
  p5.discount = '晒单返 30'
  p5.desc = '2K 夜视，停车监控，手机直连查看。'
  p5.sales = 326
  p5.tag = '安全'
  addReview(p5, '车友_陈师傅', 5, '夜视清晰，安装也简单。', '2026-10-15')
  mockMalls.push(p5)

  const p6: MallProduct = new MallProduct()
  p6.id = '6'
  p6.name = '车窗遮阳伞（前挡）'
  p6.price = 49
  p6.originalPrice = 79
  p6.discount = '夏季特惠'
  p6.desc = '钛银涂层隔热，一秒开合，收纳袋随车携带。'
  p6.sales = 1580
  p6.tag = '夏季必买'
  addReview(p6, '车友_小林', 4, '隔热效果明显，就是撑开要练练。', '2026-10-21')
  mockMalls.push(p6)
}

export function mockGetMallList(): Promise<MallProduct[]> {
  return new Promise<MallProduct[]>((resolve) => {
    if (mockMalls.length === 0) {
      initMalls()
    }
    resolve(mockMalls)
  })
}

export function mockToggleFav(id: string): Promise<boolean> {
  return new Promise<boolean>((resolve) => {
    for (let i: number = 0; i < mockMalls.length; i++) {
      if (mockMalls[i].id === id) {
        mockMalls[i].fav = !mockMalls[i].fav
        resolve(mockMalls[i].fav)
        return
      }
    }
    resolve(false)
  })
}
