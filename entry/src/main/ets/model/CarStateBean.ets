// 车辆状态（接口 4.6 data）+ 状态变更请求体（接口 4.7）；字段与 SPEC §4 一致
export class CarStat {
  carId: string = ''
  carVin: string = ''
  door: string = '' // 车门：'1' 开 / '0' 关
  light: string = '' // 车灯：'1' 开 / '0' 关
  temperature: string = '' // 车内温度
  windLevel: string = '' // 风量等级
  circulate: string = '0' // 内外循环：'1' 内循环 / '0' 外循环
  setTemp: string = '' // 空调设定温度
  acBtn: string = '1' // 空调开关
  clearFog: string = '0' // 除雾
  fanState: string = '' // 制冷/送风
}

export class CarStateBean {
  code: number = 0
  msg: string = ''
  data: CarStat = new CarStat()
}

// 状态变更请求体 CarStateChange 统一声明在 model/ApiReq.ets（避免同名双声明）

// 服务器 JSON → CarStat：逐字段兜底
export function parseCarStat(data: ESObject): CarStat {
  const stat: CarStat = new CarStat()
  if (data === undefined || data === null) {
    return stat
  }
  const d: ESObject = data as ESObject
  stat.carId = (d['carId'] as string) ?? ''
  stat.carVin = (d['carVin'] as string) ?? ''
  stat.door = (d['door'] as string) ?? ''
  stat.light = (d['light'] as string) ?? ''
  stat.temperature = (d['temperature'] as string) ?? ''
  stat.windLevel = (d['windLevel'] as string) ?? ''
  stat.circulate = (d['circulate'] as string) ?? '0'
  stat.setTemp = (d['setTemp'] as string) ?? ''
  stat.acBtn = (d['acBtn'] as string) ?? '1'
  stat.clearFog = (d['clearFog'] as string) ?? '0'
  stat.fanState = (d['fanState'] as string) ?? ''
  return stat
}
