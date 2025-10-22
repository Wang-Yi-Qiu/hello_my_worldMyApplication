# 智能计算器 App 技术方案文档（HarmonyOS + 融合 HiPER 功能）

## 一、项目概述  
**项目名称：** 智能计算器 SmartCalc  
**目标平台：** DevEco Studio（HarmonyOS）  
**主要功能：**  
- 支持基础四则运算；  
- 高等数学运算（微积分、导数、积分、极限、方程／系统方程、不等式）；  
- 函数图像生成与导出；  
- 常用公式及历史运算记录；  
- 支持离线本地使用 + 在线云端同步（多设备共享）；  
- 界面简洁，参考 “苹果计算器风格” + HiPER 多布局适配（手机、平板）。  

**技术目标：**  
- 离线功能完整，无网络也可用；  
- 登录后支持跨设备数据同步、云存储；  
- 支持高级数学表达式与图像可视化；  
- UI 支持多设备（手机/平板）与多布局模式。  

---

## 二、总体架构设计  
应用采用“双层数据架构” + “强数学运算能力”设计。  
- **本地层（离线）**：使用 SQLite 存储公式、历史、图像路径。  
- **云端层（在线）**：使用云数据库 + 文件存储（如 Supabase 或华为云）保存用户同步数据。  
- **同步层**：自定义 SyncService 模块，实现本地 ↔ 云端的双向同步。  
- **数学运算模块**：参考 HiPER 功能，支持符号计算、方程求解、多格式输入、历史显示等。  
- **UI 适配层**：支持手机竖屏／横屏、小屏 “pocket” 模式、平板 “expanded” 模式。  

### 系统架构图  
+--------------------------------------------------------------+

SmartCalc App
UI（ArkUI）
├─ CalculatorPage
├─ GraphPage
├─ FormulaPage
└─ HistoryPage
--------------------------------------------------------------
逻辑层
├─ ExpressionEngine.ts
├─ ChartGenerator.ts
├─ DataManager.ts
└─ SyncService.ts
--------------------------------------------------------------
数据层
├─ 本地：SQLite
├─ 云端：CloudDB + Storage
└─ 登录鉴权模块
+--------------------------------------------------------------+

yaml
复制代码

---

## 三、模块说明  

| 模块 | 功能描述 | 技术实现方案 |
|------|----------|-------------|
| UI界面层 | 构建按钮、展示区域、历史页、图像页等；支持多布局 | 使用 ArkUI + Canvas；实现“pocket/compact/expanded”三种布局参考 HiPER :contentReference[oaicite:2]{index=2} |
| 计算模块 | 解析表达式、执行运算、支持高级数学：方程/系统方程、不等式、极限、级数、符号计算等 | 自定义 ExpressionEngine，借鉴 HiPER 的特性 :contentReference[oaicite:3]{index=3} |
| 绘图模块 | 将用户输入函数或公式可视化为图像，支持积分区域、高亮、多函数比较 | 使用 Canvas／Chart.js，并增加导出 PNG／SVG 功能 |
| 本地存储模块 | 保存用户公式、历史记录、图像路径、离线数据 | 使用 `@ohos.data.relationalStore`（SQLite） |
| 云端存储模块 | 保存用户账户数据、同步公式、上传图像、多设备共享 | 例如 Supabase PostgreSQL + Storage 或华为云方案 |
| 同步模块 | 检测网络／登录状态，实现数据同步逻辑（上传／下载／合并） | 自定义 SyncService 模块 |
| 登录模块 | 用户注册、登录、鉴权，支持跨设备使用 | 可使用 Supabase Auth 或华为帐号系统 |

---

## 四、数据结构设计  

### 本地数据库（SQLite）表结构  

**表：formulas**  
| 字段名      | 类型    | 描述                     |
|-------------|---------|--------------------------|
| id          | INTEGER PRIMARY KEY | 本地自增 ID        |
| user_id     | TEXT    | 所属用户（可为空）         |
| name        | TEXT    | 公式名称                  |
| expression  | TEXT    | 公式表达式                |
| updated_at  | TEXT    | 最后更新时间               |
| sync_state  | INTEGER | 同步状态（0=未同步，1=已同步） |

**表：graphs**  
| 字段名      | 类型    | 描述                     |
|-------------|---------|--------------------------|
| id          | INTEGER PRIMARY KEY | 图像 ID             |
| formula_id  | INTEGER | 对应的公式 ID             |
| image_path  | TEXT    | 本地图像路径               |
| cloud_url   | TEXT    | 云端存储 URL              |
| updated_at  | TEXT    | 最后更新时间               |

**表：history_records**（新增参考 HiPER 历史功能）  
| 字段名      | 类型    | 描述                     |
|-------------|---------|--------------------------|
| id          | INTEGER PRIMARY KEY | 历史记录 ID          |
| user_id     | TEXT    | 所属用户                  |
| expression  | TEXT    | 输入的表达式               |
| result      | TEXT    | 运算结果                  |
| created_at  | TEXT    | 运算时间                  |

---

## 五、同步逻辑设计（SyncService）  

### 流程描述  
1. **应用启动**  
   - 检查用户是否登录及网络状态。  
   - 如果未登录或离线：使用本地数据库。  
   - 如果已登录且有网络：启动同步流程。  
2. **同步流程**  
   - 从云端拉取该用户最新数据（公式、图像、历史）。  
   - 对比本地记录 `updated_at` 时间戳：  
     - 本地较新 → 上传到云端。  
     - 云端较新 → 下载并覆盖或合并本地。  
   - 若有本地图像路径尚未上传：上传至云存储，返回 `cloud_url`，更新本地。  
   - 更新本地 `sync_state` 为已同步状态。  
3. **网络中断与恢复机制**  
   - 网络断开时：变为“离线模式”，用户操作将仅写入本地。  
   - 网络恢复后：恢复调用同步流程，将离线期间新增数据同步至云端。  

---

## 六、数学与绘图功能增强（参考 HiPER 特性）  
- 支持高精度运算（例如至少 100 位有效数字 + 9 位指数） :contentReference[oaicite:4]{index=4}  
- 支持分数、混合数、周期小数的输入与转换 :contentReference[oaicite:5]{index=5}  
- 支持方程与系统方程求解；支持不等式、级数和极限运算 :contentReference[oaicite:6]{index=6}  
- 支持向量／矩阵运算、复数运算、统计/回归分析 :contentReference[oaicite:7]{index=7}  
- 支持函数绘图、积分区域高亮、3D 图（可视需求决定是否实现） :contentReference[oaicite:8]{index=8}  
- 支持多格式输入（十进制、二/八/十六进制）、单位转换、常数库 :contentReference[oaicite:9]{index=9}  

---

## 七、界面设计与适配  
- 支持三种主要布局模式：  
  - Pocket 模式：适合小屏设备，仅基础按键。  
  - Compact 模式：适合手机竖屏或横屏，显示更多功能键。  
  - Expanded 模式：适合平板或大屏，左边运算区，右边历史/公式/图像区。  
- UI 风格简洁、参考苹果计算器，同时融入 HiPER 多布局适配理念。  
- 支持黑／白／主题切换。  
- 在图像页面提供导出按钮（PNG/SVG），缩放、拖拽、光标查看函数值。  

---

## 八、推荐开发技术栈  

| 模块            | 技术选型                           | 说明                                   |
|-----------------|------------------------------------|----------------------------------------|
| 前端框架        | ArkUI (HarmonyOS)                  | 官方 UI 框架                            |
| 计算模块        | TypeScript + 自定义解析引擎        | 支持高级数学功能                         |
| 绘图模块        | Canvas + Chart.js 或 自绘逻辑      | 实现函数/积分图像绘制                   |
| 本地数据库      | `@ohos.data.relationalStore`       | SQLite 实现                             |
| 云端数据库      | Supabase PostgreSQL 或 华为 CloudDB | 多设备同步、云端存储                     |
| 文件存储        | Supabase Storage 或 华为云存储     | 保存导出图像、用户文件                   |
| 用户鉴权        | Supabase Auth 或 华为帐号系统       | 支持登录、跨设备同步                     |
| 同步服务模块    | 自定义 SyncService.ts              | 实现数据同步逻辑                         |

---

## 九、项目目录结构（建议）  
/entry
├─ ets/
│ ├─ pages/
│ │ ├─ CalculatorPage.ets
│ │ ├─ GraphPage.ets
│ │ ├─ FormulaPage.ets
│ │ └─ HistoryPage.ets
│ ├─ components/
│ │ ├─ CalculatorButton.ets
│ │ └─ FormulaListItem.ets
│ ├─ modules/
│ │ ├─ DataManager.ts
│ │ ├─ SyncService.ts
│ │ ├─ ExpressionEngine.ts
│ │ └─ ChartGenerator.ts
│ └─ main.ets
├─ resources/
│ └─ images/
└─ config.json

yaml
复制代码

---

## 十、未来扩展方向  
- 增加 AI 辅助公式识别（如拍照识别公式）  
- 增加 3D 图及更高级绘图功能  
- 支持语音输入公式  
- 支持华为云账号＋AppGallery 发布，全鸿蒙生态支持  
- 增加用户分享功能（例如分享到社交平台／导出公式包）  

---

## 十一、总结  
- 通过融合 HiPER 的高级数学能力，我们让 SmartCalc 不只是一个普通计算器，而成为**专业级数学工具**。  
- 同时保留你原本设计的“云同步 +多设备 +简洁界面”理念。  
- 模块化架构、双层数据设计、强功能数学模块与多布局 UI 结合，为你打造一个功能强大且用户友好的 App。  

---

## 十二、参考资料  
- HiPER 官方特性说明 :contentReference[oaicite:10]{index=10}  
- HarmonyOS 开发文档（DevEco Studio）  
- Supabase 官方文档  
