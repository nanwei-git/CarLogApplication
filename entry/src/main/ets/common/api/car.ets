// 车辆接口函数（4.5 车辆信息 / 4.6 车辆状态 / 4.7 状态变更 / 4.8 移动）
import { post } from '../utils/RequestUtil'
import { ApiPath, USE_MOCK } from '../constants/HttpApi'
import { IResult } from '../model/IResult'
import { CarInfoBean, parseCarInfo } from '../model/CarInfoBean'
import { CarInfoReq } from '../model/ApiReq'
import { getCarId } from '../utils/StorageUtils'
import { mockGetCarInfo } from '../utils/MockData'

// 4.5 车辆管理信息（名称/续航/电量/更新时间）
export function getCarInfo(): Promise<CarInfoBean> {
  if (USE_MOCK) {
    return mockGetCarInfo()
  }
  const req: CarInfoReq = { carId: getCarId() }
  return post(ApiPath.carInfo, req).then((res: IResult) => parseCarInfo(res.data as ESObject))
}
