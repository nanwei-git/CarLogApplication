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

## D4 · USE_MOCK 当前为 true（与 SPEC 记录不一致）

- **决策**：`common/constants/HttpApi.ets` 的 `USE_MOCK` 现为 `true`，全量走 `MockData.ets`。
- **理由**：真服务器 `/app/**` 返回业务码 401（后端鉴权未放行），先在模拟器验收 UI。
- **影响**：SPEC §3「默认 false 直连」与现状不符，已在 SPEC 标注为已知偏差。后端放行后改回 `false` 即可。

## D5 · 持久化沿用 AppStorage + PersistentStorage（KT10）

- **决策**：不用指导书示例的 `preferences.getPreferencesSync`，沿用既有的 `PersistentStorage.persistProp` + `AppStorage`，键名集中 `StorageUtils.ets`。
- **理由**：底层同为「用户首选项」，满足 KT10，且贴合本工程既有规范。

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

## D11 · 编译只能回 DevEco

- **现象**：本机命令行无 `hvigorw`，`local.properties` 未配 SDK 路径。
- **决策**：代码改动只做静态自检（引用链、括号配平），编译与运行回到 DevEco Studio。

---

## 待裁决清单

| 编号 | 事项 | 选项 | 推荐 |
|---|---|---|---|
| D9 | 车主商城入口 | A 在「我的」页加一行「车主商城」 / B 顶栏加图标 / C 保持现状 | A，代价最小且不占 Tab 位 |
