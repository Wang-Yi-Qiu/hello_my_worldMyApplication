/**
 * 性能监控工具类
 * 用于监控应用性能指标
 */
export class PerformanceMonitor {
  private static instance: PerformanceMonitor;
  private timers: Map<string, number> = new Map();
  private metrics: PerformanceMetric[] = [];
  private maxMetricsSize: number = 1000;

  private constructor() {}

  /**
   * 获取单例实例
   */
  public static getInstance(): PerformanceMonitor {
    if (!PerformanceMonitor.instance) {
      PerformanceMonitor.instance = new PerformanceMonitor();
    }
    return PerformanceMonitor.instance;
  }

  /**
   * 开始性能计时
   */
  public startTimer(name: string): string {
    const timerId = this.generateTimerId(name);
    this.timers.set(timerId, Date.now());
    return timerId;
  }

  /**
   * 结束性能计时
   */
  public endTimer(timerId: string): PerformanceMetric {
    const startTime = this.timers.get(timerId);
    if (!startTime) {
      throw new Error(`Timer ${timerId} not found`);
    }

    const duration = Date.now() - startTime;
    const metric: PerformanceMetric = {
      name: this.extractTimerName(timerId),
      duration,
      timestamp: Date.now(),
      context: { timerId }
    };

    this.recordMetric(metric);
    this.timers.delete(timerId);
    
    return metric;
  }

  /**
   * 记录性能指标
   */
  public recordMetric(metric: PerformanceMetric): void {
    this.metrics.unshift(metric);
    
    // 限制指标数量
    if (this.metrics.length > this.maxMetricsSize) {
      this.metrics = this.metrics.slice(0, this.maxMetricsSize);
    }
  }

  /**
   * 获取性能报告
   */
  public getPerformanceReport(timeRange?: TimeRange): PerformanceReport {
    let filteredMetrics = this.metrics;
    
    if (timeRange) {
      filteredMetrics = this.metrics.filter(metric => 
        metric.timestamp >= timeRange.start && metric.timestamp <= timeRange.end
      );
    }

    if (filteredMetrics.length === 0) {
      return {
        averageResponseTime: 0,
        maxResponseTime: 0,
        minResponseTime: 0,
        totalOperations: 0,
        metrics: []
      };
    }

    const durations = filteredMetrics.map(m => m.duration);
    const averageResponseTime = durations.reduce((sum, duration) => sum + duration, 0) / durations.length;
    const maxResponseTime = Math.max(...durations);
    const minResponseTime = Math.min(...durations);

    return {
      averageResponseTime,
      maxResponseTime,
      minResponseTime,
      totalOperations: filteredMetrics.length,
      metrics: filteredMetrics
    };
  }

  /**
   * 清除性能指标
   */
  public clearMetrics(olderThan?: number): void {
    if (olderThan) {
      this.metrics = this.metrics.filter(metric => metric.timestamp > olderThan);
    } else {
      this.metrics = [];
    }
  }

  /**
   * 获取特定操作的性能统计
   */
  public getOperationStats(operationName: string, timeRange?: TimeRange): PerformanceReport {
    let filteredMetrics = this.metrics.filter(metric => metric.name === operationName);
    
    if (timeRange) {
      filteredMetrics = filteredMetrics.filter(metric => 
        metric.timestamp >= timeRange.start && metric.timestamp <= timeRange.end
      );
    }

    if (filteredMetrics.length === 0) {
      return {
        averageResponseTime: 0,
        maxResponseTime: 0,
        minResponseTime: 0,
        totalOperations: 0,
        metrics: []
      };
    }

    const durations = filteredMetrics.map(m => m.duration);
    const averageResponseTime = durations.reduce((sum, duration) => sum + duration, 0) / durations.length;
    const maxResponseTime = Math.max(...durations);
    const minResponseTime = Math.min(...durations);

    return {
      averageResponseTime,
      maxResponseTime,
      minResponseTime,
      totalOperations: filteredMetrics.length,
      metrics: filteredMetrics
    };
  }

  /**
   * 检查性能是否达标
   */
  public checkPerformanceThreshold(operationName: string, threshold: number): boolean {
    const stats = this.getOperationStats(operationName);
    return stats.averageResponseTime <= threshold;
  }

  /**
   * 生成计时器ID
   */
  private generateTimerId(name: string): string {
    return `${name}_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }

  /**
   * 提取计时器名称
   */
  private extractTimerName(timerId: string): string {
    return timerId.split('_')[0];
  }
}

/**
 * 性能指标数据模型
 */
export interface PerformanceMetric {
  name: string;
  duration: number;
  timestamp: number;
  context?: any;
}

/**
 * 性能报告数据模型
 */
export interface PerformanceReport {
  averageResponseTime: number;
  maxResponseTime: number;
  minResponseTime: number;
  totalOperations: number;
  metrics: PerformanceMetric[];
}

/**
 * 时间范围数据模型
 */
export interface TimeRange {
  start: number;
  end: number;
}

/**
 * 性能阈值配置
 */
export interface PerformanceThresholds {
  calculation: number;        // 计算响应时间阈值（毫秒）
  uiUpdate: number;          // UI更新响应时间阈值（毫秒）
  dataLoad: number;          // 数据加载响应时间阈值（毫秒）
  animation: number;         // 动画响应时间阈值（毫秒）
}

/**
 * 默认性能阈值
 */
export const DEFAULT_PERFORMANCE_THRESHOLDS: PerformanceThresholds = {
  calculation: 1000,         // 1秒
  uiUpdate: 100,            // 100毫秒
  dataLoad: 500,            // 500毫秒
  animation: 300             // 300毫秒
};

/**
 * 性能监控装饰器
 */
export function performanceMonitor(operationName: string) {
  return function (target: any, propertyName: string, descriptor: PropertyDescriptor) {
    const method = descriptor.value;
    
    descriptor.value = async function (...args: any[]) {
      const monitor = PerformanceMonitor.getInstance();
      const timerId = monitor.startTimer(operationName);
      
      try {
        const result = await method.apply(this, args);
        const metric = monitor.endTimer(timerId);
        console.log(`[Performance] ${operationName}: ${metric.duration}ms`);
        return result;
      } catch (error) {
        monitor.endTimer(timerId);
        throw error;
      }
    };
  };
}
