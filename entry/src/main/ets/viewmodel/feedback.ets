// 反馈接口函数（4.9.1 列表 / 4.9.2 新增 / 4.9.3 详情 / 4.9.4 删除）
import { post } from '../common/utils/RequestUtil'
import { ApiPath, USE_MOCK } from '../common/constants/HttpApi'
import { IResult } from '../model/IResult'
import { Feedback, FeedBackListBean, parseFeedback } from '../model/FeedBackBean'
import { FeedbackPageReq, FeedbackAddReq, FeedbackIdReq } from '../model/ApiReq'
import { FEEDBACK_UNREAD } from '../common/constants/Constants'
import {
  mockGetFeedbackList,
  mockAddFeedback,
  mockGetFeedbackDetail,
  mockDeleteFeedback
} from '../common/utils/MockData'

// 4.9.1 反馈列表（分页）
export function getFeedbackList(pageNum: number, pageSize: number): Promise<FeedBackListBean> {
  if (USE_MOCK) {
    return mockGetFeedbackList(pageNum, pageSize)
  }
  const req: FeedbackPageReq = { pageNum: pageNum, pageSize: pageSize }
  return post(ApiPath.feedbackList, req).then((res: IResult) => {
    const bean: FeedBackListBean = new FeedBackListBean()
    bean.code = res.code
    bean.msg = res.msg
    const d: ESObject = res.data as ESObject
    if (d === undefined || d === null) {
      return bean
    }
    bean.total = (d['total'] as number) ?? 0
    const rows: ESObject[] = (d['rows'] as ESObject[]) ?? []
    for (let i = 0; i < rows.length; i++) {
      bean.rows.push(parseFeedback(rows[i] as ESObject))
    }
    return bean
  })
}

// 4.9.2 新增反馈
export function addFeedback(content: string): Promise<IResult> {
  if (USE_MOCK) {
    return mockAddFeedback(content)
  }
  const req: FeedbackAddReq = { content: content, status: FEEDBACK_UNREAD }
  return post(ApiPath.feedbackAdd, req)
}

// 4.9.3 反馈详情（含官方回复）
export function getFeedbackDetail(id: string): Promise<Feedback> {
  if (USE_MOCK) {
    return mockGetFeedbackDetail(id)
  }
  const req: FeedbackIdReq = { id: id }
  return post(ApiPath.feedbackDetail, req).then((res: IResult) => parseFeedback(res.data as ESObject))
}

// 4.9.4 删除反馈
export function deleteFeedback(id: string): Promise<IResult> {
  if (USE_MOCK) {
    return mockDeleteFeedback(id)
  }
  const req: FeedbackIdReq = { id: id }
  return post(ApiPath.feedbackDelete, req)
}
