/**
 * 全局常量定义
 */

// 应用信息
export const APP_NAME = 'HarmonyOS 智能计算器增强版';
export const APP_VERSION = '1.0.0';
export const BUNDLE_NAME = 'com.example.calculator';

// 数据库配置
export const DB_NAME = 'SmartCalc.db';
export const DB_VERSION = 1;

// 计算配置
export const DEFAULT_PRECISION = 10;
export const DEFAULT_ANGLE_UNIT = 'degree';
export const DEFAULT_ZERO_SNAP_THRESHOLD = 1e-12; // 结果显示为0的吸附阈值
export const DEFAULT_ASYMPTOTE_THRESHOLD = 1e-12; // 渐近点判定阈值（如 tan）
export const MAX_HISTORY_RECORDS = 1000;

// UI 配置
export const DEFAULT_THEME = 'light';
export const DEFAULT_LAYOUT = 'compact';

// 布局断点（单位：vp）
export const LAYOUT_BREAKPOINTS = {
  POCKET: 600,   // < 600vp: Pocket 模式
  COMPACT: 900,  // 600-900vp: Compact 模式
  EXPANDED: 900  // >= 900vp: Expanded 模式
};

// 主题颜色
export const THEME_COLORS = {
  light: {
    primary: '#1890ff',
    background: '#ffffff',
    text: '#000000',
    error: '#ff4d4f',
    success: '#52c41a'
  },
  dark: {
    primary: '#177ddc',
    background: '#141414',
    text: '#ffffff',
    error: '#ff7875',
    success: '#73d13d'
  }
};

// 计算类型
export enum CalcType {
  BASIC = 'basic',
  EQUATION = 'equation',
  CALCULUS = 'calculus',
  MATRIX = 'matrix',
  GRAPH = 'graph',
  CONVERSION = 'conversion'
}

// 公式分类
export enum FormulaCategory {
  GENERAL = 'general',
  ALGEBRA = 'algebra',
  CALCULUS = 'calculus',
  GEOMETRY = 'geometry',
  TRIGONOMETRY = 'trigonometry',
  STATISTICS = 'statistics'
}

// 同步状态
export enum SyncState {
  UNSYNCED = 0,
  SYNCING = -1,
  SYNCED = 1
}

// 角度单位
export enum AngleUnit {
  DEGREE = 'degree',
  RADIAN = 'radian'
}

// 布局模式
export enum LayoutMode {
  POCKET = 'pocket',
  COMPACT = 'compact',
  EXPANDED = 'expanded'
}

// 错误消息
export const ERROR_MESSAGES = {
  INVALID_EXPRESSION: '表达式无效',
  DIVISION_BY_ZERO: '除以零错误',
  CALCULATION_ERROR: '计算错误',
  DATABASE_ERROR: '数据库错误',
  NETWORK_ERROR: '网络错误',
  SYNC_ERROR: '同步失败'
};

// 新增常量定义
export const PRIMARY_COLOR = '#007DFF';
export const SUCCESS_COLOR = '#00C853';
export const ERROR_COLOR = '#FF1744';
export const WARNING_COLOR = '#FF9800';

// 性能阈值
export const PERFORMANCE_THRESHOLDS = {
  CALCULATION: 1000,    // 1秒
  UI_UPDATE: 100,       // 100毫秒
  DATA_LOAD: 500,       // 500毫秒
  ANIMATION: 300        // 300毫秒
};

// Widget相关
export const WIDGET_NAME = 'QuickConvertWidget';
export const WIDGET_UPDATE_INTERVAL = 86400; // 24小时

// 存储键
export const STORAGE_KEYS = {
  HISTORY: 'history_records',
  SETTINGS: 'app_settings',
  PREFERENCES: 'user_preferences',
  CONVERT_CONFIGS: 'convert_configs',
  EMOTION_FEEDBACKS: 'emotion_feedbacks',
  EASTER_EGG_CONFIGS: 'easter_egg_configs'
};

// 彩蛋触发值
export const EASTER_EGG_VALUES = {
  LOVE: 1314,
  DEVIL: 666,
  FORTUNE: 888,
  ROMANCE: 520
};

// 货币代码
export const CURRENCY_CODES = {
  USD: 'USD',
  CNY: 'CNY',
  JPY: 'JPY'
};

