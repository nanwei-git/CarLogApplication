// 反馈接口函数（4.9.1 列表 / 4.9.2 新增 / 4.9.3 详情 / 4.9.4 删除）
// 全量直连真服务器（USE_MOCK=false）；实现按《鸿蒙智能座舱系统接口文档V1.1》
import { post, get, del } from '../common/utils/RequestUtil'
import { ApiPath, USE_MOCK } from '../common/constants/HttpApi'
import { IResult } from '../model/IResult'
import { Feedback, FeedBackListBean, parseFeedback } from '../model/FeedBackBean'
import { FeedbackAddReq } from '../model/ApiReq'
import { FEEDBACK_UNREAD } from '../common/constants/Constants'
import {
  mockGetFeedbackList, mockAddFeedback, mockGetFeedbackDetail, mockDeleteFeedback
} from '../common/utils/MockData'

// 4.9.1 反馈列表（GET /cockpit/feedback/backList，data 为数组）
export function getFeedbackList(pageNum: number, pageSize: number): Promise<Feedback[]> {
  if (USE_MOCK) {
    return mockGetFeedbackList(pageNum, pageSize).then((b: FeedBackListBean) => b.rows)
  }
  return get(ApiPath.feedbackList).then((res: IResult) => {
    const arr: ESObject[] = (res.data as ESObject[]) ?? []
    return arr.map((d: ESObject) => parseFeedback(d))
  })
}

// 4.9.2 新增反馈（POST /cockpit/feedback/add）
export function addFeedback(content: string): Promise<IResult> {
  if (USE_MOCK) {
    return mockAddFeedback(content)
  }
  const req: FeedbackAddReq = { content: content, status: FEEDBACK_UNREAD }
  return post(ApiPath.feedbackAdd, req)
}

// 4.9.3 反馈详情（GET /cockpit/feedback/{id}）
export function getFeedbackDetail(id: string): Promise<Feedback> {
  if (USE_MOCK) {
    return mockGetFeedbackDetail(id)
  }
  return get(ApiPath.feedbackDetail.replace('{id}', id))
    .then((res: IResult) => parseFeedback(res.data as ESObject))
}

// 4.9.4 删除反馈（DELETE /cockpit/feedback/{ids}）
export function deleteFeedback(id: string): Promise<IResult> {
  if (USE_MOCK) {
    return mockDeleteFeedback(id)
  }
  return del(ApiPath.feedbackDelete.replace('{ids}', id))
}
