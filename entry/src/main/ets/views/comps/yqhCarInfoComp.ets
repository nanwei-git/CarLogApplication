// 首页车辆信息卡（M4，接口 4.5/4.6）：大圆形续航表盘（电量环）+ 快捷控制网格
// 形态参考 Tesla 新拟态；配色沿用浅青白底 / 纯白卡 / 青蓝主色
import { promptAction } from '@kit.ArkUI'
import { COLORS } from '../../common/style/Style'
import { YqhGlassCard } from '../yqhGlassCard'
import { YqhButton } from '../yqhButton'
import { getCarInfo, getCarState, changeCarState } from '../../viewmodel/car'
import { CarInfoBean } from '../../model/CarInfoBean'
import { CarStat } from '../../model/CarStateBean'
import { CarStateChange } from '../../model/ApiReq'
import { IResult } from '../../model/IResult'
import { getCarVin } from '../../common/utils/StorageUtils'
import { SWITCH_ON, SWITCH_OFF, TOAST_MS } from '../../common/constants/Constants'

// 新拟态圆形按钮底色（略深于背景，便于投影出"浮起"质感）
const NEU_BG: string = '#E9F2F4'

@Component
export struct YqhCarInfoComp {
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
    const p: number = this.info.batteryPower.percent
    if (p < 0) {
      return 0
    }
    if (p > 100) {
      return 100
    }
    return p
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

  // 续航大圆形表盘（电量进度环 + 中心续航）
  @Builder
  rangeDial() {
    Stack({ alignContent: Alignment.Center }) {
      Progress({ value: this.percent(), total: 100, type: ProgressType.Ring })
        .width(190)
        .height(190)
        .style({ strokeWidth: 14 })
        .color(COLORS.accent)
      Column({ space: 2 }) {
        Text(this.info.enduranceMileage === '' ? '--' : this.info.enduranceMileage)
          .fontSize(44)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.ink)
        Text('可续航 km')
          .fontSize(13)
          .fontColor(COLORS.inkSub)
        Text(this.percent() + '% 电量')
          .fontSize(12)
          .fontColor(COLORS.accentDeep)
          .margin({ top: 6 })
      }
    }
    .width(190)
    .height(190)
  }

  // 快捷控制网格：锁车 / 车灯 / 空调
  @Builder
  quickGrid() {
    Row({ space: 16 }) {
      Column({ space: 6 }) {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_door_lock'))
            .width(26)
            .height(26)
        }
        .width(56)
        .height(56)
        .borderRadius(28)
        .backgroundColor(this.isOn(this.stat.door) ? COLORS.highlight : NEU_BG)
        .shadow({ radius: 8, color: 'rgba(31,35,41,0.12)', offsetX: 3, offsetY: 3 })
        .border({ width: 1, color: 'rgba(255,255,255,0.9)' })
        .onClick(() => {
          this.toggle('door', !this.isOn(this.stat.door))
        })
        Text('锁车')
          .fontSize(12)
          .fontColor(COLORS.inkSub)
      }
      Column({ space: 6 }) {
        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.ic_light_open'))
            .width(26)
            .height(26)
        }
        .width(56)
        .height(56)
        .borderRadius(28)
        .backgroundColor(this.isOn(this.stat.light) ? COLORS.highlight : NEU_BG)
        .shadow({ radius: 8, color: 'rgba(31,35,41,0.12)', offsetX: 3, offsetY: 3 })
        .border({ width: 1, color: 'rgba(255,255,255,0.9)' })
        .onClick(() => {
          this.toggle('light', !this.isOn(this.stat.light))
        })
        Text('车灯')
          .fontSize(12)
          .fontColor(COLORS.inkSub)
      }
      Column({ space: 6 }) {
        Button({ type: ButtonType.Circle }) {
          Text('❄')
            .fontSize(24)
            .fontColor(this.isOn(this.stat.acBtn) ? COLORS.accentDeep : COLORS.ink)
        }
        .width(56)
        .height(56)
        .borderRadius(28)
        .backgroundColor(this.isOn(this.stat.acBtn) ? COLORS.highlight : NEU_BG)
        .shadow({ radius: 8, color: 'rgba(31,35,41,0.12)', offsetX: 3, offsetY: 3 })
        .border({ width: 1, color: 'rgba(255,255,255,0.9)' })
        .onClick(() => {
          this.toggle('ac', !this.isOn(this.stat.acBtn))
        })
        Text('空调')
          .fontSize(12)
          .fontColor(COLORS.inkSub)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
  }

  build() {
    Column({ space: 12 }) {
      if (this.loading) {
        LoadingProgress()
          .width(28)
          .height(28)
          .color(COLORS.accent)
        Text('正在获取车辆状态…')
          .fontSize(13)
          .fontColor(COLORS.inkSub)
      } else {
        YqhGlassCard({ pad: 20 }) {
          Column({ space: 16 }) {
            Row() {
              Column({ space: 2 }) {
                Text(this.info.carName === '' ? '未绑定车辆' : this.info.carName)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(COLORS.ink)
                Text(
                  (this.info.brand === '' ? '未知品牌' : this.info.brand) +
                  ' · VIN ' + getCarVin()
                )
                  .fontSize(12)
                  .fontColor(COLORS.inkSub)
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
            }
            .width('100%')

            Row() {
              this.rangeDial()
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)

            this.quickGrid()

            Text('更新于 ' + (this.info.createYm === '' ? '--' : this.info.createYm))
              .fontSize(12)
              .fontColor(COLORS.inkSub)
              .width('100%')
              .textAlign(TextAlign.Center)
          }
        }
        YqhButton({
          text: '刷新',
          primary: false,
          btnHeight: 36,
          onBtnClick: () => this.load()
        })
      }
    }
    .width('100%')
    .padding(16)
  }
}
