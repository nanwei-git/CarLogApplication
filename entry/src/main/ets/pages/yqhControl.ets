// 车控（M6，接口 4.6/4.8）：图标按钮网格（新拟态圆形按钮）
// 锁车/车灯/空调 + 前后左右移动（按住移动、松开停车）
// 形态参考 Tesla 新拟态；配色沿用浅青白 / 青蓝
import { promptAction } from '@kit.ArkUI'
import { COLORS } from '../common/style/Style'
import { YqhGlassCard } from '../views/yqhGlassCard'
import { getCarState, changeCarState, moveCar } from '../viewmodel/car'
import { CarStat } from '../model/CarStateBean'
import { CarStateChange } from '../model/ApiReq'
import { IResult } from '../model/IResult'
import { getCarVin } from '../common/utils/StorageUtils'
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

const NEU_BG: string = '#E9F2F4'

@Component
export struct YqhControl {
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

  // 普通圆形开关按钮（锁车/车灯/空调）
  @Builder
  gridBtn(icon: string, label: string, active: boolean, onClick: () => void) {
    Column({ space: 8 }) {
      Button({ type: ButtonType.Circle }) {
        Text(icon)
          .fontSize(24)
          .fontColor(active ? '#FFFFFF' : COLORS.ink)
      }
      .width(72)
      .height(72)
      .borderRadius(36)
      .backgroundColor(active ? COLORS.accent : NEU_BG)
      .shadow({ radius: 10, color: 'rgba(31,35,41,0.12)', offsetX: 4, offsetY: 4 })
      .border({ width: 1, color: 'rgba(255,255,255,0.9)' })
      .onClick(onClick)
      Text(label)
        .fontSize(13)
        .fontColor(COLORS.inkSub)
    }
  }

  // 方向按钮（按住移动，松开停车）
  @Builder
  moveBtn(icon: string, label: string, direction: string) {
    Column({ space: 8 }) {
      Button({ type: ButtonType.Circle }) {
        Text(icon)
          .fontSize(24)
          .fontColor(COLORS.ink)
      }
      .width(72)
      .height(72)
      .borderRadius(36)
      .backgroundColor(NEU_BG)
      .shadow({ radius: 10, color: 'rgba(31,35,41,0.12)', offsetX: 4, offsetY: 4 })
      .border({ width: 1, color: 'rgba(255,255,255,0.9)' })
      .onTouch((e: TouchEvent) => {
        if (e.type === TouchType.Down) {
          this.doMove(direction, label)
        } else if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
          this.doMove(MOVE_STOP, '停')
        }
      })
      Text(label)
        .fontSize(13)
        .fontColor(COLORS.inkSub)
    }
  }

  build() {
    Column({ space: 16 }) {
      if (this.loading) {
        LoadingProgress()
          .width(28)
          .height(28)
          .color(COLORS.accent)
        Text('正在获取车辆状态…')
          .fontSize(13)
          .fontColor(COLORS.inkSub)
      } else {
        Text('车辆控制')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.ink)
          .width('100%')
          .textAlign(TextAlign.Center)

        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround, alignContent: FlexAlign.SpaceAround }) {
          this.gridBtn('🔒', '锁车', this.isOn(this.stat.door), () => {
            this.switchField('door', !this.isOn(this.stat.door))
          })
          this.gridBtn('💡', '车灯', this.isOn(this.stat.light), () => {
            this.switchField('light', !this.isOn(this.stat.light))
          })
          this.gridBtn('❄', '空调', this.isOn(this.stat.acBtn), () => {
            this.switchField('ac', !this.isOn(this.stat.acBtn))
          })
          this.moveBtn('⬆', '前进', MOVE_FRONT)
          this.moveBtn('⬇', '后退', MOVE_BACK)
          this.moveBtn('⬅', '左转', MOVE_LEFT)
          this.moveBtn('➡', '右转', MOVE_RIGHT)
        }
        .width('100%')
        .padding(8)

        YqhGlassCard({ pad: 16 }) {
          Column({ space: 6 }) {
            Text(this.moving === '' ? '当前状态：静止' : '当前状态：' + this.moving)
              .fontSize(13)
              .fontColor(COLORS.accentDeep)
              .width('100%')
              .textAlign(TextAlign.Center)
            Text('按住方向键移动，松开即停车')
              .fontSize(12)
              .fontColor(COLORS.inkSub)
              .width('100%')
              .textAlign(TextAlign.Center)
          }
        }
      }
    }
    .width('100%')
    .padding(16)
  }
}
