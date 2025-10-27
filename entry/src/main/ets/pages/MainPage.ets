/**
 * 主页面 - 简化版
 * 只包含计算器和历史记录
 */
import { AppTheme } from '../utils/AppTheme';
import { Logger } from '../utils/Logger';
import { ThemeManager } from '../utils/ThemeManager';
import { CalculatorPage } from './CalculatorPage';
import { HistoryPage } from './HistoryPage';
import { SettingsPage } from './SettingsPage';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;
  @StorageLink('currentTheme') currentTheme: string = 'light';
  private themeManager: ThemeManager = ThemeManager.getInstance();

  aboutToAppear() {
    Logger.info('MainPage loaded');
    // 初始化主题
    AppStorage.setOrCreate('currentTheme', this.themeManager.getCurrentTheme());
  }

  build() {
    Column() {
      // 内容区域
      Tabs({ index: this.currentIndex }) {
        TabContent() {
          CalculatorPage()
        }
        .tabBar(this.buildTabBarItem('计算器', 0, ''))

        TabContent() {
          HistoryPage()
        }
        .tabBar(this.buildTabBarItem('历史', 1, ''))

        TabContent() {
          SettingsPage()
        }
        .tabBar(this.buildTabBarItem('设置', 2, ''))
      }
      .barMode(BarMode.Fixed)
      .barPosition(BarPosition.End)
      .onChange((index: number) => {
        this.currentIndex = index;
        Logger.info(`Tab switched to: ${index}`);
      })
      .layoutWeight(1)
      .vertical(false)
      .scrollable(false)
      .animationDuration(200)
      .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
  }

  /**
   * 构建底部导航栏项
   */
  @Builder buildTabBarItem(title: string, index: number, iconResource: string) {
    Column() {
      // 图标和文字垂直布局
      Column() {
        // 根据不同的标签显示不同的图标（使用Unicode字符）
        if (index === 0) {
          // Calculator - 计算器图标
          Text('⊞')
            .fontSize(22)
            .fontWeight(FontWeight.Normal)
            .fontColor(this.currentIndex === index ? AppTheme.PRIMARY_COLOR : AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
        } else if (index === 1) {
          // History - 时钟图标
          Text('🕐')
            .fontSize(22)
            .fontColor(this.currentIndex === index ? AppTheme.PRIMARY_COLOR : AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
        } else if (index === 2) {
          // Settings - 齿轮图标
          Text('⚙')
            .fontSize(22)
            .fontColor(this.currentIndex === index ? AppTheme.PRIMARY_COLOR : AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
        }
        
        Text(title)
          .fontSize(AppTheme.FONT_SIZE_MINI)
          .fontColor(this.currentIndex === index ? AppTheme.PRIMARY_COLOR : AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
          .margin({ top: AppTheme.SPACING_MINI })
      }
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)
      
      // 底部选中指示器
      Row()
        .width(40)
        .height(3)
        .backgroundColor(this.currentIndex === index ? AppTheme.PRIMARY_COLOR : 'transparent')
        .borderRadius(1.5)
        .margin({ top: 4 })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}