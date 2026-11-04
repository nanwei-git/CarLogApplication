// 全局状态键 + 持久化（KT10：用户首选项）
// 真正实现：用 @ohos.data.preferences（用户首选项）落盘，AppStorage 仅作内存响应式缓存层。
// 页面/组件仍通过 @StorageProp/@StorageLink 读 AppStorage；写入统一走本文件的 setXxx，同步双写用户首选项。

import { preferences } from '@kit.ArkData'

interface StorageKeyMap {
  isLogin: string
  token: string
  userId: string
  userName: string
  carVin: string
  carId: string
  avatar: string
  fontScale: string // 设置：字号缩放（KT10）
  darkMode: string // 设置：深色主题（KT10）
}

export const StorageKeys: StorageKeyMap = {
  isLogin: 'isLogin',
  token: 'token',
  userId: 'userId',
  userName: 'userName',
  carVin: 'carVin',
  carId: 'carId',
  avatar: 'avatar',
  fontScale: 'fontScale',
  darkMode: 'darkMode'
}

// 各键默认值（首次启动或用户首选项无记录时使用）；用元组数组避免 ArkTS 的动态属性索引限制
const STORAGE_DEFAULTS: Array<[string, number | string | boolean]> = [
  [StorageKeys.isLogin, false],
  [StorageKeys.token, ''],
  [StorageKeys.userId, ''],
  [StorageKeys.userName, ''],
  [StorageKeys.carVin, ''],
  [StorageKeys.carId, ''],
  [StorageKeys.avatar, ''],
  [StorageKeys.fontScale, 1.0],
  [StorageKeys.darkMode, true]
]

// 用户首选项实例（应用级偏好存储，对应 KT10 的"用户首选项"）
let store: preferences.Preferences | null = null

// 必须在 Ability 拿到 Context 后调用一次（见 EntryAbility.onCreate）：
// 建立用户首选项实例，并把已保存的值载回 AppStorage（启动恢复）。
export function initStorage(context: Context): void {
  if (store) {
    return
  }
  store = preferences.getPreferencesSync(context, { name: 'CarLogStore' })
  for (const item of STORAGE_DEFAULTS) {
    const key = item[0]
    const def = item[1]
    const saved = store.getSync(key, def)
    AppStorage.setOrCreate(key, saved)
  }
}

// 写：内存（AppStorage，驱动 UI）+ 磁盘（用户首选项）双写
function persist(key: string, val: number | string | boolean): void {
  AppStorage.setOrCreate(key, val)
  if (store) {
    store.putSync(key, val)
    store.flush()
  }
}

export function getIsLogin(): boolean {
  return AppStorage.get(StorageKeys.isLogin) as boolean
}

export function setIsLogin(v: boolean): void {
  persist(StorageKeys.isLogin, v)
}

// 退出/清登录态：清掉本次会话的 token/用户/车辆，isLogin 置 false
export function clearSession(): void {
  setIsLogin(false)
  persist(StorageKeys.token, '')
  persist(StorageKeys.userId, '')
  persist(StorageKeys.userName, '')
  persist(StorageKeys.carVin, '')
  persist(StorageKeys.carId, '')
  persist(StorageKeys.avatar, '')
}

// 各字段存取（token/user/car）封装，统一走用户首选项 + AppStorage
export function setToken(v: string): void {
  persist(StorageKeys.token, v)
}
export function getToken(): string {
  return (AppStorage.get(StorageKeys.token) as string) ?? ''
}
export function setUserName(v: string): void {
  persist(StorageKeys.userName, v)
}
export function getUserName(): string {
  return (AppStorage.get(StorageKeys.userName) as string) ?? ''
}
export function setUserId(v: string): void {
  persist(StorageKeys.userId, v)
}
export function setCarVin(v: string): void {
  persist(StorageKeys.carVin, v)
}
export function getCarVin(): string {
  return (AppStorage.get(StorageKeys.carVin) as string) ?? ''
}
export function setCarId(v: string): void {
  persist(StorageKeys.carId, v)
}
export function getCarId(): string {
  return (AppStorage.get(StorageKeys.carId) as string) ?? ''
}
export function setAvatar(v: string): void {
  persist(StorageKeys.avatar, v)
}

// 设置项（字号 / 主题，KT10 持久化）
export function setFontScale(v: number): void {
  persist(StorageKeys.fontScale, v)
}
export function getFontScale(): number {
  return (AppStorage.get(StorageKeys.fontScale) as number) ?? 1.0
}
export function setDarkMode(v: boolean): void {
  persist(StorageKeys.darkMode, v)
}
export function getDarkMode(): boolean {
  return (AppStorage.get(StorageKeys.darkMode) as boolean) ?? true
}
