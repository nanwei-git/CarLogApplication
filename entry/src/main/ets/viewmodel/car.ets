// 车辆接口函数（4.5 车辆信息 / 4.6 车辆状态 / 4.7 状态变更 / 4.8 控制 / 4.10 日志）
// 全量直连真服务器（USE_MOCK=false）；实现按《鸿蒙智能座舱系统接口文档V1.1》
import { post, get, put } from '../common/utils/RequestUtil'
import { ApiPath, USE_MOCK } from '../common/constants/HttpApi'
import { IResult } from '../model/IResult'
import { CarInfoBean, parseCarInfo } from '../model/CarInfoBean'
import { CarStat, parseCarStat } from '../model/CarStateBean'
import { OperationLog, parseCarLogs } from '../model/CarLogBean'
import { CarStateChange, CarControlReq } from '../model/ApiReq'
import { getCarId, getCarVin } from '../common/utils/StorageUtils'
import {
  mockGetCarInfo, mockGetCarState, mockChangeCarState, mockGetCarLogs
} from '../common/utils/MockData'

// 4.5 车辆管理信息（GET /cockpit/info/{id}，id=车辆id）
export function getCarInfo(): Promise<CarInfoBean> {
  if (USE_MOCK) {
    return mockGetCarInfo()
  }
  const carId: string = getCarId()
  return get(ApiPath.carInfo.replace('{id}', carId))
    .then((res: IResult) => parseCarInfo(res.data as ESObject))
}

// 4.6 车辆状态（GET /cockpit/state/{carVin}）
export function getCarState(): Promise<CarStat> {
  if (USE_MOCK) {
    return mockGetCarState()
  }
  return get(ApiPath.carState.replace('{carVin}', getCarVin()))
    .then((res: IResult) => parseCarStat(res.data as ESObject))
}

// 4.7 修改状态（PUT /cockpit/state）：空调开关/温度/循环/除雾/风量/车门/车灯等
export function changeCarState(change: CarStateChange): Promise<IResult> {
  if (change.carVin === '') {
    change.carVin = getCarVin()
  }
  if (USE_MOCK) {
    return mockChangeCarState(change)
  }
  return put(ApiPath.carStateChange, change)
}

// 4.8.1 车门控制（POST /cockpit/control/door）
export function controlDoor(carId: string, door: string): Promise<IResult> {
  const req: CarControlReq = new CarControlReq()
  req.carId = carId
  req.door = door
  return post(ApiPath.carControlDoor, req)
}

// 4.8.2 车灯控制（POST /cockpit/control/light）
export function controlLight(carId: string, light: string): Promise<IResult> {
  const req: CarControlReq = new CarControlReq()
  req.carId = carId
  req.light = light
  return post(ApiPath.carControlLight, req)
}

// 4.8.3~4.8.7 车辆移动（POST /cockpit/control/{stop|right|left|move|back}/{carId}）
export function moveCar(direction: string): Promise<IResult> {
  const carId: string = getCarId()
  let path: string = ApiPath.carControlStop.replace('{carId}', carId)
  if (direction === 'front') {
    path = ApiPath.carControlMove.replace('{carId}', carId)
  } else if (direction === 'back') {
    path = ApiPath.carControlBack.replace('{carId}', carId)
  } else if (direction === 'left') {
    path = ApiPath.carControlLeft.replace('{carId}', carId)
  } else if (direction === 'right') {
    path = ApiPath.carControlRight.replace('{carId}', carId)
  }
  return post(path)
}

// 4.10 车辆操作日志（GET /cockpit/log/list：响应顶层含 total / rows）
export function getCarLogs(): Promise<OperationLog[]> {
  if (USE_MOCK) {
    return mockGetCarLogs()
  }
  const url: string = ApiPath.logList + '?pageNum=1&pageSize=20&operaContent='
  return get(url).then((res: IResult) => {
    const rows: ESObject[] = ((res as ESObject)['rows'] as ESObject[]) ?? []
    return parseCarLogs(rows)
  })
}
