# 快速开始指南：HarmonyOS 智能计算器增强版

**项目：** HarmonyOS 智能计算器增强版
**版本：** 1.0.0
**日期：** 2025-01-27

---

## 项目概述

HarmonyOS 智能计算器增强版是一个基于HarmonyOS ArkUI框架的创新计算器应用，在传统计算功能的基础上，加入了多个具有互动性和趣味性的扩展模块，旨在为用户提供"既能算，又能玩"的体验。

---

## 核心功能

### 🧮 基础计算功能
- 支持加、减、乘、除四则运算
- 复杂数学表达式解析和计算
- 高精度计算结果
- 友好的错误提示

### 🎯 极速转换卡片
- 桌面服务卡片，无需打开应用
- 支持货币、长度、时间等单位转换
- 实时转换，输入即显示结果
- 支持多种常用单位

### 😊 情绪化计算器
- 根据计算结果提供表情反馈
- 趣味语句增加使用乐趣
- 支持自定义情绪规则
- 表情图片和emoji支持

### 🍀 幸运运势计算器
- 每次计算后生成幸运提示
- 包含财运、爱情、学习等主题
- 基于计算结果的随机算法
- 支持自定义幸运提示

### 📜 历史记录与回溯
- 自动保存最近10条计算记录
- 点击历史记录可重新填入
- 支持修改历史表达式
- 数据持久化存储

### 🎉 隐藏彩蛋模式
- 特定数字触发特殊效果
- 动画和音效支持
- 自定义彩蛋配置
- 增加探索乐趣

---

## 技术架构

### 技术栈
- **前端框架：** ArkUI Declarative UI
- **开发工具：** DevEco Studio 5.0+
- **数据存储：** @ohos.data.preferences
- **卡片类型：** Form Widget
- **编程语言：** ArkTS / TypeScript

### 项目结构
```
entry/src/main/ets/
├── pages/                    # 页面组件
│   ├── CalculatorPage.ets    # 计算器主页面
│   ├── HistoryPage.ets       # 历史记录页面
│   ├── SettingsPage.ets      # 设置页面
│   └── MainPage.ets          # 主页面
├── widgets/                  # Widget组件
│   └── QuickConvertWidget.ets # 极速转换卡片
├── modules/                  # 业务逻辑模块
│   ├── ExpressionEngine.ts   # 表达式解析引擎
│   ├── DataManager.ts        # 数据管理器
│   └── DatabaseManager.ts    # 数据库管理器
├── utils/                    # 工具类
│   ├── AppTheme.ts           # 主题管理
│   ├── Constants.ts          # 常量定义
│   └── ToastHelper.ts        # 提示工具
└── models/                   # 数据模型
    └── HistoryRecord.ts      # 历史记录模型
```

---

## 开发环境设置

### 1. 系统要求
- HarmonyOS 3.0+ 或 OpenHarmony 3.2+
- DevEco Studio 5.0+
- Node.js 16.0+
- TypeScript 4.9+

### 2. 环境配置
```bash
# 1. 安装 DevEco Studio
# 下载并安装 DevEco Studio 5.0+

# 2. 配置 HarmonyOS SDK
# 在 DevEco Studio 中配置 HarmonyOS SDK

# 3. 创建项目
# 使用 DevEco Studio 创建新的 HarmonyOS 项目

# 4. 安装依赖
npm install
```

### 3. 项目配置
```json5
// oh-package.json5
{
  "name": "hello_my_worldMyApplication",
  "version": "1.0.0",
  "description": "HarmonyOS 智能计算器增强版",
  "main": "index.ets",
  "author": "",
  "license": "",
  "dependencies": {
    "@ohos/hypium": "1.0.0"
  },
  "devDependencies": {
    "@ohos/hvigor-ohos-plugin": "5.0.0",
    "@ohos/hvigor": "5.0.0"
  }
}
```

---

## 快速开始

### 1. 克隆项目
```bash
git clone <repository-url>
cd hello_my_worldMyApplication
```

### 2. 打开项目
```bash
# 使用 DevEco Studio 打开项目
# File -> Open -> 选择项目目录
```

### 3. 运行项目
```bash
# 在 DevEco Studio 中点击运行按钮
# 或使用命令行
hvigorw assembleHap
```

### 4. 添加桌面卡片
1. 长按桌面空白处
2. 选择"服务卡片"
3. 找到"智能计算器"
4. 选择"极速转换"卡片
5. 添加到桌面

---

## 核心模块使用

### 1. 基础计算
```typescript
import { ExpressionEngine } from '../modules/ExpressionEngine';

const calculator = new ExpressionEngine();

// 计算表达式
const result = await calculator.calculate("2+3*4");
console.log(result); // 14

// 验证表达式
const isValid = calculator.validate("2+3*4");
console.log(isValid); // true
```

### 2. 历史记录管理
```typescript
import { DataManager } from '../modules/DataManager';

const dataManager = new DataManager();

// 保存计算记录
await dataManager.saveHistoryRecord({
  expression: "2+3*4",
  result: 14,
  timestamp: Date.now()
});

// 获取历史记录
const history = await dataManager.getHistoryRecords(10);
console.log(history);
```

### 3. 情绪化反馈
```typescript
import { EmotionCalculator } from '../modules/EmotionCalculator';

const emotionCalc = new EmotionCalculator();

// 获取情绪反馈
const feedback = emotionCalc.getEmotionFeedback(14);
console.log(feedback.text); // "稳如老狗 😏"
console.log(feedback.emoji); // "😏"
```

### 4. 单位转换
```typescript
import { ConvertService } from '../modules/ConvertService';

const convertService = new ConvertService();

// 货币转换
const result = await convertService.convert(100, "USD", "CNY");
console.log(result); // 724.00

// 长度转换
const lengthResult = await convertService.convert(1, "m", "cm");
console.log(lengthResult); // 100
```

---

## Widget 开发

### 1. 创建 Widget 组件
```typescript
// widgets/QuickConvertWidget.ets
@Entry
@Component
struct QuickConvertWidget {
  @State inputValue: string = '';
  @State fromUnit: string = 'USD';
  @State toUnit: string = 'CNY';
  @State result: string = '0.00';

  build() {
    Column() {
      TextInput({ placeholder: '输入金额', text: this.inputValue })
        .onChange((value) => {
          this.inputValue = value;
          this.convert();
        })
      
      Row() {
        Select({ selected: this.fromUnit, options: ['USD', 'CNY', 'JPY'] })
          .onSelect((option) => {
            this.fromUnit = option.value;
            this.convert();
          })
        
        Text('→')
        
        Select({ selected: this.toUnit, options: ['CNY', 'USD', 'JPY'] })
          .onSelect((option) => {
            this.toUnit = option.value;
            this.convert();
          })
      }
      
      Text(`结果：${this.result}`)
        .fontSize(20)
        .fontColor('#007DFF')
    }
    .padding(20)
  }

  private convert() {
    // 转换逻辑
    const value = parseFloat(this.inputValue);
    if (!isNaN(value)) {
      const rate = this.getRate(this.fromUnit, this.toUnit);
      this.result = (value * rate).toFixed(2);
    }
  }
}
```

### 2. 注册 Widget
```json5
// module.json5
{
  "forms": [
    {
      "name": "QuickConvertWidget",
      "type": "JS",
      "isDefault": true,
      "colorMode": "auto",
      "scheduledUpdateTime": "00:00",
      "updateDuration": 86400
    }
  ]
}
```

---

## 配置说明

### 1. 应用配置
```json5
// AppScope/app.json5
{
  "app": {
    "bundleName": "com.example.calculator",
    "vendor": "example",
    "versionCode": 1000000,
    "versionName": "1.0.0",
    "icon": "$media:app_icon",
    "label": "$string:app_name"
  }
}
```

### 2. 模块配置
```json5
// entry/src/main/module.json5
{
  "module": {
    "name": "entry",
    "type": "entry",
    "description": "$string:module_desc",
    "mainElement": "EntryAbility",
    "deviceTypes": ["phone", "tablet"],
    "deliveryWithInstall": true,
    "installationFree": false,
    "pages": "$profile:main_pages",
    "abilities": [
      {
        "name": "EntryAbility",
        "srcEntry": "./ets/entryability/EntryAbility.ets",
        "description": "$string:EntryAbility_desc",
        "icon": "$media:icon",
        "label": "$string:EntryAbility_label",
        "startWindowIcon": "$media:startIcon",
        "startWindowBackground": "$color:start_window_background",
        "exported": true,
        "skills": [
          {
            "entities": ["entity.system.home"],
            "actions": ["action.system.home"]
          }
        ]
      }
    ]
  }
}
```

---

## 测试指南

### 1. 单元测试
```typescript
// test/ExpressionEngine.test.ets
import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { ExpressionEngine } from '../src/main/ets/modules/ExpressionEngine';

export default function abilityTest() {
  describe('ExpressionEngine', function () {
    let calculator: ExpressionEngine;

    beforeEach(function () {
      calculator = new ExpressionEngine();
    });

    it('should calculate basic addition', 0, function () {
      const result = calculator.calculate('2+3');
      expect(result).assertEqual(5);
    });

    it('should calculate complex expression', 0, function () {
      const result = calculator.calculate('2+3*4');
      expect(result).assertEqual(14);
    });
  });
}
```

### 2. 运行测试
```bash
# 运行所有测试
hvigorw test

# 运行特定测试
hvigorw test --testName="ExpressionEngine"
```

---

## 部署说明

### 1. 构建应用
```bash
# 构建 HAP 包
hvigorw assembleHap

# 构建 HAR 包
hvigorw assembleHar
```

### 2. 安装应用
```bash
# 使用 hdc 安装
hdc install entry-default-signed.hap

# 或使用 DevEco Studio 直接安装
```

### 3. 添加桌面卡片
1. 长按桌面空白处
2. 选择"服务卡片"
3. 找到"智能计算器"
4. 选择"极速转换"卡片
5. 添加到桌面

---

## 常见问题

### Q: 如何添加新的转换单位？
A: 在 `ConvertService` 中添加新的转换配置，更新 `ConvertConfig` 接口。

### Q: 如何自定义情绪反馈？
A: 在 `EmotionCalculator` 中添加新的情绪规则，或通过设置页面配置。

### Q: Widget 无法显示怎么办？
A: 检查 `module.json5` 中的 Widget 配置，确保正确注册了 Widget 组件。

### Q: 如何修改历史记录数量限制？
A: 在 `AppSettings` 中修改 `historyLimit` 属性，或在设置页面中调整。

---

## 技术支持

- **文档：** 查看项目文档目录
- **问题反馈：** 提交 Issue 到项目仓库
- **功能建议：** 通过 Pull Request 提交
- **技术交流：** 加入开发者社区

---

*本快速开始指南帮助您快速上手 HarmonyOS 智能计算器增强版项目开发。*
