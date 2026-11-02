// 统一 HTTP 封装（POST/GET/PUT/DELETE）：带 Authorization、判 401 自动清登录回登录页（KT7/KT10）
// 按《鸿蒙智能座舱系统接口文档V1.1》整理：除登录/注册外，均需 Bearer token；
// 响应对信封不统一（getInfo/logList 字段在顶层，carInfo/carState/feedback 在 data 内），由各 viewmodel 自行解析。
import { http } from '@kit.NetworkKit'
import { router, promptAction } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { BaseUrl } from '../constants/HttpApi'
import { clearSession } from './StorageUtils'
import { IResult } from '../../model/IResult'

function currentToken(): string {
  return (AppStorage.get('token') as string) ?? ''
}

function buildHeaders(): Record<string, string> {
  // 若依类后端要求 "Bearer <token>"，未登录时不带该请求头（避免空值触发鉴权失败）
  const headers: Record<string, string> = { 'Content-Type': 'application/json' }
  const token: string = currentToken()
  if (token !== '') {
    headers['Authorization'] = 'Bearer ' + token
  }
  return headers
}

// 统一请求核心；HTTP 401 自动清登录并跳登录页
function doRequest(method: http.RequestMethod, path: string, body?: Object): Promise<IResult> {
  return new Promise<IResult>((resolve, reject) => {
    let httpRequest = http.createHttp()
    const url: string = BaseUrl + path
    const start: number = Date.now()
    const headers: Record<string, string> = buildHeaders()
    const extraData: string | undefined = body !== undefined ? JSON.stringify(body) : undefined
    hilog.info(0x0001, 'yqhHttp', '%{public}s %{public}s body=%{public}s', method.toString(), url, extraData ?? '')
    httpRequest.request(url, {
      method: method,
      header: headers,
      extraData: extraData
    }, (err, data) => {
      httpRequest.destroy()
      if (err) {
        hilog.error(0x0001, 'yqhHttp', '%{public}s %{public}s failed: %{public}s', method.toString(), url, JSON.stringify(err))
        reject(err)
        return
      }
      hilog.info(0x0001, 'yqhHttp', '%{public}s %{public}s code=%{public}d cost=%{public}dms result=%{public}s',
        method.toString(), url, data.responseCode, Date.now() - start, (data.result as string) ?? '')
      if (data.responseCode === 401) {
        clearSession()
        promptAction.showToast({ message: '登录已过期，请重新登录', duration: 2000 })
        router.replaceUrl({ url: 'pages/yqhLogin' })
        reject(new Error('401'))
        return
      }
      if (data.responseCode === http.ResponseCode.OK) {
        const res = JSON.parse(data.result as string) as IResult
        if (res.code === 401) {
          // 业务码 401：后端鉴权未放行该路径（非 HTTP 401），记录原文便于排查
          hilog.error(0x0001, 'yqhHttp', 'business 401 on %{public}s: %{public}s', url, res.msg)
        }
        resolve(res)
      } else {
        reject(new Error('responseCode: ' + data.responseCode))
      }
    })
  })
}

export function post(path: string, body?: Object): Promise<IResult> {
  return doRequest(http.RequestMethod.POST, path, body)
}

export function get(path: string): Promise<IResult> {
  return doRequest(http.RequestMethod.GET, path)
}

export function put(path: string, body?: Object): Promise<IResult> {
  return doRequest(http.RequestMethod.PUT, path, body)
}

export function del(path: string): Promise<IResult> {
  return doRequest(http.RequestMethod.DELETE, path)
}
