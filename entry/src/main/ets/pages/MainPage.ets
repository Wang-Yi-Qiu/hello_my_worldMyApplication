/**
 * 主页面
 * 包含 TabBar 导航的主界面
 */
import { AppTheme } from '../utils/AppTheme';
import { Logger } from '../utils/Logger';
import { ThemeManager } from '../utils/ThemeManager';
import { CalculatorPage } from './CalculatorPage';
import { HistoryPage } from './HistoryPage';
import { AdvancedMathPage } from './AdvancedMathPage';
import { GraphPage } from './GraphPage';
import { ImageOCRPage } from './ImageOCRPage';
import { SettingsPage } from './SettingsPage';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

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
        .tabBar(this.buildTabBarItem('Calculator', 0, 'app.media.startIcon'))

        TabContent() {
          HistoryPage()
        }
        .tabBar(this.buildTabBarItem('History', 1, ''))

        TabContent() {
          AdvancedMathPage()
        }
        .tabBar(this.buildTabBarItem('Converter', 2, ''))

        TabContent() {
          this.buildToolsPage()
        }
        .tabBar(this.buildTabBarItem('Tools', 3, ''))

        TabContent() {
          SettingsPage()
        }
        .tabBar(this.buildTabBarItem('Settings', 4, ''))
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
          // Converter - 转换图标
          Text('⇄')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.currentIndex === index ? AppTheme.PRIMARY_COLOR : AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
        } else if (index === 3) {
          // Tools - 工具图标
          Text('🔧')
            .fontSize(22)
            .fontColor(this.currentIndex === index ? AppTheme.PRIMARY_COLOR : AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
        } else if (index === 4) {
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

  /**
   * Tools 页面
   */
  @Builder buildToolsPage() {
    Column() {
      // 标题
      Row() {
        Text('工具')
          .fontSize(AppTheme.FONT_SIZE_LARGE)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
      }
      .width('100%')
      .height(56)
      .padding({ left: AppTheme.SPACING_LARGE })
      .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
      .justifyContent(FlexAlign.Start)

      Scroll() {
        Column() {
          // 图像识别工具卡片
          this.buildToolCard(
            '图像识别',
            '拍照或上传图片识别数学公式',
            '📷',
            () => {
              router.pushUrl({
                url: 'pages/ImageOCRPage'
              }).catch((err: BusinessError) => {
                Logger.error('Failed to navigate to ImageOCRPage', err);
              });
            }
          );

          // 单位转换工具卡片
          this.buildToolCard(
            '单位转换',
            '长度、重量、温度等单位转换',
            '🔄',
            () => {
              router.pushUrl({
                url: 'pages/UnitConversionPage'
              }).catch((err: BusinessError) => {
                Logger.error('Failed to navigate to UnitConversionPage', err);
              });
            }
          );
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16 })
      }
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  /**
   * 工具卡片
   */
  @Builder buildToolCard(title: string, description: string, icon: string, onClick: () => void) {
    Column() {
      Row() {
        // 图标
        Text(icon)
          .fontSize(40)
          .margin({ right: AppTheme.SPACING_MEDIUM })

        // 文字信息
        Column() {
          Text(title)
            .fontSize(AppTheme.FONT_SIZE_SUBTITLE)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
            .width('100%')
            .margin({ bottom: AppTheme.SPACING_MINI })

          Text(description)
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .fontColor(AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
            .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 箭头
        Text('›')
          .fontSize(AppTheme.FONT_SIZE_LARGE)
          .fontColor(AppTheme.TEXT_DISABLED)
      }
      .width('100%')
      .padding(AppTheme.SPACING_MEDIUM)
    }
    .width('100%')
    .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
    .borderRadius(AppTheme.BORDER_RADIUS_MEDIUM)
    .margin({ bottom: AppTheme.SPACING_NORMAL })
    .onClick(onClick)
  }

  /**
   * 占位符页面
   */
  @Builder buildPlaceholder(title: string) {
    Column() {
      Text(`${title}功能`)
        .fontSize(24)
        .fontColor('#999')
      
      Text('开发中...')
        .fontSize(16)
        .fontColor('#ccc')
        .margin({ top: 10 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#fff')
  }
}

