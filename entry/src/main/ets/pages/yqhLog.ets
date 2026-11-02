// 车辆操作日志「信息」页（Dark Neumorphism）
import { promptAction } from '@kit.ArkUI'
import { neu, neuBg } from '../common/style/Style'
import { YqhNeuCard } from '../common/ui/yqhNeuCard'
import { getCarLogs } from '../viewmodel/car'
import { OperationLog } from '../model/CarLogBean'
import { TOAST_MS } from '../common/constants/Constants'

@Component
export struct YqhLog {
  @Consume('navPathStack') navPathStack: NavPathStack
  @StorageProp('darkMode') dark: boolean = true
  @State list: OperationLog[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    this.load()
  }

  private load(): void {
    this.loading = true
    getCarLogs()
      .then((list: OperationLog[]) => {
        this.list = list
        this.loading = false
      })
      .catch(() => {
        this.loading = false
        promptAction.showToast({ message: '日志加载失败', duration: TOAST_MS })
      })
  }

  build() {
    Stack() {
      Column({ space: 12 }) {
        if (this.loading) {
          LoadingProgress()
            .width(32)
            .height(32)
            .color(neu(this.dark).accent)
        } else if (this.list.length === 0) {
          Text('暂无操作日志')
            .fontSize(14)
            .fontColor(neu(this.dark).inkSub)
        } else {
          List({ space: 12 }) {
            ForEach(this.list, (log: OperationLog) => {
              ListItem() {
                YqhNeuCard({ pad: 16 }) {
                  Column({ space: 6 }) {
                    Row() {
                      Text(log.title)
                        .fontSize(15)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(neu(this.dark).ink)
                      Text(log.time)
                        .fontSize(11)
                        .fontColor(neu(this.dark).inkSub)
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)
                    Text(log.desc)
                      .fontSize(13)
                      .fontColor(neu(this.dark).inkSub)
                      .width('100%')
                  }
                }
              }
            }, (log: OperationLog) => log.id)
          }
          .width('100%')
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .linearGradient(neuBg(this.dark))
  }
}
