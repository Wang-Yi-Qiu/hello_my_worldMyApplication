/**
 * 网络状态监控工具
 * 监控网络连接状态
 */
import { Logger } from './Logger';

export enum NetworkState {
  UNKNOWN = 'unknown',
  CONNECTED = 'connected',
  DISCONNECTED = 'disconnected',
  ONLINE = 'online'
}

export class NetworkMonitor {
  private static instance: NetworkMonitor;
  private currentState: NetworkState = NetworkState.UNKNOWN;
  private listeners: ((state: NetworkState) => void)[] = [];

  private constructor() {
    // 初始化网络状态监控
    this.initializeNetworkMonitoring();
  }

  public static getInstance(): NetworkMonitor {
    if (!NetworkMonitor.instance) {
      NetworkMonitor.instance = new NetworkMonitor();
    }
    return NetworkMonitor.instance;
  }

  private initializeNetworkMonitoring(): void {
    // 这里可以添加实际的网络状态监控逻辑
    // 目前返回模拟状态
    this.currentState = NetworkState.CONNECTED;
    Logger.info('NetworkMonitor initialized');
  }

  public getCurrentState(): NetworkState {
    return this.currentState;
  }

  public addListener(listener: (state: NetworkState) => void): void {
    this.listeners.push(listener);
  }

  public removeListener(listener: (state: NetworkState) => void): void {
    const index = this.listeners.indexOf(listener);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }

  private notifyListeners(state: NetworkState): void {
    this.currentState = state;
    this.listeners.forEach(listener => {
      try {
        listener(state);
      } catch (error) {
        Logger.error('Error in network state listener', error);
      }
    });
  }
}
