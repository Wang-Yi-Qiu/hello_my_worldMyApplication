# 数据模型设计：HarmonyOS 智能计算器增强版

**项目：** HarmonyOS 智能计算器增强版
**版本：** 1.0.0
**日期：** 2025-01-27

---

## 数据模型概述

本文档定义了HarmonyOS智能计算器增强版应用中的所有数据实体、关系和约束。数据模型设计遵循HarmonyOS开发规范，使用ArkTS类型系统确保类型安全。

---

## 1. 核心实体

### 1.1 计算记录（HistoryRecord）

**用途：** 存储用户的计算历史记录

```typescript
interface HistoryRecord {
  id: string;                    // 唯一标识符
  expression: string;            // 数学表达式
  result: number;               // 计算结果
  timestamp: number;            // 计算时间戳（毫秒）
  emotion: EmotionFeedback;     // 情绪化反馈
  fortune: string;              // 幸运提示
  isEasterEgg: boolean;         // 是否触发彩蛋
}
```

**约束：**
- `id` 必须唯一，使用UUID生成
- `expression` 不能为空，最大长度1000字符
- `result` 必须是有效数字
- `timestamp` 使用Date.now()生成
- 最多保存10条记录，超出时删除最旧的记录

**状态转换：**
- 创建 → 活跃 → 归档（超过10条时）

---

### 1.2 转换配置（ConvertConfig）

**用途：** 定义单位转换的配置信息

```typescript
interface ConvertConfig {
  id: string;                   // 配置ID
  fromUnit: string;             // 源单位
  toUnit: string;               // 目标单位
  rate: number;                 // 转换比率
  type: ConvertType;            // 转换类型
  category: string;             // 分类（货币、长度、重量等）
  isEnabled: boolean;           // 是否启用
}

enum ConvertType {
  CURRENCY = 'currency',        // 货币
  LENGTH = 'length',            // 长度
  WEIGHT = 'weight',            // 重量
  TIME = 'time',                // 时间
  TEMPERATURE = 'temperature'   // 温度
}
```

**约束：**
- `rate` 必须大于0
- `fromUnit` 和 `toUnit` 不能相同
- 同一类型下不能有重复的转换对

---

### 1.3 情绪反馈（EmotionFeedback）

**用途：** 定义情绪化反馈的配置

```typescript
interface EmotionFeedback {
  id: string;                   // 反馈ID
  condition: string;            // 触发条件（表达式）
  text: string;                 // 显示文本
  emoji: string;                // 表情符号
  imagePath?: string;           // 表情图片路径（可选）
  priority: number;             // 优先级（数字越小优先级越高）
  isEnabled: boolean;           // 是否启用
}

interface EmotionRule {
  condition: (result: number) => boolean;  // 条件函数
  feedback: EmotionFeedback;              // 反馈内容
}
```

**约束：**
- `condition` 必须是有效的JavaScript表达式
- `text` 最大长度200字符
- `priority` 范围1-100
- 同一结果只能匹配一个最高优先级的规则

---

### 1.4 彩蛋配置（EasterEggConfig）

**用途：** 定义彩蛋模式的触发条件和效果

```typescript
interface EasterEggConfig {
  id: string;                   // 彩蛋ID
  triggerValue: number;         // 触发数值
  triggerType: TriggerType;     // 触发类型
  message: string;              // 彩蛋消息
  animationType: AnimationType; // 动画类型
  soundPath?: string;           // 音效路径（可选）
  isEnabled: boolean;           // 是否启用
}

enum TriggerType {
  EXACT = 'exact',              // 精确匹配
  CONTAINS = 'contains',        // 包含匹配
  RANGE = 'range'               // 范围匹配
}

enum AnimationType {
  BOUNCE = 'bounce',            // 弹跳
  FADE = 'fade',                // 淡入淡出
  ROTATE = 'rotate',            // 旋转
  SCALE = 'scale',              // 缩放
  FIREWORKS = 'fireworks'       // 烟花效果
}
```

**约束：**
- `triggerValue` 必须是有效数字
- `message` 最大长度100字符
- 同一数值只能有一个彩蛋配置

---

## 2. 用户设置实体

### 2.1 应用设置（AppSettings）

**用途：** 存储用户的个性化设置

```typescript
interface AppSettings {
  theme: ThemeType;             // 主题设置
  language: string;             // 语言设置
  precision: number;            // 计算精度
  historyLimit: number;         // 历史记录限制
  enableEmotion: boolean;       // 是否启用情绪化反馈
  enableFortune: boolean;       // 是否启用幸运提示
  enableEasterEgg: boolean;     // 是否启用彩蛋模式
  enableAnimation: boolean;     // 是否启用动画
  defaultConvertType: ConvertType; // 默认转换类型
}

enum ThemeType {
  LIGHT = 'light',              // 浅色主题
  DARK = 'dark',                // 深色主题
  AUTO = 'auto'                 // 自动主题
}
```

**约束：**
- `precision` 范围1-10位小数
- `historyLimit` 范围1-50条记录
- `language` 必须是支持的语言代码

---

### 2.2 用户偏好（UserPreferences）

**用途：** 存储用户的使用偏好

```typescript
interface UserPreferences {
  favoriteConvertPairs: string[];  // 常用转换对
  recentExpressions: string[];     // 最近使用的表达式
  customEmotionRules: EmotionRule[]; // 自定义情绪规则
  widgetConfig: WidgetConfig;      // Widget配置
}

interface WidgetConfig {
  size: WidgetSize;             // Widget尺寸
  position: WidgetPosition;     // Widget位置
  showResult: boolean;          // 是否显示结果
  showAnimation: boolean;       // 是否显示动画
}

enum WidgetSize {
  SMALL = 'small',              // 小尺寸
  MEDIUM = 'medium',            // 中尺寸
  LARGE = 'large'               // 大尺寸
}

interface WidgetPosition {
  x: number;                    // X坐标
  y: number;                    // Y坐标
}
```

---

## 3. 数据关系

### 3.1 实体关系图

```
HistoryRecord
├── EmotionFeedback (1:1)
├── ConvertConfig (0:1) - 如果是转换计算
└── EasterEggConfig (0:1) - 如果触发彩蛋

AppSettings
├── UserPreferences (1:1)
└── ConvertConfig[] (1:N) - 启用的转换配置

EmotionFeedback
└── EmotionRule[] (1:N) - 包含的规则

EasterEggConfig
└── AnimationConfig (1:1) - 动画配置
```

### 3.2 数据流

```
用户输入 → 表达式解析 → 计算执行 → 结果生成
    ↓
历史记录创建 → 情绪反馈匹配 → 幸运提示生成 → 彩蛋检查
    ↓
数据持久化 → UI更新 → 动画播放
```

---

## 4. 数据验证规则

### 4.1 输入验证

```typescript
// 表达式验证
function validateExpression(expr: string): boolean {
  return expr.length > 0 && 
         expr.length <= 1000 && 
         /^[0-9+\-*/().\s]+$/.test(expr);
}

// 数值验证
function validateNumber(value: number): boolean {
  return !isNaN(value) && 
         isFinite(value) && 
         value >= Number.MIN_SAFE_INTEGER && 
         value <= Number.MAX_SAFE_INTEGER;
}

// 转换比率验证
function validateRate(rate: number): boolean {
  return rate > 0 && 
         rate < Number.MAX_SAFE_INTEGER;
}
```

### 4.2 业务规则验证

```typescript
// 历史记录限制
function validateHistoryLimit(records: HistoryRecord[]): boolean {
  return records.length <= 10;
}

// 情绪规则优先级
function validateEmotionPriority(rules: EmotionRule[]): boolean {
  const priorities = rules.map(r => r.feedback.priority);
  return new Set(priorities).size === priorities.length;
}
```

---

## 5. 数据持久化策略

### 5.1 存储结构

```typescript
interface StorageStructure {
  'app_settings': AppSettings;
  'user_preferences': UserPreferences;
  'history_records': HistoryRecord[];
  'convert_configs': ConvertConfig[];
  'emotion_feedbacks': EmotionFeedback[];
  'easter_egg_configs': EasterEggConfig[];
}
```

### 5.2 数据迁移

```typescript
interface DataMigration {
  version: string;              // 数据版本
  fromVersion: string;          // 源版本
  toVersion: string;            // 目标版本
  migrationScript: string;      // 迁移脚本
  rollbackScript: string;       // 回滚脚本
}
```

---

## 6. 性能优化

### 6.1 数据缓存

- 历史记录：内存缓存最近5条记录
- 转换配置：启动时加载到内存
- 情绪规则：编译为函数缓存
- 彩蛋配置：按触发值建立索引

### 6.2 数据清理

- 历史记录：超过限制时自动清理
- 临时数据：应用退出时清理
- 缓存数据：定期清理过期数据
- 日志数据：按大小和时间清理

---

## 7. 安全考虑

### 7.1 数据加密

- 敏感设置使用系统加密API
- 历史记录可选择加密存储
- 用户偏好数据本地存储

### 7.2 数据验证

- 所有输入数据必须验证
- 防止SQL注入和XSS攻击
- 数值范围检查防止溢出

---

## 8. 扩展性设计

### 8.1 插件化支持

```typescript
interface Plugin {
  id: string;
  name: string;
  version: string;
  dataModel: any;
  validationRules: ValidationRule[];
}
```

### 8.2 国际化支持

```typescript
interface LocalizedString {
  [locale: string]: string;
}

interface LocalizedData {
  emotionTexts: LocalizedString;
  fortuneTexts: LocalizedString;
  easterEggMessages: LocalizedString;
}
```

---

*本数据模型设计遵循HarmonyOS开发规范，确保类型安全和性能优化。*
