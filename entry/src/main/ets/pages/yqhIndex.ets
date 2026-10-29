// 首页枢纽（M1 骨架）：根 Navigation + NavPathStack + 底部 Tabs（首页/车控/反馈/我的）
// 列表→详情后续里程碑通过 navPathStack.pushPath 走 NavDestination（C5 已裁决）。
import { COLORS, BG_GRADIENT } from '../common/style/Style'
import { YqhCarInfoComp } from '../views/comps/yqhCarInfoComp'
import { YqhAirConditionComp } from '../views/comps/yqhAirConditionComp'
import { YqhControl } from './yqhControl'
import { YqhFeedback } from './yqhFeedback'
import { YqhFeedbackAdd } from './yqhFeedbackAdd'
import { YqhFeedbackDetail } from './yqhFeedbackDetail'
import { YqhMine } from './yqhMine'
import { YqhSettings } from './yqhSettings'
import { YqhMall } from './yqhMall'
import { YqhMallDetail } from './yqhMallDetail'
import { YqhLog } from './yqhLog'

@Entry
@Component
struct YqhIndex {
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack()
  @State currentIndex: number = 0

  // 详情页路由表（M2+ 按 name 渲染各 NavDestination）
  // 详情页路由表（C5：列表→详情走 NavDestination 子页）
  @Builder
  pageMap(name: string, param: Object) {
    if (name === 'FeedbackAdd') {
      NavDestination() {
        YqhFeedbackAdd()
      }
      .title('新增反馈')
    } else if (name === 'FeedbackDetail') {
      NavDestination() {
        YqhFeedbackDetail({ feedbackId: param as string })
      }
      .title('反馈详情')
    } else if (name === 'Settings') {
      NavDestination() {
        YqhSettings()
      }
      .title('设置')
    } else if (name === 'Mall') {
      NavDestination() {
        YqhMall()
      }
      .title('车主商城')
    } else if (name === 'MallDetail') {
      NavDestination() {
        YqhMallDetail({ productId: param as string })
      }
      .title('商品详情')
    } else if (name === 'Log') {
      NavDestination() {
        YqhLog()
      }
      .title('信息')
    }
  }

  @Builder
  tabBarBuilder(title: string, index: number) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(14)
        .fontColor(index === this.currentIndex ? COLORS.accentDeep : COLORS.inkSub)
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          Scroll() {
            Column() {
              Row() {
                Text('我的爱车')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(COLORS.ink)
                Blank()
                Row() {
                  Text('📋')
                    .fontSize(18)
                    .fontColor(COLORS.ink)
                }
                .width(36)
                .height(36)
                .borderRadius(18)
                .backgroundColor('rgba(255,255,255,0.7)')
                .justifyContent(FlexAlign.Center)
                .onClick(() => {
                  this.navPathStack.pushPath({ name: 'Log' })
                })
              }
              .width('100%')
              .padding({ left: 4, right: 4 })
              YqhCarInfoComp()
              YqhAirConditionComp()
            }
            .width('100%')
          }
          .width('100%')
          .height('100%')
        }.tabBar(this.tabBarBuilder('首页', 0))

        TabContent() {
          Scroll() {
            YqhControl()
          }
          .width('100%')
          .height('100%')
        }.tabBar(this.tabBarBuilder('车控', 1))

        TabContent() {
          YqhFeedback()
        }.tabBar(this.tabBarBuilder('反馈', 2))

        TabContent() {
          YqhMine()
        }.tabBar(this.tabBarBuilder('我的', 3))
      }
      .onSelected((val: number) => {
        this.currentIndex = val
      })
      .backgroundColor(Color.Transparent)
    }
    .navDestination(this.pageMap)
    .title('杨庆鸿的车主App')
    .linearGradient(BG_GRADIENT)
  }
}
