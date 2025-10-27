/**
 * 离线管理器
 * 管理离线状态和数据同步
 */
import { Logger } from '../utils/Logger';

export interface OfflineStatus {
  isOffline: boolean;
  isOnline: boolean;
  lastSyncTime?: string;
  pendingSyncCount: number;
  pendingSyncTasks: number;
}

export class OfflineManager {
  private static instance: OfflineManager;
  private status: OfflineStatus = {
    isOffline: false,
    isOnline: true,
    pendingSyncCount: 0,
    pendingSyncTasks: 0
  };
  private listeners: ((status: OfflineStatus) => void)[] = [];

  private constructor() {
    this.initializeOfflineManager();
  }

  public static getInstance(): OfflineManager {
    if (!OfflineManager.instance) {
      OfflineManager.instance = new OfflineManager();
    }
    return OfflineManager.instance;
  }

  private initializeOfflineManager(): void {
    // 初始化离线管理器
    Logger.info('OfflineManager initialized');
  }

  public getStatus(): OfflineStatus {
    return { ...this.status };
  }

  public setOfflineStatus(isOffline: boolean): void {
    this.status.isOffline = isOffline;
    this.status.isOnline = !isOffline;
    if (!isOffline) {
      this.status.lastSyncTime = new Date().toISOString();
    }
    this.notifyListeners();
    Logger.info(`Offline status changed: ${isOffline}`);
  }

  public getOfflineStatus(): OfflineStatus {
    return { ...this.status };
  }

  public addPendingSync(): void {
    this.status.pendingSyncCount++;
    this.notifyListeners();
  }

  public removePendingSync(): void {
    if (this.status.pendingSyncCount > 0) {
      this.status.pendingSyncCount--;
      this.notifyListeners();
    }
  }

  public clearPendingSync(): void {
    this.status.pendingSyncCount = 0;
    this.status.pendingSyncTasks = 0;
    this.notifyListeners();
  }

  public async manualSync(): Promise<boolean> {
    try {
      Logger.info('Starting manual sync...');
      // 这里可以添加实际的同步逻辑
      // 目前只是模拟同步
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      this.clearPendingSync();
      this.status.lastSyncTime = new Date().toISOString();
      this.notifyListeners();
      
      Logger.info('Manual sync completed');
      return true;
    } catch (error) {
      Logger.error('Manual sync failed', error);
      return false;
    }
  }

  public addListener(listener: (status: OfflineStatus) => void): void {
    this.listeners.push(listener);
  }

  public removeListener(listener: (status: OfflineStatus) => void): void {
    const index = this.listeners.indexOf(listener);
    if (index > -1) {
      this.listeners.splice(index, 1);
    }
  }

  private notifyListeners(): void {
    this.listeners.forEach(listener => {
      try {
        listener({ ...this.status });
      } catch (error) {
        Logger.error('Error in offline status listener', error);
      }
    });
  }
}
