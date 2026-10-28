// 反馈列表/详情 Bean（接口 4.9.1–4.9.4）；字段与 SPEC §4 一致
export class Feedback {
  id: string = ''
  userId: string = ''
  userName: string = ''
  nickName: string = ''
  phonenumber: string = ''
  content: string = ''
  status: string = '' // '0' 未读 / '1' 已读
  picUrl: string = ''
  delFlag: string = '' // '0' 删除 / '1' 正常
  replyRead: string = ''
  createTime: string = ''
  updateTime: string = ''
  reply: string = '' // 官方回复内容（服务器返回对象时取 content）
}

export class FeedBackListBean {
  code: number = 0
  msg: string = ''
  total: number = 0
  rows: Feedback[] = []
}

// 服务器 JSON → Feedback：逐字段兜底
export function parseFeedback(data: ESObject): Feedback {
  const bean: Feedback = new Feedback()
  if (data === undefined || data === null) {
    return bean
  }
  const d: ESObject = data as ESObject
  bean.id = (d['id'] as string) ?? ''
  bean.userId = (d['userId'] as string) ?? ''
  bean.userName = (d['userName'] as string) ?? ''
  bean.nickName = (d['nickName'] as string) ?? ''
  bean.phonenumber = (d['phonenumber'] as string) ?? ''
  bean.content = (d['content'] as string) ?? ''
  bean.status = (d['status'] as string) ?? ''
  bean.picUrl = (d['picUrl'] as string) ?? ''
  bean.delFlag = (d['delFlag'] as string) ?? ''
  bean.replyRead = (d['replyRead'] as string) ?? ''
  bean.createTime = (d['createTime'] as string) ?? ''
  bean.updateTime = (d['updateTime'] as string) ?? ''
  const rp: ESObject = d['reply'] as ESObject
  if (rp !== undefined && rp !== null) {
    bean.reply = (rp['content'] as string) ?? ''
  }
  return bean
}
