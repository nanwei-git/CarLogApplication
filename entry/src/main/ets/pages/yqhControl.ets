// 车控（M6，接口 4.6/4.8）：车门 / 车灯开关（圆形按钮，active 换图）；前后左右移动（方向盘，按下高亮青色，松开停车）
// 原型对齐：居中标题 + 车顶俯视大图（bg_owner_normal/开门/开灯态切换）+ 左右锁/灯圆按钮 + 底部圆形方向盘
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

@Component
export struct YqhControl {
  @State stat: CarStat = new CarStat()
  @State loading: boolean = true
  @State moving: string = '' // 当前移动提示文案
  @State pressedDir: string = '' // 方向盘当前按下的方向（用于高亮）

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

  // 锁/灯圆形按钮：active 时换图 + 浅青高亮底
  @Builder
  roundCtrl(iconOff: ResourceStr, iconOn: ResourceStr, active: boolean, label: string, onClick: () => void) {
    Column({ space: 6 }) {
      Button({ type: ButtonType.Circle }) {
        Image(active ? iconOn : iconOff)
          .width(30)
          .height(30)
      }
      .width(64)
      .height(64)
      .borderRadius(32)
      .backgroundColor(active ? COLORS.highlight : COLORS.card)
      .border({ width: 1, color: COLORS.line })
      .onClick(onClick)
      Text(label)
        .fontSize(13)
        .fontColor(COLORS.inkSub)
    }
  }

  // 方向盘方向键：按下高亮青色，松开停车
  @Builder
  wheelBtn(direction: string, icon: ResourceStr, label: string) {
    Button({ type: ButtonType.Circle }) {
      Image(icon)
        .width(28)
        .height(28)
        .fillColor(this.pressedDir === direction ? '#FFFFFF' : COLORS.ink)
    }
    .width(64)
    .height(64)
    .borderRadius(32)
    .backgroundColor(this.pressedDir === direction ? COLORS.accent : COLORS.card)
    .border({ width: 1, color: COLORS.line })
    .onTouch((e: TouchEvent) => {
      if (e.type === TouchType.Down) {
        this.pressedDir = direction
        this.doMove(direction, label)
      } else if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
        this.pressedDir = ''
        this.doMove(MOVE_STOP, '停')
      }
    })
  }

  // 俯视图随门/灯状态切换
  private carImage(): ResourceStr {
    if (this.isOn(this.stat.door)) {
      return $r('app.media.bg_owner_open_door')
    }
    if (this.isOn(this.stat.light)) {
      return $r('app.media.bg_owner_open_light')
    }
    return $r('app.media.bg_owner_normal')
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

        // 车顶俯视大图
        YqhGlassCard({ pad: 16 }) {
          Image(this.carImage())
            .width('100%')
            .height(200)
            .objectFit(ImageFit.Cover)
            .borderRadius(12)
        }

        // 左右：锁 / 灯 圆形按钮
        Row({ space: 48 }) {
          this.roundCtrl(
            $r('app.media.ic_door_lock'),
            $r('app.media.ic_door_lock_active'),
            this.isOn(this.stat.door),
            '车门',
            () => {
              this.switchDoorLight('door', !this.isOn(this.stat.door))
            }
          )
          this.roundCtrl(
            $r('app.media.ic_light_open'),
            $r('app.media.ic_light_open_active'),
            this.isOn(this.stat.light),
            '车灯',
            () => {
              this.switchDoorLight('light', !this.isOn(this.stat.light))
            }
          )
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)

        // 底部圆形方向盘（ic_direction 为中心，四向高亮）
        Column({ space: 10 }) {
          Row() {
            this.wheelBtn(MOVE_FRONT, $r('app.media.ic_direction_up'), '前')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          Row({ space: 10 }) {
            this.wheelBtn(MOVE_LEFT, $r('app.media.ic_direction_left'), '左')
            Image($r('app.media.ic_direction'))
              .width(150)
              .height(150)
              .objectFit(ImageFit.Contain)
            this.wheelBtn(MOVE_RIGHT, $r('app.media.ic_direction_right'), '右')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          Row() {
            this.wheelBtn(MOVE_BACK, $r('app.media.ic_direction_down'), '后')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        .width('100%')

        Text(this.moving === '' ? '当前状态：静止' : '当前状态：' + this.moving)
          .fontSize(13)
          .fontColor(COLORS.accentDeep)
          .width('100%')
          .textAlign(TextAlign.Center)
        Text('按住方向盘方向键移动，松开即停车')
          .fontSize(12)
          .fontColor(COLORS.inkSub)
          .width('100%')
          .textAlign(TextAlign.Center)
      }
    }
    .width('100%')
    .padding(16)
  }
}
