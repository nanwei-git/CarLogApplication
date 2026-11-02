// 接口服务器地址（C2：默认直连真服务器）
export const BaseUrl: string = 'http://121.36.14.143:10001'

// 接口路径（依据《鸿蒙智能座舱系统接口文档V1.1》）
// 说明：带 {} 的为路径参数，由各 viewmodel 据 StorageUtils 的 carId/carVin 代入。
interface ApiPathMap {
  login: string               // POST  /app/login
  register: string            // POST  /system/user/register
  userInfo: string            // GET   /getInfo
  bindCar: string             // POST  /cockpit/info/bindCarVin
  carInfo: string             // GET   /cockpit/info/{id}
  carState: string            // GET   /cockpit/state/{carVin}
  carStateChange: string      // PUT   /cockpit/state
  carControlDoor: string      // POST  /cockpit/control/door
  carControlLight: string     // POST  /cockpit/control/light
  carControlStop: string      // POST  /cockpit/control/stop/{carId}
  carControlRight: string     // POST  /cockpit/control/right/{carId}
  carControlLeft: string      // POST  /cockpit/control/left/{carId}
  carControlMove: string      // POST  /cockpit/control/move/{carId}
  carControlBack: string      // POST  /cockpit/control/back/{carId}
  feedbackList: string        // GET   /cockpit/feedback/backList
  feedbackAdd: string         // POST  /cockpit/feedback/add
  feedbackDetail: string      // GET   /cockpit/feedback/{id}
  feedbackDelete: string      // DELETE /cockpit/feedback/{ids}
  logList: string            // GET   /cockpit/log/list
  logDelete: string          // DELETE /cockpit/log/{ids}
  mallList: string           // 预留（商城未提供接口）
}

export const ApiPath: ApiPathMap = {
  login: '/app/login',
  register: '/system/user/register',
  userInfo: '/getInfo',
  bindCar: '/cockpit/info/bindCarVin',
  carInfo: '/cockpit/info/{id}',
  carState: '/cockpit/state/{carVin}',
  carStateChange: '/cockpit/state',
  carControlDoor: '/cockpit/control/door',
  carControlLight: '/cockpit/control/light',
  carControlStop: '/cockpit/control/stop/{carId}',
  carControlRight: '/cockpit/control/right/{carId}',
  carControlLeft: '/cockpit/control/left/{carId}',
  carControlMove: '/cockpit/control/move/{carId}',
  carControlBack: '/cockpit/control/back/{carId}',
  feedbackList: '/cockpit/feedback/backList',
  feedbackAdd: '/cockpit/feedback/add',
  feedbackDetail: '/cockpit/feedback/{id}',
  feedbackDelete: '/cockpit/feedback/{ids}',
  logList: '/cockpit/log/list',
  logDelete: '/cockpit/log/{ids}',
  mallList: '/mall/list'
}

// C2：false 直连真服务器；true 走本地 mock
// 按需求「整套 app 都直连真服务器」，全量置 false
export const USE_MOCK: boolean = false

// 兼容既有 LoginPage 的常量
export const LoginUrl: string = BaseUrl + ApiPath.login
