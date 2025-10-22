/**
 * 网络状态监听器
 * 监听网络连接状态变化
 */
import connection from '@ohos.net.connection';
import { Logger } from './Logger';

export enum NetworkState {
  ONLINE = 'online',
  OFFLINE = 'offline',
  UNKNOWN = 'unknown'
}

export type NetworkStateCallback = (state: NetworkState) => void;

/**
 * 网络监听器类
 */
export class NetworkMonitor {
  private static instance: NetworkMonitor;
  private currentState: NetworkState = NetworkState.UNKNOWN;
  private callbacks: NetworkStateCallback[] = [];
  
  private constructor() {
    this.initMonitor();
  }
  
  /**
   * 获取单例实例
   */
  static getInstance(): NetworkMonitor {
    if (!NetworkMonitor.instance) {
      NetworkMonitor.instance = new NetworkMonitor();
    }
    return NetworkMonitor.instance;
  }
  
  /**
   * 初始化网络监听
   */
  private async initMonitor() {
    try {
      // 获取当前网络状态
      await this.checkNetworkState();
      
      // TODO: 在新版本的HarmonyOS API中,网络监听方式可能需要更新
      // 暂时只获取一次网络状态,不进行持续监听
      
      Logger.info('Network monitor initialized');
    } catch (error) {
      Logger.error('Failed to initialize network monitor', error);
    }
  }
  
  /**
   * 检查当前网络状态
   */
  private async checkNetworkState() {
    try {
      const defaultNet = await connection.getDefaultNet();
      const capabilities = await connection.getNetCapabilities(defaultNet);
      
      if (capabilities && capabilities.bearerTypes.length > 0) {
        this.updateState(NetworkState.ONLINE);
      } else {
        this.updateState(NetworkState.OFFLINE);
      }
    } catch (error) {
      Logger.warn('Could not determine network state', error);
      this.updateState(NetworkState.UNKNOWN);
    }
  }
  
  /**
   * 更新网络状态
   */
  private updateState(newState: NetworkState) {
    if (this.currentState !== newState) {
      const oldState = this.currentState;
      this.currentState = newState;
      
      Logger.info(`Network state changed: ${oldState} -> ${newState}`);
      
      // 通知所有监听器
      this.callbacks.forEach(callback => {
        try {
          callback(newState);
        } catch (error) {
          Logger.error('Network callback error', error);
        }
      });
    }
  }
  
  /**
   * 获取当前网络状态
   */
  getCurrentState(): NetworkState {
    return this.currentState;
  }
  
  /**
   * 是否在线
   */
  isOnline(): boolean {
    return this.currentState === NetworkState.ONLINE;
  }
  
  /**
   * 是否离线
   */
  isOffline(): boolean {
    return this.currentState === NetworkState.OFFLINE;
  }
  
  /**
   * 添加状态变化监听器
   */
  addListener(callback: NetworkStateCallback) {
    this.callbacks.push(callback);
  }
  
  /**
   * 移除状态变化监听器
   */
  removeListener(callback: NetworkStateCallback) {
    const index = this.callbacks.indexOf(callback);
    if (index > -1) {
      this.callbacks.splice(index, 1);
    }
  }
  
  /**
   * 清除所有监听器
   */
  clearListeners() {
    this.callbacks = [];
  }
}

