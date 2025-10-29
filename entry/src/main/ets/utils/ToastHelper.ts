/**
 * Toast 提示工具类
 * 封装 promptAction.showToast，自动处理异常
 */
import { promptAction } from '@kit.ArkUI';
import { Logger } from './Logger';

export class ToastHelper {
  /**
   * 显示 Toast 提示
   * @param message 提示消息
   * @param duration 显示时长（毫秒），默认 2000ms
   */
  static show(message: string, duration: number = 2000): void {
    try {
      // 使用 showToast 显示提示信息
      promptAction.showToast({
        message: message,
        duration: duration
      });
      Logger.info('Toast shown successfully');
    } catch (error) {
      Logger.error('Failed to show toast', error);
      // Toast 失败不应该影响主流程，只记录日志
    }
  }

  /**
   * 显示短时 Toast（1500ms）
   * @param message 提示消息
   */
  static showShort(message: string): void {
    ToastHelper.show(message, 1500);
  }

  /**
   * 显示长时 Toast（3500ms）
   * @param message 提示消息
   */
  static showLong(message: string): void {
    ToastHelper.show(message, 3500);
  }

  /**
   * 显示成功提示
   * @param message 提示消息
   */
  static showSuccess(message: string): void {
    ToastHelper.show(`✓ ${message}`);
  }

  /**
   * 显示错误提示
   * @param message 提示消息
   */
  static showError(message: string): void {
    ToastHelper.show(`✗ ${message}`);
  }

  /**
   * 显示警告提示
   * @param message 提示消息
   */
  static showWarning(message: string): void {
    ToastHelper.show(`⚠ ${message}`);
  }

  /**
   * 显示信息提示
   * @param message 提示消息
   */
  static showInfo(message: string): void {
    ToastHelper.show(`ℹ ${message}`);
  }
}

