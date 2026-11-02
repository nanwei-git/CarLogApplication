// 车辆管理信息（接口 4.5 data）；字段与《鸿蒙智能座舱系统接口文档V1.1》§4.5 一致
// 注意：文档中 batteryPower 为字符串（如 "999"），非对象
export class CarInfoBean {
  id: string = ''
  carName: string = ''
  brand: string = ''
  carVin: string = ''
  batteryPower: string = '' // 电池电量（字符串，如 "999"）
  enduranceMileage: string = '' // 可续航里程
  horsePower: string = ''
  maxPower: string = ''
  maxTorque: string = ''
  carSize: string = ''
  wheelBase: string = ''
  batteryCapacity: string = '' // 电池容量
  nominalVoltage: string = ''
  totalTripNum: number = 0
  totalTripMile: string = ''
  createYm: string = '' // 更新时间
}

// 服务器 JSON → Bean：逐字段兜底，避免缺字段导致 UI 显示 undefined
export function parseCarInfo(data: ESObject): CarInfoBean {
  const bean: CarInfoBean = new CarInfoBean()
  if (data === undefined || data === null) {
    return bean
  }
  const d: ESObject = data as ESObject
  bean.id = (d['id'] as string) ?? ''
  bean.carName = (d['carName'] as string) ?? ''
  bean.brand = (d['brand'] as string) ?? ''
  bean.carVin = (d['carVin'] as string) ?? ''
  bean.enduranceMileage = (d['enduranceMileage'] as string) ?? ''
  bean.horsePower = (d['horsePower'] as string) ?? ''
  bean.maxPower = (d['maxPower'] as string) ?? ''
  bean.maxTorque = (d['maxTorque'] as string) ?? ''
  bean.carSize = (d['carSize'] as string) ?? ''
  bean.wheelBase = (d['wheelBase'] as string) ?? ''
  bean.batteryCapacity = (d['batteryCapacity'] as string) ?? ''
  bean.nominalVoltage = (d['nominalVoltage'] as string) ?? ''
  bean.totalTripNum = (d['totalTripNum'] as number) ?? 0
  bean.totalTripMile = (d['totalTripMile'] as string) ?? ''
  bean.createYm = (d['createYm'] as string) ?? ''
  bean.batteryPower = (d['batteryPower'] as string) ?? ''
  return bean
}
