import { ResourceData } from "./ResourceData"

// 推荐课程数据
export const recommendList: ResourceData[] = [
  {
    id: '1',
    imgSrc: $r('app.media.enablement_pic1'),
    title: 'Android应用开发',
    description: '本例中获取天气通过中国天气网和51万年历获取，也许有其他方式来获取，这里定义了接口，统一获取天气的方式，然后在两种方式获取的M中实现'
  },
  {
    id: '2',
    imgSrc: $r('app.media.enablement_pic2'),
    title: '前端开发实践',
    description: '该项目是应用在移动端的App项目。项目包括启动界面、首页、目的地、景点、登录页、注册页、我的、相册和评论9个页面。功能包括登录信息验证，注册信息验证，个人信息修改，无刷新评论和移动端相册等。'
  },
  {
    id: '3',
    imgSrc: $r('app.media.enablement_pic3'),
    title: 'PHP开发实践（ThinkPHP）',
    description: '利用Thinkphp技术实现的一个餐饮店管理系统'
  },
  {
    id: '4',
    imgSrc: $r('app.media.enablement_pic4'),
    title: '足球赛事预告',
    description: '实现了足球比赛信息的展示（包括英超, 西甲, 德甲, 意甲, 法甲, 中超），用户也可以观看比赛的视频直播与文字直播'
  },
  {
    id: '5',
    imgSrc: $r('app.media.enablement_pic5'),
    title: '知行天气',
    description: '通过和风天气提供的免费API获取实时天气信息，并且可以进行添加、删除、搜索城市。'
  },
  {
    id: '6',
    imgSrc: $r('app.media.enablement_pic6'),
    title: '掌上东软',
    description: '进入app后首先看到的是闪屏页，实现了旋转、缩放、渐变等效果。'
  }
]
