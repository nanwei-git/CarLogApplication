import App from '@system.app';
import { HomeCom } from './Views/HomeCom';
import { ResourceCom } from './Views/ResourceCom';
import { TaskCom } from './Views/TaskCom';
import { MineCom } from './Views/MineCom';

// 定义导航项数据接口
interface NavItem {
  title: string,
  targetIndex: number,
  iconImg: Resource,
  activeIconImg: Resource
}

@Entry
@Component
struct IndexyqhPage {
  @State currentIndex: number = 0;
  // 底部导航数据
  @State navItem: NavItem[] = [
    {
      title: '首页',
      targetIndex: 0,
      iconImg: $r('app.media.HOME_line'),
      activeIconImg: $r('app.media.HOME_theme')
    },
    {
      title: '资源',
      targetIndex: 1,
      iconImg: $r('app.media.FIND_line'),
      activeIconImg: $r('app.media.FIND_theme')
    },
    {
      title: '任务',
      targetIndex: 2,
      iconImg: $r('app.media.SUB_line'),
      activeIconImg: $r('app.media.SUB_theme')
    },
    {
      title: '我的',
      targetIndex: 3,
      iconImg: $r('app.media.MINE_line'),
      activeIconImg: $r('app.media.MINE_theme')
    }
  ];
  @Builder tabBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 25, height: 25 })
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? '#1698CE' : '#6B6B6B')
    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }
  build() {
    Tabs({ barPosition: BarPosition.End }) {
      //渲染TabContent
      ForEach(this.navItem, (item: NavItem, index) => {
        TabContent() {
          if (index === 0) {
            HomeCom()
          }
          else if (index === 1) {
            ResourceCom()
          }
          else if (index === 2) {
            TaskCom()
          }
          else if (index === 3) {
            MineCom()
          }
        }
        .tabBar(this.tabBuilder(item.title, item.targetIndex, item.activeIconImg, item.iconImg))
      })
    }
    .onSelected((val) => {this.currentIndex = val;})

  }
}

