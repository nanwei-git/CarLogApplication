// 车辆接口函数（4.5 车辆信息 / 4.6 车辆状态 / 4.7 状态变更 / 4.8 移动）
import { post } from '../common/utils/RequestUtil'
import { ApiPath, USE_MOCK } from '../common/constants/HttpApi'
import { IResult } from '../model/IResult'
import { CarInfoBean, parseCarInfo } from '../model/CarInfoBean'
import { CarStat, parseCarStat } from '../model/CarStateBean'
import { OperationLog, parseCarLogs } from '../model/CarLogBean'
import { CarInfoReq, CarStateChange, CarMoveReq } from '../model/ApiReq'
import { getCarId, getCarVin } from '../common/utils/StorageUtils'
import { mockGetCarInfo, mockGetCarState, mockChangeCarState, mockMoveCar, mockGetCarLogs } from '../common/utils/MockData'

// 4.5 车辆管理信息（名称/续航/电量/更新时间）
export function getCarInfo(): Promise<CarInfoBean> {
  if (USE_MOCK) {
    return mockGetCarInfo()
  }
  const req: CarInfoReq = { carId: getCarId() }
  return post(ApiPath.carInfo, req).then((res: IResult) => parseCarInfo(res.data as ESObject))
}

// 4.6 车辆状态（门/灯/空调/循环/除雾/温度）
export function getCarState(): Promise<CarStat> {
  if (USE_MOCK) {
    return mockGetCarState()
  }
  const req: CarInfoReq = { carId: getCarId() }
  return post(ApiPath.carState, req).then((res: IResult) => parseCarStat(res.data as ESObject))
}

// 4.7 变更车辆状态：只传变更字段，成功后由调用方重新 getCarState 回写刷新
export function changeCarState(change: CarStateChange): Promise<IResult> {
  if (change.carVin === '') {
    change.carVin = getCarVin()
  }
  if (USE_MOCK) {
    return mockChangeCarState(change)
  }
  return post(ApiPath.carStateChange, change)
}

// 4.8 车辆移动：direction = front/back/left/right，stop 表示停车
export function moveCar(direction: string): Promise<IResult> {
  if (USE_MOCK) {
    return mockMoveCar(direction)
  }
  const req: CarMoveReq = { carVin: getCarVin(), direction: direction }
  return post(ApiPath.carMove, req)
}

// 车辆操作日志（首页「信息」页）：目前本地生成（SPEC 无对应接口，预留解析与请求位）
export function getCarLogs(): Promise<OperationLog[]> {
  return mockGetCarLogs()
}
