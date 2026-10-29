// 车辆操作日志 Bean（首页右上「信息」页：记录本地与远程操作）
export class OperationLog {
  id: string = ''
  title: string = '' // 主标题，如「车辆启动」「车门上锁」
  desc: string = '' // 描述，如「完成自检，电量 78%」
  time: string = '' // 发生时间
}

// 服务器 JSON → 日志数组（目前本地生成，保留解析便于后续接接口）
export function parseCarLogs(data: ESObject): OperationLog[] {
  const list: OperationLog[] = []
  if (data === undefined || data === null) {
    return list
  }
  const rows: ESObject[] = (data as ESObject[]) ?? []
  for (let i: number = 0; i < rows.length; i++) {
    const d: ESObject = rows[i] as ESObject
    const log: OperationLog = new OperationLog()
    log.id = (d['id'] as string) ?? ''
    log.title = (d['title'] as string) ?? ''
    log.desc = (d['desc'] as string) ?? ''
    log.time = (d['time'] as string) ?? ''
    list.push(log)
  }
  return list
}
