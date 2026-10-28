// 首页枢纽（M1 骨架）：根 Navigation + NavPathStack + 底部 Tabs（首页/车控/反馈/我的）
// 列表→详情后续里程碑通过 navPathStack.pushPath 走 NavDestination（C5 已裁决）。
import { COLORS, BG_GRADIENT } from '../../common/style/Style'

@Entry
@Component
struct YqhIndex {
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack()
  @State currentIndex: number = 0

  // 详情页路由表（M2+ 按 name 渲染各 NavDestination）
  @Builder
  pageMap(name: string, param: Object) {
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
          Column() {
            Text('首页（M4+ 车辆信息 / 智能空调）')
              .fontColor(COLORS.ink)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height('100%')
        }.tabBar(this.tabBarBuilder('首页', 0))

        TabContent() {
          Column() {
            Text('车控（M6+ 门窗灯 / 移动）')
              .fontColor(COLORS.ink)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height('100%')
        }.tabBar(this.tabBarBuilder('车控', 1))

        TabContent() {
          Column() {
            Text('反馈（M7+ 列表 / 新增 / 详情）')
              .fontColor(COLORS.ink)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height('100%')
        }.tabBar(this.tabBarBuilder('反馈', 2))

        TabContent() {
          Column() {
            Text('我的（M8+ 个人信息 / 换绑 / 设置）')
              .fontColor(COLORS.ink)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height('100%')
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
