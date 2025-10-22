/**
 * 离线数据管理器
 * 处理离线模式下的数据缓存和同步队列
 */
import { Logger } from '../utils/Logger';
import { NetworkMonitor, NetworkState } from '../utils/NetworkMonitor';

export interface SyncTask {
  id: string;
  type: 'create' | 'update' | 'delete';
  entity: string;
  data: any;
  timestamp: number;
}

export interface OfflineStatus {
  isOnline: boolean;
  pendingSyncTasks: number;
  lastSyncTime?: number;
}

/**
 * 离线管理器类
 */
export class OfflineManager {
  private static instance: OfflineManager;
  private networkMonitor: NetworkMonitor;
  private syncQueue: SyncTask[] = [];
  private isSyncing: boolean = false;
  
  private constructor() {
    this.networkMonitor = NetworkMonitor.getInstance();
    this.initNetworkListener();
  }
  
  /**
   * 获取单例实例
   */
  static getInstance(): OfflineManager {
    if (!OfflineManager.instance) {
      OfflineManager.instance = new OfflineManager();
    }
    return OfflineManager.instance;
  }
  
  /**
   * 初始化网络监听
   */
  private initNetworkListener() {
    this.networkMonitor.addListener((state: NetworkState) => {
      if (state === NetworkState.ONLINE) {
        Logger.info('Network online, starting sync...');
        this.processSyncQueue();
      } else {
        Logger.info('Network offline, queueing operations');
      }
    });
  }
  
  /**
   * 添加同步任务到队列
   */
  addSyncTask(task: Omit<SyncTask, 'id' | 'timestamp'>): string {
    const taskId = `${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    const fullTask: SyncTask = {
      ...task,
      id: taskId,
      timestamp: Date.now()
    };
    
    this.syncQueue.push(fullTask);
    Logger.info(`Sync task added: ${taskId}, queue size: ${this.syncQueue.length}`);
    
    // 如果在线，立即尝试同步
    if (this.networkMonitor.isOnline()) {
      this.processSyncQueue();
    }
    
    return taskId;
  }
  
  /**
   * 处理同步队列
   */
  private async processSyncQueue() {
    if (this.isSyncing || this.syncQueue.length === 0) {
      return;
    }
    
    if (!this.networkMonitor.isOnline()) {
      Logger.warn('Cannot sync: network offline');
      return;
    }
    
    this.isSyncing = true;
    Logger.info(`Processing sync queue, ${this.syncQueue.length} tasks`);
    
    try {
      while (this.syncQueue.length > 0 && this.networkMonitor.isOnline()) {
        const task = this.syncQueue[0];
        
        try {
          await this.executeSyncTask(task);
          // 成功后移除任务
          this.syncQueue.shift();
          Logger.info(`Sync task completed: ${task.id}`);
        } catch (error) {
          Logger.error(`Sync task failed: ${task.id}`, error);
          // 失败则停止，等待下次重试
          break;
        }
      }
    } finally {
      this.isSyncing = false;
    }
  }
  
  /**
   * 执行单个同步任务
   */
  private async executeSyncTask(task: SyncTask): Promise<void> {
    // 这里应该调用实际的云端 API
    // 目前是占位实现
    Logger.info(`Executing sync task: ${task.type} ${task.entity}`);
    
    return new Promise((resolve, reject) => {
      // 模拟网络请求
      setTimeout(() => {
        // 模拟 90% 成功率
        if (Math.random() > 0.1) {
          resolve();
        } else {
          reject(new Error('Sync failed'));
        }
      }, 100);
    });
  }
  
  /**
   * 获取离线状态
   */
  getOfflineStatus(): OfflineStatus {
    return {
      isOnline: this.networkMonitor.isOnline(),
      pendingSyncTasks: this.syncQueue.length,
      lastSyncTime: this.getLastSyncTime()
    };
  }
  
  /**
   * 获取最后同步时间
   */
  private getLastSyncTime(): number | undefined {
    // 这里应该从持久化存储中读取
    // 目前返回 undefined
    return undefined;
  }
  
  /**
   * 清空同步队列
   */
  clearSyncQueue() {
    this.syncQueue = [];
    Logger.info('Sync queue cleared');
  }
  
  /**
   * 获取同步队列大小
   */
  getSyncQueueSize(): number {
    return this.syncQueue.length;
  }
  
  /**
   * 手动触发同步
   */
  async manualSync(): Promise<void> {
    if (!this.networkMonitor.isOnline()) {
      throw new Error('Cannot sync: network offline');
    }
    
    await this.processSyncQueue();
  }
}

