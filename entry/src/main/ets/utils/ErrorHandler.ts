/**
 * 错误处理工具类
 * 提供统一的错误处理和日志记录功能
 */
export class ErrorHandler {
  private static instance: ErrorHandler;
  private errorLogs: ErrorLog[] = [];
  private maxLogSize: number = 1000;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): ErrorHandler {
    if (!ErrorHandler.instance) {
      ErrorHandler.instance = new ErrorHandler();
    }
    return ErrorHandler.instance;
  }

  /**
   * 处理错误
   */
  public handleError(error: Error, context?: ErrorContext): void {
    const errorLog: ErrorLog = {
      id: this.generateId(),
      message: error.message,
      stack: error.stack,
      context: context || {
        component: 'Unknown',
        action: 'Unknown',
        timestamp: Date.now()
      },
      timestamp: Date.now()
    };

    // 添加到错误日志
    this.addErrorLog(errorLog);

    // 控制台输出
    console.error(`[ErrorHandler] ${errorLog.id}: ${error.message}`, {
      context: errorLog.context,
      stack: errorLog.stack
    });

    // 可以在这里添加更多错误处理逻辑，如上报到服务器
  }

  /**
   * 处理Promise错误
   */
  public handlePromiseError(error: any, context?: ErrorContext): void {
    if (error instanceof Error) {
      this.handleError(error, context);
    } else {
      const customError = new Error(String(error));
      this.handleError(customError, context);
    }
  }

  /**
   * 添加错误日志
   */
  private addErrorLog(errorLog: ErrorLog): void {
    this.errorLogs.unshift(errorLog);
    
    // 限制日志数量
    if (this.errorLogs.length > this.maxLogSize) {
      this.errorLogs = this.errorLogs.slice(0, this.maxLogSize);
    }
  }

  /**
   * 获取错误统计
   */
  public getErrorStats(timeRange?: TimeRange): ErrorStats {
    let filteredLogs = this.errorLogs;
    
    if (timeRange) {
      filteredLogs = this.errorLogs.filter(log => 
        log.timestamp >= timeRange.start && log.timestamp <= timeRange.end
      );
    }

    const errorTypes: { [type: string]: number } = {};
    filteredLogs.forEach(log => {
      const type = this.getErrorType(log.message);
      errorTypes[type] = (errorTypes[type] || 0) + 1;
    });

    return {
      totalErrors: filteredLogs.length,
      errorTypes,
      recentErrors: filteredLogs.slice(0, 10)
    };
  }

  /**
   * 清除错误日志
   */
  public clearErrorLogs(olderThan?: number): void {
    if (olderThan) {
      this.errorLogs = this.errorLogs.filter(log => log.timestamp > olderThan);
    } else {
      this.errorLogs = [];
    }
  }

  /**
   * 获取错误类型
   */
  private getErrorType(message: string): string {
    if (message.includes('Network')) return 'Network';
    if (message.includes('Validation')) return 'Validation';
    if (message.includes('Calculation')) return 'Calculation';
    if (message.includes('Storage')) return 'Storage';
    if (message.includes('UI')) return 'UI';
    return 'Unknown';
  }

  /**
   * 生成唯一ID
   */
  private generateId(): string {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
  }
}

/**
 * 错误日志数据模型
 */
export interface ErrorLog {
  id: string;
  message: string;
  stack?: string;
  context: ErrorContext;
  timestamp: number;
}

/**
 * 错误上下文数据模型
 */
export interface ErrorContext {
  component: string;
  action: string;
  userId?: string;
  timestamp: number;
}

/**
 * 时间范围数据模型
 */
export interface TimeRange {
  start: number;
  end: number;
}

/**
 * 错误统计数据模型
 */
export interface ErrorStats {
  totalErrors: number;
  errorTypes: { [type: string]: number };
  recentErrors: ErrorLog[];
}

/**
 * 计算器特定错误类
 */
export class CalculatorError extends Error {
  public code: string;
  public context?: any;

  constructor(message: string, code: string, context?: any) {
    super(message);
    this.name = 'CalculatorError';
    this.code = code;
    this.context = context;
  }
}

/**
 * 表达式解析错误
 */
export class ExpressionParseError extends CalculatorError {
  constructor(message: string, expression?: string) {
    super(message, 'EXPRESSION_PARSE_ERROR', { expression });
    this.name = 'ExpressionParseError';
  }
}

/**
 * 计算错误
 */
export class CalculationError extends CalculatorError {
  constructor(message: string, expression?: string) {
    super(message, 'CALCULATION_ERROR', { expression });
    this.name = 'CalculationError';
  }
}

/**
 * 数据存储错误
 */
export class StorageError extends CalculatorError {
  constructor(message: string, operation?: string) {
    super(message, 'STORAGE_ERROR', { operation });
    this.name = 'StorageError';
  }
}

/**
 * 网络错误
 */
export class NetworkError extends CalculatorError {
  constructor(message: string, url?: string) {
    super(message, 'NETWORK_ERROR', { url });
    this.name = 'NetworkError';
  }
}
