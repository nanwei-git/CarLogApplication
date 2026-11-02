// 车控（M6，接口 4.6/4.8）：开关网格 + 十字方向键（按住移动、松开停车）
// 视觉：Dark Neumorphism —— 凸起圆键，按下凹陷 + 微缩，激活主色发光。
import { promptAction } from '@kit.ArkUI'
import { neu } from '../common/style/Style'
import { YqhNeuCard } from '../common/ui/yqhNeuCard'
import { YqhNeuCircleButton } from '../common/ui/yqhNeuCircleButton'
import { YqhNeuChip } from '../common/ui/yqhNeuChip'
import { getCarState, changeCarState, moveCar, controlDoor, controlLight } from '../viewmodel/car'
import { CarStat } from '../model/CarStateBean'
import { IResult } from '../model/IResult'
import { getCarVin, getCarId } from '../common/utils/StorageUtils'
import {
  SWITCH_ON,
  SWITCH_OFF,
  MOVE_FRONT,
  MOVE_BACK,
  MOVE_LEFT,
  MOVE_RIGHT,
  MOVE_STOP,
  TOAST_MS
} from '../common/constants/Constants'

@Component
export struct YqhControl {
  @StorageProp('darkMode') dark: boolean = true
  @State stat: CarStat = new CarStat()
  @State loading: boolean = true
  @State moving: string = ''
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

  private switchField(field: string, on: boolean): void {
    if (this.busy) {
      return
    }
    this.busy = true
    const val: string = on ? SWITCH_ON : SWITCH_OFF
    const carId: string = getCarId()
    let req: Promise<IResult>
    if (field === 'door') {
      req = controlDoor(carId, val)
    } else if (field === 'light') {
      req = controlLight(carId, val)
    } else {
      req = changeCarState({ carVin: getCarVin(), acBtn: val })
    }
    req
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

  private doMove(direction: string, label: string): void {
    moveCar(direction)
      .then((res: IResult) => {
        if (res.code === 200 || res.code === 0) {
          this.moving = direction === MOVE_STOP ? '已停车' : '正在向' + label + '移动'
        } else {
          this.moving = ''
          this.toast(res.msg || '移动指令失败')
        }
      })
      .catch(() => {
        this.moving = ''
        this.toast('网络异常，请稍后重试')
      })
  }

  build() {
    Column({ space: 16 }) {
      if (this.loading) {
        LoadingProgress()
          .width(32)
          .height(32)
          .color(neu(this.dark).accent)
        Text('正在获取车辆状态…')
          .fontSize(13)
          .fontColor(neu(this.dark).inkSub)
      } else {
        Row() {
          Text('车辆控制')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(neu(this.dark).ink)
          Blank()
          YqhNeuChip({
            text: this.moving === '' ? '静止' : '移动中',
            tone: this.moving === '' ? '' : 'accent'
          })
        }
        .width('100%')
        .padding({ left: 8, right: 8 })

        // 车门 / 车灯 / 空调
        YqhNeuCard({ pad: 18 }) {
          Row({ space: 12 }) {
            YqhNeuCircleButton({
              icon: '🔒',
              label: '车门',
              diameter: 64,
              active: this.isOn(this.stat.door),
              onBtnClick: () => this.switchField('door', !this.isOn(this.stat.door))
            })
            YqhNeuCircleButton({
              icon: '💡',
              label: '车灯',
              diameter: 64,
              active: this.isOn(this.stat.light),
              onBtnClick: () => this.switchField('light', !this.isOn(this.stat.light))
            })
            YqhNeuCircleButton({
              icon: '❄',
              label: '空调',
              diameter: 64,
              active: this.isOn(this.stat.acBtn),
              onBtnClick: () => this.switchField('ac', !this.isOn(this.stat.acBtn))
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceEvenly)
        }

        // 十字方向键：按住移动，松开停车
        YqhNeuCard({ pad: 18 }) {
          Column({ space: 12 }) {
            YqhNeuCircleButton({
              icon: '⬆',
              diameter: 64,
              onBtnTouch: (e: TouchEvent) => {
                if (e.type === TouchType.Down) {
                  this.doMove(MOVE_FRONT, '前')
                } else if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
                  this.doMove(MOVE_STOP, '停')
                }
              }
            })
            Row({ space: 12 }) {
              YqhNeuCircleButton({
                icon: '⬅',
                diameter: 64,
                onBtnTouch: (e: TouchEvent) => {
                  if (e.type === TouchType.Down) {
                    this.doMove(MOVE_LEFT, '左')
                  } else if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
                    this.doMove(MOVE_STOP, '停')
                  }
                }
              })
              YqhNeuCircleButton({
                icon: '⏹',
                diameter: 64,
                onBtnClick: () => this.doMove(MOVE_STOP, '停')
              })
              YqhNeuCircleButton({
                icon: '➡',
                diameter: 64,
                onBtnTouch: (e: TouchEvent) => {
                  if (e.type === TouchType.Down) {
                    this.doMove(MOVE_RIGHT, '右')
                  } else if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
                    this.doMove(MOVE_STOP, '停')
                  }
                }
              })
            }
            YqhNeuCircleButton({
              icon: '⬇',
              diameter: 64,
              onBtnTouch: (e: TouchEvent) => {
                if (e.type === TouchType.Down) {
                  this.doMove(MOVE_BACK, '后')
                } else if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
                  this.doMove(MOVE_STOP, '停')
                }
              }
            })
          }
          .width('100%')
        }

        // 状态回显
        YqhNeuCard({ pad: 16, sunken: true }) {
          Column({ space: 6 }) {
            Text(this.moving === '' ? '当前状态：静止' : '当前状态：' + this.moving)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.moving === '' ? neu(this.dark).ink : neu(this.dark).accent)
              .width('100%')
              .textAlign(TextAlign.Center)
            Text('按住方向键移动，松开即停车')
              .fontSize(12)
              .fontColor(neu(this.dark).inkSub)
              .width('100%')
              .textAlign(TextAlign.Center)
          }
        }
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 24 })
  }
}
