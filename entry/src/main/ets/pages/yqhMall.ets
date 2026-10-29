// 车主商城列表（M8b，自定义功能 C4）：优惠提醒 + 商品卡 + 收藏切换
import { COLORS, BG_GRADIENT } from '../common/style/Style'
import { YqhGlassCard } from '../views/yqhGlassCard'
import { getMallList, toggleFav } from '../viewmodel/mall'
import { MallProduct } from '../model/MallBean'

@Component
export struct YqhMall {
  @Consume('navPathStack') navPathStack: NavPathStack
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
      Column({ space: 4 }) {
        Row({ space: 6 }) {
          if (item.tag !== '') {
            Text(item.tag)
              .fontSize(11)
              .fontColor(COLORS.ink)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius(6)
              .backgroundColor(COLORS.highlight)
          }
          Text(item.name)
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.ink)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
        }
        .width('100%')
        Row({ space: 8 }) {
          Text('¥' + item.price)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(COLORS.accentDeep)
          Text('¥' + item.originalPrice)
            .fontSize(12)
            .fontColor(COLORS.inkSub)
            .decoration({ type: TextDecorationType.LineThrough })
          if (item.discount !== '') {
            Text(item.discount)
              .fontSize(11)
              .fontColor(COLORS.danger)
          }
        }
        Text('已售 ' + item.sales + ' 件')
          .fontSize(11)
          .fontColor(COLORS.inkSub)
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .onClick(() => {
        this.navPathStack.pushPath({ name: 'MallDetail', param: item.id })
      })

      Column() {
        Text(item.fav ? '♥' : '♡')
          .fontSize(24)
          .fontColor(item.fav ? COLORS.danger : COLORS.inkSub)
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
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
        YqhGlassCard({ pad: 14 }) {
          Row({ space: 8 }) {
            Text('惠')
              .fontSize(13)
              .fontColor(COLORS.ink)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .borderRadius(8)
              .backgroundColor(COLORS.highlight)
            Text('车主专享：部分商品满 199 减 30，新人首单立减 10')
              .fontSize(12)
              .fontColor(COLORS.ink)
              .layoutWeight(1)
          }
          .width('100%')
        }

        if (this.loading) {
          LoadingProgress()
            .width(28)
            .height(28)
            .color(COLORS.accent)
        } else {
          List({ space: 10 }) {
            ForEach(this.list, (item: MallProduct) => {
              ListItem() {
                YqhGlassCard({ pad: 0 }) {
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
    .linearGradient(BG_GRADIENT)
  }
}
