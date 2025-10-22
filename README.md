# 智能计算器 SmartCalc

> 专业级数学工具应用 - HarmonyOS 原生应用

## 项目概述

SmartCalc 是一个功能强大的数学计算器应用，支持基础运算、高等数学、函数图像生成、离线使用和云端同步。

**版本：** 1.0.0  
**平台：** HarmonyOS (API 10+)  
**开发工具：** DevEco Studio 4.0+

## 主要功能

- ✅ **基础计算**：四则运算、高精度计算（100位精度）
- ✅ **高等数学**：方程求解、微积分、矩阵运算
- ✅ **函数图像**：2D函数绘图、交互缩放、导出图像
- ✅ **公式管理**：保存常用公式、分类管理
- ✅ **历史记录**：自动保存计算历史、搜索和导出
- ✅ **多设备同步**：云端数据同步、多设备共享
- ✅ **离线使用**：完全离线可用、网络恢复后自动同步
- ✅ **多布局适配**：支持手机、平板（Pocket/Compact/Expanded模式）

## 快速开始

### 环境要求

- DevEco Studio 4.0 或更高版本
- HarmonyOS SDK (API 10+)
- Node.js 16.0 或更高版本

### 安装依赖

```bash
# 安装 HarmonyOS 依赖
ohpm install

# 或使用 npm（如果支持）
npm install
```

### 运行应用

1. 在 DevEco Studio 中打开项目
2. 连接 HarmonyOS 设备或启动模拟器
3. 点击 Run 按钮或按 Shift+F10

```bash
# 命令行构建
hvigorw assembleHap
```

### 运行测试

```bash
# 运行所有测试
hvigorw test

# 运行特定测试
hvigorw test --tests ExpressionEngine.test.ets
```

## 项目结构

```
entry/src/main/
├── ets/
│   ├── pages/              # 页面组件
│   │   └── Index.ets       # 欢迎页面
│   ├── components/         # 可复用组件
│   ├── modules/            # 业务逻辑模块
│   ├── models/             # 数据模型
│   ├── utils/              # 工具类
│   │   ├── Constants.ts    # 全局常量
│   │   └── Logger.ts       # 日志工具
│   └── workers/            # 后台任务
├── resources/
│   ├── base/               # 基础资源
│   │   └── element/
│   │       └── string.json # 字符串资源
│   └── rawfile/
│       └── config.json     # 应用配置
└── module.json5            # 模块配置
```

## 技术栈

- **UI 框架**：ArkUI (HarmonyOS)
- **数学计算**：math.js (高精度计算)
- **图像生成**：Canvas + ECharts
- **本地存储**：SQLite (@ohos.data.relationalStore)
- **云端服务**：Supabase (PostgreSQL + Auth + Storage)
- **开发语言**：TypeScript (ArkTS)
- **测试框架**：@ohos/hypium

## 开发状态

### ✅ Phase 1: 项目设置 (完成)

- [x] 项目结构创建
- [x] 依赖配置
- [x] 环境变量配置
- [x] 基础工具类（Logger, Constants）
- [x] 欢迎页面

### ⏳ Phase 2: 基础设施 (进行中)

- [ ] 数据库管理器
- [ ] 数据模型（Formula, HistoryRecord等）
- [ ] 数据管理器（CRUD操作）
- [ ] 主题和布局管理器

### 📋 Phase 3-8: 核心功能开发 (待开始)

详见 `specs/001-smartcalc-app/tasks.md`

## 配置说明

### 环境变量

编辑 `entry/src/main/resources/rawfile/config.json`：

```json
{
  "supabase": {
    "url": "your-supabase-url",
    "anonKey": "your-anon-key",
    "enabled": true
  },
  "calculation": {
    "precision": 100,
    "defaultAngleUnit": "degree"
  }
}
```

### 构建配置

- **开发版本**：`hvigorw assembleHap`
- **发布版本**：`hvigorw assembleHap --mode release`
- **代码混淆**：在 `entry/build-profile.json5` 中配置

## 文档

- [功能规范](specs/001-smartcalc-app/spec.md)
- [实施计划](specs/001-smartcalc-app/plan.md)
- [任务清单](specs/001-smartcalc-app/tasks.md)
- [数据模型](specs/001-smartcalc-app/data-model.md)
- [API 契约](specs/001-smartcalc-app/contracts/api-contracts.md)
- [技术研究](specs/001-smartcalc-app/research.md)
- [快速开始指南](specs/001-smartcalc-app/quickstart.md)

## 贡献指南

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 联系方式

- 项目地址：[GitHub](https://github.com/your-username/smartcalc)
- 问题反馈：[Issues](https://github.com/your-username/smartcalc/issues)

## 致谢

- [HarmonyOS](https://developer.harmonyos.com/) - 应用平台
- [math.js](https://mathjs.org/) - 数学计算库
- [ECharts](https://echarts.apache.org/) - 图表库
- [Supabase](https://supabase.com/) - 云端服务

---

**版本历史**

- **v1.0.0** (2025-10-22) - 初始版本，项目设置完成
- 更多版本信息见 [CHANGELOG.md](CHANGELOG.md)

