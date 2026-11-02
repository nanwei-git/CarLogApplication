// 首页智能空调（M5，接口 4.6/4.7）：环形温度旋钮 + 循环 / A·C / 除雾（Dark Neumorphism）
import { promptAction } from '@kit.ArkUI'
import { neu } from '../../common/style/Style'
import { YqhNeuCard } from '../../common/ui/yqhNeuCard'
import { YqhNeuRing } from '../../common/ui/yqhNeuRing'
import { YqhNeuCircleButton } from '../../common/ui/yqhNeuCircleButton'
import { YqhNeuButton } from '../../common/ui/yqhNeuButton'
import { YqhNeuChip } from '../../common/ui/yqhNeuChip'
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
  @StorageProp('darkMode') dark: boolean = true
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
            // 标题行
            Row() {
              Text('智能空调')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor(neu(this.dark).ink)
              Blank()
              YqhNeuChip({
                text: this.isOn(this.stat.acBtn) ? '运行中' : '已关闭',
                tone: this.isOn(this.stat.acBtn) ? 'accent' : ''
              })
            }
            .width('100%')

            if (!this.isOn(this.stat.acBtn)) {
              // 关闭态：空环 + OFF
              YqhNeuRing({ value: 0, diameter: 150, stroke: 12 }) {
                Column({ space: 4 }) {
                  Text('OFF')
                    .fontSize(26)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(neu(this.dark).inkSub)
                  Text('空调已关闭')
                    .fontSize(12)
                    .fontColor(neu(this.dark).inkSub)
                }
              }
              YqhNeuButton({
                text: '开启空调',
                onBtnClick: () => this.apply({ carVin: getCarVin(), acBtn: SWITCH_ON })
              })
            } else {
              // 开启态：温度旋钮 + 两侧微调
              Row({ space: 10 }) {
                YqhNeuCircleButton({
                  icon: '-',
                  diameter: 46,
                  onBtnClick: () => this.changeTemp(-TEMP_STEP)
                })
                YqhNeuRing({ value: this.tempPercent(), diameter: 150, stroke: 12 }) {
                  Column({ space: 2 }) {
                    Text(this.currentTemp() + '℃')
                      .fontSize(32)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(neu(this.dark).ink)
                    Text('设定温度')
                      .fontSize(11)
                      .fontColor(neu(this.dark).inkSub)
                  }
                }
                YqhNeuCircleButton({
                  icon: '+',
                  diameter: 46,
                  onBtnClick: () => this.changeTemp(TEMP_STEP)
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)

              // 循环 / A·C / 除雾
              Row({ space: 12 }) {
                YqhNeuCircleButton({
                  icon: '🔄',
                  label: '循环',
                  diameter: 60,
                  active: this.isOn(this.stat.circulate),
                  onBtnClick: () => this.apply({
                    carVin: getCarVin(),
                    circulate: this.isOn(this.stat.circulate) ? SWITCH_OFF : SWITCH_ON
                  })
                })
                YqhNeuCircleButton({
                  icon: '❄',
                  label: 'A/C',
                  diameter: 60,
                  active: true,
                  onBtnClick: () => this.apply({ carVin: getCarVin(), acBtn: SWITCH_OFF })
                })
                YqhNeuCircleButton({
                  icon: '🌫',
                  label: '除雾',
                  diameter: 60,
                  active: this.isOn(this.stat.clearFog),
                  onBtnClick: () => this.apply({
                    carVin: getCarVin(),
                    clearFog: this.isOn(this.stat.clearFog) ? SWITCH_OFF : SWITCH_ON
                  })
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceEvenly)

              YqhNeuButton({
                text: '关闭空调',
                primary: false,
                btnHeight: 44,
                onBtnClick: () => this.apply({ carVin: getCarVin(), acBtn: SWITCH_OFF })
              })
            }
          }
        }
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 16 })
  }
}
