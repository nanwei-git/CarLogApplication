// 接口服务器地址（C2：默认直连真服务器）
export const BaseUrl: string = 'http://121.36.14.143:10001'

// 接口路径（login 与既有 LoginUrl 一致；其余按需求文档约定，待真服务器校核）
export const ApiPath = {
  login: '/app/login',
  register: '/app/register',
  userInfo: '/app/user/info',
  bindCar: '/app/car/bind'
}

// C2：默认 false 直连真服务器；置 true 走本地 mock（便于无后端验收 UI）
export const USE_MOCK: boolean = false

// 兼容既有 LoginPage 的常量
export const LoginUrl: string = BaseUrl + ApiPath.login
