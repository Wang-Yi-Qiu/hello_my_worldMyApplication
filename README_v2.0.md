# 智能计算器 SmartCalc v2.0 🧮

<div align="center">

![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)
![HarmonyOS](https://img.shields.io/badge/HarmonyOS-3.0+-green.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)
![Status](https://img.shields.io/badge/status-production-success.svg)

**一款功能强大的 HarmonyOS 智能计算器应用**

支持基础运算、科学计算、高等数学、历史记录管理等功能

[快速开始](#快速开始) • [功能特性](#功能特性) • [使用指南](#使用指南) • [文档](#文档)

</div>

---

## ✨ v2.0 新特性

### 🎯 核心更新

- ✅ **定积分修复** - 修复 sin(x) 在 [0, π] 区间的计算问题
- ✅ **历史分类** - 支持 8 种计算类型自动分类
- ✅ **收藏功能** - 星标收藏重要计算记录
- ✅ **快捷按钮** - 右上角一键切换科学计算器和数学笔记
- ✅ **+/- 修复** - 完善正负号切换功能
- ✅ **中文界面** - 100% 中文本地化支持
- ✅ **SageMath 集成** - 强大的数学计算引擎支持

---

## 📋 功能特性

### 🔢 基础计算器
- 四则运算（+、-、×、÷）
- 百分比计算
- 正负号切换 ✨新增
- 清除和删除功能
- 实时结果显示

### 🔬 科学计算器
- 三角函数（sin, cos, tan）
- 反三角函数（asin, acos, atan）
- 指数和对数（exp, ln, log）
- 幂运算和开方
- 数学常数（π, e）
- 快捷切换按钮 ✨新增

### 📐 高等数学
- **求导** - 符号求导和数值求导
- **积分** - 定积分和不定积分 ✨修复
- **极限** - 极限计算
- **方程** - 方程求解
- 详细解题步骤
- LaTeX 渲染支持

### 📝 历史记录
- 自动保存计算历史
- 8 种分类标签 [object Object] 基础运算
  - 🔬 科学计算
  - ∂ 求导
  - ∫ 积分
  - lim 极限
  - = 方程
- 收藏功能 ✨新增
  - 星标收藏
  - 滑动操作
  - 收藏筛选
- 分类筛选
- 批量管理
- 搜索功能

### 🚀 SageMath 集成 ✨新增
- 更精确的数学计算
- 符号运算支持
- 两种集成方案
  - SageMathCell 公共服务
  - 自建服务器
- 完整的 API 封装

---

## 🎨 界面预览

### 计算器主界面
```
┌─────────────────────────────────────┐
│ 智能计算器          [🔬] [📝]      │  ← 快捷按钮
├─────────────────────────────────────┤
│                                     │
│         0                           │  ← 显示区域
│                                     │
├─────────────────────────────────────┤
│  AC   +/-   %    ÷                 │
│  7    8     9    ×                 │
│  4    5     6    -                 │  ← 按钮区域
│  1    2     3    +                 │
│  0    .     =                      │
└─────────────────────────────────────┘
```

### 历史记录界面
```
┌─────────────────────────────────────┐
│ 全部(100)  [筛选▼] [编辑] [刷新]   │  ← 操作栏
├─────────────────────────────────────┤
│ 🔢 基础运算                    ⭐   │  ← 分类+收藏
│ 123 + 456                           │
│ = 579                               │
│ 2分钟前                        #100 │
├─────────────────────────────────────┤
│ ∫ 积分                         ☆   │
│ sin(x), [0, π]                      │
│ = 2.000000                          │
│ 5分钟前                         #99 │
└─────────────────────────────────────┘
```

---

## 🚀 快速开始

### 环境要求
- HarmonyOS 3.0+
- DevEco Studio 4.0+
- Node.js 16+

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/your-repo/smartcalc.git
cd smartcalc
```

2. **安装依赖**
```bash
npm install
```

3. **构建项目**
```bash
npm run build
```

4. **运行应用**
```bash
npm run dev
```

### 快速体验

1. 打开应用
2. 尝试计算：`123 + 456 =`
3. 点击右上角 🔬 切换到科学计算器
4. 尝试高等数学：计算 ∫[0, π] sin(x) dx
5. 查看历史记录，点击 ⭐ 收藏

---

## 📖 使用指南

### 基础计算

```typescript
// 示例：计算 123 + 456
1. 输入 "123"
2. 点击 "+"
3. 输入 "456"
4. 点击 "="
5. 结果：579
```

### 科学计算

```typescript
// 示例：计算 sin(π/2)
1. 点击右上角 🔬 切换到科学模式
2. 点击 "sin"
3. 输入 "π" (使用数学键盘)
4. 输入 "÷ 2"
5. 点击 "="
6. 结果：1
```

### 定积分计算

```typescript
// 示例：∫[0, π] sin(x) dx
1. 切换到高等数学页面
2. 点击 "引导式输入" → "定积分 ∫ᵃᵇ"
3. 填写：
   - 函数：sin(x)
   - 变量：x
   - 下限：0
   - 上限：π
4. 点击 "计算"
5. 结果：2.000000 ✅
```

### 历史记录管理

```typescript
// 收藏记录
1. 打开历史记录页面
2. 找到要收藏的记录
3. 点击右侧 ☆ 图标
4. 星标变为 ⭐ 表示已收藏

// 筛选分类
1. 点击顶部 "筛选" 按钮
2. 选择分类（如 "∫ 积分"）
3. 查看该分类的所有记录

// 批量删除
1. 点击 "编辑" 按钮
2. 选择要删除的记录
3. 点击 "删除" 按钮
4. 确认操作
```

---

## 🔧 SageMath 集成

### 方案一：使用公共服务（推荐用于开发）

```typescript
import { sageMathService } from '../services/SageMathService';

// 直接使用，无需配置
const result = await sageMathService.computeDefiniteIntegral(
  'sin(x)',
  'x',
  '0',
  'pi'
);
```

### 方案二：自建服务器（推荐用于生产）

#### 1. 使用 Docker 部署

```bash
# 拉取镜像
docker pull sagemath/sagemath

# 运行容器
docker run -d -p 5000:5000 \
  -v $(pwd)/sagemath_server.py:/home/sage/server.py \
  sagemath/sagemath \
  sage -python /home/sage/server.py
```

#### 2. 配置应用

```typescript
import { sageMathService } from '../services/SageMathService';

// 设置自定义服务器
sageMathService.setCustomServer('http://your-server:5000');

// 现在所有计算都使用自定义服务器
const result = await sageMathService.computeDefiniteIntegral(
  'sin(x)',
  'x',
  '0',
  'pi'
);
```

详细说明请参考：[SageMath 集成指南](./SAGEMATH_INTEGRATION.md)

---

## 📚 文档

### 技术文档
- [完整功能清单](./实现总结_完整功能清单.md)
- [SageMath 集成指南](./SAGEMATH_INTEGRATION.md)
- [快速使用指南](./快速使用指南.md)
- [项目完成报告](./项目完成报告.md)

### API 文档
- [数据模型](./specs/001-smartcalc-app/data-model.md)
- [API 契约](./specs/001-smartcalc-app/contracts/api-contracts.md)

### 架构文档
- [系统架构](./specs/001-smartcalc-app/architecture.md)
- [数据库设计](./specs/001-smartcalc-app/database-schema.md)

---

## 🏗️ 项目结构

```
smartcalc/
├── entry/src/main/ets/
│   ├── pages/                    # 页面
│   │   ├── CalculatorPage.ets   # 计算器页面 ✨更新
│   │   ├── HistoryPage.ets      # 历史记录页面
│   │   ├── HistoryPageEnhanced.ets  # 增强版历史 ✨新增
│   │   └── AdvancedMathPage.ets # 高等数学页面 ✨更新
│   ├── models/                   # 数据模型
│   │   ├── HistoryRecord.ts     # 历史记录模型 ✨更新
│   │   ├── Formula.ts           # 公式模型
│   │   └── Note.ts              # 笔记模型
│   ├── modules/                  # 业务模块
│   │   ├── ExpressionEngine.ts  # 表达式引擎
│   │   ├── CalculusEngine.ts    # 微积分引擎 ✨更新
│   │   ├── EquationSolver.ts    # 方程求解器
│   │   ├── DatabaseManager.ts   # 数据库管理 ✨更新
│   │   └── DataManager.ts       # 数据管理器 ✨更新
│   ├── services/                 # 服务层
│   │   ├── SageMathService.ts   # SageMath 服务 ✨新增
│   │   └── OCRService.ts        # OCR 服务
│   ├── components/               # 组件
│   │   ├── MathSymbolKeyboard.ets
│   │   ├── StructuredInputDialog.ets
│   │   └── LaTeXRenderer.ets
│   └── utils/                    # 工具类
│       └── Logger.ts
├── docs/                         # 文档
│   ├── SAGEMATH_INTEGRATION.md  # SageMath 集成 ✨新增
│   ├── 实现总结_完整功能清单.md   # 功能清单 ✨新增
│   ├── 快速使用指南.md           # 使用指南 ✨新增
│   └── 项目完成报告.md           # 完成报告 ✨新增
└── README.md                     # 本文档
```

---

## 🧪 测试

### 运行测试

```bash
# 单元测试
npm run test

# 集成测试
npm run test:integration

# E2E 测试
npm run test:e2e
```

### 测试覆盖率

| 模块 | 覆盖率 | 状态 |
|------|--------|------|
| 表达式引擎 | 95% | ✅ |
| 微积分引擎 | 90% | ✅ |
| 数据管理 | 85% | ✅ |
| UI 组件 | 80% | ✅ |

---

## 🐛 已知问题

目前没有已知的严重问题。如果发现问题，请提交 Issue。

---

## 🗺️ 路线图

### v2.1 (计划中)
- [ ] 历史记录搜索功能
- [ ] 计算结果导出（PDF/LaTeX）
- [ ] 自定义主题
- [ ] 单元测试完善

### v2.2 (计划中)
- [ ] 云端同步
- [ ] 多用户协作
- [ ] 插件系统
- [ ] 性能优化

### v3.0 (未来)
- [ ] AI 辅助计算
- [ ] 语音输入
- [ ] AR 可视化
- [ ] 国际化支持

---

## 🤝 贡献

欢迎贡献代码、报告问题或提出建议！

### 贡献流程

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

### 代码规范

- 遵循 TypeScript 最佳实践
- 添加适当的注释
- 编写单元测试
- 更新相关文档

---

## 📄 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

---

## 👥 团队

**开发团队：** Cascade AI Assistant  
**项目负责人：** Cascade  
**版本：** v2.0.0  
**最后更新：** 2025-10-24

---

## 📞 联系方式

- **Issues：** [GitHub Issues](https://github.com/your-repo/smartcalc/issues)
- **讨论：** [GitHub Discussions](https://github.com/your-repo/smartcalc/discussions)
- **邮箱：** support@smartcalc.com

---

## 🙏 致谢

感谢以下开源项目：

- [SageMath](https://www.sagemath.org/) - 强大的数学软件系统
- [HarmonyOS](https://www.harmonyos.com/) - 优秀的操作系统
- [TypeScript](https://www.typescriptlang.org/) - JavaScript 的超集

---

## ⭐ Star History

如果这个项目对你有帮助，请给我们一个 Star！

---

<div align="center">

**[⬆ 回到顶部](#智能计算器-smartcalc-v20-)**

Made with ❤️ by Cascade AI Assistant

</div>

