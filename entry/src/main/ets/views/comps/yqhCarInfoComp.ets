// 首页车辆信息卡（M4，接口 4.5）：车辆名称 / 可续航里程 / 电池电量+百分比 / 更新时间
// 自取数 + 自管加载态，业务页只做组装（规范第 11 条）
import { promptAction } from '@kit.ArkUI'
import { COLORS } from '../../common/style/Style'
import { YqhGlassCard } from '../yqhGlassCard'
import { YqhButton } from '../yqhButton'
import { getCarInfo } from '../../viewmodel/car'
import { CarInfoBean } from '../../model/CarInfoBean'
import { getCarVin } from '../../common/utils/StorageUtils'
import { TOAST_MS } from '../../common/constants/Constants'

@Component
export struct YqhCarInfoComp {
  @State info: CarInfoBean = new CarInfoBean()
  @State loading: boolean = true

  aboutToAppear(): void {
    this.load()
  }

  private load(): void {
    this.loading = true
    getCarInfo()
      .then((info: CarInfoBean) => {
        this.info = info
        this.loading = false
      })
      .catch(() => {
        this.loading = false
        promptAction.showToast({ message: '车辆信息获取失败，请稍后重试', duration: TOAST_MS })
      })
  }

  // 电量百分比钳到 0–100，防止脏数据撑爆进度条
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

  @Builder
  infoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(13)
        .fontColor(COLORS.inkSub)
      Text(value)
        .fontSize(13)
        .fontColor(COLORS.ink)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  batteryBar() {
    Column({ space: 6 }) {
      Row() {
        Text('电池电量')
          .fontSize(13)
          .fontColor(COLORS.inkSub)
        Text(this.percent() + '%')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.accentDeep)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width('100%')
          .height(8)
          .borderRadius(4)
          .backgroundColor('rgba(255,255,255,0.75)')
        Row()
          .width(this.percent() + '%')
          .height(8)
          .borderRadius(4)
          .backgroundColor(COLORS.accent)
      }
      .width('100%')
      .height(8)
      .borderRadius(4)
      Text('剩余 ' + this.info.batteryPower.power + ' kWh · 容量 ' + this.info.batteryCapacity + ' kWh')
        .fontSize(12)
        .fontColor(COLORS.inkSub)
    }
    .width('100%')
  }

  build() {
    Column({ space: 12 }) {
      if (this.loading) {
        LoadingProgress()
          .width(28)
          .height(28)
          .color(COLORS.accent)
        Text('正在获取车辆信息…')
          .fontSize(13)
          .fontColor(COLORS.inkSub)
      } else {
        YqhGlassCard({ pad: 20 }) {
          Column({ space: 12 }) {
            // 车辆图：小米 SU7（数据来源：Wikimedia Commons，文件 "Xiaomi SU7 004.jpg"，
            // 作者 Wikisympathisant，许可证 CC BY-SA 4.0，链接见下方引用）
            Image($r('app.media.su7'))
              .width('100%')
              .height(140)
              .objectFit(ImageFit.Cover)
              .borderRadius(16)
              .margin({ bottom: 4 })

            Text(this.info.carName === '' ? '未绑定车辆' : this.info.carName)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor(COLORS.ink)
            Row({ space: 10 }) {
              Text(this.info.brand === '' ? '未知品牌' : this.info.brand)
                .fontSize(12)
                .fontColor(COLORS.accentDeep)
              Text('VIN ' + getCarVin())
                .fontSize(12)
                .fontColor(COLORS.inkSub)
            }
            .width('100%')
            this.batteryBar()
            this.infoRow('可续航里程', this.info.enduranceMileage + ' km')
            this.infoRow('累计出行', this.info.totalTripNum + ' 次 · ' + this.info.totalTripMile + ' km')
            this.infoRow('更新时间', this.info.createYm === '' ? '--' : this.info.createYm)
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
