/**
 * 日志工具类
 * 封装 HarmonyOS hilog 功能
 */
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000; // 日志域，可自定义
const TAG = 'SmartCalc'; // 日志标签

export class Logger {
  /**
   * 输出 Debug 级别日志
   */
  static debug(message: string, ...args: any[]): void {
    hilog.debug(DOMAIN, TAG, `[DEBUG] ${message}`, ...args);
  }

  /**
   * 输出 Info 级别日志
   */
  static info(message: string, ...args: any[]): void {
    hilog.info(DOMAIN, TAG, `[INFO] ${message}`, ...args);
  }

  /**
   * 输出 Warn 级别日志
   */
  static warn(message: string, ...args: any[]): void {
    hilog.warn(DOMAIN, TAG, `[WARN] ${message}`, ...args);
  }

  /**
   * 输出 Error 级别日志
   */
  static error(message: string, ...args: any[]): void {
    hilog.error(DOMAIN, TAG, `[ERROR] ${message}`, ...args);
  }

  /**
   * 输出 Fatal 级别日志
   */
  static fatal(message: string, ...args: any[]): void {
    hilog.fatal(DOMAIN, TAG, `[FATAL] ${message}`, ...args);
  }

  /**
   * 格式化对象为 JSON 字符串输出
   */
  static json(level: 'debug' | 'info' | 'warn' | 'error', obj: any): void {
    const jsonStr = JSON.stringify(obj, null, 2);
    switch (level) {
      case 'debug':
        this.debug(jsonStr);
        break;
      case 'info':
        this.info(jsonStr);
        break;
      case 'warn':
        this.warn(jsonStr);
        break;
      case 'error':
        this.error(jsonStr);
        break;
    }
  }

  /**
   * 性能计时开始
   */
  static time(label: string): void {
    console.time(label);
  }

  /**
   * 性能计时结束
   */
  static timeEnd(label: string): void {
    console.timeEnd(label);
  }
}

