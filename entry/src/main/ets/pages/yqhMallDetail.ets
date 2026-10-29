// 商城详情（M8b，自定义功能 C4）：价格 / 优惠 / 描述 / 收藏 + 产品评价
import { COLORS, BG_GRADIENT } from '../common/style/Style'
import { YqhGlassCard } from '../views/yqhGlassCard'
import { YqhButton } from '../views/yqhButton'
import { getMallList, toggleFav } from '../viewmodel/mall'
import { MallProduct, Review } from '../model/MallBean'

@Component
export struct YqhMallDetail {
  @Consume('navPathStack') navPathStack: NavPathStack
  @Prop productId: string = ''
  @State item: MallProduct = new MallProduct()
  @State favOn: boolean = false // 收藏态单独成 @State，保证切换后即时刷新
  @State loading: boolean = true

  aboutToAppear(): void {
    getMallList()
      .then((list: MallProduct[]) => {
        for (let i: number = 0; i < list.length; i++) {
          if (list[i].id === this.productId) {
            this.item = list[i]
            this.favOn = list[i].fav
            break
          }
        }
        this.loading = false
      })
      .catch(() => {
        this.loading = false
      })
  }

  private stars(n: number): string {
    let s: string = ''
    for (let i: number = 0; i < n; i++) {
      s = s + '★'
    }
    return s
  }

  private fav(): void {
    toggleFav(this.item.id)
      .then((on: boolean) => {
        this.favOn = on
        this.item.fav = on
      })
      .catch(() => {
      })
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: 14 }) {
          if (this.loading) {
            LoadingProgress()
              .width(28)
              .height(28)
              .color(COLORS.accent)
          } else {
            YqhGlassCard({ pad: 20 }) {
              Column({ space: 10 }) {
                if (this.item.tag !== '') {
                  Text(this.item.tag)
                    .fontSize(11)
                    .fontColor(COLORS.ink)
                    .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                    .borderRadius(8)
                    .backgroundColor(COLORS.highlight)
                }
                Text(this.item.name === '' ? '商品不存在' : this.item.name)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(COLORS.ink)
                  .width('100%')
                Row({ space: 10 }) {
                  Text('¥' + this.item.price)
                    .fontSize(26)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(COLORS.accentDeep)
                  Text('¥' + this.item.originalPrice)
                    .fontSize(14)
                    .fontColor(COLORS.inkSub)
                    .decoration({ type: TextDecorationType.LineThrough })
                  if (this.item.discount !== '') {
                    Text(this.item.discount)
                      .fontSize(12)
                      .fontColor(COLORS.danger)
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .borderRadius(8)
                      .backgroundColor('rgba(255,255,255,0.7)')
                  }
                }
                .width('100%')
                Text('已售 ' + this.item.sales + ' 件')
                  .fontSize(12)
                  .fontColor(COLORS.inkSub)
                  .width('100%')
                Text(this.item.desc)
                  .fontSize(14)
                  .fontColor(COLORS.ink)
                  .width('100%')
                YqhButton({
                  text: this.favOn ? '已收藏 ♥' : '收藏商品 ♡',
                  primary: !this.favOn,
                  onBtnClick: () => {
                    this.fav()
                  }
                })
              }
            }

            // 产品评价（C4 ④）
            YqhGlassCard({ pad: 16 }) {
              Column({ space: 10 }) {
                Text('产品评价（' + this.item.reviews.length + '）')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(COLORS.ink)
                  .width('100%')
                ForEach(this.item.reviews, (r: Review) => {
                  Column({ space: 4 }) {
                    Row() {
                      Text(r.user)
                        .fontSize(12)
                        .fontColor(COLORS.inkSub)
                      Text(this.stars(r.rating))
                        .fontSize(12)
                        .fontColor(COLORS.highlight)
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)
                    Text(r.content)
                      .fontSize(13)
                      .fontColor(COLORS.ink)
                      .width('100%')
                    Text(r.time)
                      .fontSize(11)
                      .fontColor(COLORS.inkSub)
                      .width('100%')
                  }
                  .width('100%')
                  .padding(10)
                  .borderRadius(10)
                  .backgroundColor('rgba(255,255,255,0.55)')
                }, (r: Review) => r.user + r.time)
              }
            }
          }
        }
        .width('100%')
        .padding(16)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .linearGradient(BG_GRADIENT)
  }
}
