# SPEC · 车主 App（HarmonyOS ArkTS 原生版）

> 状态：**M1–M8 功能全部落地，M9 视觉改版完成 → 现处 S5 打磨 / S6 交付**。
> 来源：鸿蒙智能座舱系统需求文档 V1.3、接口文档 V1.1、业务流程判断节点说明、东软实验指导书。
> 视觉主题：**Dark Neumorphism（特斯拉风深色拟态）**——已取代原「用户色卡 奶油黄→薄荷青」与 Apple Liquid Glass 参考，见 §5 / `DECISIONS.md` D1。
> 约定：遵循 `AI-WORKFLOW.md`（规格先于代码、一次一个可验证变化、疑问优先）。项目地图/代码索引见 `CLAUDE.md`，决策记录见 `DECISIONS.md`。

---

## 0. 约束变更说明（重要）

你最初要求 SPEC 包含「静态站 / 零美术资产 / 无构建步骤」三条硬约束，但随后选择「忠实鸿蒙 ArkTS」。二者无法共存，按你的选择裁定：

| 原硬约束 | 裁定 | 理由 |
|---|---|---|
| 静态站 | **舍弃** | ArkTS 须由 DevEco/鸿蒙工具链编译打包，不是浏览器静态资源。 |
| 无构建步骤 | **舍弃** | 同上，鸿蒙工程必然有编译/签名步骤。 |
| 零美术资产 | **保留（口径见下方补充）** | 不新增 png/jpg/mp3 等美术/音频文件；改用 ArkUI 内置组件、矢量绘制（Shape/Path）、系统符号/emoji 或纯色/渐变占位。 |

> **现状补充（M9）**：课程推进中实际引入了 4 个 media 图片（车辆底图 `bg_start`/`bg_owner_car`、控制图标 `ic_door_lock`/`ic_light_open`，来源与许可证已标注在设置页「素材来源」）。故该约束**执行口径放宽为「不再新增美术资产，图标优先 emoji + ArkUI 绘制」**——M9 视觉改版本身**未新增任何图片**，拟态质感（双投影 / 渐变 / 凹陷轨道）全部由 ArkUI 绘制。

**技术靶心 = 鸿蒙 ArkTS（Stage 模型 + ArkUI 声明式 + MVVM 分层）**，满足东软实验指导书的 KT1–KT11 与评分标准。

---

## 0.1 项目标识与个人信息（C1 / C7 已裁决）

- 姓名：杨庆鸿 ｜ 班级：24002 ｜ 学号：240002120509
- 工程命名（指导书"姓名首字母拼音班级学号"）：`yqh24002240002120509`（杨 y / 庆 q / 鸿 h + 班级 24002 + 学号 240002120509）。工程根目录已落地为 `D:\Harmony\yqh24002240002120509`（由 `CarLogApplication` 迁入改名，原 `yqhapplication` 已并入同一根）。
- 应用名称（`module.json5` 的 `label`）：`杨庆鸿的车主App`
- 个人 VIN（绑车用）：`00661718330`（车辆：小米SU7）。台架调试须用给定 VIN `4494356c`，个人 VIN 不可用于台架。
- SDK / API 版本（C7 已裁决）：HarmonyOS NEXT，**API 12+**，Stage 模型。

## 1. 核心循环一句话

**用户打开 App → 欢迎页 3s 按登录态分流 → 登录/注册/绑车 → 在「首页 / 车控 / 反馈 / 我的」四个页面查看车辆与个人信息、远程控车（空调 + 移动/门窗灯）、提交并管理反馈、浏览车主商城（列表+详情+收藏），所有数据走本地 token 鉴权的 HTTP 接口（可一键切 mock）。**

---

## 2. 模块划分（文件 / 职责 / 实测行数；车主 App 部分 ≈ 4250 行，不含课堂作业 3094 行）

工程采用 Stage 模型 + MVVM 目录（参考华为官方 ArkTS-MVVM，**遵循既有 `yqhapplication` 代码规范**：struct 带 `yqh` 前缀、组件 `XxxCom.ets`/`Xxx.ets`、`@kit` 导入、`AppStorage`+`PersistentStorage` 持久化、根 `Navigation`+`NavPathStack`+`Tabs` 导航、集中 `Style.ets` 令牌）。

> **目录已于 MVVM 重构后变更（与此前记录不同，下表为现况）**：模型在 `ets/model/`、接口函数在 `ets/viewmodel/`、业务组件在 `views/comps/`、通用控件在 `common/ui/`、页面直接放 `pages/` 根（**不再有 `pages/yqhcar/` 分组**）；启动页 `pages/yqhWelcome` 注册为 `main_pages.json` 首项。车主 App 与课堂作业（`pages/leson*`、`pages/zuoye*`、`pages/login`、`pages/Perferences`、`pages/Index.ets`）严格隔离，后者只读不改。
> 视觉主题已于 M9 改为 **Dark Neumorphism（特斯拉风深色拟态）**，见 §5「UI 风格」与 `DECISIONS.md` D1。图标用 emoji + ArkUI 绘制（仅保留 4 个既有 media 图片：车辆底图 `bg_start`/`bg_owner_car`、控制图标 `ic_door_lock`/`ic_light_open`），见 §0 约束变更说明。

> 行数为当前实测值（含本次 M9 视觉改版）。

| 文件 | 行 | 职责 | 什么时候改它 |
|---|---|---|---|
| **入口** | | | |
| `entry/src/main/ets/entryability/EntryAbility.ets` | 50 | Ability 生命周期；冷启动进入 `pages/yqhWelcome` | 改启动/权限 |
| **视图 · 页面**（`pages/`，共 14 个车主页） | | | |
| `pages/yqhWelcome.ets` | 59 | 欢迎页：拟态品牌环 + 标语，3s 后按 `isLogin` 分流 | 改欢迎页 |
| `pages/yqhLogin.ets` | 200 | 登录：账号密码→`getLogin`→存 token→`getUserInfo` 判 carVin→绑车/首页；401 内联红字 | 改登录 |
| `pages/yqhRegister.ets` | 159 | 注册：两次密码一致校验、必填校验、调用 `getRegister` | 改注册 |
| `pages/yqhBindCar.ets` | 132 | 绑车/换绑：VIN 校验→`bindCarByVin`→回首页（`from=mine` 时 back） | 改绑车 |
| `pages/yqhIndex.ets` | 142 | 根 `Navigation`+`NavPathStack`+`Tabs` 枢纽：四个 Tab（首页/车辆控制/反馈/我的）；`pageMap` 挂 7 个子页（C5） | 改导航 / 加子页 |
| `pages/yqhControl.ets` | 231 | 车控：十字方向键（按住移动/松开停车）+ 车门/车灯/空调圆键（4.6/4.8） | 改车控 |
| `pages/yqhFeedback.ets` | 242 | 反馈列表：下拉刷新 / 上拉加载 / 左滑删除 + 二次确认（4.9.1/4.9.4） | 改反馈列表 |
| `pages/yqhFeedbackAdd.ets` | 109 | 新增反馈：≤100 字校验（4.9.2） | 改新增 |
| `pages/yqhFeedbackDetail.ets` | 104 | 反馈详情 + 官方回复（4.9.3） | 改详情 |
| `pages/yqhLog.ets` | 82 | 车辆操作日志「信息」页（当前本地生成，接口 4.10 预留） | 改日志 |
| `pages/yqhMall.ets` | 150 | 车主商城列表：优惠提醒 + 商品卡 + 收藏 | 改商城列表 |
| `pages/yqhMallDetail.ets` | 158 | 商城详情：价格/优惠/描述/收藏 + **产品评价**（C4） | 改商城详情 |
| `pages/yqhMine.ets` | 167 | 我的：凹陷头像 + 昵称 + VIN 条 + 三行入口 + 退出登录（清状态） | 改我的 |
| `pages/yqhSettings.ets` | 143 | 设置：字号三档 + 深色拟态主题（PersistentStorage，KT10）+ 素材来源 | 改设置 |
| **视图 · 业务组件**（`views/comps/`） | | | |
| `views/comps/yqhCarInfoComp.ets` | 200 | 首页车辆信息卡：环形电量表盘 + 门/灯/空调圆键（4.5/4.6） | 改车辆信息 |
| `views/comps/yqhAirConditionComp.ets` | 224 | 首页智能空调：环形温度旋钮 + 循环/A·C/除雾（4.6/4.7） | 改空调 |
| **视图 · 通用组件库**（`common/ui/`，业务页只组装） | | | |
| `common/ui/yqhNeuCard.ets` | 53 | 拟态卡片（凸起 / 凹陷双投影） | 改卡片 |
| `common/ui/yqhNeuButton.ets` | 61 | 主/次按钮（红渐变发光 / 拟态凸起） | 改按钮 |
| `common/ui/yqhNeuCircleButton.ets` | 99 | 圆形快捷键：凸起→按下凹陷微缩→激活发光；支持 emoji / 图片 / 标签 / 长按 | 改圆键 |
| `common/ui/yqhNeuRing.ets` | 58 | 环形表盘（电量 / 温度），凹陷轨道 | 改表盘 |
| `common/ui/yqhNeuToggle.ets` | 55 | 开关行 | 改开关 |
| `common/ui/yqhNeuTabItem.ets` | 39 | 底部 Tab 项（选中凹陷 + 主色） | 改 Tab |
| `common/ui/yqhNeuChip.ets` | 38 | 状态徽标（accent/ok/warn/danger） | 改徽标 |
| **数据 · 接口函数**（`viewmodel/`） | | | |
| `viewmodel/auth.ets` | 39 | 登录 / 注册 / 用户信息 / 绑车 | 改鉴权接口 |
| `viewmodel/car.ets` | 78 | 车辆信息 / 状态 / 状态变更(PUT) / 移动 / 操作日志 / 独立车门·车灯控制 | 改车辆接口 |
| `viewmodel/feedback.ets` | 43 | 反馈列表(数组) / 新增 / 详情 / 删除 | 改反馈接口 |
| `viewmodel/mall.ets` | 12 | 商城列表 / 收藏（本地 mock） | 改商城接口 |
| **数据 · 模型**（`model/`） | 284 | `ApiReq`68 / `CarInfoBean`42 / `CarStateBean`36 / `CarLogBean`23 / `FeedBackBean`46 / `MallBean`50 / `UserInfoBean`13 / `IResult`6：请求体 + `parseXxx` 解析 | 加 / 改字段 |
| **基础设施** | | | |
| `common/utils/RequestUtil.ets` | 79 | 统一 GET/PUT/POST/DELETE：Bearer 鉴权、响应体 `code===401` 清态跳登录、hilog 埋点 | 改请求 / 错误 |
| `common/utils/StorageUtils.ets` | 97 | `StorageKeys` + `AppStorage`/`PersistentStorage` 封装（KT10） | 改持久化 |
| `common/utils/MockData.ets` | 359 | 与接口字段一致的本地 mock（登录/用户/车辆/状态/反馈/日志/商城），`USE_MOCK=true` 时兜底 | 调 mock |
| `common/constants/HttpApi.ets` | 56 | `BaseUrl` + 18 条接口路径（/app/login、/system/user/register、/getInfo、/cockpit/**）+ `USE_MOCK` 开关（C2，现状 `false`） | 改接口地址 / 切 mock |
| `common/constants/Constants.ets` | 47 | 数值表（含 `NEU_*` 拟态几何常量，见 §3） | 调数值 |
| `common/style/Style.ets` | 152 | 设计令牌：`NEU_DARK`/`NEU_LIGHT` + `neu()`/`neuBg()`（另保留旧 `COLORS` 色卡） | 改主题 |
| `entry/src/main/module.json5` + `resources/base/profile/main_pages.json` + `resources/base/element/string.json` | — | INTERNET 权限、22 个页面注册（启动页 `yqhWelcome` 首项）、应用名 `杨庆鸿的车主App`、字符串资源 | 改权限 / 注册 |
| **遗留（未引用，保留待清）** | | | |
| `views/yqhGlassCard.ets`20 / `views/yqhButton.ets`29 / `views/yqhToggle.ets`43 | 92 | 旧浅色玻璃风组件，车主 App 已不再引用 | — |
| **课堂作业（只读，不许改）** | | | |
| `pages/leson*/`、`pages/zuoye*/`、`pages/login/`、`pages/Perferences/`、`pages/Index.ets` | 3094 / 51 个文件 | 课程草稿，与车主 App 隔离 | 不许改 |
| **合计（车主 App 部分）** | **≈ 4250** | 66 个 .ets 文件 | |

> 单文件不超过 800 行；一个文件一个职责；struct 命名带 `yqh` 前缀体现原创性；遵循既有 `yqhapplication` 代码规范（见 §8）。

---

## 3. 数值表（落 `Constants.ets`）

| 项 | 键 | 值 | 说明 |
|---|---|---|---|
| 欢迎页自动跳转 | `WELCOME_MS` | 3000 | 到时按登录态分流 |
| 接口基地址 | `BASE_URL` | `http://121.36.14.143:10001` | 真服务器 |
| Mock 开关 | `USE_MOCK` | **`false`（现状，已直连真服务器）** | 整套 App 已直连真服务器 `BaseUrl`；`MockData.ets` 仅作离线兜底（D4 / D12） |
| 请求软超时提示阈值 | `API_WARN_MS` | 2000 | 评分要求响应 <2s，超则 toast |
| Toast 时长 | `TOAST_MS` | 2000 | |
| 日志分页大小 | `LOG_PAGE_SIZE` | 10 | 接口 `pageSize` |
| 起始页 | `PAGE_START` | 1 | |
| 空调设置温度 | `TEMP_MIN/MAX/STEP/DEFAULT` | 16 / 30 / 1 / 24 | 接口未给范围，按常识 |
| 反馈内容长度 | `FEEDBACK_MAX` | 100 | 空则报错 |
| 反馈读取状态 | `status` | 0 未读 / 1 已读 | |
| 删除标识 | `delFlag` | 0 删除 / 1 正常 | |
| 开关值 | `ON/OFF` | `"1"` / `"0"` | 门/灯/AC/循环/除雾/风扇统一字符串 |
| VIN 校验 | `VIN_PATTERN` | `^[A-Za-z0-9-]{4,17}$` | 台架 VIN=`4494356c` |
| 默认 mock carId | `MOCK_CAR_ID` | `"1"` | |
| 视觉参考（M9 更新） | — | **Dark Neumorphism（特斯拉风深色拟态）**：卡片与背景同色，靠双投影造体积 | 见 §5 / `DECISIONS.md` D1 |
| 拟态阴影偏移 | `NEU_DISTANCE` / `NEU_DISTANCE_SM` | 6 / 4 | 右下暗影偏移；小控件用小值 |
| 拟态阴影模糊 | `NEU_BLUR` / `NEU_BLUR_SM` / `NEU_BLUR_GLOW` | 12 / 8 / 16 | GLOW 用于激活态发光 |
| 卡片圆角 | `NEU_RADIUS` / `NEU_RADIUS_SM` | 24 / 16 | |
| 触控目标 | — | ≥ 44×44 vp | 无障碍 |

---

## 4. 类型表（ArkTS `interface` / `class`，落 `model/`）

```ts
// IResult.ets
export interface IResult { code: number; msg: string; token?: string; }

// UserInfoBean.ets
export class UserInfoBean {
  carVin: string = ''; carId: string = '';
  user: User = new User();
}
export class User { userId: string=''; nickName=''; userName=''; phonenumber=''; sex=''; avatar=''; email=''; status=''; }

// CarInfoBean.ets（接口4.5 data）
export class CarInfoBean {
  id=''; carName=''; brand=''; carVin=''; batteryPower:string=''; enduranceMileage='';  // 接口返回字符串（如 "999"），续航百分比用 Number() 解析
  horsePower=''; maxPower=''; maxTorque=''; carSize=''; wheelBase='';
  batteryCapacity=''; nominalVoltage=''; totalTripNum=0; totalTripMile=''; createYm='';
}

// CarStateBean.ets（接口4.6 data + 4.7 请求体）
export class CarStateBean { msg=''; code=0; data: CarStat = new CarStat(); }
export class CarStat {
  carId=''; door=''; light=''; temperature=''; windLevel=''; circulate='0';
  setTemp=''; acBtn='1'; clearFog='0'; fanState=''; carVin='';
}
export class CarStateChange { carVin=''; acBtn?; circulate?; clearFog?; setTemp?; door?; light?; ... }

// FeedBackBean.ets（反馈列表接口直接返回 Feedback[] 数组，无外层包装）
export class Feedback { id=''; userId=''; userName=''; nickName=''; phonenumber=''; content=''; status=''; picUrl=''; delFlag=''; replyRead=''; createTime=''; updateTime=''; reply?: object; }

// MessageInfoBean.ets（接口4.10；响应中 total/rows 在顶层，rows 即日志数组）
export class MessageInfoBean { total=0; rows: MessageInfo[] = []; code=0; msg=''; }
export class MessageInfo { id=0; userId=''; userName=''; carId=''; carName=''; operaType=''; operaContent=''; createTime=''; }

// MallBean.ets（自定义商城 mock）
export class MallProduct { id=''; name=''; price=0; originalPrice=0; discount=''; desc=''; sales=0; fav=false; tag=''; reviews: Review[] = []; }
export class Review { user=''; rating=5; content=''; time=''; }

// ApiReq.ets
export interface LoginReq { username: string; password: string; }
export interface RegisterReq { nickName:string; userName:string; phonenumber:string; sex:string; avatar:string; password:string; roleIds:string[]; birthDate:string; state:string; }
export interface BindReq { carVin: string; }
```

---

## 5. 技术选型

- **语言/框架**：ArkTS + ArkUI 声明式（HarmonyOS NEXT，Stage 模型）。
- **架构**：MVVM 分层（`model/` 数据模型 / `viewmodel/` 接口函数 / `common/utils`、`common/constants`、`common/style` 工具 / `pages/` + `views/comps/` + `common/ui/` 视图）；页面级状态 `@State/@Prop/@Link`（KT6），应用级共享 `@Provide/@Consume` + `AppStorage`/`PersistentStorage`（KT7）。**目录已按 MVVM 重构，旧路径 `common/model`、`common/api`、`pages/yqhcar` 已不存在**。
- **路由**：欢迎/登录/注册/绑车用 `@ohos.router`（`replaceUrl`，须 `@Entry`）；首页根 `Navigation` 承载底部模块切换（首页/车控/反馈/我的 四个 `NavDestination` + 自定义底部 Tab 栏），页内列表→详情用 `Navigation` 子页（实验指导书推荐，C5 已裁决）。
- **网络**：`@kit.NetworkKit` 的 `http`（`httpRequest.request`），需 `module.json5` 声明 `ohos.permission.INTERNET`；统一封装于 `common/utils/RequestUtil.ets`（**GET / PUT / POST / DELETE 四方法**，按《接口文档 V1.1》选用），含 `USE_MOCK` 开关（C2 裁决为 `false` 直连真服务器 `BaseUrl`；**现状已为 `false`**，整套 App 直连，接口路径见 `HttpApi.ets`）。服务器恒返回 HTTP 200，成败看响应体 `code`（200 成功 / 401 鉴权 / 500 业务）。请求/响应/耗时用 `hilog`（tag `yqhHttp`）落日志，便于联调。
- **绑车判据（C3 已裁决）**：登录成功后 `getUserInfo`，仅当 `carVin` 为空才进绑车页，否则进首页（贴合需求文档/流程节点，不判 `carId`）。
- **持久化（KT10，遵循既有代码规范）**：采用既有 `PersistentStorage.persistProp` + `AppStorage`（`setOrCreate`/`get`/`@StorageProp`/`@StorageLink`）模式，底层即为"用户首选项"；`StorageUtils.ets` 仅封装键名常量，存 token/carVin/carId/userId/userName/avatar/isLogin。**注**：与实验指导书示例的 `preferences.getPreferencesSync` 写法不同，但同为 KT10 持久化，且更贴合本工程既有规范。
- **UI 风格（M9 已裁决：Dark Neumorphism 特斯拉风深色拟态，覆盖先前的"用户色卡"与"暗色玻璃"）**：近黑底 `#22262B` + 特斯拉红 `#E82127`；卡片与背景同色，靠「左上亮边 + 右下暗影」双层投影造体积；进度/表盘用凹陷轨道；主按钮红渐变 + 柔光；正文 `#EAEEF3` 保证暗底对比度。**零新增美术资产**（质感全部由 ArkUI 绘制）。拟态令牌见 §8 第 7 条。
- **图标（M9 已更新）**：业务页一律用 **emoji + ArkUI 绘制**（零美术资产，规避 `SymbolGlyph` 在部分 API 版本的兼容问题）；仅车辆底图 `bg_start`/`bg_owner_car` 与控制图标 `ic_door_lock`/`ic_light_open` 沿用既有 4 个 media 图片；头像用字母圆形占位（凹陷面），不新增任何 media 资源。
- **命名与目录（遵循既有规范，M9 已同步现况）**：struct 带 `Yqh` 前缀、PascalCase（如 `YqhLogin`/`YqhIndex`）体现原创性；页面文件 `pages/yqhXxx.ets`、业务组件 `views/comps/yqhXxxComp.ets`、通用控件 `common/ui/yqhNeuXxx.ets`；车主 App 页面直接置于 `pages/` 根（课堂作业 `pages/leson*|zuoye*|login|Perferences` 隔离，只读不改）；启动页 `pages/yqhWelcome` 注册为 `main_pages.json` 首项；应用名在 `string.json` 设为 `杨庆鸿的车主App`（C1）。
- **扩展技术**：① 列表下拉刷新（`Refresh`）+ 上拉加载（`List.onReachEnd`/`edgeEffect`）；② 请求封装（已做）；③ 可选 Axios（鸿蒙版）作为加分项；④ 设置页字号/主题持久化（KT10）。

---

## 6. 里程碑 M0–M8（每个一个可验收的"能看到什么"）

| 里程碑 | 能看到什么（玩家可感知） |
|---|---|
| **M0** | 本 SPEC 定稿（模块划分、数值/类型表、约束裁定）。无代码。 |
| **M1** | 工程可编译运行；**欢迎页**出现（深色拟态底 + 拟态品牌环），3s 后按是否已登录自动跳登录页或首页。**完成后 git 提交并推送（见 §9）**。 |
| **M2** | **登录 / 注册页**可用：登录存 token；注册含"两次密码一致"校验与"账号已存在"提示。**（已完成）** |
| **M3** | **绑车流程**：首次登录（无 carVin）强制进绑车页，VIN 格式校验，绑定后回首页；非首次直进首页。 |
| **M4** | **首页车辆信息卡**：显示车辆名称、可续航里程、电池电量+百分比、更新时间（接口4.5 / mock）。 |
| **M5** | **首页智能空调**：开/关 AC、内外循环、制冷、除雾切换 + 温度±；操作后状态回写刷新。 |
| **M6** | **车控页**：车门/车灯开关；前/后/左/右移动（按下移动、松开停车）；状态实时反映。 |
| **M7** | **反馈模块**：列表（下拉刷新/上拉加载）、新增（≤100 字校验）、详情看内容与官方回复、左滑删除+二次确认。 |
| **M8** | **我的页 + 车主商城**：个人信息、换绑车辆、退出清状态、设置持久化；商城列表+详情+收藏+**产品评价**（mock）。 |
| **M9** | **视觉改版 Dark Neumorphism**：14 个车主页 + 2 个业务组件 + 7 个新拟态组件换成特斯拉风深色拟态——环形电量表盘、环形温度旋钮、十字方向键（按住移动/松开停车）、拟态 Tab 栏。**零新增图片**，质感全部由 ArkUI 绘制。（含文档：CLAUDE.md / DECISIONS.md） |

> M1–M9 每个只交付"一个玩家能感知的行为变化"，对应一条 commit + 一句英文行为描述（见 AI-WORKFLOW 收尾规范）。
> **进度**：M1–M9 均已完成并入 git；当前处在 S6 交付（文档齐全 + 推送 GitHub）。
> **遗留**：车主商城（M8b）页面已写好但**没有入口**，见 §7 C10 与 `DECISIONS.md` D9。
> **编译提醒**：本机已可用命令行构建（设 `DEVECO_SDK_HOME` 后执行 `hvigorw.js assembleHap`，已验证 `BUILD SUCCESSFUL`）；运行仍回 DevEco Studio/模拟器（见 `DECISIONS.md` D11）。

---

## 6.1 联调测试套件（tests/，Python unittest）

- **目的**：服务器开放后，按阶段对每个后端接口做 HTTP 契约集成测试（断言路径 / 方法 / 鉴权 / 响应结构），不删 / 不跳 / 不降标。
- **结构**：`tests/common.py`（统一 `call` 客户端，校验响应体 `code`）+ `test_auth.py`（登录/注册/用户信息/绑车）、`test_car.py`（车辆信息/状态）、`test_control.py`（空调/车门/车灯/移动）、`test_feedback.py`（列表/详情/增删）、`test_logs.py`（列表/删除）+ `run_all.py`。
- **运行**：全量 `python tests/run_all.py`；单阶段 `python tests/test_auth.py`。
- **现状**：23 个用例全部通过（HTTP 200 + 响应体 `code===200`），含各接口"无 token 鉴权"负向用例。
- **说明**：本环境无法跑 ArkUI 真机，故联调以协议级集成测试实现，验证 App 实际使用的请求契约与活服务器完全一致（App 代码已在 `02e5266` 对齐文档 V1.1）。

## 7. 与实验指导书的冲突 / 差异标注（待你裁决）

> 规则：凡"我的设定"与"实验指导书"不一致，一律在此标注，由你拍板。下表"冲突"= 指导书有明确要求而我未满足；"差异"= 实现方式不同但不违背。

| 编号 | 实验指导书要求 | SPEC 当前设定 | 性质 | 待你裁决 |
|---|---|---|---|---|
| **C1** 工程/应用命名 | 工程名须为"姓名首字母拼音班级学号"；应用名改为"xxx的车主App"（xxx=姓名），需体现个人信息 | 未包含命名规范与个人信息占位 | 已裁决（已补） | 已裁决：工程名 `yqh24002240002120509`、应用名 `杨庆鸿的车主App`、个人 VIN `00661718330`（台架用 `4494356c`） |
| **C2** 数据来源 | 所有接口直接调用真服务器（`http` 模块），未提及 mock | 默认 `USE_MOCK=false` 直连真服务器，可切本地 mock（你已选"两者皆要+开关"） | 与指导书"直连"期望一致 | 已裁决：默认直连真服务器（`USE_MOCK=false`），置 `true` 可切本地 mock |
| **C3** 绑车判断字段 | 示例代码判断 `carId==''||undefined \|\| carVin==''||undefined`，任一为空即进绑车 | 以 `carVin` 单判（贴合需求/流程节点"是否存在 carVin 属性"） | 与示例代码双判不一致（C3 已裁决） | 已裁决：**carVin 单判**（贴合需求文档，不判 carId） |
| **C4** 自定义功能-车主商城内容 | 4.7.3 要求至少含：①车主商品 ②优惠提醒 ③收藏与心愿单 ④产品评价 | 列表+详情+收藏+**产品评价**（详情页补评价区块） | 已裁决（补齐四要素） | 已裁决：详情页补"产品评价"，贴合 4.7.3 |
| **C5** 底部导航实现 | 推荐 `Navigation` 做模块内/跨模块导航 | 根 `Navigation` 承载底部模块切换（首页/车控/反馈/我的 四个 NavDestination + 自定义底部 Tab 栏） | 已裁决（取指导书推荐） | 已裁决：改用 `Navigation` 承载底部模块切换 |
| **C6** 课程交付物 | 须提交实验报告 + 演示视频 mp4 + 源码压缩 | SPEC 仅覆盖代码 | 范围外 | 报告/视频由你按模板另行完成；我可后续协助生成报告大纲/自检清单 |
| **C7** SDK/API 版本 | 未指定具体版本（按教学环境） | 默认 HarmonyOS NEXT（API 12+）Stage 模型 | 已裁决（取最新） | 已裁决：用最新 API 12+（NEXT） |
| **C8** 路由策略 | 欢迎/注册/登录用 `@ohos.router`（须 `@Entry`）；模块内/跨模块用 `Navigation` | 欢迎/登录/注册/绑车用 router；首页 Tab 用 Tabs；页内跳转用 Navigation | 一致 | 无需裁决（与指导书一致，记录备查） |
| **C9** 视觉风格 | 未指定（只要求原创、体现个人信息） | 用户改选 **Dark Neumorphism（特斯拉风深色拟态）**，取代原「用户色卡」与「暗色玻璃」 | 用户最新裁决 | 已裁决：按 Figma 社区稿靶心落地（见 §5 / `DECISIONS.md` D1） |
| **C10** 车主商城入口（C4） | 4.7.3 要求自定义功能可演示 | 商城列表 + 详情已写好，但没有任何页面能跳转过去 | **内部缺陷** | **待裁决**：A「我的」页加一行「车主商城」 / B 首页顶栏加图标 / C 保持现状；推荐 A |

> 其余与指导书一致项（MVVM 分层、Preferences 持久化键名、请求封装 BASE_URL/Authorization/401 处理、aboutToAppear 取数、KT9/KT10 双选等）不列入冲突。

---

## 8. 代码规范（取自 `yqhapplication` 既有代码，作为本工程编码标准）

> 来源：`D:\Harmony\yqh24002240002120509\entry\src\main\ets\pages` 下 `leson5/`、`login/`、`zuoye2/`、`leson7-yangnawtabs/` 等。下列约定在写 M1+ 代码时强制执行。

1. **导入（API 12+ `@kit` 体系）**：`import { http } from '@kit.NetworkKit'`、`import { router, promptAction } from '@kit.ArkUI'`、`import App from '@system.app'`。
2. **命名**：
   - 页面 `@Entry @Component struct YqhXxx`（如 `YqhLogin`/`YqhIndex`/`YqhWelcome`，PascalCase + `Yqh` 前缀），文件 `pages/yqhXxx.ets`（业务组件 `views/comps/yqhXxxComp.ets`，通用控件 `common/ui/yqhNeuXxx.ets`）。
   - 组件 `@Component`（跨文件导入时 `export struct`），文件 `XxxCom.ets` 或 `Xxx.ets`（如 `MineCom.ets`、`LoginCom.ets`、`SwipeArea.ets`）；同文件内子组件可直接定义（如 `MyRegisterPage.ets` 内 `SignupModule`/`SignupButton`）。
   - 模型 `class Xxx`（如 `LoginModel`、`Feedback`）；Bean 与请求体集中放 `model/`，接口函数放 `viewmodel/`，常量放 `common/constants/`。
   - 全局态键：模块顶部 `PersistentStorage.persistProp('userName','')`；组件内 `@StorageProp('userName')` 只读、`@StorageLink` 双向。
3. **导航（C5，且与 `newtabsPage.ets` 一致）**：根 `@Entry` 页 `@Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack()`；`@Builder pageMap(name, param)` 用 `if/else` 渲染各 `NavDestination(){...}.title(...)`；`build(){ Navigation(this.navPathStack){ Tabs({barPosition:BarPosition.End}){ TabContent(){...}.tabBar(...) } }.navDestination(this.pageMap) }`。列表→详情：`navPathStack.pushPath({name:'XxxDetail', param: obj})`，详情页 `param as Xxx`。底部四个 Tab：首页/车控/反馈/我的。
4. **路由（页面级）**：`router.pushUrl({url, params})` / `router.replaceUrl` / `router.back()` / `router.getParams()`；欢迎/登录/注册/绑车用 router。
5. **HTTP**：集中 `common/constants/HttpApi.ets` 放 `BaseUrl` + 各接口路径（如 `BaseUrl + '/app/login'`、`BaseUrl + '/cockpit/info/{id}'` 等，详见 `HttpApi.ets`）；`http.createHttp()` → `request(url,{method,header,extraData},(err,data)=>{...})`，结束 `httpRequest.destroy()`；成功判 `data.responseCode === http.ResponseCode.OK` 后 `JSON.parse(data.result as string)`。`common/utils/RequestUtil.ets` 封装为 Promise（**GET/PUT/POST/DELETE 四方法**，按接口文档选用**），统一带 `Authorization: Bearer <token>`（未登录时不带）、响应体 `code===401` 清态回登录；`USE_MOCK` 时走 `MockData.ets`。请求与响应用 `hilog`（tag `yqhHttp`）落日志。
6. **状态/持久化（KT7/KT10）**：用 `AppStorage` + `PersistentStorage`（既有 `MyLoginPage.ets`/`MineCom.ets` 范式）——**未采纳**指导书示例的 `preferences.getPreferencesSync` 写法，但底层同为"用户首选项"，且更贴合本工程既有规范。
7. **样式（M9 已改：Dark Neumorphism，覆盖先前的用户色卡与暗色玻璃风）**：集中 `common/style/Style.ets` 导出拟态令牌 `NEU_DARK` / `NEU_LIGHT`，取值函数 `neu(dark)` / `neuBg(dark)`：
   - `bg0..bg3 = '#23272C' → '#191C20'`（`neuBg()` 纵向渐变，页面根容器统一使用）
   - `surface = '#22262B'`（卡片与背景同色）、`surfaceRaised = '#282D33'`（内圈高光面）、`surfaceSunken = '#181B1F'`（按下态 / 轨道）
   - `accent = '#E82127'`（特斯拉红）、`accentDeep = '#FF6A6A'`、`accentSoft = 'rgba(232,33,39,0.30)'`（激活态发光）
   - `ink = '#EAEEF3'`（正文）、`inkSub = '#8B949F'`（次级）、`line = 'rgba(255,255,255,0.06)'`（细描边）
   - `shadowDark = 'rgba(0,0,0,0.70)'`（右下暗影）、`shadowLight = 'rgba(255,255,255,0.055)'`（左上亮边）
   - 几何常量在 `Constants.ets`：`NEU_DISTANCE`6 / `NEU_DISTANCE_SM`4 / `NEU_BLUR`12 / `NEU_BLUR_SM`8 / `NEU_BLUR_GLOW`16 / `NEU_RADIUS`24 / `NEU_RADIUS_SM`16
   凸起 = 暗影右下 + 亮边左上；凹陷 = 反过来 + 内深色面。**页面一律用 `neu(this.dark)` 取值，禁止写死色值**。旧色卡令牌 `COLORS*` 保留（课堂作业与遗留组件仍在用）。
8. **图标（M9 已改）**：业务页一律用 **emoji + ArkUI 绘制**（零美术资产，规避 `SymbolGlyph` 在部分 API 版本的兼容问题）；仅车辆底图 `bg_start`/`bg_owner_car` 与控制图标 `ic_door_lock`/`ic_light_open` 沿用既有 4 个 media 图片；头像用字母圆形占位（凹陷面），不新增任何 media 资源。
9. **注释/格式**：2 空格缩进；中文注释 `// `（可编号 `// 1、`）；链式修饰符分行；字符串单引号；组件可加 `@Preview`；Toast 用 `promptAction.showToast({message, duration})`。
10. **入口/注册**：启动页 `pages/yqhWelcome` 置 `main_pages.json` 首项；`module.json5` 已含 `ohos.permission.INTERNET`；应用名在 `string.json` 设 `EntryAbility_label = 杨庆鸿的车主App`（C1）。既有 `leson*` 草稿保留不删，课堂作业区（`pages/leson*`、`pages/zuoye*`、`pages/login`、`pages/Perferences`、`pages/Index.ets`）只读不改。
11. **UI 组件库（M9 已换为拟态组件，业务页只组装）**：所有通用 UI 控件一律封装为独立、可复用组件，集中放在 `entry/src/main/ets/common/ui/`，命名 `yqhNeuXxx.ets`，做到"封存好、随用随调"——每个组件 `@Component`（可加 `@Preview`），通过 `@Prop/@Link/@BuilderParam` 入参定制，不写死业务数据；业务页只做组装、不重复内联样式。当前 7 个：`YqhNeuCard`（拟态卡片，凸起/凹陷）、`YqhNeuButton`（主/次按钮）、`YqhNeuCircleButton`（圆形快捷键：凸起→按下凹陷微缩→激活发光）、`YqhNeuRing`（环形表盘）、`YqhNeuToggle`（开关行）、`YqhNeuTabItem`（底部 Tab 项）、`YqhNeuChip`（状态徽标）。色值/阴影一律引 `Style.ets` 的 `neu(dark)`。

### 8.1 与既有代码 / 指导书的细微差异（已主动裁定，优先级：用户最新裁决 > 硬约束 > 指导书 > 既有代码）

- **视觉主题**：用户最新裁决为 **Dark Neumorphism（特斯拉风深色拟态）**；早先的"用户色卡（奶油黄→薄荷青）"与"暗色玻璃"均已作废（见 §5 / `DECISIONS.md` D1）。
- **图标**：既有用 `Image($r('app.media.*'))` 图片；**改用 emoji + ArkUI 绘制**（不用 `SymbolGlyph`，规避 API 版本兼容问题），仅保留 4 个既有 media 图片（车辆底图 ×2、控制图标 ×2），不新增图片资源。
- **持久化**：既有用 `PersistentStorage`/`AppStorage`（非指导书示例的 `preferences.getPreferencesSync`）；**沿用既有**（它即用户首选项，满足 KT10）。
- **目录**：MVVM 重构后为 `model/` / `viewmodel/` / `views/comps/` / `pages/`（原计划的 `common/model`、`common/api`、`pages/yqhcar/` 已不存在）。
- **Toast API**：既有用 `promptAction.openToast`；**改用 `showToast`**（API 12 正确 API）。

---

## 待确认 / 待办

- **C10 车主商城入口（未裁决）**：商城列表 + 详情已写好，但没有任何页面能跳转过去。
  - A「我的」页加一行「车主商城」——**推荐**，代价：我的页多一行（现 3 行 → 4 行）
  - B 首页顶栏加图标——代价：顶栏已有「信息」图标，会挤
  - C 保持现状——代价：C4 自定义功能演示不到，等于没做
- **USE_MOCK 回切**：已完成——`USE_MOCK=false`，整套 App 已直连真服务器并通过 23 个接口集成测试（见 `tests/` 与 `DECISIONS.md` D13）。
- **编译验证**：本机命令行已可出包（`hvigorw.js assembleHap` → `BUILD SUCCESSFUL`，见 D11）；真机/模拟器运行验证待 DevEco 完成。
- mock 数据（可选）：登录账号/密码、车辆/反馈数据按合理样例造；你有指定测试账号可告知。

---

## 9. 交付节奏：每完成一个里程碑 → git 提交并推送（用户指令）

- **仓库**：`https://github.com/nanwei-git/CarLogApplication.git`（remote 名 `origin`）。
- **仓库目录**：DevEco 工程根 `D:\Harmony\yqh24002240002120509`（已迁入并改名，含 `.git`；`SPEC.md` 现位于工程根，与代码同仓）。M1 已 `git init` + 配置 `.gitignore`（忽略 `.hvigor/`、`build/`、`oh_modules/`、`.idea/`、`local.properties` 等）+ `git remote add origin <url>`。
- **节奏**：每完成一个里程碑（M1–M9）→ `git add` → `git commit -m "M<n>: <可感知行为描述>"` → `git push`（首次 `push -u origin main`，分支名以 init 默认为准）。一轮对话 = 一件事 = 一条 commit。
- **现状**：本地 `main` 曾长期领先 `origin/main`（含 MVVM 重构、P1–P5 原型对齐、M9 视觉改版等），本次一并推送。
- **凭据**：推送需 GitHub 凭据；若本机凭据管理器可用则静默完成，否则报 403/要求登录，届时我停下并告知你处理，不擅自绕过。
- `SPEC.md` / `CLAUDE.md` / `DECISIONS.md` 均位于工程根 `yqh24002240002120509`，与代码同仓提交，无需单独处理。
