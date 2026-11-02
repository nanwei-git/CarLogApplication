// 首页车辆信息卡（M4，接口 4.5/4.6）：环形电量表盘 + 快捷控制（Dark Neumorphism）
import { promptAction } from '@kit.ArkUI'
import { neu } from '../../common/style/Style'
import { YqhNeuCard } from '../../common/ui/yqhNeuCard'
import { YqhNeuRing } from '../../common/ui/yqhNeuRing'
import { YqhNeuCircleButton } from '../../common/ui/yqhNeuCircleButton'
import { YqhNeuButton } from '../../common/ui/yqhNeuButton'
import { YqhNeuChip } from '../../common/ui/yqhNeuChip'
import { getCarInfo, getCarState, changeCarState } from '../../viewmodel/car'
import { CarInfoBean } from '../../model/CarInfoBean'
import { CarStat } from '../../model/CarStateBean'
import { CarStateChange } from '../../model/ApiReq'
import { IResult } from '../../model/IResult'
import { getCarVin } from '../../common/utils/StorageUtils'
import { SWITCH_ON, SWITCH_OFF, TOAST_MS } from '../../common/constants/Constants'

@Component
export struct YqhCarInfoComp {
  @StorageProp('darkMode') dark: boolean = true
  @State info: CarInfoBean = new CarInfoBean()
  @State stat: CarStat = new CarStat()
  @State loading: boolean = true
  @State busy: boolean = false

  aboutToAppear(): void {
    this.load()
  }

  private toast(msg: string): void {
    promptAction.showToast({ message: msg, duration: TOAST_MS })
  }

  private load(): void {
    this.loading = true
    Promise.all([getCarInfo(), getCarState()])
      .then((res: [CarInfoBean, CarStat]) => {
        this.info = res[0]
        this.stat = res[1]
        this.loading = false
      })
      .catch(() => {
        this.loading = false
        this.toast('车辆信息获取失败，请稍后重试')
      })
  }

  private isOn(v: string): boolean {
    return v === SWITCH_ON
  }

  private percent(): number {
    const p: number = Number(this.info.batteryPower)
    if (isNaN(p) || p < 0) {
      return 0
    }
    if (p > 100) {
      return 100
    }
    return p
  }

  // 电量环配色：充足绿 / 中等黄 / 低电红
  private batteryColor(): string {
    const p: number = this.percent()
    if (p >= 50) {
      return neu(this.dark).ok
    }
    if (p >= 20) {
      return neu(this.dark).warn
    }
    return neu(this.dark).danger
  }

  // 快捷开关：只传变更字段，成功后回写刷新
  private toggle(field: string, on: boolean): void {
    if (this.busy) {
      return
    }
    this.busy = true
    const change: CarStateChange = { carVin: getCarVin() }
    if (field === 'door') {
      change.door = on ? SWITCH_ON : SWITCH_OFF
    } else if (field === 'light') {
      change.light = on ? SWITCH_ON : SWITCH_OFF
    } else {
      change.acBtn = on ? SWITCH_ON : SWITCH_OFF
    }
    changeCarState(change)
      .then((res: IResult) => {
        this.busy = false
        if (res.code === 200 || res.code === 0) {
          this.load()
        } else {
          this.toast(res.msg || '操作失败')
        }
      })
      .catch(() => {
        this.busy = false
        this.toast('网络异常，请稍后重试')
      })
  }

  build() {
    Column({ space: 14 }) {
      if (this.loading) {
        LoadingProgress()
          .width(32)
          .height(32)
          .color(neu(this.dark).accent)
        Text('正在获取车辆状态…')
          .fontSize(13)
          .fontColor(neu(this.dark).inkSub)
      } else {
        YqhNeuCard({ pad: 20 }) {
          Column({ space: 18 }) {
            // 1、车辆身份
            Row() {
              Column({ space: 4 }) {
                Text(this.info.carName === '' ? '未绑定车辆' : this.info.carName)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(neu(this.dark).ink)
                Text(
                  (this.info.brand === '' ? '未知品牌' : this.info.brand) +
                  ' · VIN ' + getCarVin()
                )
                  .fontSize(12)
                  .fontColor(neu(this.dark).inkSub)
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              YqhNeuChip({ text: '在线', tone: 'ok' })
            }
            .width('100%')

            // 2、环形电量表盘
            YqhNeuRing({
              value: this.percent(),
              diameter: 190,
              stroke: 14,
              ringColor: this.batteryColor()
            }) {
              Column({ space: 2 }) {
                Text(this.info.enduranceMileage === '' ? '--' : this.info.enduranceMileage)
                  .fontSize(42)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(neu(this.dark).ink)
                Text('km 可续航')
                  .fontSize(12)
                  .fontColor(neu(this.dark).inkSub)
                Text(this.percent() + '%')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.batteryColor())
                  .margin({ top: 6 })
              }
            }

            // 3、快捷控制：车门 / 车灯 / 空调
            Row({ space: 12 }) {
              YqhNeuCircleButton({
                imageSrc: $r('app.media.ic_door_lock'),
                label: '车门',
                diameter: 64,
                active: this.isOn(this.stat.door),
                onBtnClick: () => this.toggle('door', !this.isOn(this.stat.door))
              })
              YqhNeuCircleButton({
                imageSrc: $r('app.media.ic_light_open'),
                label: '车灯',
                diameter: 64,
                active: this.isOn(this.stat.light),
                onBtnClick: () => this.toggle('light', !this.isOn(this.stat.light))
              })
              YqhNeuCircleButton({
                icon: '❄',
                label: '空调',
                diameter: 64,
                active: this.isOn(this.stat.acBtn),
                onBtnClick: () => this.toggle('ac', !this.isOn(this.stat.acBtn))
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceEvenly)

            // 4、更新时间
            Text('更新于 ' + (this.info.createYm === '' ? '--' : this.info.createYm))
              .fontSize(11)
              .fontColor(neu(this.dark).inkSub)
              .width('100%')
              .textAlign(TextAlign.Center)
          }
        }
        YqhNeuButton({
          text: '刷新状态',
          primary: false,
          btnHeight: 44,
          onBtnClick: () => this.load()
        })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  }
}
