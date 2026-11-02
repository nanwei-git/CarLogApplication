// 车主商城列表（M8b，自定义功能 C4，Dark Neumorphism）：优惠提醒 + 商品卡 + 收藏切换
import { neu, neuBg } from '../common/style/Style'
import { YqhNeuCard } from '../common/ui/yqhNeuCard'
import { YqhNeuChip } from '../common/ui/yqhNeuChip'
import { getMallList, toggleFav } from '../viewmodel/mall'
import { MallProduct } from '../model/MallBean'

@Component
export struct YqhMall {
  @Consume('navPathStack') navPathStack: NavPathStack
  @StorageProp('darkMode') dark: boolean = true
  @State list: MallProduct[] = []
  @State loading: boolean = true

  aboutToAppear(): void {
    this.load()
  }

  private load(): void {
    getMallList()
      .then((list: MallProduct[]) => {
        this.list = list
        this.loading = false
      })
      .catch(() => {
        this.loading = false
      })
  }

  // 收藏切换：本地数据即时生效（无收藏接口）
  private fav(item: MallProduct): void {
    toggleFav(item.id)
      .then((on: boolean) => {
        const next: MallProduct[] = []
        for (let i: number = 0; i < this.list.length; i++) {
          if (this.list[i].id === item.id) {
            this.list[i].fav = on
          }
          next.push(this.list[i])
        }
        this.list = next
      })
      .catch(() => {
      })
  }

  @Builder
  productCard(item: MallProduct) {
    Row({ space: 12 }) {
      Column({ space: 6 }) {
        Row({ space: 6 }) {
          if (item.tag !== '') {
            YqhNeuChip({ text: item.tag, tone: 'accent' })
          }
          Text(item.name)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(neu(this.dark).ink)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')
        Row({ space: 8 }) {
          Text('¥' + item.price)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(neu(this.dark).accent)
          Text('¥' + item.originalPrice)
            .fontSize(12)
            .fontColor(neu(this.dark).inkSub)
            .decoration({ type: TextDecorationType.LineThrough })
          if (item.discount !== '') {
            Text(item.discount)
              .fontSize(11)
              .fontColor(neu(this.dark).danger)
          }
        }
        Text('已售 ' + item.sales + ' 件')
          .fontSize(11)
          .fontColor(neu(this.dark).inkSub)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .onClick(() => {
        this.navPathStack.pushPath({ name: 'MallDetail', param: item.id })
      })

      Column() {
        Text(item.fav ? '♥' : '♡')
          .fontSize(22)
          .fontColor(item.fav ? neu(this.dark).accent : neu(this.dark).inkSub)
      }
      .width(46)
      .height(46)
      .borderRadius(23)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(neu(this.dark).surfaceSunken)
      .border({ width: 1, color: neu(this.dark).line })
      .onClick(() => {
        this.fav(item)
      })
    }
    .width('100%')
    .padding(14)
  }

  build() {
    Stack() {
      Column({ space: 12 }) {
        // 优惠提醒（C4 ②）
        YqhNeuCard({ pad: 14, sunken: true }) {
          Row({ space: 8 }) {
            YqhNeuChip({ text: '惠', tone: 'accent' })
            Text('车主专享：部分商品满 199 减 30，新人首单立减 10')
              .fontSize(12)
              .fontColor(neu(this.dark).ink)
              .layoutWeight(1)
          }
          .width('100%')
        }

        if (this.loading) {
          LoadingProgress()
            .width(32)
            .height(32)
            .color(neu(this.dark).accent)
        } else {
          List({ space: 12 }) {
            ForEach(this.list, (item: MallProduct) => {
              ListItem() {
                YqhNeuCard({ pad: 0 }) {
                  this.productCard(item)
                }
              }
            }, (item: MallProduct) => item.id)
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
