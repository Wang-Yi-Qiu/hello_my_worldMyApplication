/**
 * 设置页面
 * 包含主题、布局、精度等设置
 */
import { Logger } from '../utils/Logger';
import { ToastHelper } from '../utils/ToastHelper';
import { ThemeManager } from '../utils/ThemeManager';
import { NetworkMonitor, NetworkState } from '../utils/NetworkMonitor';
import { OfflineManager, OfflineStatus } from '../modules/OfflineManager';
import { APP_NAME, APP_VERSION } from '../utils/Constants';

@Component
export struct SettingsPage {
  @StorageLink('currentTheme') currentTheme: string = 'light';
  @State layoutMode: string = 'compact';
  @State precision: number = 10;
  @State angleUnit: string = 'degree';
  @State zeroSnapThreshold: number = 1e-12;
  @State asymptoteThreshold: number = 1e-12;
  private readonly thresholdOptions: number[] = [1e-6, 1e-8, 1e-10, 1e-12, 1e-13, 1e-14, 1e-15];
  @State autoSync: boolean = true;
  @State networkState: NetworkState = NetworkState.UNKNOWN;
  @State offlineStatus: OfflineStatus = {
    isOffline: false,
    isOnline: true,
    pendingSyncCount: 0,
    pendingSyncTasks: 0
  };
  @State enableEmotionFeedback: boolean = true;
  @State enableFortuneText: boolean = true;
  @State enableEasterEgg: boolean = true;
  
  private themeManager: ThemeManager = ThemeManager.getInstance();
  private networkMonitor: NetworkMonitor = NetworkMonitor.getInstance();
  private offlineManager: OfflineManager = OfflineManager.getInstance();
  
  aboutToAppear() {
    Logger.info('SettingsPage loaded');
    this.loadSettings();
    this.updateNetworkStatus();
    
    // 初始化AppStorage中的趣味设置
    if (!AppStorage.has('enableEmotionFeedback')) {
      AppStorage.setOrCreate('enableEmotionFeedback', true);
    }
    if (!AppStorage.has('enableFortuneText')) {
      AppStorage.setOrCreate('enableFortuneText', true);
    }
    if (!AppStorage.has('enableEasterEgg')) {
      AppStorage.setOrCreate('enableEasterEgg', true);
    }
    if (!AppStorage.has('angleUnit')) {
      AppStorage.setOrCreate('angleUnit', 'degree');
    }
    if (!AppStorage.has('zeroSnapThreshold')) {
      AppStorage.setOrCreate('zeroSnapThreshold', 1e-12);
    }
    if (!AppStorage.has('asymptoteThreshold')) {
      AppStorage.setOrCreate('asymptoteThreshold', 1e-12);
    }
    
    // 从AppStorage读取设置
    this.enableEmotionFeedback = AppStorage.get('enableEmotionFeedback') as boolean;
    this.enableFortuneText = AppStorage.get('enableFortuneText') as boolean;
    this.enableEasterEgg = AppStorage.get('enableEasterEgg') as boolean;
    this.angleUnit = AppStorage.get('angleUnit') as string || 'degree';
    this.zeroSnapThreshold = (AppStorage.get('zeroSnapThreshold') as number) || 1e-12;
    this.asymptoteThreshold = (AppStorage.get('asymptoteThreshold') as number) || 1e-12;
    
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
        
        // 趣味设置（情绪反馈和幸运提示）
        this.buildFunSection();
        
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
          ToastHelper.showInfo('布局模式自动适配设备');
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

        // 零点吸附阈值
        Column() {
          Row() {
            Column() {
              Text('零点吸附阈值')
                .fontSize(16)
                .fontColor('#333')
              Text('绝对值低于该阈值将显示为 0')
                .fontSize(12)
                .fontColor('#999')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text(this.zeroSnapThreshold.toExponential(1))
              .fontSize(14)
              .fontColor('#999')
          }
          .width('100%')
          .padding({ left: 15, right: 15, top: 15 })

          // 选项按钮
          Row() {
            ForEach(this.thresholdOptions, (val: number) => {
              Button(val.toExponential(1))
                .fontSize(12)
                .height(34)
                .borderRadius(16)
                .padding({ left: 10, right: 10 })
                .backgroundColor(Math.abs(this.zeroSnapThreshold - val) < 1e-18 ? '#1890ff' : '#f0f0f0')
                .fontColor(Math.abs(this.zeroSnapThreshold - val) < 1e-18 ? '#ffffff' : '#666')
                .margin({ right: 8, bottom: 12 })
                .onClick(() => {
                  this.zeroSnapThreshold = val;
                  AppStorage.setOrCreate('zeroSnapThreshold', val);
                  ToastHelper.showInfo(`零点吸附阈值已设为 ${val.toExponential(1)}`);
                })
            })
          }
          .width('100%')
          .padding({ left: 15, right: 15, bottom: 3 })
        }
        .width('100%')
        .borderWidth({ top: 1 })
        .borderColor('#f0f0f0')

        // 渐近判定阈值
        Column() {
          Row() {
            Column() {
              Text('渐近判定阈值')
                .fontSize(16)
                .fontColor('#333')
              Text('如 tan 在 |cos x| 小于该值时判为无穷')
                .fontSize(12)
                .fontColor('#999')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)

            Text(this.asymptoteThreshold.toExponential(1))
              .fontSize(14)
              .fontColor('#999')
          }
          .width('100%')
          .padding({ left: 15, right: 15, top: 15 })

          Row() {
            ForEach(this.thresholdOptions, (val: number) => {
              Button(val.toExponential(1))
                .fontSize(12)
                .height(34)
                .borderRadius(16)
                .padding({ left: 10, right: 10 })
                .backgroundColor(Math.abs(this.asymptoteThreshold - val) < 1e-18 ? '#1890ff' : '#f0f0f0')
                .fontColor(Math.abs(this.asymptoteThreshold - val) < 1e-18 ? '#ffffff' : '#666')
                .margin({ right: 8, bottom: 12 })
                .onClick(() => {
                  this.asymptoteThreshold = val;
                  AppStorage.setOrCreate('asymptoteThreshold', val);
                  ToastHelper.showInfo(`渐近阈值已设为 ${val.toExponential(1)}`);
                })
            })
          }
          .width('100%')
          .padding({ left: 15, right: 15, bottom: 3 })
        }
        .width('100%')
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
              ToastHelper.showInfo(isOn ? '已开启自动同步' : '已关闭自动同步');
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
      .fontColor(this.currentTheme === value ? '#1890ff' : '#666')
      .fontWeight(this.currentTheme === value ? FontWeight.Bold : FontWeight.Normal)
      .padding({ left: 10, right: 10 })
      .onClick(async () => {
        await this.themeManager.setTheme(value as 'light' | 'dark');
        Logger.info(`Theme changed to: ${value}`);
        ToastHelper.showInfo(`已切换到${label}主题`);
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
        // 保存到 AppStorage
        AppStorage.setOrCreate('angleUnit', value);
        Logger.info(`Angle unit changed to: ${value}`);
        ToastHelper.showInfo(`角度单位已切换到${label}`);
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
      ToastHelper.showInfo('开始同步...');
      
      await this.offlineManager.manualSync();
      
      ToastHelper.showSuccess('同步完成');
      
      this.updateOfflineStatus();
    } catch (error) {
      Logger.error('Manual sync failed', error);
      ToastHelper.showError('同步失败：' + (error as Error).message);
    }
  }

  /**
   * 趣味设置区域
   */
  @Builder buildFunSection() {
    Column() {
      Text('趣味设置')
        .fontSize(14)
        .fontColor('#999')
        .padding({ left: 15, top: 10, bottom: 5 })
        .width('100%')
      
      Column() {
        // 情绪反馈
        Row() {
          Column() {
            Text('情绪反馈')
              .fontSize(16)
              .fontColor('#333')
            
            Text('根据计算结果显示趣味表情')
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          
          Toggle({ type: ToggleType.Switch, isOn: this.enableEmotionFeedback })
            .onChange((isOn: boolean) => {
              this.enableEmotionFeedback = isOn;
              AppStorage.setOrCreate('enableEmotionFeedback', isOn);
              Logger.info(`Emotion feedback: ${isOn}`);
              ToastHelper.showInfo(isOn ? '已开启情绪反馈' : '已关闭情绪反馈');
            })
        }
        .width('100%')
        .padding(15)
        
        // 幸运提示
        Row() {
          Column() {
            Text('幸运提示')
              .fontSize(16)
              .fontColor('#333')
            
            Text('每次计算后显示幸运提示语')
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          
          Toggle({ type: ToggleType.Switch, isOn: this.enableFortuneText })
            .onChange((isOn: boolean) => {
              this.enableFortuneText = isOn;
              AppStorage.setOrCreate('enableFortuneText', isOn);
              Logger.info(`Fortune text: ${isOn}`);
              ToastHelper.showInfo(isOn ? '已开启幸运提示' : '已关闭幸运提示');
            })
        }
        .width('100%')
        .padding(15)
        .borderWidth({ top: 1 })
        .borderColor('#f0f0f0')
        
        // 彩蛋模式
        Row() {
          Column() {
            Text('彩蛋模式')
              .fontSize(16)
              .fontColor('#333')
            
            Text('特定数字触发特殊效果')
              .fontSize(12)
              .fontColor('#999')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          
          Toggle({ type: ToggleType.Switch, isOn: this.enableEasterEgg })
            .onChange((isOn: boolean) => {
              this.enableEasterEgg = isOn;
              AppStorage.setOrCreate('enableEasterEgg', isOn);
              Logger.info(`Easter egg: ${isOn}`);
              ToastHelper.showInfo(isOn ? '已开启彩蛋模式' : '已关闭彩蛋模式');
            })
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
}

