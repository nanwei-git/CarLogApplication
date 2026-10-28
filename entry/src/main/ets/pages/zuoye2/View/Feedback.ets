// 反馈数据模型与模拟数据
// 作用：定义反馈条目结构、状态枚举，并提供列表页使用的模拟数据

export enum FeedbackStatus {
  Pending = '待处理',
  Processing = '处理中',
  Resolved = '已解决'
}

export class Feedback {
  id: number;
  title: string;
  time: string;
  summary: string;
  content: string;
  status: FeedbackStatus;

  constructor(id: number, title: string, time: string, summary: string, content: string, status: FeedbackStatus) {
    this.id = id;
    this.title = title;
    this.time = time;
    this.summary = summary;
    this.content = content;
    this.status = status;
  }
}

// 模拟反馈数据（参考首页实验使用本地静态数据）
export function getMockFeedbacks(): Feedback[] {
  return [
    new Feedback(
      1,
      'App 冷启动白屏问题',
      '2026-10-12 09:30',
      '部分机型在冷启动时出现短暂白屏，影响首屏体验。',
      '在 Mate 60、Pocket 2 等机型上，应用冷启动后约 1.2 秒出现白屏，怀疑是 Splash 资源加载与首页渲染并行导致。建议优化启动帧与首屏布局的异步加载顺序。',
      FeedbackStatus.Pending
    ),
    new Feedback(
      2,
      '夜间模式对比度不足',
      '2026-10-13 14:05',
      '深色主题下部分文字与背景对比度偏低，可读性差。',
      '开启深色模式后，次要说明文字 (#888 级别) 在深色背景上几乎无法辨认，已收集 23 条用户吐槽。需要重新校准次要文本的颜色 Token。',
      FeedbackStatus.Processing
    ),
    new Feedback(
      3,
      '列表下拉刷新偶发卡顿',
      '2026-10-14 20:48',
      '弱网环境下下拉刷新会出现掉帧与回弹异常。',
      '在 4G 弱网（<-90dBm）场景下连续下拉刷新，列表出现明显掉帧，偶发回弹位置错误。初步定位为刷新回调中同步解析数据阻塞了 UI 线程。',
      FeedbackStatus.Resolved
    ),
    new Feedback(
      4,
      '提交按钮在折叠屏错位',
      '2026-10-15 11:20',
      '折叠屏展开态下底部提交按钮被安全区遮挡。',
      'Mate X5 展开态底部提交按钮部分区域落在弯折安全区内，点击热区失效。需结合安全区避让重新布局底部操作栏。',
      FeedbackStatus.Pending
    )
  ];
}
