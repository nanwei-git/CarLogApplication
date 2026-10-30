// 首页智能空调（M5，接口 4.6/4.7）：圆形温度旋钮（弧）+ 循环/A·C/除雾 圆形切换 + 开关
// 形态参考 Tesla 新拟态；配色沿用浅青白 / 青蓝
import { promptAction } from '@kit.ArkUI'
import { COLORS } from '../../common/style/Style'
import { YqhGlassCard } from '../yqhGlassCard'
import { YqhButton } from '../yqhButton'
import { getCarState, changeCarState } from '../../viewmodel/car'
import { CarStat } from '../../model/CarStateBean'
import { CarStateChange } from '../../model/ApiReq'
import { IResult } from '../../model/IResult'
import { getCarVin } from '../../common/utils/StorageUtils'
import {
  TEMP_MIN,
  TEMP_MAX,
  TEMP_STEP,
  TEMP_DEFAULT,
  SWITCH_ON,
  SWITCH_OFF,
  TOAST_MS
} from '../../common/constants/Constants'

const NEU_BG: string = '#E9F2F4'

@Component
export struct YqhAirConditionComp {
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
    getCarState()
      .then((stat: CarStat) => {
        this.stat = stat
        this.loading = false
      })
      .catch(() => {
        this.loading = false
        this.toast('车辆状态获取失败，请稍后重试')
      })
  }

  private isOn(v: string): boolean {
    return v === SWITCH_ON
  }

  private currentTemp(): number {
    if (this.stat.setTemp === '') {
      return TEMP_DEFAULT
    }
    return parseInt(this.stat.setTemp)
  }

  // 温度映射到 0-100 的弧
  private tempPercent(): number {
    const span: number = TEMP_MAX - TEMP_MIN
    let p: number = ((this.currentTemp() - TEMP_MIN) / span) * 100
    if (p < 0) {
      p = 0
    }
    if (p > 100) {
      p = 100
    }
    return p
  }

  private changeTemp(delta: number): void {
    let t: number = this.currentTemp() + delta
    if (t < TEMP_MIN) {
      t = TEMP_MIN
    }
    if (t > TEMP_MAX) {
      t = TEMP_MAX
    }
    this.apply({ carVin: getCarVin(), setTemp: t.toString() })
  }

  private apply(change: CarStateChange): void {
    if (this.busy) {
      return
    }
    this.busy = true
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

  // 圆形温度旋钮（弧）
  @Builder
  tempDial() {
    Stack({ alignContent: Alignment.Center }) {
      Progress({ value: this.tempPercent(), total: 100, type: ProgressType.Ring })
        .width(160)
        .height(160)
        .style({ strokeWidth: 12 })
        .color(COLORS.accent)
      Column({ space: 2 }) {
        Text(this.currentTemp() + '℃')
          .fontSize(34)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.accentDeep)
        Text('设定温度')
          .fontSize(12)
          .fontColor(COLORS.inkSub)
      }
    }
    .width(160)
    .height(160)
  }

  // 圆形功能切换按钮
  @Builder
  neuToggle(icon: string, label: string, active: boolean, onClick: () => void) {
    Column({ space: 6 }) {
      Button({ type: ButtonType.Circle }) {
        Text(icon)
          .fontSize(22)
          .fontColor(active ? '#FFFFFF' : COLORS.ink)
      }
      .width(60)
      .height(60)
      .borderRadius(30)
      .backgroundColor(active ? COLORS.accent : NEU_BG)
      .shadow({ radius: 8, color: 'rgba(31,35,41,0.12)', offsetX: 3, offsetY: 3 })
      .border({ width: 1, color: 'rgba(255,255,255,0.9)' })
      .onClick(onClick)
      Text(label)
        .fontSize(12)
        .fontColor(COLORS.inkSub)
    }
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
      } else if (!this.isOn(this.stat.acBtn)) {
        // 关闭态
        YqhGlassCard({ pad: 20 }) {
          Column({ space: 16 }) {
            Text('智能空调')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.ink)
              .width('100%')
            Stack({ alignContent: Alignment.Center }) {
              Progress({ value: 0, total: 100, type: ProgressType.Ring })
                .width(160)
                .height(160)
                .style({ strokeWidth: 12 })
                .color('#D5DCE0')
              Column({ space: 4 }) {
                Text('❄')
                  .fontSize(22)
                  .fontColor('#9AA3A8')
                Text('已关闭')
                  .fontSize(13)
                  .fontColor(COLORS.inkSub)
              }
            }
            .alignSelf(ItemAlign.Center)
            YqhButton({
              text: '开启空调',
              onBtnClick: () => this.apply({ carVin: getCarVin(), acBtn: SWITCH_ON })
            })
          }
        }
      } else {
        // 开启态
        YqhGlassCard({ pad: 20 }) {
          Column({ space: 16 }) {
            Text('智能空调')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.ink)
              .width('100%')

            // 温度旋钮 + 两侧微调
            Row({ space: 12 }) {
              Button({ type: ButtonType.Circle }) {
                Text('-')
                  .fontSize(28)
                  .fontColor(COLORS.accentDeep)
              }
              .width(48)
              .height(48)
              .borderRadius(24)
              .backgroundColor(NEU_BG)
              .shadow({ radius: 6, color: 'rgba(31,35,41,0.12)', offsetX: 2, offsetY: 2 })
              .border({ width: 1, color: 'rgba(255,255,255,0.9)' })
              .onClick(() => this.changeTemp(-TEMP_STEP))
              this.tempDial()
              Button({ type: ButtonType.Circle }) {
                Text('+')
                  .fontSize(28)
                  .fontColor(COLORS.accentDeep)
              }
              .width(48)
              .height(48)
              .borderRadius(24)
              .backgroundColor(NEU_BG)
              .shadow({ radius: 6, color: 'rgba(31,35,41,0.12)', offsetX: 2, offsetY: 2 })
              .border({ width: 1, color: 'rgba(255,255,255,0.9)' })
              .onClick(() => this.changeTemp(TEMP_STEP))
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)

            // 循环 / A·C / 除雾
            Row({ space: 16 }) {
              this.neuToggle('🔄', '循环', this.isOn(this.stat.circulate), () => {
                this.apply({
                  carVin: getCarVin(),
                  circulate: this.isOn(this.stat.circulate) ? SWITCH_OFF : SWITCH_ON
                })
              })
              this.neuToggle('❄', 'A/C', true, () => {
                this.apply({ carVin: getCarVin(), acBtn: SWITCH_OFF })
              })
              this.neuToggle('🌫', '除雾', this.isOn(this.stat.clearFog), () => {
                this.apply({
                  carVin: getCarVin(),
                  clearFog: this.isOn(this.stat.clearFog) ? SWITCH_OFF : SWITCH_ON
                })
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)

            YqhButton({
              text: '关闭空调',
              primary: false,
              btnHeight: 40,
              onBtnClick: () => this.apply({ carVin: getCarVin(), acBtn: SWITCH_OFF })
            })
          }
        }
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
  }
}
