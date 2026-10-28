import { Feedback, getMockFeedbacks } from '../zuoye2/View/Feedback';
import { FeedbackList } from '../zuoye2/View/FeedbackList';
import { FeedbackDetail } from '../zuoye2/View/FeedbackDetail';
import { AddFeedback } from '../zuoye2/View/AddFeedback';
import { COLORS } from '../zuoye2/View/Style';

@Entry
@Component
struct NewtabsPage {
  @Provide('navPathStack')
  navPathStack: NavPathStack = new NavPathStack();

  // 反馈数据，与列表页 @Link 共享
  @State feedbackList: Feedback[] = getMockFeedbacks();

  @Builder pageMap(name: string, param: Object) {
    if (name === 'yqhSecondPage') {
      NavDestination() {
        Column() {
          Text('第二个页面')
            .fontSize(36)
            .fontWeight(FontWeight.Bolder)
            .fontColor(Color.Blue)
          Button('第三界面')
            .onClick(() => {
              this.navPathStack.pushPath({ name: 'yqhThirdPage' })
            })
        }
      }.title('第二界面')
    } else if (name === 'yqhThirdPage') {
      NavDestination() {
        Column() {
          Text('第三个页面')
            .fontSize(46)
            .fontColor(Color.Green)
        }
      }.title('第三界面')
    } else if (name === 'FeedbackDetail') {
      // 详情页：通过路由参数接收列表传递的数据对象
      NavDestination() {
        FeedbackDetail({ item: param as Feedback })
      }.title('反馈详情')
    } else if (name === 'AddFeedback') {
      // 新增反馈：注入保存回调，写回列表并出栈
      NavDestination() {
        AddFeedback({
          onSave: (item: Feedback) => {
            this.feedbackList.push(item);
            this.navPathStack.pop();
          }
        })
      }.title('新增反馈')
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          Column() {
            Text('首页内容')
              .fontColor(COLORS.ink2)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height('100%')
        }.tabBar('首页')
        // 第二个 Tab：本次实验的反馈模块（替换原空白占位）
        TabContent() {
          FeedbackList({ list: $feedbackList })
        }.tabBar('分类')
        TabContent() {
          Column() {
            Text('视频内容')
              .fontColor(COLORS.ink2)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height('100%')
        }.tabBar('视频')
        TabContent() {
          Column() {
            Text('历史内容')
              .fontColor(COLORS.ink2)
          }
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height('100%')
        }.tabBar('历史')
      }
      .backgroundColor(COLORS.bg)
    }
    .navDestination(this.pageMap)
    .backgroundColor(COLORS.bg)
  }
}
