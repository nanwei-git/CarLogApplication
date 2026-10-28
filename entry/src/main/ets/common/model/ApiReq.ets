// 请求体类型（与 SPEC 一致）
export interface LoginReq {
  username: string
  password: string
}

export interface RegisterReq {
  nickName: string
  userName: string
  phonenumber: string
  sex: string
  avatar: string
  password: string
  roleIds: string[]
  birthDate: string
  state: string
}

export interface BindReq {
  carVin: string
}

// 无参请求体（如 /app/user/info），避免无类型对象字面量
export class EmptyReq {
}

// 车辆相关请求体（接口 4.5 车辆信息）
export interface CarInfoReq {
  carId: string
}

// 车辆移动请求体（接口 4.8）
export interface CarMoveReq {
  carVin: string
  direction: string
}

// 反馈请求体（接口 4.9.1 列表 / 4.9.2 新增 / 4.9.3 详情 / 4.9.4 删除）
export interface FeedbackPageReq {
  pageNum: number
  pageSize: number
}

export interface FeedbackAddReq {
  content: string
  status: string
}

export interface FeedbackIdReq {
  id: string
}

// 车辆状态变更请求体（接口 4.7）：接口形态同 CarStateChange，独立声明避免 UI 层反向依赖 model
export interface CarStateChange {
  carVin: string
  acBtn?: string
  circulate?: string
  clearFog?: string
  setTemp?: string
  door?: string
  light?: string
  windLevel?: string
  fanState?: string
}
