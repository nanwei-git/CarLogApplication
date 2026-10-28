// 根页面：反馈模块 Tab 页（实验入口）
// 作用：作为 Navigation 根容器 + Tabs 布局，首页为第一个 Tab，反馈模块为第二个 Tab；
//       通过 pageMap 配置动态路由，实现列表 -> 详情 / 新增 的跳转与参数传递。
import { Feedback, getMockFeedbacks } from './View/Feedback';
import { FeedbackList } from './View/FeedbackList';
import { FeedbackDetail } from './View/FeedbackDetail';
import { AddFeedback } from './View/AddFeedback';
import { COLORS } from './View/Style';

@Entry
@Component
struct FeedbackTabPage {
  // 提供全局路由栈，供子组件 @Consume 使用
  @Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack();
  // 反馈数据（与列表页 @Link 共享，新增后自动刷新）
  @State feedbackList: Feedback[] = getMockFeedbacks();

  // 路由地图：根据页面名渲染对应的 NavDestination，并接收路由参数
  @Builder
  pageMap(name: string, param: Object) {
    if (name === 'FeedbackDetail') {
      // 详情页：从路由参数获取列表传递过来的完整数据对象
      NavDestination() {
        FeedbackDetail({ item: param as Feedback })
      }
      .title('反馈详情')
    } else if (name === 'AddFeedback') {
      // 新增页：注入保存回调，写回列表并出栈
      NavDestination() {
        AddFeedback({
          onSave: (item: Feedback) => {
            this.feedbackList.push(item);
            this.navPathStack.pop();
          }
        })
      }
      .title('新增反馈')
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Tabs({ barPosition: BarPosition.End }) {
        // 第一个 Tab：首页（保持原有内容）
        TabContent() {
          Column() {
            Text('首页内容')
              .fontSize(20)
              .fontColor(COLORS.ink2)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
        .tabBar('首页')

        // 第二个 Tab：本次实验的反馈模块
        TabContent() {
          FeedbackList({ list: $feedbackList })
        }
        .tabBar('反馈')

        // 其余 Tab 保持占位
        TabContent() {
          Column() {
            Text('视频内容')
              .fontSize(20)
              .fontColor(COLORS.ink2)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
        .tabBar('视频')

        TabContent() {
          Column() {
            Text('历史内容')
              .fontSize(20)
              .fontColor(COLORS.ink2)
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
        .tabBar('历史')
      }
      .backgroundColor(COLORS.bg)
    }
    .navDestination(this.pageMap)
    .title(this.navTitle)
    .backgroundColor(COLORS.bg)
    .height('100%')
    .width('100%')
  }

  @Builder
  navTitle() {
    Text('智能反馈中心')
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .fontColor(COLORS.ink)
  }
}