# API 合约设计：HarmonyOS 智能计算器增强版

**项目：** HarmonyOS 智能计算器增强版
**版本：** 1.0.0
**日期：** 2025-01-27

---

## API 合约概述

本文档定义了HarmonyOS智能计算器增强版应用中的所有API接口，包括内部模块接口、Widget接口和外部服务接口。所有接口都遵循HarmonyOS开发规范和RESTful设计原则。

---

## 1. 核心计算服务接口

### 1.1 表达式计算服务

```typescript
interface ExpressionCalculator {
  /**
   * 计算数学表达式
   * @param expression 数学表达式字符串
   * @returns 计算结果
   */
  calculate(expression: string): Promise<CalculationResult>;
  
  /**
   * 验证表达式语法
   * @param expression 数学表达式字符串
   * @returns 验证结果
   */
  validate(expression: string): ValidationResult;
  
  /**
   * 获取计算历史
   * @param limit 记录数量限制
   * @returns 历史记录列表
   */
  getHistory(limit?: number): Promise<HistoryRecord[]>;
}

interface CalculationResult {
  success: boolean;
  result?: number;
  error?: string;
  timestamp: number;
  expression: string;
}

interface ValidationResult {
  isValid: boolean;
  error?: string;
  suggestions?: string[];
}
```

### 1.2 情绪化反馈服务

```typescript
interface EmotionService {
  /**
   * 根据计算结果获取情绪反馈
   * @param result 计算结果
   * @param context 计算上下文
   * @returns 情绪反馈
   */
  getEmotionFeedback(result: number, context?: CalculationContext): EmotionFeedback;
  
  /**
   * 获取所有情绪规则
   * @returns 情绪规则列表
   */
  getEmotionRules(): EmotionRule[];
  
  /**
   * 添加自定义情绪规则
   * @param rule 情绪规则
   * @returns 操作结果
   */
  addEmotionRule(rule: EmotionRule): Promise<OperationResult>;
}

interface CalculationContext {
  expression: string;
  complexity: number;
  isFirstTime: boolean;
  previousResults: number[];
}
```

### 1.3 幸运运势服务

```typescript
interface FortuneService {
  /**
   * 生成幸运提示
   * @param result 计算结果
   * @param seed 随机种子（可选）
   * @returns 幸运提示
   */
  generateFortune(result: number, seed?: number): string;
  
  /**
   * 获取幸运提示列表
   * @returns 幸运提示列表
   */
  getFortuneList(): string[];
  
  /**
   * 添加自定义幸运提示
   * @param fortune 幸运提示文本
   * @returns 操作结果
   */
  addFortune(fortune: string): Promise<OperationResult>;
}
```

---

## 2. 数据管理接口

### 2.1 历史记录管理

```typescript
interface HistoryManager {
  /**
   * 保存计算记录
   * @param record 计算记录
   * @returns 操作结果
   */
  saveRecord(record: HistoryRecord): Promise<OperationResult>;
  
  /**
   * 获取历史记录
   * @param limit 记录数量限制
   * @param offset 偏移量
   * @returns 历史记录列表
   */
  getRecords(limit?: number, offset?: number): Promise<HistoryRecord[]>;
  
  /**
   * 删除历史记录
   * @param id 记录ID
   * @returns 操作结果
   */
  deleteRecord(id: string): Promise<OperationResult>;
  
  /**
   * 清空历史记录
   * @returns 操作结果
   */
  clearHistory(): Promise<OperationResult>;
  
  /**
   * 更新历史记录
   * @param id 记录ID
   * @param updates 更新内容
   * @returns 操作结果
   */
  updateRecord(id: string, updates: Partial<HistoryRecord>): Promise<OperationResult>;
}
```

### 2.2 设置管理

```typescript
interface SettingsManager {
  /**
   * 获取应用设置
   * @returns 应用设置
   */
  getAppSettings(): Promise<AppSettings>;
  
  /**
   * 更新应用设置
   * @param settings 设置内容
   * @returns 操作结果
   */
  updateAppSettings(settings: Partial<AppSettings>): Promise<OperationResult>;
  
  /**
   * 获取用户偏好
   * @returns 用户偏好
   */
  getUserPreferences(): Promise<UserPreferences>;
  
  /**
   * 更新用户偏好
   * @param preferences 偏好内容
   * @returns 操作结果
   */
  updateUserPreferences(preferences: Partial<UserPreferences>): Promise<OperationResult>;
  
  /**
   * 重置为默认设置
   * @returns 操作结果
   */
  resetToDefaults(): Promise<OperationResult>;
}
```

---

## 3. 转换服务接口

### 3.1 单位转换服务

```typescript
interface ConvertService {
  /**
   * 执行单位转换
   * @param value 转换数值
   * @param fromUnit 源单位
   * @param toUnit 目标单位
   * @returns 转换结果
   */
  convert(value: number, fromUnit: string, toUnit: string): Promise<ConvertResult>;
  
  /**
   * 获取支持的转换类型
   * @returns 转换类型列表
   */
  getConvertTypes(): ConvertType[];
  
  /**
   * 获取指定类型的单位列表
   * @param type 转换类型
   * @returns 单位列表
   */
  getUnits(type: ConvertType): string[];
  
  /**
   * 获取转换配置
   * @returns 转换配置列表
   */
  getConvertConfigs(): ConvertConfig[];
  
  /**
   * 更新转换配置
   * @param config 转换配置
   * @returns 操作结果
   */
  updateConvertConfig(config: ConvertConfig): Promise<OperationResult>;
}

interface ConvertResult {
  success: boolean;
  result?: number;
  error?: string;
  fromUnit: string;
  toUnit: string;
  rate: number;
}
```

---

## 4. Widget 接口

### 4.1 极速转换卡片接口

```typescript
interface QuickConvertWidget {
  /**
   * 初始化Widget
   * @param context Widget上下文
   * @returns 初始化结果
   */
  initialize(context: WidgetContext): Promise<OperationResult>;
  
  /**
   * 更新Widget数据
   * @param data 更新数据
   * @returns 更新结果
   */
  updateData(data: WidgetData): Promise<OperationResult>;
  
  /**
   * 处理用户交互
   * @param action 交互动作
   * @param data 交互数据
   * @returns 处理结果
   */
  handleInteraction(action: WidgetAction, data: any): Promise<OperationResult>;
  
  /**
   * 销毁Widget
   * @returns 销毁结果
   */
  destroy(): Promise<OperationResult>;
}

interface WidgetContext {
  formId: string;
  bundleName: string;
  abilityName: string;
  dimensions: WidgetDimensions;
}

interface WidgetData {
  inputValue: string;
  fromUnit: string;
  toUnit: string;
  result: string;
  isError: boolean;
  errorMessage?: string;
}

enum WidgetAction {
  INPUT_CHANGE = 'input_change',
  UNIT_CHANGE = 'unit_change',
  CONVERT = 'convert',
  CLEAR = 'clear'
}
```

---

## 5. 彩蛋服务接口

### 5.1 彩蛋检测服务

```typescript
interface EasterEggService {
  /**
   * 检查是否触发彩蛋
   * @param result 计算结果
   * @param context 计算上下文
   * @returns 彩蛋检测结果
   */
  checkEasterEgg(result: number, context: CalculationContext): EasterEggResult;
  
  /**
   * 执行彩蛋效果
   * @param config 彩蛋配置
   * @returns 执行结果
   */
  executeEasterEgg(config: EasterEggConfig): Promise<OperationResult>;
  
  /**
   * 获取彩蛋配置
   * @returns 彩蛋配置列表
   */
  getEasterEggConfigs(): EasterEggConfig[];
  
  /**
   * 添加自定义彩蛋
   * @param config 彩蛋配置
   * @returns 操作结果
   */
  addEasterEgg(config: EasterEggConfig): Promise<OperationResult>;
}

interface EasterEggResult {
  triggered: boolean;
  config?: EasterEggConfig;
  message?: string;
  animationType?: AnimationType;
}
```

---

## 6. 动画服务接口

### 6.1 动画控制服务

```typescript
interface AnimationService {
  /**
   * 播放结果跳动动画
   * @param target 目标组件
   * @param duration 动画时长
   * @returns 动画Promise
   */
  playBounceAnimation(target: Component, duration?: number): Promise<void>;
  
  /**
   * 播放表情淡入动画
   * @param target 目标组件
   * @param duration 动画时长
   * @returns 动画Promise
   */
  playFadeInAnimation(target: Component, duration?: number): Promise<void>;
  
  /**
   * 播放彩蛋动画
   * @param type 动画类型
   * @param target 目标组件
   * @returns 动画Promise
   */
  playEasterEggAnimation(type: AnimationType, target: Component): Promise<void>;
  
  /**
   * 停止所有动画
   * @returns 操作结果
   */
  stopAllAnimations(): Promise<OperationResult>;
}
```

---

## 7. 错误处理接口

### 7.1 错误管理服务

```typescript
interface ErrorManager {
  /**
   * 记录错误
   * @param error 错误信息
   * @param context 错误上下文
   * @returns 操作结果
   */
  logError(error: Error, context?: ErrorContext): Promise<OperationResult>;
  
  /**
   * 获取错误统计
   * @param timeRange 时间范围
   * @returns 错误统计
   */
  getErrorStats(timeRange?: TimeRange): Promise<ErrorStats>;
  
  /**
   * 清除错误日志
   * @param olderThan 清除时间阈值
   * @returns 操作结果
   */
  clearErrorLogs(olderThan?: number): Promise<OperationResult>;
}

interface ErrorContext {
  component: string;
  action: string;
  userId?: string;
  timestamp: number;
}

interface ErrorStats {
  totalErrors: number;
  errorTypes: { [type: string]: number };
  recentErrors: ErrorLog[];
}

interface ErrorLog {
  id: string;
  message: string;
  stack?: string;
  context: ErrorContext;
  timestamp: number;
}
```

---

## 8. 性能监控接口

### 8.1 性能监控服务

```typescript
interface PerformanceMonitor {
  /**
   * 开始性能计时
   * @param name 计时名称
   * @returns 计时器ID
   */
  startTimer(name: string): string;
  
  /**
   * 结束性能计时
   * @param timerId 计时器ID
   * @returns 计时结果
   */
  endTimer(timerId: string): PerformanceMetric;
  
  /**
   * 记录性能指标
   * @param metric 性能指标
   * @returns 操作结果
   */
  recordMetric(metric: PerformanceMetric): Promise<OperationResult>;
  
  /**
   * 获取性能报告
   * @param timeRange 时间范围
   * @returns 性能报告
   */
  getPerformanceReport(timeRange?: TimeRange): Promise<PerformanceReport>;
}

interface PerformanceMetric {
  name: string;
  duration: number;
  timestamp: number;
  context?: any;
}

interface PerformanceReport {
  averageResponseTime: number;
  maxResponseTime: number;
  minResponseTime: number;
  totalOperations: number;
  metrics: PerformanceMetric[];
}
```

---

## 9. 通用接口定义

### 9.1 操作结果

```typescript
interface OperationResult {
  success: boolean;
  message?: string;
  data?: any;
  error?: Error;
  timestamp: number;
}
```

### 9.2 分页参数

```typescript
interface PaginationParams {
  page: number;
  pageSize: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
}

interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
  hasMore: boolean;
}
```

### 9.3 时间范围

```typescript
interface TimeRange {
  start: number;
  end: number;
}
```

---

## 10. API 使用示例

### 10.1 基础计算流程

```typescript
// 1. 验证表达式
const validation = await calculator.validate("2+3*4");
if (!validation.isValid) {
  throw new Error(validation.error);
}

// 2. 执行计算
const result = await calculator.calculate("2+3*4");
if (!result.success) {
  throw new Error(result.error);
}

// 3. 获取情绪反馈
const emotion = await emotionService.getEmotionFeedback(result.result!);

// 4. 生成幸运提示
const fortune = await fortuneService.generateFortune(result.result!);

// 5. 检查彩蛋
const easterEgg = await easterEggService.checkEasterEgg(result.result!);

// 6. 保存记录
const record: HistoryRecord = {
  id: generateId(),
  expression: "2+3*4",
  result: result.result!,
  timestamp: Date.now(),
  emotion,
  fortune,
  isEasterEgg: easterEgg.triggered
};
await historyManager.saveRecord(record);
```

### 10.2 Widget 使用流程

```typescript
// 1. 初始化Widget
await widget.initialize({
  formId: "form_001",
  bundleName: "com.example.calculator",
  abilityName: "MainAbility",
  dimensions: { width: 200, height: 100 }
});

// 2. 处理用户输入
await widget.handleInteraction(WidgetAction.INPUT_CHANGE, {
  inputValue: "100",
  fromUnit: "USD",
  toUnit: "CNY"
});

// 3. 执行转换
const convertResult = await convertService.convert(100, "USD", "CNY");

// 4. 更新Widget显示
await widget.updateData({
  inputValue: "100",
  fromUnit: "USD",
  toUnit: "CNY",
  result: convertResult.result?.toString() || "0",
  isError: !convertResult.success,
  errorMessage: convertResult.error
});
```

---

*本API合约设计遵循HarmonyOS开发规范，确保接口的一致性和可维护性。*
