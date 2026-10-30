// 首页智能空调（M5，接口 4.6/4.7）：AC 开关 / 内外循环 / 制冷 / 除雾 + 温度±
// 原型对齐：温度胶囊 -/+ + 三个圆形图标按钮（循环/A·C/除雾）+ 关闭空调胶囊；
// 空调关闭态为波纹图 + 「空调系统已关闭」+「开启空调」
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
    this.apply({ carVin: getCarVin(), setTemp: t.toString() })
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
  circleBtn(label: string, active: boolean, onClick: () => void) {
    Button(label)
      .width(60)
      .height(60)
      .borderRadius(30)
      .fontSize(13)
      .fontWeight(FontWeight.Medium)
      .fontColor(active ? '#FFFFFF' : COLORS.ink)
      .backgroundColor(active ? COLORS.accent : COLORS.card)
      .border(active ? undefined : { width: 1, color: COLORS.line })
      .onClick(onClick)
  }

  // 空调关闭态波纹图（无专用素材，用同心圆模拟）
  @Builder
  ripple() {
    Stack({ alignContent: Alignment.Center }) {
      Circle()
        .width(120)
        .height(120)
        .fill('#EAF7F6')
      Circle()
        .width(80)
        .height(80)
        .fill('#D5F0EE')
      Circle()
        .width(40)
        .height(40)
        .fill(COLORS.accent)
      Text('❄')
        .fontSize(20)
        .fontColor('#FFFFFF')
    }
    .width(120)
    .height(120)
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
        // 空调关闭态：波纹图 + 文案 + 开启按钮
        YqhGlassCard({ pad: 20 }) {
          Column({ space: 16 }) {
            Text('智能空调')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.ink)
              .width('100%')
            Row() {
              this.ripple()
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            Text('空调系统已关闭')
              .fontSize(14)
              .fontColor(COLORS.inkSub)
              .alignSelf(ItemAlign.Center)
            YqhButton({
              text: '开启空调',
              onBtnClick: () => this.apply({ carVin: getCarVin(), acBtn: SWITCH_ON })
            })
          }
        }
      } else {
        // 空调开启态：温度胶囊 + 三圆形按钮 + 关闭按钮
        YqhGlassCard({ pad: 20 }) {
          Column({ space: 16 }) {
            Text('智能空调')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.ink)
              .width('100%')

            // 温度胶囊（圆角容器装 - / 温度 / +）
            Row({ space: 16 }) {
              Button('-')
                .width(40)
                .height(40)
                .borderRadius(20)
                .fontSize(22)
                .fontColor(COLORS.accentDeep)
                .backgroundColor(COLORS.card)
                .border({ width: 1, color: COLORS.line })
                .onClick(() => this.changeTemp(-TEMP_STEP))
              Column({ space: 2 }) {
                Text(this.currentTemp() + '℃')
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(COLORS.accentDeep)
                Text('设定温度')
                  .fontSize(11)
                  .fontColor(COLORS.inkSub)
              }
              Button('+')
                .width(40)
                .height(40)
                .borderRadius(20)
                .fontSize(22)
                .fontColor(COLORS.accentDeep)
                .backgroundColor(COLORS.card)
                .border({ width: 1, color: COLORS.line })
                .onClick(() => this.changeTemp(TEMP_STEP))
            }
            .width('100%')
            .height(64)
            .borderRadius(32)
            .backgroundColor('#F5F6F8')
            .justifyContent(FlexAlign.Center)

            // 三个圆形图标按钮
            Row({ space: 16 }) {
              this.circleBtn('循环', this.isOn(this.stat.circulate), () => {
                this.apply({
                  carVin: getCarVin(),
                  circulate: this.isOn(this.stat.circulate) ? SWITCH_OFF : SWITCH_ON
                })
              })
              this.circleBtn('A/C', true, () => {
                this.apply({ carVin: getCarVin(), acBtn: SWITCH_OFF })
              })
              this.circleBtn('除雾', this.isOn(this.stat.clearFog), () => {
                this.apply({
                  carVin: getCarVin(),
                  clearFog: this.isOn(this.stat.clearFog) ? SWITCH_OFF : SWITCH_ON
                })
              })
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)

            // 关闭空调
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
