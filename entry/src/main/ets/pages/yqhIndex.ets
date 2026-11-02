// 首页枢纽（Dark Neumorphism）：根 Navigation + NavPathStack + 底部拟态 Tab 栏
// 列表→详情走 navPathStack.pushPath 渲染 NavDestination（C5）。
import { neu, neuBg } from '../common/style/Style'
import { YqhNeuTabItem } from '../common/ui/yqhNeuTabItem'
import { YqhNeuCircleButton } from '../common/ui/yqhNeuCircleButton'
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

// 底部 Tab（图标用系统符号字符，零美术资产）
const TAB_TITLES: string[] = ['首页', '车辆控制', '反馈', '我的']
const TAB_ICONS: string[] = ['🏠', '🎛', '💬', '👤']

@Entry
@Component
struct YqhIndex {
  @StorageProp('darkMode') dark: boolean = true
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack()
  @State currentIndex: number = 0

  // 详情页路由表（C5：列表→详情走 NavDestination 子页）
  @Builder
  pageMap(name: string, param: Object) {
    if (name === 'FeedbackAdd') {
      NavDestination() {
        YqhFeedbackAdd()
      }
      .title('反馈建议')
    } else if (name === 'FeedbackList') {
      NavDestination() {
        YqhFeedback()
      }
      .title('反馈列表')
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

  // 首页顶栏：标题 + 操控日志入口
  @Builder
  topBar() {
    Row() {
      Column({ space: 2 }) {
        Text('我的爱车')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(neu(this.dark).ink)
        Text('轻松驾驭 · 快乐出行')
          .fontSize(11)
          .fontColor(neu(this.dark).inkSub)
      }
      .alignItems(HorizontalAlign.Start)
      Blank()
      YqhNeuCircleButton({
        icon: '📋',
        diameter: 48,
        onBtnClick: () => {
          this.navPathStack.pushPath({ name: 'Log' })
        }
      })
    }
    .width('100%')
    .padding({ left: 8, right: 8 })
  }

  @Builder
  tabBarBuilder(icon: string, title: string, index: number) {
    YqhNeuTabItem({ icon: icon, title: title, active: index === this.currentIndex })
  }

  build() {
    Navigation(this.navPathStack) {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          Scroll() {
            Column({ space: 4 }) {
              this.topBar()
              YqhCarInfoComp()
              YqhAirConditionComp()
            }
            .width('100%')
            .padding({ bottom: 24 })
          }
          .width('100%')
          .height('100%')
        }.tabBar(this.tabBarBuilder(TAB_ICONS[0], TAB_TITLES[0], 0))

        TabContent() {
          Scroll() {
            YqhControl()
          }
          .width('100%')
          .height('100%')
        }.tabBar(this.tabBarBuilder(TAB_ICONS[1], TAB_TITLES[1], 1))

        TabContent() {
          YqhFeedback()
        }.tabBar(this.tabBarBuilder(TAB_ICONS[2], TAB_TITLES[2], 2))

        TabContent() {
          YqhMine()
        }.tabBar(this.tabBarBuilder(TAB_ICONS[3], TAB_TITLES[3], 3))
      }
      .onSelected((val: number) => {
        this.currentIndex = val
      })
      .barHeight(78)
      .barBackgroundColor(Color.Transparent)
      .backgroundColor(Color.Transparent)
    }
    .navDestination(this.pageMap)
    .title('杨庆鸿的车主App')
    .linearGradient(neuBg(this.dark))
  }
}
