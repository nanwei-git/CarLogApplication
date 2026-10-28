# SPEC · 车主 App（HarmonyOS ArkTS 原生版）

> 状态：S0 规格待确认（不写代码）。
> 来源：鸿蒙智能座舱系统需求文档 V1.3、接口文档 V1.1、业务流程判断节点说明、东软实验指导书、UI_STYLE_GUIDE（Apple Liquid Glass 暗色风，作为视觉参考）。
> 约定：遵循 AI-WORKFLOW.md（规格先于代码、一次一个可验证变化、疑问优先）。落地后另写 `README.md` / `DECISIONS.md`。

---

## 0. 约束变更说明（重要）

你最初要求 SPEC 包含「静态站 / 零美术资产 / 无构建步骤」三条硬约束，但随后选择「忠实鸿蒙 ArkTS」。二者无法共存，按你的选择裁定：

| 原硬约束 | 裁定 | 理由 |
|---|---|---|
| 静态站 | **舍弃** | ArkTS 须由 DevEco/鸿蒙工具链编译打包，不是浏览器静态资源。 |
| 无构建步骤 | **舍弃** | 同上，鸿蒙工程必然有编译/签名步骤。 |
| 零美术资产 | **保留** | 仍禁止新增 png/jpg/mp3 等美术/音频文件；改用 ArkUI 内置组件、矢量绘制（Shape/Path）、SVG data-URI、系统图标或纯色/渐变占位。 |

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

## 2. 模块划分（文件名 / 职责 / 预估行数，总计 ≈ 4800 行，< 5000）

工程采用 Stage 模型 + MVVM 目录（参考华为官方 ArkTS-MVVM，**遵循既有 `yqhapplication` 代码规范**：struct 带 `yqh` 前缀、组件 `XxxCom.ets`/`Xxx.ets`、`@kit` 导入、`AppStorage`+`PersistentStorage` 持久化、根 `Navigation`+`NavPathStack`+`Tabs` 导航、集中 `Style.ets` 令牌）。车主 App 页面统一置于 `pages/yqhcar/` 分组，与既有 leson 草稿隔离；启动页 `pages/yqhcar/yqhWelcome` 注册为 `main_pages.json` 首项。图标用 `SymbolGlyph` 系统符号（零美术资产，不引用 `app.media.*` 图片）。

| 文件 | 量级 | 职责 | 什么时候改它 |
|---|---|---|---|
| `entry/src/main/ets/entryability/EntryAbility.ets` | 60 | Ability 生命周期；冷启动进入 `pages/yqhcar/yqhWelcome` | 改启动/权限 |
| `entry/src/main/ets/pages/yqhcar/yqhWelcome.ets` | 130 | 欢迎页（struct YqhWelcome）：色卡浅色渐变背景，3s 计时，按 `isLogin` 分流到 yqhIndex 或 yqhLogin | 改欢迎页 |
| `entry/src/main/ets/pages/yqhcar/yqhLogin.ets` | 230 | 登录（struct YqhLogin）：账号密码→`getLogin`→存 token/user→`getUserInfo` 判 carVin→绑车或首页；401 处理 | 改登录 |
| `entry/src/main/ets/pages/yqhcar/yqhRegister.ets` | 210 | 注册（struct YqhRegister）：两次密码一致校验、必填校验、调用 `getRegister` | 改注册 |
| `entry/src/main/ets/pages/yqhcar/yqhBindCar.ets` | 150 | 绑车/换绑（struct YqhBindCar）：VIN 格式校验→`bindCarByVin`→回首页 | 改绑车 |
| `entry/src/main/ets/pages/yqhcar/yqhIndex.ets` | 240 | 根 Navigation+Tabs 首页枢纽（struct YqhIndex）：`@Provide('navPathStack')`+`pageMap`+四个 Tab（首页/车控/反馈/我的），页内详情走 NavDestination（C5） | 改导航 |
| `entry/src/main/ets/pages/yqhcar/comps/yqhCarInfoComp.ets` | 120 | 车辆信息卡：名称/续航/电量/百分比/更新时间（接口4.5） | 改车辆信息 |
| `entry/src/main/ets/pages/yqhcar/comps/yqhAirConditionComp.ets` | 250 | 智能空调：AC/循环/制冷/除雾开关+温度±（接口4.6/4.7） | 改空调 |
| `entry/src/main/ets/pages/yqhcar/comps/yqhLogListComp.ets` | 280 | 用户行为日志：List+ForEach+左滑删除+二次确认（接口4.10） | 改日志 |
| `entry/src/main/ets/pages/yqhcar/yqhControl.ets` | 230 | 车控：车门/车灯开关、前后左右移动+停车（接口4.6/4.8） | 改车控 |
| `entry/src/main/ets/pages/yqhcar/yqhFeedback.ets` | 240 | 反馈列表+下拉刷新/上拉加载+左滑删除（接口4.9.1/4.9.4） | 改反馈列表 |
| `entry/src/main/ets/pages/yqhcar/yqhFeedbackAdd.ets` | 180 | 新增反馈：≤100 字校验（接口4.9.2） | 改新增 |
| `entry/src/main/ets/pages/yqhcar/yqhFeedbackDetail.ets` | 150 | 反馈详情+官方回复（接口4.9.3） | 改详情 |
| `entry/src/main/ets/pages/yqhcar/yqhMine.ets` | 220 | 我的：个人信息、换绑入口、退出清状态、设置入口（读取 `@StorageProp`） | 改我的 |
| `entry/src/main/ets/pages/yqhcar/yqhSettings.ets` | 150 | 设置：字号/主题持久化（PersistentStorage，KT10） | 改设置 |
| `entry/src/main/ets/pages/yqhcar/yqhMall.ets` | 200 | 车主商城列表：商品卡+收藏切换（mock/接口） | 改商城列表 |
| `entry/src/main/ets/pages/yqhcar/yqhMallDetail.ets` | 220 | 商城详情：价格/优惠/描述/收藏+**产品评价**（C4） | 改商城详情 |
| `entry/src/main/ets/common/constants/HttpApi.ets` | 120 | `BaseUrl` + 全部接口路径常量；`USE_MOCK` 开关（C2） | 改接口地址 |
| `entry/src/main/ets/common/utils/RequestUtil.ets` | 280 | HTTP 封装（Promise）：`get/post/put/delete` 统一带 `Authorization`、`code==200` 判定、`401` 清登录回登录页；`USE_MOCK` 时走 MockData | 改请求/错误 |
| `entry/src/main/ets/common/utils/StorageUtils.ets` | 120 | 基于 `AppStorage`+`PersistentStorage` 的键封装（token/carVin/carId/userId/userName/avatar/isLogin），遵循既有 `persistProp` 模式（KT10） | 改持久化 |
| `entry/src/main/ets/common/utils/MockData.ets` | 200 | 与接口字段一致的本地 mock（登录/用户/车辆/状态/反馈/日志/商城） | 调 mock |
| `entry/src/main/ets/common/style/Style.ets` | 80 | 设计令牌 `COLORS`/`GLASS_GRADIENT`/`ACCENT_GRADIENT`（沿用既有 Style.ets 暗色玻璃风） | 改主题 |
| `entry/src/main/ets/common/constants/Constants.ets` | 120 | 数值表常量（见 §3） | 调数值 |
| `entry/src/main/ets/common/model/IResult.ets` | 30 | 统一返回 `IResult{code,msg,token}` | 改返回 |
| `entry/src/main/ets/common/model/UserInfoBean.ets` | 40 | 用户信息（含 user 嵌套） | — |
| `entry/src/main/ets/common/model/CarInfoBean.ets` | 50 | 车辆管理信息（接口4.5） | — |
| `entry/src/main/ets/common/model/CarStateBean.ets` | 60 | 车辆状态 + `CarStateChange` 请求体 | — |
| `entry/src/main/ets/common/model/FeedBackBean.ets` | 50 | 反馈列表/详情 Bean | — |
| `entry/src/main/ets/common/model/MessageInfoBean.ets` | 50 | 操控日志 Bean | — |
| `entry/src/main/ets/common/model/MallBean.ets` | 50 | 商城商品 + `Review` Bean | — |
| `entry/src/main/ets/common/model/ApiReq.ets` | 60 | LoginReq/RegisterReq/BindReq 等请求体 | — |
| `entry/src/main/ets/common/api/*.ets` | 220 | 接口函数（getLogin/getRegister/getUserInfo/getCarInfo/getCarState/changeCarState/getFeedbackList/addFeedback/getFeedbackDetail/deleteFeedback/getLogList/deleteLog/bindCarByVin/getMallList） | 加/改接口 |
| `entry/src/main/module.json5` + `resources/base/profile/main_pages.json` + `resources/base/element/string.json` | 200 | INTERNET 权限、页面注册（含 yqhcar 各页，启动页 yqhWelcome）、应用名 `杨庆鸿的车主App`、字符串资源（无图片 media） | 改权限/注册 |
| `entry/src/main/ets/common/ui/*.ets` | 400 | 复用 UI 组件库（封存）：`yqhGlassCard`/`yqhButton`/`yqhToggle`/`yqhSlider`/`yqhAvatar`/`yqhEmpty`/`yqhLoading`/`yqhDialog`/`yqhTabBar` 等，带 `@Prop/@Link` 入参、可 `@Preview`，业务页只组装 | 改通用 UI |
| **合计** | **≈ 5000** | | |

> 单文件不超过 800 行；一个文件一个职责；struct 命名带 `yqh` 前缀体现原创性；遵循既有 `yqhapplication` 代码规范（见 §8）。

---

## 3. 数值表（落 `Constants.ets`）

| 项 | 键 | 值 | 说明 |
|---|---|---|---|
| 欢迎页自动跳转 | `WELCOME_MS` | 3000 | 到时按登录态分流 |
| 接口基地址 | `BASE_URL` | `http://121.36.14.143:10001` | 真服务器 |
| Mock 开关 | `USE_MOCK` | `false`（默认直连真服务器） | `true` 时走本地 mock；可用 `AppStorage` 运行时切换（C2 已裁决：默认直连） |
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
| 视觉参考 | — | Apple Liquid Glass 暗色（仅参考，ArkUI 用渐变+毛玻璃 `blur`+半透明实现） | 不引入图片资源 |
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
  id=''; carName=''; brand=''; carVin=''; batteryPower:object={}; enduranceMileage='';
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

// FeedBackBean.ets
export class FeedBackListBean { total=0; rows: Feedback[] = []; code=0; msg=''; }
export class Feedback { id=''; userId=''; userName=''; nickName=''; phonenumber=''; content=''; status=''; picUrl=''; delFlag=''; replyRead=''; createTime=''; updateTime=''; reply?: object; }

// MessageInfoBean.ets（接口4.10）
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
- **架构**：MVVM 分层（`common/model` 数据 / `common/api` 接口函数 / `common/utils`、`common/constants`、`common/style` 工具 / `pages/yqhcar` 视图）；页面级状态 `@State/@Prop/@Link`（KT6），应用级共享 `@Provide/@Consume` + `AppStorage`/`PersistentStorage`（KT7）。
- **路由**：欢迎/登录/注册/绑车用 `@ohos.router`（`replaceUrl`，须 `@Entry`）；首页根 `Navigation` 承载底部模块切换（首页/车控/反馈/我的 四个 `NavDestination` + 自定义底部 Tab 栏），页内列表→详情用 `Navigation` 子页（实验指导书推荐，C5 已裁决）。
- **网络**：`@ohos.net.http`（`httpRequest.request`），需 `module.json5` 声明 `ohos.permission.INTERNET`；统一封装于 `RequestUtil`，含 `USE_MOCK` 开关（**默认 `false` 直连真服务器 `BASE_URL`**，C2 已裁决；置 `true` 走本地 mock，保留开关便于无后端验收）。注意：真服务器若未开 CORS，模拟器/真机可能跨域失败，届时可切 mock 排查。
- **绑车判据（C3 已裁决）**：登录成功后 `getUserInfo`，仅当 `carVin` 为空才进绑车页，否则进首页（贴合需求文档/流程节点，不判 `carId`）。
- **持久化（KT10，遵循既有代码规范）**：采用既有 `PersistentStorage.persistProp` + `AppStorage`（`setOrCreate`/`get`/`@StorageProp`/`@StorageLink`）模式，底层即为"用户首选项"；`StorageUtils.ets` 仅封装键名常量，存 token/carVin/carId/userId/userName/avatar/isLogin。**注**：与实验指导书示例的 `preferences.getPreferencesSync` 写法不同，但同为 KT10 持久化，且更贴合本工程既有规范。
- **UI 风格（用户色卡已裁决，覆盖先前"暗色玻璃"）**：以用户提供的色卡为主色调——奶油黄→薄荷青纵向渐变背景 + 半透明白卡 + `blur` 轻毛玻璃 + 细描边、圆角、克制动效；正文用深墨绿保证浅底对比度；**不引入任何图片/音频文件**（零美术资产）。色卡令牌见 §8 第 7 条。
- **图标（零美术资产）**：用 `SymbolGlyph` 系统符号图标（HarmonyOS NEXT 内置，无需图片文件），替代既有代码里的 `Image($r('app.media.*'))` 图片用法；头像用 `SymbolGlyph` 或字母圆形占位。不新增任何 media 图片资源。
- **命名与目录（遵循既有规范）**：struct 带 `Yqh` 前缀、PascalCase（如 `YqhLogin`/`YqhIndex`）体现原创性；页面文件 `yqhXxx.ets`、组件 `XxxCom.ets`/`Xxx.ets`；车主 App 全部页面置于 `pages/yqhcar/`（与既有 leson 草稿隔离）；启动页 `yqhWelcome` 注册为 `main_pages.json` 首项；应用名在 `string.json` 设为 `杨庆鸿的车主App`（C1）。
- **扩展技术**：① 列表下拉刷新（`Refresh`）+ 上拉加载（`List.onReachEnd`/`edgeEffect`）；② 请求封装（已做）；③ 可选 Axios（鸿蒙版）作为加分项；④ 设置页字号/主题持久化（KT10）。

---

## 6. 里程碑 M0–M8（每个一个可验收的"能看到什么"）

| 里程碑 | 能看到什么（玩家可感知） |
|---|---|
| **M0** | 本 SPEC 定稿（模块划分、数值/类型表、约束裁定）。无代码。 |
| **M1** | 工程可编译运行；**欢迎页**出现（色卡浅色渐变），3s 后按是否已登录自动跳登录页或首页。**完成后 git 提交并推送（见 §9）**。 |
| **M2** | **登录 / 注册页**可用：登录存 token；注册含"两次密码一致"校验与"账号已存在"提示。**（已完成）** |
| **M3** | **绑车流程**：首次登录（无 carVin）强制进绑车页，VIN 格式校验，绑定后回首页；非首次直进首页。 |
| **M4** | **首页车辆信息卡**：显示车辆名称、可续航里程、电池电量+百分比、更新时间（接口4.5 / mock）。 |
| **M5** | **首页智能空调**：开/关 AC、内外循环、制冷、除雾切换 + 温度±；操作后状态回写刷新。 |
| **M6** | **车控页**：车门/车灯开关；前/后/左/右移动（按下移动、松开停车）；状态实时反映。 |
| **M7** | **反馈模块**：列表（下拉刷新/上拉加载）、新增（≤100 字校验）、详情看内容与官方回复、左滑删除+二次确认。 |
| **M8** | **我的页 + 车主商城**：个人信息、换绑车辆、退出清状态、设置持久化；商城列表+详情+收藏+**产品评价**（mock）。 |

> M1–M8 每个只交付"一个玩家能感知的行为变化"，对应一条 commit + 一句英文行为描述（见 AI-WORKFLOW 收尾规范）。

---

## 7. 与实验指导书的冲突 / 差异标注（待你裁决）

> 规则：凡"我的设定"与"实验指导书"不一致，一律在此标注，由你拍板。下表"冲突"= 指导书有明确要求而我未满足；"差异"= 实现方式不同但不违背。

| 编号 | 实验指导书要求 | SPEC 当前设定 | 性质 | 待你裁决 |
|---|---|---|---|---|
| **C1** 工程/应用命名 | 工程名须为"姓名首字母拼音班级学号"；应用名改为"xxx的车主App"（xxx=姓名），需体现个人信息 | 未包含命名规范与个人信息占位 | 已裁决（已补） | 已裁决：工程名 `yqh24002240002120509`、应用名 `杨庆鸿的车主App`、个人 VIN `00661718330`（台架用 `4494356c`） |
| **C2** 数据来源 | 所有接口直接调用真服务器（`http` 模块），未提及 mock | 默认 `USE_MOCK=true`，可切真服务器（你已选"两者皆要+开关"） | 与指导书"直连"期望不同，但属你已选 | 已裁决：**默认直连真服务器**，置 `USE_MOCK=true` 可切本地 mock |
| **C3** 绑车判断字段 | 示例代码判断 `carId==''||undefined \|\| carVin==''||undefined`，任一为空即进绑车 | 以 `carVin` 单判（贴合需求/流程节点"是否存在 carVin 属性"） | 与示例代码双判不一致（C3 已裁决） | 已裁决：**carVin 单判**（贴合需求文档，不判 carId） |
| **C4** 自定义功能-车主商城内容 | 4.7.3 要求至少含：①车主商品 ②优惠提醒 ③收藏与心愿单 ④产品评价 | 列表+详情+收藏+**产品评价**（详情页补评价区块） | 已裁决（补齐四要素） | 已裁决：详情页补"产品评价"，贴合 4.7.3 |
| **C5** 底部导航实现 | 推荐 `Navigation` 做模块内/跨模块导航 | 根 `Navigation` 承载底部模块切换（首页/车控/反馈/我的 四个 NavDestination + 自定义底部 Tab 栏） | 已裁决（取指导书推荐） | 已裁决：改用 `Navigation` 承载底部模块切换 |
| **C6** 课程交付物 | 须提交实验报告 + 演示视频 mp4 + 源码压缩 | SPEC 仅覆盖代码 | 范围外 | 报告/视频由你按模板另行完成；我可后续协助生成报告大纲/自检清单 |
| **C7** SDK/API 版本 | 未指定具体版本（按教学环境） | 默认 HarmonyOS NEXT（API 12+）Stage 模型 | 已裁决（取最新） | 已裁决：用最新 API 12+（NEXT） |
| **C8** 路由策略 | 欢迎/注册/登录用 `@ohos.router`（须 `@Entry`）；模块内/跨模块用 `Navigation` | 欢迎/登录/注册/绑车用 router；首页 Tab 用 Tabs；页内跳转用 Navigation | 一致 | 无需裁决（与指导书一致，记录备查） |

> 其余与指导书一致项（MVVM 分层、Preferences 持久化键名、请求封装 BASE_URL/Authorization/401 处理、aboutToAppear 取数、KT9/KT10 双选等）不列入冲突。

---

## 8. 代码规范（取自 `yqhapplication` 既有代码，作为本工程编码标准）

> 来源：`D:\Harmony\yqh24002240002120509\entry\src\main\ets\pages` 下 `leson5/`、`login/`、`zuoye2/`、`leson7-yangnawtabs/` 等。下列约定在写 M1+ 代码时强制执行。

1. **导入（API 12+ `@kit` 体系）**：`import { http } from '@kit.NetworkKit'`、`import { router, promptAction } from '@kit.ArkUI'`、`import App from '@system.app'`。
2. **命名**：
   - 页面 `@Entry @Component struct YqhXxx`（如 `YqhLogin`/`YqhIndex`/`YqhWelcome`，PascalCase + `Yqh` 前缀），文件 `pages/yqhcar/yqhXxx.ets`。
   - 组件 `@Component`（跨文件导入时 `export struct`），文件 `XxxCom.ets` 或 `Xxx.ets`（如 `MineCom.ets`、`LoginCom.ets`、`SwipeArea.ets`）；同文件内子组件可直接定义（如 `MyRegisterPage.ets` 内 `SignupModule`/`SignupButton`）。
   - 模型 `class Xxx`（如 `LoginModel`、`Feedback`）；类型/常量集中放 `common/model`、`common/constants`。
   - 全局态键：模块顶部 `PersistentStorage.persistProp('userName','')`；组件内 `@StorageProp('userName')` 只读、`@StorageLink` 双向。
3. **导航（C5，且与 `newtabsPage.ets` 一致）**：根 `@Entry` 页 `@Provide('navPathStack') navPathStack: NavPathStack = new NavPathStack()`；`@Builder pageMap(name, param)` 用 `if/else` 渲染各 `NavDestination(){...}.title(...)`；`build(){ Navigation(this.navPathStack){ Tabs({barPosition:BarPosition.End}){ TabContent(){...}.tabBar(...) } }.navDestination(this.pageMap) }`。列表→详情：`navPathStack.pushPath({name:'XxxDetail', param: obj})`，详情页 `param as Xxx`。底部四个 Tab：首页/车控/反馈/我的。
4. **路由（页面级）**：`router.pushUrl({url, params})` / `router.replaceUrl` / `router.back()` / `router.getParams()`；欢迎/登录/注册/绑车用 router。
5. **HTTP**：集中 `common/constants/HttpApi.ets` 放 `BaseUrl` + 各接口路径（`BaseUrl + '/app/login'` 风格）；`http.createHttp()` → `request(url,{method,header,extraData},(err,data)=>{...})`，结束 `httpRequest.destroy()`；成功判 `data.responseCode === http.ResponseCode.OK` 后 `JSON.parse(data.result as string)`。`RequestUtil.ets` 封装为 Promise（`get/post/put/delete`），统一带 `Authorization`、判 `code==200`、401 回登录；`USE_MOCK` 时走 `MockData.ets`。
6. **状态/持久化（KT7/KT10）**：用 `AppStorage` + `PersistentStorage`（既有 `MyLoginPage.ets`/`MineCom.ets` 范式）——**未采纳**指导书示例的 `preferences.getPreferencesSync` 写法，但底层同为"用户首选项"，且更贴合本工程既有规范。
7. **样式（用户色卡已裁决，覆盖先前暗色玻璃风）**：集中 `common/style/Style.ets` 导出 `COLORS`（ColorToken）与渐变令牌，取值取自用户色卡（奶油黄→薄荷青）：
   - `BG_GRADIENT = ['#FDF6DC', '#E9F5DA', '#C8F0E4', '#BFF0EC']`（纵向线性渐变背景）
   - `COLORS.card = 'rgba(255,255,255,0.82)'`（半透明白卡）、`COLORS.line = 'rgba(255,255,255,0.65)'`（细描边）
   - `COLORS.ink = '#2F4F49'`（正文）、`COLORS.inkSub = '#6E8B85'`（次级文字）
   - `COLORS.accent = '#3FB9A2'`（薄荷主色，按钮/选中态）、`COLORS.accentDeep = '#2E9E8A'`（按压/强调）
   - `COLORS.highlight = '#F6E7A9'`（奶油黄高亮/优惠标签）、`COLORS.danger = '#E58A8A'`（删除/警示）
   背景 `Stack`+线性渐变，卡片 `Column` 半透明白 + `blur` 轻毛玻璃 + 细白描边；正文一律深墨绿，保证浅底对比度。
8. **图标（零美术资产）**：用 `SymbolGlyph`（系统符号，无图片文件）替代既有 `Image($r('app.media.*'))`；头像用 `SymbolGlyph` 或字母圆形占位。
9. **注释/格式**：2 空格缩进；中文注释 `// `（可编号 `// 1、`）；链式修饰符分行；字符串单引号；组件可加 `@Preview`；Toast 用 `promptAction.showToast({message, duration})`。
10. **入口/注册**：启动页 `pages/yqhcar/yqhWelcome` 置 `main_pages.json` 首项；`module.json5` 已含 `ohos.permission.INTERNET`；应用名在 `string.json` 设 `EntryAbility_label = 杨庆鸿的车主App`（C1）。既有 `leson*` 草稿保留不删，隔离在 `pages/yqhcar` 之外。
11. **UI 组件库（封存复用，用户指令）**：所有通用 UI 控件一律封装为独立、可复用组件，集中放在 `entry/src/main/ets/common/ui/`（或 `pages/yqhcar/widgets/`），做到"封存好、随用随调"——每个组件 `@Component`（可加 `@Preview`），通过 `@Prop/@Link/@BuilderParam` 入参定制，不写死业务数据；业务页只做组装、不重复内联样式。首批沉淀：`YqhGlassCard`（半透明玻璃卡）、`YqhButton`（主/次按钮，薄荷主色）、`YqhToggle`（开关）、`YqhSlider`、`YqhAvatar`（字母/SymbolGlyph 头像）、`YqhEmpty`/`YqhLoading`、`YqhDialog`、`YqhTabBar`（底部 Tab 栏）。色卡令牌统一引 `Style.ets`。

### 8.1 与既有代码 / 指导书的细微差异（已主动裁定，优先级：硬约束 > 指导书 > 既有代码）

- **图标**：既有用 `Image($r('app.media.*'))` 图片；因"零美术资产"硬约束，**改用 `SymbolGlyph`**，不新增任何图片资源。
- **持久化**：既有用 `PersistentStorage`/`AppStorage`（非指导书示例的 `preferences.getPreferencesSync`）；**沿用既有**（它即用户首选项，满足 KT10）。
- **Toast API**：既有用 `promptAction.openToast`；**改用 `showToast`**（API 12 正确 API）。

---

## 待确认（已全部裁决，仅保留可选建议）

- mock 默认值（可选）：若真服务器 CORS 不可用需切 mock 排查，登录账号/密码、mock 车辆/反馈数据按合理样例造；你有指定测试账号可告知。

---

## 9. 交付节奏：每完成一个里程碑 → git 提交并推送（用户指令）

- **仓库**：`https://github.com/nanwei-git/CarLogApplication.git`（remote 名 `origin`）。
- **仓库目录**：DevEco 工程根 `D:\Harmony\yqh24002240002120509`（已迁入并改名，含 `.git`；`SPEC.md` 现位于工程根，与代码同仓）。M1 已 `git init` + 配置 `.gitignore`（忽略 `.hvigor/`、`build/`、`oh_modules/`、`.idea/`、`local.properties` 等）+ `git remote add origin <url>`。
- **节奏**：每完成一个里程碑（M1–M8）→ `git add` → `git commit -m "M<n>: <可感知行为描述>"` → `git push`（首次 `push -u origin main`，分支名以 init 默认为准）。
- **凭据**：推送需 GitHub 凭据；若本机凭据管理器可用则静默完成，否则报 403/要求登录，届时我停下并告知你处理，不擅自绕过。
- `SPEC.md` 现已随工程一并入库（位于工程根 `yqh24002240002120509`），与代码同仓提交，无需单独处理。
