// 首页智能空调（M5，接口 4.6/4.7）：AC 开关 / 内外循环 / 制冷 / 除雾 + 温度±
// 每次操作只传变更字段 → 成功后重新 getCarState 回写刷新
import { promptAction } from '@kit.ArkUI'
import { COLORS } from '../../common/style/Style'
import { YqhGlassCard } from '../yqhGlassCard'
import { YqhToggle } from '../yqhToggle'
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

@Component
export struct YqhAirConditionComp {
  @State stat: CarStat = new CarStat()
  @State loading: boolean = true
  @State saving: boolean = false

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

  private changeTemp(delta: number): void {
    let t: number = this.currentTemp() + delta
    if (t < TEMP_MIN) {
      t = TEMP_MIN
    }
    if (t > TEMP_MAX) {
      t = TEMP_MAX
    }
    const change: CarStateChange = { carVin: getCarVin(), setTemp: t.toString() }
    this.apply(change)
  }

  // 统一提交：变更成功后回写刷新（服务器为准）
  private apply(change: CarStateChange): void {
    if (this.saving) {
      return
    }
    this.saving = true
    changeCarState(change)
      .then((res: IResult) => {
        this.saving = false
        if (res.code === 200 || res.code === 0) {
          this.load()
        } else {
          this.toast(res.msg || '操作失败')
        }
      })
      .catch(() => {
        this.saving = false
        this.toast('网络异常，请稍后重试')
      })
  }

  @Builder
  tempStepBtn(text: string, delta: number) {
    Button(text)
      .width(36)
      .height(36)
      .borderRadius(18)
      .fontSize(20)
      .backgroundColor('rgba(255,255,255,0.75)')
      .fontColor(COLORS.accentDeep)
      .onClick(() => {
        this.changeTemp(delta)
      })
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
          Column({ space: 14 }) {
            Row() {
              Text('智能空调')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(COLORS.ink)
              if (this.saving) {
                LoadingProgress()
                  .width(16)
                  .height(16)
                  .color(COLORS.accent)
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            // 温度 ±
            Row({ space: 20 }) {
              this.tempStepBtn('-', -TEMP_STEP)
              Column({ space: 2 }) {
                Text(this.currentTemp() + '℃')
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(COLORS.accentDeep)
                Text('设定温度 ' + TEMP_MIN + '-' + TEMP_MAX + '℃')
                  .fontSize(11)
                  .fontColor(COLORS.inkSub)
              }
              this.tempStepBtn('+', TEMP_STEP)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)

            YqhToggle({
              label: '空调 AC',
              sub: this.isOn(this.stat.acBtn) ? '已开启' : '已关闭',
              checked: this.isOn(this.stat.acBtn),
              onToggleChange: (v: boolean) => {
                const change: CarStateChange = { carVin: getCarVin(), acBtn: v ? SWITCH_ON : SWITCH_OFF }
                this.apply(change)
              }
            })
            YqhToggle({
              label: '内循环',
              sub: this.isOn(this.stat.circulate) ? '内循环' : '外循环',
              checked: this.isOn(this.stat.circulate),
              onToggleChange: (v: boolean) => {
                const change: CarStateChange = { carVin: getCarVin(), circulate: v ? SWITCH_ON : SWITCH_OFF }
                this.apply(change)
              }
            })
            YqhToggle({
              label: '制冷送风',
              sub: this.stat.windLevel === '' ? '风量 --' : '风量 ' + this.stat.windLevel,
              checked: this.isOn(this.stat.fanState),
              onToggleChange: (v: boolean) => {
                const change: CarStateChange = { carVin: getCarVin(), fanState: v ? SWITCH_ON : SWITCH_OFF }
                this.apply(change)
              }
            })
            YqhToggle({
              label: '除雾',
              sub: this.isOn(this.stat.clearFog) ? '除雾中' : '已关闭',
              checked: this.isOn(this.stat.clearFog),
              onToggleChange: (v: boolean) => {
                const change: CarStateChange = { carVin: getCarVin(), clearFog: v ? SWITCH_ON : SWITCH_OFF }
                this.apply(change)
              }
            })
            Text('车内温度 ' + (this.stat.temperature === '' ? '--' : this.stat.temperature + '℃'))
              .fontSize(12)
              .fontColor(COLORS.inkSub)
          }
        }
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
  }
}
