/**
 * 计算记录数据模型
 * 用于存储用户的计算历史记录
 */
export interface HistoryRecord {
  id: string;                    // 唯一标识符
  expression: string;            // 数学表达式
  result: number;               // 计算结果
  timestamp: number;            // 计算时间戳（毫秒）
  emotion: EmotionFeedback;     // 情绪化反馈
  fortune: string;              // 幸运提示
  isEasterEgg: boolean;         // 是否触发彩蛋
}

/**
 * 情绪反馈数据模型
 */
export interface EmotionFeedback {
  id: string;                   // 反馈ID
  condition: string;            // 触发条件（表达式）
  text: string;                 // 显示文本
  emoji: string;                // 表情符号
  imagePath?: string;           // 表情图片路径（可选）
  priority: number;             // 优先级（数字越小优先级越高）
  isEnabled: boolean;           // 是否启用
}

/**
 * 情绪规则数据模型
 */
export interface EmotionRule {
  condition: (result: number) => boolean;  // 条件函数
  feedback: EmotionFeedback;              // 反馈内容
}

/**
 * 转换配置数据模型
 */
export interface ConvertConfig {
  id: string;                   // 配置ID
  fromUnit: string;             // 源单位
  toUnit: string;               // 目标单位
  rate: number;                 // 转换比率
  offset?: number;              // 偏移量（用于温度转换等）
  type: ConvertType;            // 转换类型
  category: string;             // 分类（货币、长度、重量等）
  isEnabled: boolean;           // 是否启用
}

/**
 * 转换类型枚举
 */
export enum ConvertType {
  CURRENCY = 'currency',        // 货币
  LENGTH = 'length',            // 长度
  WEIGHT = 'weight',            // 重量
  TIME = 'time',                // 时间
  TEMPERATURE = 'temperature',   // 温度
  AREA = 'area',                // 面积
  VOLUME = 'volume'             // 体积
}

/**
 * 彩蛋配置数据模型
 */
export interface EasterEggConfig {
  id: string;                   // 彩蛋ID
  triggerValue: number;         // 触发数值
  triggerType: TriggerType;     // 触发类型
  message: string;              // 彩蛋消息
  animationType: AnimationType; // 动画类型
  soundPath?: string;           // 音效路径（可选）
  isEnabled: boolean;           // 是否启用
}

/**
 * 触发类型枚举
 */
export enum TriggerType {
  EXACT = 'exact',              // 精确匹配
  CONTAINS = 'contains',        // 包含匹配
  RANGE = 'range'               // 范围匹配
}

/**
 * 动画类型枚举
 */
export enum AnimationType {
  BOUNCE = 'bounce',            // 弹跳
  FADE = 'fade',                // 淡入淡出
  ROTATE = 'rotate',            // 旋转
  SCALE = 'scale',              // 缩放
  FIREWORKS = 'fireworks'       // 烟花效果
}

/**
 * 应用设置数据模型
 */
export interface AppSettings {
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

/**
 * 主题类型枚举
 */
export enum ThemeType {
  LIGHT = 'light',              // 浅色主题
  DARK = 'dark',                // 深色主题
  AUTO = 'auto'                 // 自动主题
}

/**
 * 用户偏好数据模型
 */
export interface UserPreferences {
  favoriteConvertPairs: string[];  // 常用转换对
  recentExpressions: string[];     // 最近使用的表达式
  customEmotionRules: EmotionRule[]; // 自定义情绪规则
  widgetConfig: WidgetConfig;      // Widget配置
}

/**
 * Widget配置数据模型
 */
export interface WidgetConfig {
  size: WidgetSize;             // Widget尺寸
  position: WidgetPosition;     // Widget位置
  showResult: boolean;          // 是否显示结果
  showAnimation: boolean;       // 是否显示动画
}

/**
 * Widget尺寸枚举
 */
export enum WidgetSize {
  SMALL = 'small',              // 小尺寸
  MEDIUM = 'medium',            // 中尺寸
  LARGE = 'large'               // 大尺寸
}

/**
 * Widget位置数据模型
 */
export interface WidgetPosition {
  x: number;                    // X坐标
  y: number;                    // Y坐标
}

/**
 * 数据验证工具类
 */
export class DataValidator {
  /**
   * 验证表达式
   */
  static validateExpression(expr: string): boolean {
    return expr.length > 0 && 
           expr.length <= 1000 && 
           /^[0-9+\-*/().\s]+$/.test(expr);
  }

  /**
   * 验证数值
   */
  static validateNumber(value: number): boolean {
    return !isNaN(value) && 
           isFinite(value) && 
           value >= Number.MIN_SAFE_INTEGER && 
           value <= Number.MAX_SAFE_INTEGER;
  }

  /**
   * 验证转换比率
   */
  static validateRate(rate: number): boolean {
    return rate > 0 && 
           rate < Number.MAX_SAFE_INTEGER;
  }

  /**
   * 验证历史记录限制
   */
  static validateHistoryLimit(records: HistoryRecord[]): boolean {
    return records.length <= 10;
  }

  /**
   * 验证情绪规则优先级
   */
  static validateEmotionPriority(rules: EmotionRule[]): boolean {
    const priorities = rules.map(r => r.feedback.priority);
    return new Set(priorities).size === priorities.length;
  }
}