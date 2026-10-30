// 反馈列表（M7，接口 4.9.1/4.9.4）：下拉刷新 + 上拉加载 + 左滑删除（二次确认）
// 由 yqhIndex 的"反馈" TabContent 组装；列表→详情走 NavDestination（C5）
// 原型对齐：标题「反馈列表」+ 右上圆形「+」；卡片 时间(灰)/内容(黑两行)/分隔线/查看详情 ›
import { promptAction } from '@kit.ArkUI'
import { COLORS } from '../common/style/Style'
import { YqhGlassCard } from '../views/yqhGlassCard'
import { getFeedbackList, deleteFeedback } from '../viewmodel/feedback'
import { Feedback, FeedBackListBean } from '../model/FeedBackBean'
import { IResult } from '../model/IResult'
import { PAGE_START, LOG_PAGE_SIZE, TOAST_MS, FEEDBACK_UNREAD } from '../common/constants/Constants'

@Component
export struct YqhFeedback {
  @Consume('navPathStack') navPathStack: NavPathStack
  @StorageLink('feedbackDirty') @Watch('onDirty') dirty: boolean = false
  @State list: Feedback[] = []
  @State refreshing: boolean = false
  @State loading: boolean = true
  @State loadingMore: boolean = false
  @State pageNum: number = PAGE_START
  @State hasMore: boolean = true
  @State total: number = 0

  aboutToAppear(): void {
    this.refresh()
  }

  // 新增/删除页写脏标记 → 返回列表自动刷新
  onDirty(): void {
    if (this.dirty) {
      this.refresh()
      this.dirty = false
    }
  }

  private toast(msg: string): void {
    promptAction.showToast({ message: msg, duration: TOAST_MS })
  }

  private refresh(): void {
    this.pageNum = PAGE_START
    this.hasMore = true
    this.load(true)
  }

  private loadMore(): void {
    if (!this.hasMore || this.loadingMore || this.loading) {
      return
    }
    this.pageNum = this.pageNum + 1
    this.load(false)
  }

  private load(reset: boolean): void {
    getFeedbackList(this.pageNum, LOG_PAGE_SIZE)
      .then((res: FeedBackListBean) => {
        if (reset) {
          this.list = res.rows
        } else {
          this.list = this.list.concat(res.rows)
        }
        this.total = res.total
        this.hasMore = this.list.length < res.total
        this.loading = false
        this.loadingMore = false
        this.refreshing = false
      })
      .catch(() => {
        this.loading = false
        this.loadingMore = false
        this.refreshing = false
        this.toast('反馈列表获取失败，请稍后重试')
      })
  }

  private doDelete(item: Feedback): void {
    deleteFeedback(item.id)
      .then((res: IResult) => {
        if (res.code === 200 || res.code === 0) {
          this.toast('删除成功')
          this.refresh()
        } else {
          this.toast(res.msg || '删除失败')
        }
      })
      .catch(() => {
        this.toast('网络异常，请稍后重试')
      })
  }

  // 左滑删除 + 二次确认对话框
  @Builder
  delBuilder(item: Feedback) {
    Row() {
      Text('删除')
        .fontSize(14)
        .fontColor('#FFFFFF')
    }
    .width(72)
    .height('100%')
    .backgroundColor(COLORS.danger)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      AlertDialog.show({
        title: '删除反馈',
        message: '删除后不可恢复，确定删除这条反馈吗？',
        autoCancel: true,
        alignment: DialogAlignment.Center,
        primaryButton: {
          value: '取消',
          fontColor: COLORS.inkSub,
          action: () => {
          }
        },
        secondaryButton: {
          value: '删除',
          fontColor: COLORS.danger,
          action: () => {
            this.doDelete(item)
          }
        }
      })
    })
  }

  @Builder
  feedbackItem(item: Feedback) {
    YqhGlassCard({ pad: 16 }) {
      Column({ space: 8 }) {
        Text(item.createTime)
          .fontSize(12)
          .fontColor(COLORS.inkSub)
        Text(item.content)
          .fontSize(15)
          .fontColor(COLORS.ink)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Divider()
          .color(COLORS.line)
          .width('100%')
        Row() {
          Blank()
          Row({ space: 4 }) {
            Text('查看详情')
              .fontSize(13)
              .fontColor(COLORS.accent)
            Text('›')
              .fontSize(16)
              .fontColor(COLORS.inkSub)
          }
        }
        .width('100%')
      }
    }
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        Text('反馈列表')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(COLORS.ink)
        Button('+')
          .width(40)
          .height(40)
          .borderRadius(20)
          .fontSize(26)
          .fontColor(COLORS.accent)
          .backgroundColor(COLORS.card)
          .border({ width: 1, color: COLORS.line })
          .onClick(() => {
            this.navPathStack.pushPath({ name: 'FeedbackAdd' })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ left: 16, right: 16, top: 8 })

      if (this.loading) {
        LoadingProgress()
          .width(28)
          .height(28)
          .color(COLORS.accent)
      } else if (this.list.length === 0) {
        Text('暂无反馈，点击右上角"+"提交')
          .fontSize(13)
          .fontColor(COLORS.inkSub)
          .padding(24)
      } else {
        Refresh({ refreshing: $$this.refreshing }) {
          List({ space: 10 }) {
            ForEach(this.list, (item: Feedback) => {
              ListItem() {
                this.feedbackItem(item)
              }
              .padding({ left: 16, right: 16 })
              .onClick(() => {
                this.navPathStack.pushPath({ name: 'FeedbackDetail', param: item.id })
              })
              .swipeAction({
                end: (): void => {
                  this.delBuilder(item)
                }
              })
            }, (item: Feedback) => item.id)
            if (this.loadingMore || this.hasMore) {
              ListItem() {
                Row() {
                  Text(this.loadingMore ? '加载中…' : '上拉加载更多')
                    .fontSize(12)
                    .fontColor(COLORS.inkSub)
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .height(44)
              }
            }
          }
          .width('100%')
          .height('100%')
          .onReachEnd(() => {
            this.loadingMore = true
            this.loadMore()
          })
        }
        .width('100%')
        .layoutWeight(1)
        .onRefreshing(() => {
          this.refresh()
        })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ top: 12, bottom: 12 })
  }
}
