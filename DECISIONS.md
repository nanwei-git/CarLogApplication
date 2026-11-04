# DECISIONS.md · 决策记录

> 用途：跨会话最容易丢的就是"为什么这么定"。每次做架构取舍或定下新约束，追加一条。
> 协作协议见 `AI-WORKFLOW.md`；代码索引/项目介绍见 `CLAUDE.md`。

---

## D1 · 视觉主题改为 Dark Neumorphism（特斯拉风深色拟态）

- **决策**：车主 App 统一为 Dark Neumorphism——近黑底 `#22262B` + 特斯拉红 `#E82127`，卡片与背景同色，靠「左上亮边 + 右下暗影」双层投影造体积感。
- **理由**：用户选定 Figma 社区稿 *Dark Neumorphism UI (Tesla app)* 为视觉靶心；该风格零美术资产也能做出质感（全部由 ArkUI 绘制）。
- **影响**：推翻 SPEC §5/§8 的「用户色卡 奶油黄→薄荷青」设定。旧色卡令牌 `COLORS*` 保留（课堂作业与遗留组件仍用），车主 App 一律改用 `neu(dark)` / `neuBg(dark)`。
- **连带**：`StorageUtils.ets` 中 `darkMode` 的持久化默认值 `false` → `true`。

## D2 · 组件库换成拟态组件，业务页只组装

- **决策**：通用控件集中 `common/ui/`，命名 `yqhNeuXxx.ets`；业务页不复写阴影/圆角/色值。
- **理由**：拟态的质感全在阴影参数上，散落在各页必然走形，且改主题要改十几个文件。
- **影响**：遗留 `views/yqhGlassCard|yqhButton|yqhToggle` 不再被车主 App 引用（保留待清）。

## D3 · 目录重构为 MVVM（model / viewmodel / views / pages）

- **决策**：模型收 `ets/model/`、接口函数收 `ets/viewmodel/`（原 `common/api`）、业务组件收 `views/comps/`、页面直接放 `pages/` 根。
- **理由**：贴近华为官方 ArkTS-MVVM 分层，也让「数据 / 取数 / 视图」三层职责分明。
- **影响**：SPEC §2 的旧路径（`pages/yqhcar/*`、`common/model/*`、`common/api/*`）全部失效，**已同步**。

## D4 · USE_MOCK 当前为 false（已直连真服务器）

- **决策**：`common/constants/HttpApi.ets` 的 `USE_MOCK` 现为 **`false`**，整套 App 已直连真服务器 `http://121.36.14.143:10001`。
- **理由**：后端已开放联调；按需求「整套 app 都直连真服务器」全量置 false，`MockData.ets` 仅作离线兜底。
- **影响**：SPEC §3 现与现状一致（默认直连）。联调结论：服务器恒返回 HTTP 200，成败看响应体 `code`（200 成功 / 401 鉴权 / 500 业务）。**本条目已结案**。

## D5 · 持久化改用用户首选项 preferences（KT10，已落地）

- **决策**：`StorageUtils.ets` 用 `@ohos.data.preferences`（`preferences.getPreferencesSync`，仓库名 `CarLogStore`）落盘存储 token / 字号 / 主题 / 用户与车辆信息；`AppStorage` 仅作内存响应式缓存层，页面经 `@StorageProp/@StorageLink` 读取，写入统一走 `setXxx`（同步双写首选项）。
- **理由**：明确满足课程 KT10「使用用户首选项实现数据持久化」的要求（此前用 `PersistentStorage`，其底层虽也是首选项但写法不直接显式）。`EntryAbility.onCreate` 用 `this.context` 调 `initStorage(context)` 初始化一次。
- **影响**：所有 `setXxx` 现在同步双写 AppStorage + 用户首选项；读取仍走 AppStorage，UI 绑定不变。字段与函数签名完全兼容，页面零改动。

## D6 · 导航分工：router 做入口，Navigation 做壳内跳转

- **决策**：欢迎/登录/注册/绑车用 `@ohos.router`（须 `@Entry`）；首页用根 `Navigation` + `NavPathStack` + `Tabs`（4 个 Tab），列表→详情走 `pushPath` 渲染 `NavDestination`（C5）。
- **影响**：加页要分清——router 页须注册 `main_pages.json`；子页只须在 `yqhIndex.ets` 的 `pageMap` 里加分支。

## D7 · 车控方向键用 onTouch（按住移动 / 松开停车）

- **决策**：方向键不做点击，用 `onTouch` 的 `Down` 触发移动、`Up`/`Cancel` 触发停车；中间为独立的停车键。
- **理由**：贴合指导书「按下移动、松开停车」的语义，点击式无法表达持续位移。

## D8 · 课堂作业区只读

- **决策**：`pages/leson*`、`pages/zuoye*`、`pages/login`、`pages/Perferences`、`pages/Index.ets` 一律不动。
- **理由**：课程草稿，与车主 App 隔离；改坏了无法解释。

## D9 · 已知坑：车主商城页没有入口（待裁决）

- **现象**：`yqhIndex.ets` 的 `pageMap` 注册了 `Mall` 子页，但没有任何页面 `pushPath({name:'Mall'})`；「我的」页只有 绑定车辆/我的反馈/设置 三行。
- **影响**：自定义功能 C4（车主商城）验收时点不到，等于没做。
- **状态**：**未裁决**——不在本轮擅自改（本轮只做文档 + 推送）。

## D10 · 环形进度的可行写法

- **现象**：`Progress` 传 `strokeRadius`、或把 `@Builder` 内组件的 `alignSelf` 当容器属性用，都会编译报错。
- **决策**：环形统一 `Progress({type: ProgressType.Ring}).style({strokeWidth})` + `.color()` + `.backgroundColor()`（轨道色）；居中一律放容器上。

## D11 · 命令行可构建（推翻原"只能回 DevEco"）

- **现象（原）**：本机命令行无 `hvigorw`，`local.properties` 未配 SDK 路径。
- **现状（已推翻）**：设 `DEVECO_SDK_HOME=D:\Harmony\DevEco\DevEco Studio\sdk` 后，直接调用 `tools\hvigor\bin\hvigorw.js assembleHap` 即可命令行出包，已验证 `BUILD SUCCESSFUL`。
- **命令示例**：
  `& "$DEVECO\tools\node\node.exe" "$DEVECO\tools\hvigor\bin\hvigorw.js" --no-daemon -p module=entry@default -p product=default assembleHap`

## D12 · 接口路径按《接口文档 V1.1》全面修正（核对联调）

- **现象**：原 App 的 `ApiPath` 几乎全错（如注册写成 `/app/register`、用户信息 `/app/user/info`、车辆信息 `/app/car/info`、状态变更 `/app/car/state/change`、反馈列表 `/app/feedback/list`、日志无接口），这是当初 `/app/register` 收 401、登录异常的根因之一。
- **决策**：对照《鸿蒙智能座舱系统接口文档 V1.1》逐接口修正，见 `common/constants/HttpApi.ets`：
  - 登录 `POST /app/login`、注册 `POST /system/user/register`、用户信息 `GET /getInfo`（字段在响应**顶层**）
  - 绑车 `POST /cockpit/info/bindCarVin`
  - 车辆信息 `GET /cockpit/info/{id}`、车辆状态 `GET /cockpit/state/{carVin}`、空调变更 `PUT /cockpit/state`
  - 车门 `POST /cockpit/control/door`、车灯 `POST /cockpit/control/light`、移动/前后左右 `POST /cockpit/control/{move|back|left|right|stop}/{carId}`
  - 反馈列表 `GET /cockpit/feedback/backList`（**直接数组**）、详情 `GET /cockpit/feedback/{id}`、删除 `DELETE /cockpit/feedback/{ids}`
  - 日志列表 `GET /cockpit/log/list`（**顶层** `total`/`rows`）、删除 `DELETE /cockpit/log/{ids}`
- **连带修复**：`getInfo`/`logList` 顶层字段解析；反馈列表数组解析；`batteryPower` 由 `object` 改为 `string`（`Number()` 解析续航百分比）。

## D13 · 新增后端集成测试套件（tests/）

- **决策**：在 `tests/` 下用 Python `unittest` 直连真服务器，按阶段写接口集成测试（不删/不跳/不降标）。
- **结构**：`common.py`（统一 `call` 客户端，校验响应体 `code`）+ `test_auth.py` / `test_car.py` / `test_control.py` / `test_feedback.py` / `test_logs.py` + `run_all.py`。
- **运行**：全量 `python tests/run_all.py`；单阶段 `python tests/test_auth.py`。
- **现状**：23 个用例全部通过（HTTP 200 + 响应体 `code===200`），覆盖登录/注册/用户信息/绑车、车辆信息/状态、空调/车门/车灯/移动、反馈列表/详情/增删、日志列表/删除，以及各接口的"无 token 鉴权"负向用例。

## D14 · module.json5 不支持 allowCleartextTraffic（SDK 6.1.1）

- **现象**：为让 App 直连 `http://` 后端，曾在 `module.json5` 加 `allowCleartextTraffic: true`，但该 SDK（6.1.1 / API 12）schema 不认此字段——放在 ability 层或 module 层都报 `Schema validate failed`。
- **决策**：**不添加**该字段。
- **理由**：实测明文 HTTP 在本 SDK 默认可用（曾收到服务器 401 即证明链路通），无需该开关；强行添加反而导致构建失败。

---

## 待裁决清单

| 编号 | 事项 | 选项 | 推荐 |
|---|---|---|---|
| D9 | 车主商城入口 | A 在「我的」页加一行「车主商城」 / B 顶栏加图标 / C 保持现状 | A，代价最小且不占 Tab 位 |
