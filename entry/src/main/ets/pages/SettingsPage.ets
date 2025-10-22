/**
 * 设置页面
 * 包含主题、布局、精度等设置
 */
import { Logger } from '../utils/Logger';
import { NetworkMonitor, NetworkState } from '../utils/NetworkMonitor';
import { OfflineManager, OfflineStatus } from '../modules/OfflineManager';
import { APP_NAME, APP_VERSION } from '../utils/Constants';
import promptAction from '@ohos.promptAction';

@Component
export struct SettingsPage {
  @State theme: string = 'light';
  @State layoutMode: string = 'compact';
  @State precision: number = 10;
  @State angleUnit: string = 'degree';
  @State autoSync: boolean = true;
  @State networkState: NetworkState = NetworkState.UNKNOWN;
  @State offlineStatus: OfflineStatus = {
    isOnline: false,
    pendingSyncTasks: 0
  };
  
  private networkMonitor: NetworkMonitor = NetworkMonitor.getInstance();
  private offlineManager: OfflineManager = OfflineManager.getInstance();
  
  aboutToAppear() {
    Logger.info('SettingsPage loaded');
    this.loadSettings();
    this.updateNetworkStatus();
    
    // 监听网络状态变化
    this.networkMonitor.addListener((state: NetworkState) => {
      this.networkState = state;
      this.updateOfflineStatus();
    });
  }
  
  /**
   * 加载设置
   */
  private loadSettings() {
    // TODO: 从数据库加载设置
    Logger.info('Loading settings from database');
  }
  
  /**
   * 更新网络状态
   */
  private updateNetworkStatus() {
    this.networkState = this.networkMonitor.getCurrentState();
    this.updateOfflineStatus();
  }
  
  /**
   * 更新离线状态
   */
  private updateOfflineStatus() {
    this.offlineStatus = this.offlineManager.getOfflineStatus();
  }
  
  build() {
    Scroll() {
      Column() {
        // 标题
        Text('设置')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .padding(20)
          .width('100%')
          .textAlign(TextAlign.Start)
        
        // 网络状态
        this.buildNetworkSection();
        
        // 显示设置
        this.buildDisplaySection();
        
        // 计算设置
        this.buildCalculationSection();
        
        // 数据同步
        this.buildSyncSection();
        
        // 关于
        this.buildAboutSection();
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
  }
  
  /**
   * 网络状态区域
   */
  @Builder buildNetworkSection() {
    Column() {
      Text('网络状态')
        .fontSize(14)
        .fontColor('#999')
        .padding({ left: 15, top: 10, bottom: 5 })
        .width('100%')
      
      Column() {
        Row() {
          Text('当前状态')
            .fontSize(16)
            .fontColor('#333')
            .layoutWeight(1)
          
          Row() {
            Circle({ width: 8, height: 8 })
              .fill(this.networkState === NetworkState.ONLINE ? '#52c41a' : '#ff4d4f')
              .margin({ right: 5 })
            
            Text(this.networkState === NetworkState.ONLINE ? '在线' : '离线')
              .fontSize(14)
              .fontColor(this.networkState === NetworkState.ONLINE ? '#52c41a' : '#ff4d4f')
          }
        }
        .width('100%')
        .padding(15)
        
        if (this.offlineStatus.pendingSyncTasks > 0) {
          Row() {
            Text('待同步数据')
              .fontSize(16)
              .fontColor('#333')
              .layoutWeight(1)
            
            Text(`${this.offlineStatus.pendingSyncTasks} 项`)
              .fontSize(14)
              .fontColor('#fa8c16')
          }
          .width('100%')
          .padding(15)
          .borderWidth({ top: 1 })
          .borderColor('#f0f0f0')
        }
      }
      .width('100%')
      .backgroundColor('#fff')
      .borderRadius(8)
      .margin({ left: 15, right: 15, bottom: 15 })
    }
  }
  
  /**
   * 显示设置区域
   */
  @Builder buildDisplaySection() {
    Column() {
      Text('显示')
        .fontSize(14)
        .fontColor('#999')
        .padding({ left: 15, top: 10, bottom: 5 })
        .width('100%')
      
      Column() {
        // 主题
        Row() {
          Text('主题')
            .fontSize(16)
            .fontColor('#333')
            .layoutWeight(1)
          
          Row() {
            this.buildThemeOption('浅色', 'light');
            this.buildThemeOption('深色', 'dark');
          }
        }
        .width('100%')
        .padding(15)
        
        // 布局模式
        Row() {
          Text('布局模式')
            .fontSize(16)
            .fontColor('#333')
            .layoutWeight(1)
          
          Text(this.getLayoutName(this.layoutMode))
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .padding(15)
        .borderWidth({ top: 1 })
        .borderColor('#f0f0f0')
        .onClick(() => {
          promptAction.showToast({
            message: '布局模式自动适配设备'
          });
        })
      }
      .width('100%')
      .backgroundColor('#fff')
      .borderRadius(8)
      .margin({ left: 15, right: 15, bottom: 15 })
    }
  }
  
  /**
   * 计算设置区域
   */
  @Builder buildCalculationSection() {
    Column() {
      Text('计算')
        .fontSize(14)
        .fontColor('#999')
        .padding({ left: 15, top: 10, bottom: 5 })
        .width('100%')
      
      Column() {
        // 计算精度
        Row() {
          Text('计算精度')
            .fontSize(16)
            .fontColor('#333')
            .layoutWeight(1)
          
          Text(`${this.precision} 位`)
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .padding(15)
        
        // 角度单位
        Row() {
          Text('角度单位')
            .fontSize(16)
            .fontColor('#333')
            .layoutWeight(1)
          
          Row() {
            this.buildAngleUnitOption('角度', 'degree');
            this.buildAngleUnitOption('弧度', 'radian');
          }
        }
        .width('100%')
        .padding(15)
        .borderWidth({ top: 1 })
        .borderColor('#f0f0f0')
      }
      .width('100%')
      .backgroundColor('#fff')
      .borderRadius(8)
      .margin({ left: 15, right: 15, bottom: 15 })
    }
  }
  
  /**
   * 数据同步区域
   */
  @Builder buildSyncSection() {
    Column() {
      Text('数据同步')
        .fontSize(14)
        .fontColor('#999')
        .padding({ left: 15, top: 10, bottom: 5 })
        .width('100%')
      
      Column() {
        // 自动同步
        Row() {
          Text('自动同步')
            .fontSize(16)
            .fontColor('#333')
            .layoutWeight(1)
          
          Toggle({ type: ToggleType.Switch, isOn: this.autoSync })
            .onChange((isOn: boolean) => {
              this.autoSync = isOn;
              Logger.info(`Auto sync: ${isOn}`);
              promptAction.showToast({
                message: isOn ? '已开启自动同步' : '已关闭自动同步'
              });
            })
        }
        .width('100%')
        .padding(15)
        
        // 立即同步
        Row() {
          Text('立即同步')
            .fontSize(16)
            .fontColor('#1890ff')
            .layoutWeight(1)
          
          Text('→')
            .fontSize(16)
            .fontColor('#1890ff')
        }
        .width('100%')
        .padding(15)
        .borderWidth({ top: 1 })
        .borderColor('#f0f0f0')
        .onClick(() => {
          this.handleManualSync();
        })
      }
      .width('100%')
      .backgroundColor('#fff')
      .borderRadius(8)
      .margin({ left: 15, right: 15, bottom: 15 })
    }
  }
  
  /**
   * 关于区域
   */
  @Builder buildAboutSection() {
    Column() {
      Text('关于')
        .fontSize(14)
        .fontColor('#999')
        .padding({ left: 15, top: 10, bottom: 5 })
        .width('100%')
      
      Column() {
        Row() {
          Text('应用名称')
            .fontSize(16)
            .fontColor('#333')
            .layoutWeight(1)
          
          Text(APP_NAME)
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .padding(15)
        
        Row() {
          Text('版本号')
            .fontSize(16)
            .fontColor('#333')
            .layoutWeight(1)
          
          Text(`v${APP_VERSION}`)
            .fontSize(14)
            .fontColor('#999')
        }
        .width('100%')
        .padding(15)
        .borderWidth({ top: 1 })
        .borderColor('#f0f0f0')
      }
      .width('100%')
      .backgroundColor('#fff')
      .borderRadius(8)
      .margin({ left: 15, right: 15, bottom: 15 })
    }
  }
  
  /**
   * 主题选项
   */
  @Builder buildThemeOption(label: string, value: string) {
    Text(label)
      .fontSize(14)
      .fontColor(this.theme === value ? '#1890ff' : '#666')
      .fontWeight(this.theme === value ? FontWeight.Bold : FontWeight.Normal)
      .padding({ left: 10, right: 10 })
      .onClick(() => {
        this.theme = value;
        Logger.info(`Theme changed to: ${value}`);
        promptAction.showToast({
          message: `已切换到${label}主题`
        });
      })
  }
  
  /**
   * 角度单位选项
   */
  @Builder buildAngleUnitOption(label: string, value: string) {
    Text(label)
      .fontSize(14)
      .fontColor(this.angleUnit === value ? '#1890ff' : '#666')
      .fontWeight(this.angleUnit === value ? FontWeight.Bold : FontWeight.Normal)
      .padding({ left: 10, right: 10 })
      .onClick(() => {
        this.angleUnit = value;
        Logger.info(`Angle unit changed to: ${value}`);
        promptAction.showToast({
          message: `角度单位已切换到${label}`
        });
      })
  }
  
  /**
   * 获取布局名称
   */
  private getLayoutName(mode: string): string {
    switch (mode) {
      case 'pocket':
        return '紧凑模式';
      case 'compact':
        return '标准模式';
      case 'expanded':
        return '展开模式';
      default:
        return '未知';
    }
  }
  
  /**
   * 手动同步
   */
  private async handleManualSync() {
    try {
      promptAction.showToast({
        message: '开始同步...'
      });
      
      await this.offlineManager.manualSync();
      
      promptAction.showToast({
        message: '同步完成'
      });
      
      this.updateOfflineStatus();
    } catch (error) {
      Logger.error('Manual sync failed', error);
      promptAction.showToast({
        message: '同步失败：' + (error as Error).message
      });
    }
  }
}

