# CLAUDE.md · 项目地图（车主 App）

## 一句话（项目介绍）

HarmonyOS NEXT 车主 App（ArkTS / ArkUI 声明式，Stage 模型 + MVVM 分层），对接真实后端 `http://121.36.14.143:10001`：
仅登录为 `POST /app/login`，其余为 `POST /system/user/register`、`GET /getInfo`、`/cockpit/**` 等（详见 `common/constants/HttpApi.ets`）。
登录 / 注册 / 绑车 → 首页看车辆状态与智能空调、车控页远程控车（门+灯+方向）、反馈模块提交与管理、
车主商城浏览收藏、我的页换绑与退出。视觉主题为 **Dark Neumorphism（特斯拉风深色拟态）**：近黑底 +
特斯拉红，卡片与背景同色，靠「左上亮边 + 右下暗影」双层投影造体积，全部由 ArkUI 绘制、零新增美术资产。

## 怎么跑

- **环境**：DevEco Studio + HarmonyOS NEXT SDK（API 12+）。打开工程根 `yqh24002240002120509` → Build → Run 到模拟器/真机。
  ⚠️ 本机也可用命令行构建：设 `DEVECO_SDK_HOME` 后执行 `hvigorw.js assembleHap`（已验证可出包，详见 `DECISIONS.md` D11）。
- **后端**：`http://121.36.14.143:10001`（`common/constants/HttpApi.ets`）。`USE_MOCK` 当前为 **`false`**，整套 App 已直连真服务器。
  联调结论：服务器始终返回 HTTP 200，成败看响应体 `code`（200 成功 / 401 鉴权 / 500 业务）。
- **VIN**：台架调试 `4494356c`；个人 VIN `00661718330`（不可用于台架）。
- **联调**：HiLog 过滤 tag `yqhHttp`，可看到每次请求的 URL / 耗时 / 响应码 / 报文。
- **接口集成测试**：`tests/`（Python `unittest`）直连真服务器校验每个接口的路径/方法/鉴权/响应结构。
  全量：`python tests/run_all.py`；单阶段：`python tests/test_auth.py`（另有 `test_car/control/feedback/logs.py`）。

## 硬性约束（违反即打回）

1. **不许改课堂作业**：`pages/leson*`、`pages/zuoye*`、`pages/login`、`pages/Perferences`、`pages/Index.ets`——一个字都不动。
2. **色值 / 阴影 / 圆角一律取令牌**：`neu(this.dark)` / `neuBg(this.dark)`（`common/style/Style.ets`）；页面里不写死色值。
3. **通用控件只从 `common/ui/` 取**：新控件也放这里（`yqhNeuXxx.ets`），业务页只组装、不内联阴影。
4. **常量不落页面**：数值 → `common/constants/Constants.ets`，接口路径 → `common/constants/HttpApi.ets`。
5. **不新增美术资产**：优先 emoji + ArkUI 绘制；现有 media 仅 4 个（车辆底图 `bg_start`/`bg_owner_car`、控制图标 `ic_door_lock`/`ic_light_open`）。
6. 单文件 ≤ 800 行；一轮对话 = 一件事 = 一条 commit。

## 模块地图（代码索引）

行数为实测值（含本次按接口文档 V1.1 对齐后的变动）。车主 App 部分 **66 个 .ets / ≈ 4250 行**（另有 `tests/` 下 Python 联调测试，不计入）；课堂作业部分 51 个 / 3094 行（只读）。

| 层 / 目录 | 文件（行） | 职责 |
|---|---|---|
| **入口** | `entryability/EntryAbility.ets`（53） | Ability 生命周期，冷启动进 `pages/yqhWelcome`；`onCreate` 调 `initStorage` 初始化用户首选项 |
| **页面** `pages/`（14 个） | `yqhWelcome`59、`yqhLogin`200、`yqhRegister`159、`yqhBindCar`132、`yqhIndex`142、`yqhControl`232、`yqhFeedback`241、`yqhFeedbackAdd`109、`yqhFeedbackDetail`104、`yqhLog`82、`yqhMall`150、`yqhMallDetail`158、`yqhMine`167、`yqhSettings`143 | 路由页（欢迎/登录/注册/绑车）+ Tab 页（首页/车辆控制/反馈/我的）+ NavDestination 子页（反馈增删详情、日志、商城、商品详情、设置） |
| **业务组件** `views/comps/` | `yqhCarInfoComp`200、`yqhAirConditionComp`224 | 首页两块：车辆信息卡（环形电量表盘 + 门/灯/空调圆键）、智能空调（环形温度旋钮 + 循环/A·C/除雾） |
| **通用组件** `common/ui/` | `yqhNeuCard`53、`yqhNeuButton`61、`yqhNeuCircleButton`99、`yqhNeuRing`58、`yqhNeuToggle`55、`yqhNeuTabItem`39、`yqhNeuChip`38 | 拟态组件库：卡片 / 按钮 / 圆键 / 环形表盘 / 开关 / Tab 项 / 徽标。业务页只组装 |
| **接口函数** `viewmodel/` | `auth`39、`car`78、`feedback`43、`mall`12 | 登录注册绑车、车辆信息状态移动日志、反馈增删查、商城列表收藏 |
| **模型** `model/` | `ApiReq`68、`CarInfoBean`42、`CarStateBean`36、`CarLogBean`23、`FeedBackBean`46、`MallBean`50、`UserInfoBean`13、`IResult`6 | 请求体 + `parseXxx` 解析 |
| **基础设施** `common/` | `utils/RequestUtil`79、`utils/StorageUtils`125、`utils/MockData`359、`constants/HttpApi`56、`constants/Constants`47、`style/Style`152 | 统一 GET/PUT/POST/DELETE（Bearer + 401 清态 + hilog）、用户首选项(preferences)落盘 + AppStorage 缓存（KT10）、本地 mock、接口路径/开关、数值表、设计令牌 |
| **遗留（未引用）** `views/` | `yqhGlassCard`20、`yqhButton`29、`yqhToggle`43 | 旧浅色玻璃风组件，车主 App 已不引用，保留待清 |
| **课堂作业（只读）** | `pages/leson*`、`pages/zuoye*`、`pages/login`、`pages/Perferences`、`pages/Index.ets`（3094） | 课程草稿，隔离区 |

## 架构要点

- **数据流**：页面 `aboutToAppear` → `viewmodel/xxx` 函数 →（`USE_MOCK` ? `MockData` : `RequestUtil` 统一 GET/PUT/POST/DELETE）→ `model` 的 `parseXxx` → 写入 `@State` 渲染。
- **状态**：页面内 `@State`；跨页 `@Provide/@Consume('navPathStack')`；应用级 `AppStorage`（响应式缓存）+ 用户首选项 `preferences`（落盘，键名集中 `StorageUtils.ets`，`EntryAbility.onCreate` 调 `initStorage`）。
- **导航分工（C5）**：欢迎/登录/注册/绑车用 `@ohos.router`（须 `@Entry`，注册在 `main_pages.json`）；首页用根 `Navigation` + `NavPathStack` + `Tabs`（4 个 Tab），详情用 `pushPath` 渲染 `NavDestination`。
  子页名：`Log`、`FeedbackAdd`、`FeedbackList`、`FeedbackDetail`、`Settings`、`Mall`、`MallDetail`。
- **鉴权**：token 存 `AppStorage('token')`，`RequestUtil` 带 `Bearer <token>`；HTTP 401（响应体 `code===401`）→ `clearSession()` + 跳登录页。
- **主题**：`@StorageProp('darkMode')` + `neu()` 令牌；设置页开关切换（KT10 持久化）。
- **配置**：`HttpApi.ets` 的 `BaseUrl` 与 `USE_MOCK` 是唯一的后端开关点。

## 代码风格

照抄 `common/ui/yqhNeuCard.ets`：2 空格缩进、单引号、链式修饰符分行、中文注释（`// 1、` 编号）、
`@kit.*` 导入（`NetworkKit` / `ArkUI` / `PerformanceAnalysisKit`）、struct 带 `Yqh` 前缀、
日志 `hilog.info(0x0001, 'yqhHttp', ...)`、Toast 用 `promptAction.showToast`。

## 常见任务 → 改哪里

| 我想… | 去哪 |
|---|---|
| 改配色 / 阴影 / 圆角 | `common/style/Style.ets` 的 `NEU_DARK` / `NEU_LIGHT` |
| 加一个通用控件 | 新建 `common/ui/yqhNeuXxx.ets` |
| 改接口地址 / 切 mock | `common/constants/HttpApi.ets`（`BaseUrl` / `USE_MOCK`） |
| 改车辆卡片 / 空调卡 | `views/comps/yqhCarInfoComp.ets` / `yqhAirConditionComp.ets` |
| 加一个 NavDestination 子页 | `pages/yqhIndex.ets` 的 `pageMap` |
| 加一个 router 页面 | 同时改 `resources/base/profile/main_pages.json` |
| 加接口 | `viewmodel/xxx.ets` + `model/XxxBean.ets` |
| 改持久化键 | `common/utils/StorageUtils.ets` |
| 调数值（温度/分页/字号） | `common/constants/Constants.ets` |

## 已知坑

1. **车主商城页没有入口**：`pageMap` 注册了 `Mall` 子页，但没有任何页面 `pushPath({name:'Mall'})`；「我的」页只有 绑定车辆/我的反馈/设置 三行。验收 C4 时点不到（见 `DECISIONS.md` D9，**待裁决**）。
2. `USE_MOCK` 当前为 `false`，整套 App 已直连真服务器；`MockData.ets` 仅作离线兜底。
3. `darkMode` 持久化默认值已改为 `true`；设备上若已存过 `false`，需在设置页手动打开。
4. `Progress` 不支持 `strokeRadius`（也没有 `ProgressType.Circular`）；环形只能用 `.type(ProgressType.Ring).style({strokeWidth})`，`@Builder` 内别用 `alignSelf`。
5. 本机可用命令行构建：设 `DEVECO_SDK_HOME` 后执行 `hvigorw.js assembleHap` 即可出包（已验证 `BUILD SUCCESSFUL`）。
6. 联调测试套件在 `tests/`（Python `unittest`）：`python tests/run_all.py` 一键跑全部 23 个接口集成用例；按阶段分 `test_auth/car/control/feedback/logs.py`。

## 协作

见 `AI-WORKFLOW.md`（四段式需求模板、疑问优先、里程碑切法、收尾例行）；决策记录见 `DECISIONS.md`。
