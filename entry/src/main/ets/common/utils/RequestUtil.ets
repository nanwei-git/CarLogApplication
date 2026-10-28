// 统一 HTTP（POST）封装：带 Authorization、判 401 自动清登录回登录页（KT7/KT10）
import { http } from '@kit.NetworkKit'
import { router, promptAction } from '@kit.ArkUI'
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
    httpRequest.request(BaseUrl + path, {
      method: http.RequestMethod.POST,
      header: {
        'Content-Type': 'application/json',
        'Authorization': currentToken()
      },
      extraData: JSON.stringify(body)
    }, (err, data) => {
      httpRequest.destroy()
      if (err) {
        reject(err)
        return
      }
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
