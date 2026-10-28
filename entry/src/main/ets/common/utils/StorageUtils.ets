// 全局状态键 + 持久化（遵循既有 PersistentStorage 范式，KT10）
// 底层即为"用户首选项"，满足课程 KT10 要求。

export const StorageKeys = {
  isLogin: 'isLogin',
  token: 'token',
  userId: 'userId',
  userName: 'userName',
  carVin: 'carVin',
  carId: 'carId',
  avatar: 'avatar'
}

// 模块加载即把下列键挂到持久化（重启后自动回填）
PersistentStorage.persistProp(StorageKeys.isLogin, false)
PersistentStorage.persistProp(StorageKeys.token, '')
PersistentStorage.persistProp(StorageKeys.userId, '')
PersistentStorage.persistProp(StorageKeys.userName, '')
PersistentStorage.persistProp(StorageKeys.carVin, '')
PersistentStorage.persistProp(StorageKeys.carId, '')
PersistentStorage.persistProp(StorageKeys.avatar, '')

export function getIsLogin(): boolean {
  return AppStorage.get(StorageKeys.isLogin) as boolean
}

export function setIsLogin(v: boolean): void {
  AppStorage.setOrCreate(StorageKeys.isLogin, v)
}

// 退出/清登录态：清掉本次会话的 token/用户/车辆，isLogin 置 false
export function clearSession(): void {
  setIsLogin(false)
  AppStorage.setOrCreate(StorageKeys.token, '')
  AppStorage.setOrCreate(StorageKeys.userId, '')
  AppStorage.setOrCreate(StorageKeys.userName, '')
  AppStorage.setOrCreate(StorageKeys.carVin, '')
  AppStorage.setOrCreate(StorageKeys.carId, '')
  AppStorage.setOrCreate(StorageKeys.avatar, '')
}

// 各字段存取（token/user/car）封装，统一走 AppStorage
export function setToken(v: string): void {
  AppStorage.setOrCreate(StorageKeys.token, v)
}
export function getToken(): string {
  return (AppStorage.get(StorageKeys.token) as string) ?? ''
}
export function setUserName(v: string): void {
  AppStorage.setOrCreate(StorageKeys.userName, v)
}
export function getUserName(): string {
  return (AppStorage.get(StorageKeys.userName) as string) ?? ''
}
export function setUserId(v: string): void {
  AppStorage.setOrCreate(StorageKeys.userId, v)
}
export function setCarVin(v: string): void {
  AppStorage.setOrCreate(StorageKeys.carVin, v)
}
export function getCarVin(): string {
  return (AppStorage.get(StorageKeys.carVin) as string) ?? ''
}
export function setCarId(v: string): void {
  AppStorage.setOrCreate(StorageKeys.carId, v)
}
export function setAvatar(v: string): void {
  AppStorage.setOrCreate(StorageKeys.avatar, v)
}
