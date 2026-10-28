// 数值表常量（SPEC §3）：全工程统一引用，禁止在页面里写魔法数字。

// 计时 / 提示
export const WELCOME_MS: number = 3000 // 欢迎页自动跳转
export const TOAST_MS: number = 2000 // Toast 时长
export const API_WARN_MS: number = 2000 // 请求软超时提示阈值

// 分页
export const LOG_PAGE_SIZE: number = 10 // 日志分页大小
export const PAGE_START: number = 1 // 起始页

// 空调温度（接口未给范围，按常识）
export const TEMP_MIN: number = 16
export const TEMP_MAX: number = 30
export const TEMP_STEP: number = 1
export const TEMP_DEFAULT: number = 24

// 反馈
export const FEEDBACK_MAX: number = 100 // 反馈内容最大长度
export const FEEDBACK_UNREAD: string = '0' // status：未读
export const FEEDBACK_READ: string = '1' // status：已读

// 删除标识
export const DEL_DELETED: string = '0' // delFlag：已删除
export const DEL_NORMAL: string = '1' // delFlag：正常

// 开关值（门/灯/AC/循环/除雾/风扇统一字符串）
export const SWITCH_ON: string = '1'
export const SWITCH_OFF: string = '0'

// 绑车
export const VIN_PATTERN: string = '^[A-Za-z0-9-]{4,17}$' // VIN 校验
export const VIN_MIN_LEN: number = 4
export const VIN_MAX_LEN: number = 17
export const BENCH_VIN: string = '4494356c' // 台架调试 VIN（个人 VIN 不可用于台架）

// 设置：字号档位（KT10 持久化）
export const FONT_SMALL: number = 0.9
export const FONT_NORMAL: number = 1.0
export const FONT_LARGE: number = 1.15

// 车辆移动方向（接口 4.8）：按下移动、松开停车
export const MOVE_FRONT: string = 'front'
export const MOVE_BACK: string = 'back'
export const MOVE_LEFT: string = 'left'
export const MOVE_RIGHT: string = 'right'
export const MOVE_STOP: string = 'stop'

// 商城/车辆 mock
export const MOCK_CAR_ID: string = '1'
