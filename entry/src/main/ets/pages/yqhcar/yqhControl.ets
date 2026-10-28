// 车控（M6，接口 4.6/4.8）：车门 / 车灯开关；前后左右移动（按住移动、松开停车）
// 由 yqhIndex 的"车控" TabContent 组装（C5：底部模块切换由根 Navigation + Tabs 承载）
// 注意：TouchEvent / TouchType 为 ArkTS 全局类型，不需要（也不能）从 @kit.ArkUI 导入
import { promptAction } from '@kit.ArkUI'
import { COLORS } from '../../common/style/Style'
import { YqhGlassCard } from '../../common/ui/yqhGlassCard'
import { YqhToggle } from '../../common/ui/yqhToggle'
import { getCarState, changeCarState, moveCar } from '../../common/api/car'
import { CarStat } from '../../common/model/CarStateBean'
import { CarStateChange } from '../../common/model/ApiReq'
import { IResult } from '../../common/model/IResult'
import { getCarVin } from '../../common/utils/StorageUtils'
import {
  SWITCH_ON,
  SWITCH_OFF,
  MOVE_FRONT,
  MOVE_BACK,
  MOVE_LEFT,
  MOVE_RIGHT,
  MOVE_STOP,
  TOAST_MS
} from '../../common/constants/Constants'

@Component
export struct YqhControl {
  @State stat: CarStat = new CarStat()
  @State loading: boolean = true
  @State moving: string = '' // 当前方向提示文案

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

  // 门/灯开关：只传变更字段，成功后回写刷新
  private switchDoorLight(field: string, on: boolean): void {
    const change: CarStateChange = { carVin: getCarVin() }
    if (field === 'door') {
      change.door = on ? SWITCH_ON : SWITCH_OFF
    } else {
      change.light = on ? SWITCH_ON : SWITCH_OFF
    }
    changeCarState(change)
      .then((res: IResult) => {
        if (res.code === 200 || res.code === 0) {
          this.load()
        } else {
          this.toast(res.msg || '操作失败')
        }
      })
      .catch(() => {
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

  // 方向键：按住 Down 下发移动，松开 Up/Cancel 下发停车
  @Builder
  dirBtn(text: string, direction: string, label: string) {
    Button(text)
      .width(64)
      .height(64)
      .borderRadius(32)
      .fontSize(24)
      .backgroundColor(direction === MOVE_STOP ? COLORS.highlight : COLORS.card)
      .fontColor(COLORS.accentDeep)
      .onTouch((e: TouchEvent) => {
        if (e.type === TouchType.Down) {
          this.doMove(direction, label)
        } else if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
          this.doMove(MOVE_STOP, '停')
        }
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
            Text('车门与车灯')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.ink)
            YqhToggle({
              label: '车门',
              sub: this.isOn(this.stat.door) ? '已开启' : '已关闭',
              checked: this.isOn(this.stat.door),
              onToggleChange: (v: boolean) => {
                this.switchDoorLight('door', v)
              }
            })
            YqhToggle({
              label: '车灯',
              sub: this.isOn(this.stat.light) ? '已开启' : '已关闭',
              checked: this.isOn(this.stat.light),
              onToggleChange: (v: boolean) => {
                this.switchDoorLight('light', v)
              }
            })
          }
        }

        YqhGlassCard({ pad: 20 }) {
          Column({ space: 12 }) {
            Text('遥控移动')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.ink)
            // 十字方向键
            Column({ space: 10 }) {
              Row() {
                this.dirBtn('↑', MOVE_FRONT, '前')
              }
              Row({ space: 10 }) {
                this.dirBtn('←', MOVE_LEFT, '左')
                this.dirBtn('停', MOVE_STOP, '停')
                this.dirBtn('→', MOVE_RIGHT, '右')
              }
              Row() {
                this.dirBtn('↓', MOVE_BACK, '后')
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            Text('按住方向键移动，松开即停车')
              .fontSize(12)
              .fontColor(COLORS.inkSub)
            Text(this.moving === '' ? '当前状态：静止' : '当前状态：' + this.moving)
              .fontSize(13)
              .fontColor(COLORS.accentDeep)
          }
        }
      }
    }
    .width('100%')
    .padding(16)
  }
}
