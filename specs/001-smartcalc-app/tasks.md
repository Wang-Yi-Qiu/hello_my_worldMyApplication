# 任务清单：智能计算器 SmartCalc

**项目：** 智能计算器 SmartCalc  
**版本：** 1.0.0  
**日期：** 2025-10-22  
**分支：** 001-smartcalc-app

---

## 任务概览

**总任务数：** 120+  
**用户故事：** 5 个（基于用户场景）  
**预计周期：** 14 周  
**MVP 范围：** 用户故事 1（基础数学计算）

---

## 依赖关系

### 用户故事完成顺序

```
Phase 1: Setup (必须) → Phase 2: Foundational (必须)
  ↓
Phase 3: US1 (基础计算) [MVP] ← 优先级最高
  ↓
Phase 4: US2 (高等数学) [可独立开发]
Phase 5: US3 (函数图像) [可独立开发]
  ↓
Phase 6: US4 (离线使用) [依赖 US1, US2, US3]
Phase 7: US5 (多设备同步) [依赖 US1, US2, US3]
  ↓
Phase 8: Polish (最后)
```

### 并行执行机会

- **US2 和 US3** 可以并行开发（不同模块，无依赖）
- **US4 和 US5** 可以并行开发（云端服务和离线模式相对独立）
- 同一用户故事内，标记 [P] 的任务可并行执行

---

## Phase 1: 项目设置（Setup）

**目标：** 搭建开发环境和项目基础结构

**独立测试标准：**
- ✅ 项目在 DevEco Studio 中成功构建并运行
- ✅ 显示 "Hello HarmonyOS" 欢迎页面
- ✅ 依赖包成功安装

### 任务列表

- [x] T001 创建 HarmonyOS 项目结构在 DevEco Studio
- [x] T002 配置 oh-package.json5 添加依赖：math.js, @ohos/hypium
- [x] T003 创建目录结构：entry/src/main/ets/{pages,components,modules,models,utils,workers}
- [x] T004 [P] 配置环境变量文件 entry/src/main/resources/rawfile/config.json
- [x] T005 [P] 创建全局常量文件 entry/src/main/ets/utils/Constants.ts
- [x] T006 [P] 创建日志工具 entry/src/main/ets/utils/Logger.ts
- [x] T007 配置 build-profile.json5 构建参数
- [x] T008 配置 module.json5 应用权限和元数据
- [x] T009 创建欢迎页面 entry/src/main/ets/pages/Index.ets
- [x] T010 运行应用验证基础配置

**完成标准：** 项目成功运行，显示欢迎页面

---

## Phase 2: 基础设施（Foundational）

**目标：** 实现所有用户故事依赖的核心基础设施

**独立测试标准：**
- ✅ 数据库成功初始化并创建所有表
- ✅ 数据管理器可以执行基本 CRUD 操作
- ✅ 主题和布局切换正常工作

### 数据层基础

- [x] T011 创建数据库管理器 entry/src/main/ets/modules/DatabaseManager.ts
- [x] T012 实现数据库初始化和表创建（formulas, history_records, graph_records, user_settings）
- [x] T013 创建 Formula 模型 entry/src/main/ets/models/Formula.ts
- [x] T014 [P] 创建 HistoryRecord 模型 entry/src/main/ets/models/HistoryRecord.ts
- [ ] T015 [P] 创建 GraphRecord 模型 entry/src/main/ets/models/GraphRecord.ts
- [ ] T016 [P] 创建 UserSettings 模型 entry/src/main/ets/models/UserSettings.ts
- [x] T017 创建 DataManager 基础类 entry/src/main/ets/modules/DataManager.ts
- [x] T018 实现 DataManager.saveFormula() 方法
- [x] T019 [P] 实现 DataManager.getFormulas() 方法
- [x] T020 [P] 实现 DataManager.deleteFormula() 方法
- [x] T021 [P] 实现 DataManager.saveHistory() 方法
- [x] T022 [P] 实现 DataManager.getHistory() 方法
- [ ] T023 [P] 实现 DataManager.saveSettings() 方法
- [ ] T024 [P] 实现 DataManager.getSettings() 方法

### UI 基础组件

- [ ] T025 创建主题管理器 entry/src/main/ets/utils/ThemeManager.ts
- [ ] T026 创建布局管理器 entry/src/main/ets/utils/LayoutManager.ts
- [ ] T027 创建资源文件 entry/src/main/resources/base/element/color.json（主题颜色）
- [ ] T028 [P] 创建资源文件 entry/src/main/resources/dark/element/color.json（深色主题）
- [ ] T029 [P] 创建字符串资源 entry/src/main/resources/base/element/string.json
- [ ] T030 创建导航框架 entry/src/main/ets/pages/MainPage.ets（TabBar 导航）

### 验证工具

- [ ] T031 [P] 创建表达式验证器 entry/src/main/ets/utils/Validator.ts
- [ ] T032 [P] 创建格式化工具 entry/src/main/ets/utils/Formatter.ts

**完成标准：** 数据库初始化成功，基础 CRUD 操作通过测试

---

## Phase 3: US1 - 基础数学计算（MVP）

**用户故事：** 作为普通用户，我想快速完成日常四则运算，以便处理日常计算需求

**优先级：** P1（最高，MVP 核心功能）

**独立测试标准：**
- ✅ 用户可以输入 "1+2*3" 并得到正确结果 "7"
- ✅ 支持小数和负数运算
- ✅ 除以零显示友好错误提示
- ✅ 计算历史自动保存并可查看
- ✅ 计算响应时间 < 0.1 秒

### 数学引擎（US1）

- [x] T033 [US1] 安装 math.js 依赖并配置高精度模式
- [x] T034 [US1] 创建 ExpressionEngine 类 entry/src/main/ets/modules/ExpressionEngine.ts
- [x] T035 [US1] 实现 ExpressionEngine.evaluate() 方法（基础四则运算）
- [x] T036 [US1] 实现高精度计算配置（100 位精度）
- [x] T037 [US1] 实现表达式验证和错误处理
- [x] T038 [US1] 实现科学计数法显示格式化
- [ ] T039 [US1] 实现 Worker 后台计算 entry/src/main/ets/workers/CalcWorker.ts
- [ ] T040 [P] [US1] 编写单元测试 entry/src/ohosTest/ets/test/ExpressionEngine.test.ets

### 计算器 UI（US1）

- [x] T041 [US1] 创建 CalculatorPage 页面 entry/src/main/ets/pages/CalculatorPage.ets
- [x] T042 [US1] 创建计算器按钮组件 entry/src/main/ets/components/CalculatorButton.ets
- [x] T043 [US1] 创建显示区域组件 entry/src/main/ets/components/DisplayArea.ets
- [x] T044 [US1] 实现 Pocket 布局模式（小屏设备，基础按键）
- [x] T045 [P] [US1] 实现 Compact 布局模式（手机竖屏/横屏，更多按键）
- [ ] T046 [P] [US1] 实现 Expanded 布局模式（平板大屏，分栏布局）
- [x] T047 [US1] 实现按钮点击事件处理和表达式拼接
- [x] T048 [US1] 实现表达式实时验证和错误高亮
- [x] T049 [US1] 实现等号按钮触发计算
- [x] T050 [US1] 实现计算结果显示和格式化
- [x] T051 [US1] 实现清除（C）和删除（DEL）按钮
- [ ] T052 [US1] 实现主题切换按钮和逻辑

### 历史记录（US1）

- [x] T053 [US1] 创建 HistoryPage 页面 entry/src/main/ets/pages/HistoryPage.ets
- [x] T054 [US1] 创建历史记录列表项组件 entry/src/main/ets/components/HistoryListItem.ets
- [x] T055 [US1] 实现历史记录自动保存（计算完成后）
- [x] T056 [US1] 实现历史记录列表显示（虚拟滚动优化）
- [ ] T057 [US1] 实现点击历史记录重新加载到计算器
- [ ] T058 [P] [US1] 实现历史记录搜索和筛选
- [ ] T059 [P] [US1] 实现历史记录删除（单条和批量）
- [x] T060 [US1] 实现历史记录清空功能

### 集成测试（US1）

- [ ] T061 [US1] 端到端测试：完整计算流程（输入 → 计算 → 显示 → 保存历史）
- [ ] T062 [US1] 性能测试：计算响应时间验证（< 0.1 秒）
- [ ] T063 [US1] 多设备测试：验证三种布局模式显示正常

**完成标准：** 基础计算器功能完整，所有测试通过，可作为 MVP 发布

---

## Phase 4: US2 - 高等数学运算

**用户故事：** 作为大学生，我想求解方程和计算微积分，以便完成数学作业

**优先级：** P2

**独立测试标准：**
- ✅ 用户可以输入 "x^2 - 4 = 0" 并得到解 "x = -2, x = 2"
- ✅ 支持导数计算 "d/dx(x^2)" 得到 "2*x"
- ✅ 支持积分计算
- ✅ 复杂计算响应时间 < 1 秒
- ✅ 结果可以保存到公式库

### 高等数学引擎（US2）

- [ ] T064 [US2] 实现 ExpressionEngine.solveEquation() 方法（方程求解）
- [ ] T065 [US2] 实现 ExpressionEngine.differentiate() 方法（求导）
- [ ] T066 [US2] 实现 ExpressionEngine.integrate() 方法（积分）
- [ ] T067 [P] [US2] 实现矩阵运算支持 ExpressionEngine.matrixOps()
- [ ] T068 [P] [US2] 实现统计计算支持 ExpressionEngine.statistics()
- [ ] T069 [US2] 实现复数运算支持
- [ ] T070 [P] [US2] 编写单元测试（方程、微积分、矩阵、统计）

### 高级计算器 UI（US2）

- [ ] T071 [US2] 扩展 CalculatorPage 添加高级模式切换按钮
- [ ] T072 [US2] 创建高级数学函数按钮面板
- [ ] T073 [US2] 实现方程输入界面（变量选择）
- [ ] T074 [US2] 实现微积分输入界面（导数/积分选择）
- [ ] T075 [P] [US2] 实现矩阵输入界面
- [ ] T076 [US2] 实现高级计算结果展示（多解显示、符号显示）

### 公式管理（US2）

- [ ] T077 [US2] 创建 FormulaPage 页面 entry/src/main/ets/pages/FormulaPage.ets
- [ ] T078 [US2] 创建公式列表项组件 entry/src/main/ets/components/FormulaListItem.ets
- [ ] T079 [US2] 创建公式详情页面 entry/src/main/ets/pages/FormulaDetailPage.ets
- [ ] T080 [US2] 实现公式添加/编辑界面
- [ ] T081 [US2] 实现公式保存到数据库
- [ ] T082 [US2] 实现公式列表显示（按分类和时间排序）
- [ ] T083 [P] [US2] 实现公式搜索功能
- [ ] T084 [P] [US2] 实现公式分类管理
- [ ] T085 [US2] 实现点击公式快速加载到计算器
- [ ] T086 [P] [US2] 实现公式导入/导出（JSON 格式）

### 集成测试（US2）

- [ ] T087 [US2] 端到端测试：方程求解完整流程
- [ ] T088 [US2] 端到端测试：微积分计算流程
- [ ] T089 [US2] 性能测试：复杂计算响应时间验证（< 1 秒）

**完成标准：** 高等数学功能完整，公式管理可用，测试通过

---

## Phase 5: US3 - 函数图像生成

**用户故事：** 作为高中生，我想绘制函数图像，以便理解数学概念

**优先级：** P2

**独立测试标准：**
- ✅ 用户可以输入 "sin(x)" 并看到正弦波图像
- ✅ 支持缩放、拖拽、光标追踪
- ✅ 图像生成时间 < 0.5 秒
- ✅ 可以导出为 PNG 和 SVG 格式
- ✅ 支持多函数同时显示（不同颜色）

### 图像生成引擎（US3）

- [ ] T090 [US3] 安装 ECharts（eChart-ohos）依赖
- [ ] T091 [US3] 创建 ChartGenerator 类 entry/src/main/ets/modules/ChartGenerator.ts
- [ ] T092 [US3] 实现 ChartGenerator.generateGraph() 方法（2D 函数绘图）
- [ ] T093 [US3] 实现坐标轴自动范围计算
- [ ] T094 [US3] 实现多函数同时绘制（颜色区分）
- [ ] T095 [US3] 实现采样点优化算法（性能优化）
- [ ] T096 [P] [US3] 实现 ChartGenerator.exportToPNG() 方法
- [ ] T097 [P] [US3] 实现 ChartGenerator.exportToSVG() 方法
- [ ] T098 [P] [US3] 编写单元测试

### 图像 UI（US3）

- [ ] T099 [US3] 创建 GraphPage 页面 entry/src/main/ets/pages/GraphPage.ets
- [ ] T100 [US3] 创建 Canvas 组件 entry/src/main/ets/components/GraphCanvas.ets
- [ ] T101 [US3] 实现函数表达式输入界面
- [ ] T102 [US3] 实现图像实时绘制
- [ ] T103 [US3] 实现缩放手势处理（捏合缩放）
- [ ] T104 [US3] 实现拖拽手势处理（平移视图）
- [ ] T105 [US3] 实现光标追踪和坐标显示
- [ ] T106 [US3] 实现积分区域高亮显示
- [ ] T107 [US3] 实现图像导出按钮和文件保存
- [ ] T108 [US3] 实现多函数管理（添加、删除、颜色选择）
- [ ] T109 [US3] 实现图像设置面板（坐标范围、网格显示等）

### 图像记录管理（US3）

- [ ] T110 [US3] 实现图像记录保存到数据库
- [ ] T111 [US3] 实现图像记录列表显示
- [ ] T112 [P] [US3] 实现图像记录加载和重绘

### 集成测试（US3）

- [ ] T113 [US3] 端到端测试：函数图像生成完整流程
- [ ] T114 [US3] 性能测试：图像生成时间验证（< 0.5 秒）
- [ ] T115 [US3] 交互测试：缩放、拖拽、导出功能验证

**完成标准：** 函数图像功能完整，交互流畅，导出正常

---

## Phase 6: US4 - 离线使用

**用户故事：** 作为野外工作的工程师，我想在无网络环境下使用应用，以便随时进行计算

**优先级：** P3

**依赖：** US1, US2, US3（需要核心功能已完成）

**独立测试标准：**
- ✅ 应用在飞行模式下正常启动
- ✅ 所有核心功能（计算、图像、公式、历史）离线可用
- ✅ 数据保存在本地数据库
- ✅ 网络恢复后显示同步提示

### 离线模式实现（US4）

- [ ] T116 [US4] 创建网络状态监听器 entry/src/main/ets/utils/NetworkMonitor.ts
- [ ] T117 [US4] 实现离线模式检测和 UI 提示
- [ ] T118 [US4] 优化本地数据库查询性能
- [ ] T119 [US4] 实现数据库索引优化
- [ ] T120 [US4] 实现数据库压缩（VACUUM）
- [ ] T121 [P] [US4] 实现数据导出功能（备份到本地文件）
- [ ] T122 [P] [US4] 实现数据导入功能（从备份恢复）

### 离线测试（US4）

- [ ] T123 [US4] 飞行模式测试：验证所有功能可用
- [ ] T124 [US4] 数据持久化测试：应用重启后数据完整
- [ ] T125 [US4] 离线性能测试：响应时间不受影响

**完成标准：** 应用完全离线可用，数据可靠保存

---

## Phase 7: US5 - 多设备同步

**用户故事：** 作为使用多台设备的教师，我想在手机和平板间共享数据，以便随时访问我的公式和历史

**优先级：** P3

**依赖：** US1, US2, US3（需要核心数据已定义）

**独立测试标准：**
- ✅ 用户可以注册和登录账号
- ✅ 登录后数据自动同步到云端
- ✅ 在另一台设备登录后看到同步的数据
- ✅ 同步在 5 秒内完成（1MB 数据）
- ✅ 冲突解决正确（保留最新版本）

### Supabase 集成（US5）

- [ ] T126 [US5] 创建 Supabase 项目并获取凭据
- [ ] T127 [US5] 创建云端数据库表（cloud_formulas, cloud_history, cloud_graphs, cloud_settings）
- [ ] T128 [US5] 配置 RLS 策略（Row Level Security）
- [ ] T129 [US5] 配置 Storage bucket（图像存储）
- [ ] T130 [P] [US5] 安装 Supabase 客户端依赖

### 认证服务（US5）

- [ ] T131 [US5] 创建 AuthService 类 entry/src/main/ets/modules/AuthService.ts
- [ ] T132 [US5] 实现 AuthService.signUp() 方法（邮箱注册）
- [ ] T133 [US5] 实现 AuthService.signIn() 方法（邮箱登录）
- [ ] T134 [US5] 实现 AuthService.signOut() 方法
- [ ] T135 [US5] 实现 AuthService.getSession() 方法（会话管理）
- [ ] T136 [US5] 实现 AuthService.refreshSession() 方法（令牌刷新）
- [ ] T137 [P] [US5] 实现登录状态持久化
- [ ] T138 [P] [US5] 编写单元测试

### 认证 UI（US5）

- [ ] T139 [US5] 创建 LoginPage 页面 entry/src/main/ets/pages/LoginPage.ets
- [ ] T140 [US5] 创建 RegisterPage 页面 entry/src/main/ets/pages/RegisterPage.ets
- [ ] T141 [US5] 实现登录表单和验证
- [ ] T142 [US5] 实现注册表单和验证
- [ ] T143 [US5] 实现登录/注册错误提示
- [ ] T144 [US5] 实现"记住我"功能
- [ ] T145 [P] [US5] 实现设置页面（账号信息、登出）

### 同步服务（US5）

- [ ] T146 [US5] 创建 SyncService 类 entry/src/main/ets/modules/SyncService.ts
- [ ] T147 [US5] 实现 SyncService.syncToCloud() 方法（上传本地数据）
- [ ] T148 [US5] 实现 SyncService.syncFromCloud() 方法（下载云端数据）
- [ ] T149 [US5] 实现增量同步逻辑（仅同步变更数据）
- [ ] T150 [US5] 实现冲突解决策略（Last Write Wins）
- [ ] T151 [US5] 实现同步状态管理（sync_state 字段）
- [ ] T152 [US5] 实现自动同步触发（网络恢复、登录后）
- [ ] T153 [US5] 实现手动同步按钮
- [ ] T154 [US5] 实现同步进度提示
- [ ] T155 [P] [US5] 实现同步错误处理和重试
- [ ] T156 [P] [US5] 编写单元测试

### 图像上传（US5）

- [ ] T157 [US5] 实现图像文件上传到 Supabase Storage
- [ ] T158 [US5] 实现图像 URL 保存到云端数据库
- [ ] T159 [P] [US5] 实现图像下载和缓存

### 集成测试（US5）

- [ ] T160 [US5] 端到端测试：用户注册、登录、数据同步完整流程
- [ ] T161 [US5] 多设备测试：验证数据在两台设备间同步
- [ ] T162 [US5] 冲突测试：验证冲突解决策略
- [ ] T163 [US5] 性能测试：同步时间验证（< 5 秒）
- [ ] T164 [US5] 安全测试：JWT 令牌验证、RLS 策略验证

**完成标准：** 用户认证和数据同步功能完整，多设备数据一致

---

## Phase 8: 打磨与优化（Polish）

**目标：** 性能优化、用户体验改进、发布准备

**独立测试标准：**
- ✅ 启动时间 < 2 秒
- ✅ 内存占用 < 200MB
- ✅ 所有功能流畅运行
- ✅ 用户满意度测试通过
- ✅ 应用通过审核要求

### 性能优化

- [ ] T165 实现懒加载（非核心模块延迟加载）
- [ ] T166 实现资源压缩和打包优化
- [ ] T167 实现图像渲染优化（requestAnimationFrame）
- [ ] T168 实现虚拟列表优化（历史记录、公式列表）
- [ ] T169 [P] 实现防抖/节流处理（用户输入）
- [ ] T170 [P] 实现表达式缓存（重复计算优化）
- [ ] T171 性能测试：验证启动时间 < 2 秒
- [ ] T172 性能测试：验证内存占用 < 200MB

### 用户体验改进

- [ ] T173 实现加载动画和骨架屏
- [ ] T174 实现空状态提示（无历史、无公式等）
- [ ] T175 实现错误状态友好提示
- [ ] T176 实现操作反馈（按钮点击效果、Toast 提示）
- [ ] T177 [P] 实现无障碍功能（屏幕阅读器支持）
- [ ] T178 [P] 实现字体放大支持
- [ ] T179 [P] 实现高对比度模式
- [ ] T180 用户体验测试：10+ 测试用户反馈

### 安全和隐私

- [ ] T181 实现本地数据库加密（SQLCipher）
- [ ] T182 实现密码哈希（bcrypt）
- [ ] T183 配置 HTTPS 网络请求
- [ ] T184 实现代码混淆配置
- [ ] T185 [P] 编写隐私政策文档
- [ ] T186 [P] 编写用户协议文档
- [ ] T187 安全审查：敏感数据处理验证

### 文档和发布

- [ ] T188 编写用户使用说明（README.md）
- [ ] T189 [P] 编写 API 文档（开发者参考）
- [ ] T190 [P] 录制功能演示视频
- [ ] T191 准备应用截图（至少 5 张）
- [ ] T192 准备应用描述和宣传文案
- [ ] T193 配置应用签名和证书
- [ ] T194 生成 Release 版本 HAP 包
- [ ] T195 提交华为应用市场审核

**完成标准：** 应用性能达标，用户体验优秀，可以发布

---

## 实施策略

### MVP 优先策略

**MVP 范围（Phase 3: US1）：**
- 基础数学计算
- 计算器 UI（三种布局）
- 历史记录管理
- 主题切换

**MVP 交付标准：**
- ✅ 用户可以完成日常四则运算
- ✅ 界面简洁直观
- ✅ 数据可靠保存
- ✅ 性能达标（响应 < 0.1 秒）

**MVP 后迭代：**
1. 第一次迭代：US2（高等数学）+ US3（函数图像）
2. 第二次迭代：US4（离线）+ US5（同步）
3. 第三次迭代：Polish（优化和发布）

### 增量交付策略

每个用户故事作为一个独立的可交付增量：
- **US1 → MVP**：可以独立发布，满足基础用户需求
- **US2 + US3 → v1.1**：增加高级功能，满足专业用户需求
- **US4 + US5 → v1.2**：增加离线和同步，满足多设备用户需求
- **Polish → v1.3**：优化体验，正式发布

### 并行开发建议

**阶段 1（US2 和 US3 可并行）：**
- 团队 A：开发 US2（高等数学）
- 团队 B：开发 US3（函数图像）
- 两个模块相对独立，可以同时开发

**阶段 2（US4 和 US5 可并行）：**
- 团队 A：开发 US4（离线优化）
- 团队 B：开发 US5（云端同步）
- 离线和云端功能可以并行开发，最后集成

---

## 验证检查清单

### 格式验证

- ✅ 所有任务都以 `- [ ]` 开头（markdown checkbox）
- ✅ 所有任务都有唯一的任务 ID（T001, T002...）
- ✅ 用户故事任务都有 [US1], [US2] 等标签
- ✅ 可并行任务标记 [P]
- ✅ 所有任务都包含文件路径或明确的实现位置

### 完整性验证

- ✅ 每个用户故事都有独立的测试标准
- ✅ 每个用户故事都有完整的任务覆盖（从模型到 UI）
- ✅ 依赖关系清晰标注
- ✅ MVP 范围明确定义
- ✅ 并行执行机会已识别

---

## 总结

**任务总数：** 195 个  
**用户故事：** 5 个  
**并行机会：** 80+ 个任务可并行  
**MVP 任务数：** 29 个（T033-T063）  
**预计 MVP 周期：** 4-6 周  
**预计完整项目周期：** 14 周

**关键里程碑：**
- Week 2: Setup + Foundational 完成
- Week 6: MVP (US1) 完成并可发布
- Week 10: US2 + US3 完成
- Week 12: US4 + US5 完成
- Week 14: Polish 完成，正式发布

---

*本任务清单基于功能规范、实施计划和技术研究文档生成，所有任务都是可执行的具体行动项。建议按照用户故事优先级和依赖关系顺序执行。*
