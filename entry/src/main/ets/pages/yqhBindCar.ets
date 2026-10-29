// 绑车/换绑页（M3）：VIN 格式校验 → bindCarByVin → 存 carVin → 回首页（C3：carVin 单判）
// 入口①：登录后无 carVin 强制进此页；入口②：我的页"换绑车辆"（from=mine，绑定后 back）
import { router, promptAction } from '@kit.ArkUI'
import { COLORS, BG_GRADIENT } from '../common/style/Style'
import { YqhGlassCard } from '../views/yqhGlassCard'
import { YqhButton } from '../views/yqhButton'
import { bindCarByVin } from '../viewmodel/auth'
import { setCarVin, getCarVin, clearSession } from '../common/utils/StorageUtils'
import { IResult } from '../model/IResult'
import { VIN_PATTERN, VIN_MIN_LEN, VIN_MAX_LEN, TOAST_MS } from '../common/constants/Constants'

@Entry
@Component
struct YqhBindCar {
  @State vin: string = ''
  @State fromMine: boolean = false // 我的页换绑入口：绑完直接 back

  aboutToAppear(): void {
    // 1、换绑入口带 from=mine；否则为登录后强制绑车
    const p = router.getParams()
    if (p) {
      const from = (p as Record<string, string>)['from']
      this.fromMine = from === 'mine'
    }
    // 2、已绑车时回填原 VIN，便于核对/覆盖
    const old = getCarVin()
    if (old !== '') {
      this.vin = old
    }
  }

  // VIN 校验：4–17 位，仅字母/数字/短横线
  private isVinValid(v: string): boolean {
    if (v.length < VIN_MIN_LEN || v.length > VIN_MAX_LEN) {
      return false
    }
    return new RegExp(VIN_PATTERN).test(v)
  }

  private toast(msg: string): void {
    promptAction.showToast({ message: msg, duration: TOAST_MS })
  }

  private doBind(): void {
    const vin = this.vin.trim()
    if (vin === '') {
      this.toast('请输入车辆 VIN')
      return
    }
    if (!this.isVinValid(vin)) {
      this.toast('VIN 需为 ' + VIN_MIN_LEN + '-' + VIN_MAX_LEN + ' 位字母、数字或短横线')
      return
    }
    bindCarByVin(vin)
      .then((res: IResult) => {
        if (res.code === 200 || res.code === 0) {
          setCarVin(vin)
          this.toast('绑定成功')
          if (this.fromMine) {
            router.back()
          } else {
            router.replaceUrl({ url: 'pages/yqhIndex' })
          }
        } else {
          // 账号过期/服务器错误：直接提示服务器返回信息
          this.toast(res.msg || '绑定失败')
        }
      })
      .catch(() => {
        this.toast('网络异常，请稍后重试')
      })
  }

  build() {
    Stack() {
      Column() {
        YqhGlassCard({ pad: 24 }) {
          Column({ space: 16 }) {
            Text(this.fromMine ? '换绑车辆' : '绑定车辆')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.ink)
            Text(this.fromMine ? '输入新的车架号以更换绑定车辆' : '首次使用请先绑定车辆，未绑定无法使用车控功能')
              .fontSize(13)
              .fontColor(COLORS.inkSub)
            TextInput({ placeholder: '请输入车辆 VIN', text: this.vin })
              .width('100%')
              .height(44)
              .backgroundColor(COLORS.card)
              .borderRadius(10)
              .onChange((v: string) => {
                this.vin = v
              })
            Text('VIN 为 4-17 位字母/数字/短横线，台架调试请用 4494356c')
              .fontSize(12)
              .fontColor(COLORS.inkSub)
            YqhButton({
              text: '确认绑定',
              primary: true,
              onBtnClick: () => this.doBind()
            })
            YqhButton({
              text: '退出登录',
              primary: false,
              onBtnClick: () => {
                clearSession()
                router.replaceUrl({ url: 'pages/yqhLogin' })
              }
            })
          }
        }
      }
      .width('100%')
      .height('100%')
      .padding(24)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .linearGradient(BG_GRADIENT)
  }
}
