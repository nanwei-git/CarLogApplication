// 统一 HTTP（POST）封装：带 Authorization、判 401 自动清登录回登录页（KT7/KT10）
import { http } from '@kit.NetworkKit'
import { router, promptAction } from '@kit.ArkUI'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { BaseUrl } from '../constants/HttpApi'
import { clearSession } from './StorageUtils'
import { IResult } from '../model/IResult'

function currentToken(): string {
  return (AppStorage.get('token') as string) ?? ''
}

// 统一 POST；返回解析后的 IResult。HTTP 401 自动清登录并跳登录页。
export function post(path: string, body: Object): Promise<IResult> {
  return new Promise<IResult>((resolve, reject) => {
    let httpRequest = http.createHttp()
    const url: string = BaseUrl + path
    const start: number = Date.now()
    // 模拟器联调用：HiLog 过滤 "yqhHttp" 即可看到每次请求的方法/耗时/响应码/报文
    hilog.info(0x0001, 'yqhHttp', 'POST %{public}s body=%{public}s', url, JSON.stringify(body))
    httpRequest.request(url, {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        'Authorization': currentToken()
      },
      extraData: JSON.stringify(body)
    }, (err, data) => {
      httpRequest.destroy()
      if (err) {
        hilog.error(0x0001, 'yqhHttp', 'POST %{public}s failed: %{public}s', url, JSON.stringify(err))
        reject(err)
        return
      }
      hilog.info(0x0001, 'yqhHttp', 'POST %{public}s code=%{public}d cost=%{public}dms result=%{public}s',
        url, data.responseCode, Date.now() - start, (data.result as string) ?? '')
      if (data.responseCode === 401) {
        clearSession()
        promptAction.showToast({ message: '登录已过期，请重新登录', duration: 2000 })
        router.replaceUrl({ url: 'pages/yqhcar/yqhLogin' })
        reject(new Error('401'))
        return
      }
      if (data.responseCode === http.ResponseCode.OK) {
        const res = JSON.parse(data.result as string) as IResult
        resolve(res)
      } else {
        reject(new Error('responseCode: ' + data.responseCode))
      }
    })
  })
}
