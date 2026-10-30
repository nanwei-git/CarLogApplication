// 首页车辆信息卡（M4，接口 4.5）：车辆大图 / 可续航大数字 / 电量进度 / 更新时间
// 原型对齐：bg_owner_car 大图 + 336 超大续航数字 + 电量进度条 + 更新于
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
          Column({ space: 14 }) {
            // 车辆大图（原型 bg_owner_car）
            Image($r('app.media.bg_owner_car'))
              .width('100%')
              .height(150)
              .objectFit(ImageFit.Cover)
              .borderRadius(16)
              .margin({ bottom: 4 })

            Row() {
              Column({ space: 2 }) {
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
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
            }
            .width('100%')

            // 续航大数字（原型 336 超大字 + 可续航 km）
            Row({ space: 10 }) {
              Text(this.info.enduranceMileage === '' ? '--' : this.info.enduranceMileage)
                .fontSize(52)
                .fontWeight(FontWeight.Bold)
                .fontColor(COLORS.accentDeep)
              Column({ space: 2 }) {
                Text('可续航')
                  .fontSize(13)
                  .fontColor(COLORS.inkSub)
                Text('km')
                  .fontSize(13)
                  .fontColor(COLORS.inkSub)
              }
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .margin({ top: 4 })

            // 电量进度 + 百分比
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
                .backgroundColor('#EEF1F4')
              Row()
                .width(this.percent() + '%')
                .height(8)
                .borderRadius(4)
                .linearGradient({
                  direction: GradientDirection.Right,
                  colors: [[COLORS.accent, 0.0], [COLORS.accentDeep, 1.0]] as [ResourceColor, number][]
                })
            }
            .width('100%')
            .height(8)
            .borderRadius(4)

            Text('剩余 ' + this.info.batteryPower.power + ' kWh · 容量 ' + this.info.batteryCapacity + ' kWh')
              .fontSize(12)
              .fontColor(COLORS.inkSub)
              .width('100%')
            Text('更新于 ' + (this.info.createYm === '' ? '--' : this.info.createYm))
              .fontSize(12)
              .fontColor(COLORS.inkSub)
              .width('100%')
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
