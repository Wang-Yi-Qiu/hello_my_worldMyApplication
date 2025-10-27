# 🌟 HarmonyOS 智能计算器增强版开发文档

## 📘 一、项目概述
本项目是基于 **HarmonyOS（鸿蒙系统） ArkUI 框架** 与 **DevEco Studio** 开发的一款创新型计算器应用。  
在传统计算功能的基础上，加入了多个具有互动性和趣味性的扩展模块，旨在为用户提供“既能算，又能玩”的体验。

---

### 📦 数学引擎实现说明

为保证科学计算的精度与函数完备性，项目实现了双重数学计算引擎。

#### 🚀 WebView + mathjs 引擎（主要）
- **实现方式**：通过 WebView 调用 mathjs 库进行高精度数学计算
- **支持功能**：
  - 基础运算：四则运算、幂运算、取模
  - 三角函数：sin, cos, tan, asin, acos, atan 及其双曲函数
  - 对数指数：log, ln, log2, log10, exp, pow
  - 根式：sqrt（平方根）、cbrt（立方根）
  - 高级数学：微积分、微分、积分
  - 矩阵运算：矩阵加法、乘法、求逆、转置
  - 复数运算：复数四则运算、共轭、模长
  - 统计函数：mean、std、median、variance
  - 方程求解：一元一次、二次方程
- **精度控制**：保留最多15位有效数字，智能科学计数法格式
- **网络依赖**：需要网络权限加载 mathjs CDN
- **回退机制**：网络不可用时自动回退到内置 AST 引擎
- **特色功能**：
  - 支持复数结果显示
  - 矩阵运算结果格式化
  - 方程求解接口
  - 异常值处理（NaN、Infinity）

#### 🔧 内置 AST 引擎（备用）
- **实现方式**：`ExpressionEngine` 使用 AST（抽象语法树）解析和计算数学表达式
- **支持功能**：
  - 四则运算：+、-、*、/（支持括号优先级）
  - 高级运算：幂运算（^，右结合）、取模（%）
  - 三角函数：sin, cos, tan, asin, acos, atan（支持角度/弧度转换）
  - 双曲函数：sinh, cosh, tanh, asinh, acosh, atanh
  - 对数指数：log（常用对数）、ln（自然对数）、log2、log10、exp
  - 根式运算：sqrt、cbrt
  - 数学常数：π（pi）、e（自然常数）
  - 排列组合：P(n,r)、C(n,r)
  - 阶乘：n!（支持整数阶乘）
  - 取整函数：ceil、floor、round、trunc、abs、sign
  - 统计函数：min、max
- **精度控制**：通过 `setPrecision()` 方法动态调整计算精度
- **安全计算**：内置输入验证和错误处理，防止恶意表达式执行
- **兼容性**：完全基于 HarmonyOS ArkTS 原生实现，无需外部依赖
- **运算符优先级**：正确处理乘除优先于加减，幂运算右结合

示例：
```ts
const engine = new ExpressionEngine(10)
await engine.initialize(context) // 初始化 WebView
engine.evaluate('sin(30) + sqrt(2)^2') // 优先使用 mathjs
engine.evaluate('5! + C(10,3)') // 回退到内置引擎
```

## 🧩 二、功能结构概览

| 模块名称 | 功能简介 | 技术说明 | 难度 |
|-----------|------------|------------|--------|
| **极速转换卡片（核心）** | 在桌面或应用中快速实现单位/货币换算 | 通过 ArkUI 构建独立 Widget，实现实时输入输出 | ⭐ |
| **情绪化计算器** | 根据计算结果或输入难度，输出表情和趣味语句 | 逻辑条件判断 + 随机反应文案 | ⭐ |
| **幸运运势计算器** | 每次计算后生成一个“幸运提示” | 哈希/随机算法 + 文案数组 | ⭐ |
| **历史记录与回溯编辑** | 保存最近 10 条计算记录，可回溯修改 | 本地缓存 + 列表展示 | ⭐⭐ |
| **隐藏彩蛋模式** | 特定输入触发动画或弹窗 | 特殊输入监听 + 触发机制 | ⭐⭐ |

---

## ⚙️ 三、技术架构设计

### 🧱 核心技术栈
- **语言**：ArkTS / TypeScript
- **框架**：ArkUI Declarative UI
- **状态管理**：`@State`、`@Prop`
- **数据存储**：`Preferences`（持久化）
- **卡片类型**：Form Widget（独立原子服务）
- **开发工具**：DevEco Studio 5.0+

---

## 🧠 四、核心模块详细说明

---

### 🧮 模块一：极速转换卡片（QuickConvert Widget）

#### 💡 功能说明
“极速转换卡片”是整个项目的核心创新模块。  
用户可在主界面或桌面服务卡片中快速输入数字并选择单位（如货币、长度、时间等），即时得到换算结果。  
无需跨设备通信，也不依赖分布式软总线。

#### 🔧 实现原理
1. 采用 ArkUI 的 `TextInput`、`Select`、`Text` 组件实现输入与输出；
2. 使用 `@State` 实现输入与结果绑定；
3. 通过本地函数或 JSON 文件读取换算系数；
4. 输入或下拉选择变化时触发计算；
5. 在 `module.json5` 中注册卡片。

#### 🧱 页面布局示例（QuickConvertWidget.ets）
```ts
import { Column, Row, Text, TextInput, Select } from '@ohos/arkui';

@Entry
@Component
struct QuickConvertWidget {
  @State inputValue: string = ''
  @State fromUnit: string = 'USD'
  @State toUnit: string = 'CNY'
  @State resultValue: string = '0.00'

  private rates: Record<string, Record<string, number>> = {
    'USD': { 'CNY': 7.24, 'JPY': 150.3 },
    'CNY': { 'USD': 0.138, 'JPY': 20.77 },
    'JPY': { 'CNY': 0.048, 'USD': 0.0067 }
  }

  convert() {
    const value = parseFloat(this.inputValue)
    if (isNaN(value)) {
      this.resultValue = '请输入有效数字'
      return
    }
    const rate = this.rates[this.fromUnit]?.[this.toUnit] || 1
    this.resultValue = (value * rate).toFixed(2)
  }

  build() {
    Column({ space: 12 }) {
      Row() {
        TextInput({ placeholder: '输入金额', text: this.inputValue })
          .onChange((val) => { this.inputValue = val; this.convert() })
      }.width('100%')

      Row({ space: 10 }) {
        Select({
          selected: this.fromUnit,
          options: ['USD', 'CNY', 'JPY'],
          onSelect: (opt) => { this.fromUnit = opt.value; this.convert() }
        })
        Text('→')
        Select({
          selected: this.toUnit,
          options: ['CNY', 'USD', 'JPY'],
          onSelect: (opt) => { this.toUnit = opt.value; this.convert() }
        })
      }

      Text(`结果：${this.resultValue}`)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#007DFF')
    }
    .width('100%')
    .padding(20)
  }
}
📦 module.json5 配置示例
json
复制代码
{
  "forms": [
    {
      "name": "QuickConvertWidget",
      "type": "JS",
      "isDefault": true,
      "colorMode": "auto",
      "scheduledUpdateTime": "00:00",
      "updateDuration": "86400"
    }
  ]
}
🎭 模块二：情绪化计算器（Emotion Calculator）
💡 功能说明
通过检测计算结果的大小、复杂度或频率，动态展示不同的“情绪反馈”与“表情贴图”。

🧱 实现示例
ts
复制代码
@State emotionText: string = ''
@State emotionImg: string = ''

emotionList = [
  { condition: (res) => res < 10, text: '这题太简单啦 😎', img: 'easy.png' },
  { condition: (res) => res > 1000, text: '哇，这么大！💥', img: 'shock.png' },
  { condition: (res) => res === 520, text: '爱意满满 💕', img: 'love.png' }
]

updateEmotion(result: number) {
  for (let e of this.emotionList) {
    if (e.condition(result)) {
      this.emotionText = e.text
      this.emotionImg = e.img
      return
    }
  }
  this.emotionText = '稳如老狗 😏'
  this.emotionImg = 'normal.png'
}
🍀 模块三：幸运运势计算器（Fortune Mode）
💡 功能说明
每次计算后随机生成一个“幸运提示”。

🧱 示例逻辑
ts
复制代码
@State fortuneText: string = ''

fortuneList = [
  '今天的你超幸运 ✨',
  '注意财务，别乱花钱 💰',
  '爱情要靠主动 ❤️',
  '学习好运连连 📚'
]

updateFortune(result: number) {
  const index = result % this.fortuneList.length
  this.fortuneText = this.fortuneList[index]
}
📜 模块四：历史记录与回溯编辑
💡 功能说明
保存最近 10 条计算记录，并允许用户点击回溯到输入框。

🧱 示例代码
ts
复制代码
import preferences from '@ohos.data.preferences';

@State historyList: string[] = []

saveToHistory(expression: string, result: number) {
  this.historyList.unshift(`${expression} = ${result}`)
  this.historyList = this.historyList.slice(0, 10)
  preferences.getPreferences('calc_history').then(pref => {
    pref.put('list', JSON.stringify(this.historyList))
    pref.flush()
  })
}

loadHistory() {
  preferences.getPreferences('calc_history').then(pref => {
    const data = pref.getSync('list', '[]')
    this.historyList = JSON.parse(data)
  })
}
🪄 模块五：隐藏彩蛋模式
💡 功能说明
当用户输入特定数字（如“1314”、“666”）时，触发动画、音效或彩蛋页面。

🧱 示例代码
ts
复制代码
if (result === 1314) {
  this.showPopup('一生一世 ❤️')
} else if (result === 666) {
  this.playAnimation('fireworks.json')
}
🎨 五、UI与交互设计建议
颜色风格：浅色为主，使用品牌蓝 (#007DFF) 强调结果区域；

字体建议：Harmony Sans；

动画：使用 animateTo 实现结果跳动或表情淡入；

图标：保存在 resources/images/ 下，命名统一；

交互流畅，兼顾动画性能。

📁 六、项目结构建议
bash
复制代码
/entry
 ├─ /src/main/ets/
 │   ├─ pages/
 │   │   ├─ CalculatorPage.ets
 │   │   ├─ HistoryPage.ets
 │   │   └─ SettingsPage.ets
 │   ├─ widgets/
 │   │   └─ QuickConvertWidget.ets
 │   ├─ common/
 │   │   └─ utils/
 │   │       └─ convert.ts
 │   └─ App.ets
 ├─ module.json5
 └─ resources/
     ├─ images/
     ├─ strings/
     └─ animations/
🧩 七、开发路线图
阶段	目标	说明
阶段一	构建核心计算逻辑与 UI	基础输入、输出、运算逻辑
阶段二	实现极速转换卡片	完整 Widget 独立运行
阶段三	添加情绪化与运势模块	增强交互体验
阶段四	集成历史与彩蛋功能	优化用户留存
阶段五	视觉完善与性能优化	动画与 UI 细节打磨

🏁 八、预期成果
一个能运行在鸿蒙系统上的完整智能计算器；

拥有极速转换服务卡片；

具备趣味化反馈、幸运提示与历史功能；

UI 风格统一，操作流畅；

可扩展性强，为后续语音识别或跨设备同步奠定基础。

---

## 🎨 九、UI优化更新记录

### 计算器按钮布局优化（最新）

**优化目标**：解决科学计算器模式下按键过多导致的溢出问题，确保所有按键能正常显示并保持美观。

**优化内容**：
1. **科学计算器按钮尺寸调整**
   - 按钮尺寸：从 70×50 调整为 60×45
   - 字体大小：从 16 调整为 14
   - 圆角：从 25 调整为 22
   - 行间距：从 SPACING_MINI (4px) 调整为 SPACING_SMALL (8px)

2. **普通按钮动态调整**
   - 在普通计算器模式：保持原有尺寸 70×70，字体 18
   - 在科学计算器模式：自动缩小至 60×60，字体 16
   - 圆角根据模式自动调整：35 → 30
   - 行间距根据模式动态调整：SPACING_MINI (4px) → SPACING_SMALL (8px)

3. **整体布局优化**
   - 科学计算器按钮区域使用紧凑布局
   - 保持按钮之间的视觉平衡
   - 确保所有按钮在同一屏内完整显示
   - 过渡动画效果流畅自然

**技术实现**：
- 使用 `@Builder` 装饰器创建动态按钮构建器
- 通过 `this.showScientificButtons` 状态控制按钮尺寸
- 使用三元运算符实现条件样式渲染
- 保持代码简洁性和可维护性

**用户体验提升**：
- ✅ 所有按键均可正常显示，无溢出
- ✅ 在普通模式下保持大按钮，操作便捷
- ✅ 在科学模式下自动适应，空间利用更合理
- ✅ 视觉效果统一美观，符合鸿蒙设计规范

