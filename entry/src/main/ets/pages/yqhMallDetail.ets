// 商城详情（M8b，自定义功能 C4，Dark Neumorphism）：价格 / 优惠 / 描述 / 收藏 + 产品评价
import { neu, neuBg } from '../common/style/Style'
import { YqhNeuCard } from '../common/ui/yqhNeuCard'
import { YqhNeuButton } from '../common/ui/yqhNeuButton'
import { YqhNeuChip } from '../common/ui/yqhNeuChip'
import { getMallList, toggleFav } from '../viewmodel/mall'
import { MallProduct, Review } from '../model/MallBean'

@Component
export struct YqhMallDetail {
  @Consume('navPathStack') navPathStack: NavPathStack
  @StorageProp('darkMode') dark: boolean = true
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
              .width(32)
              .height(32)
              .color(neu(this.dark).accent)
          } else {
            YqhNeuCard({ pad: 20 }) {
              Column({ space: 10 }) {
                Row({ space: 8 }) {
                  if (this.item.tag !== '') {
                    YqhNeuChip({ text: this.item.tag, tone: 'accent' })
                  }
                  Blank()
                }
                .width('100%')
                Text(this.item.name === '' ? '商品不存在' : this.item.name)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(neu(this.dark).ink)
                  .width('100%')
                Row({ space: 10 }) {
                  Text('¥' + this.item.price)
                    .fontSize(26)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(neu(this.dark).accent)
                  Text('¥' + this.item.originalPrice)
                    .fontSize(14)
                    .fontColor(neu(this.dark).inkSub)
                    .decoration({ type: TextDecorationType.LineThrough })
                  if (this.item.discount !== '') {
                    YqhNeuChip({ text: this.item.discount, tone: 'danger' })
                  }
                }
                .width('100%')
                Text('已售 ' + this.item.sales + ' 件')
                  .fontSize(12)
                  .fontColor(neu(this.dark).inkSub)
                  .width('100%')
                Text(this.item.desc)
                  .fontSize(14)
                  .fontColor(neu(this.dark).ink)
                  .width('100%')
                YqhNeuButton({
                  text: this.favOn ? '已收藏 ♥' : '收藏商品 ♡',
                  primary: !this.favOn,
                  onBtnClick: () => {
                    this.fav()
                  }
                })
              }
            }

            // 产品评价（C4 ④）
            YqhNeuCard({ pad: 16 }) {
              Column({ space: 10 }) {
                Text('产品评价（' + this.item.reviews.length + '）')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(neu(this.dark).ink)
                  .width('100%')
                ForEach(this.item.reviews, (r: Review) => {
                  Column({ space: 4 }) {
                    Row() {
                      Text(r.user)
                        .fontSize(12)
                        .fontColor(neu(this.dark).inkSub)
                      Text(this.stars(r.rating))
                        .fontSize(12)
                        .fontColor(neu(this.dark).warn)
                    }
                    .width('100%')
                    .justifyContent(FlexAlign.SpaceBetween)
                    Text(r.content)
                      .fontSize(13)
                      .fontColor(neu(this.dark).ink)
                      .width('100%')
                    Text(r.time)
                      .fontSize(11)
                      .fontColor(neu(this.dark).inkSub)
                      .width('100%')
                  }
                  .width('100%')
                  .padding(12)
                  .borderRadius(16)
                  .backgroundColor(neu(this.dark).surfaceSunken)
                  .border({ width: 1, color: neu(this.dark).line })
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
    .linearGradient(neuBg(this.dark))
  }
}
