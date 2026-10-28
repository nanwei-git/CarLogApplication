// 接口服务器地址（C2：默认直连真服务器）
export const BaseUrl: string = 'http://121.36.14.143:10001'

// 接口路径（login 与既有 LoginUrl 一致；其余按需求文档约定，待真服务器校核）
interface ApiPathMap {
  login: string
  register: string
  userInfo: string
  bindCar: string
  carInfo: string
  carState: string
  carStateChange: string
  carMove: string
  feedbackList: string
  feedbackAdd: string
  feedbackDetail: string
  feedbackDelete: string
}

export const ApiPath: ApiPathMap = {
  login: '/app/login',
  register: '/app/register',
  userInfo: '/app/user/info',
  bindCar: '/app/car/bind',
  carInfo: '/app/car/info',
  carState: '/app/car/state',
  carStateChange: '/app/car/state/change',
  carMove: '/app/car/move',
  feedbackList: '/app/feedback/list',
  feedbackAdd: '/app/feedback/add',
  feedbackDetail: '/app/feedback/detail',
  feedbackDelete: '/app/feedback/delete'
}

// C2：false 直连真服务器；true 走本地 mock
// 当前置 true：真服务器 /app/register 返回业务码 401（后端鉴权未放行），先在模拟器验收 UI；
// 待后端放行 /app/** 后改回 false 即可直连
export const USE_MOCK: boolean = true

// 兼容既有 LoginPage 的常量
export const LoginUrl: string = BaseUrl + ApiPath.login
