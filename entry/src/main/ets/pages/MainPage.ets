/**
 * 主页面
 * 包含 TabBar 导航的主界面
 */
import { Logger } from '../utils/Logger';
import { ThemeManager } from '../utils/ThemeManager';
import { CalculatorPage } from './CalculatorPage';
import { HistoryPage } from './HistoryPage';
import { AdvancedMathPage } from './AdvancedMathPage';
import { GraphPage } from './GraphPage';
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
      // 标题栏
      Row() {
        Text('智能计算器')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.currentTheme === 'dark' ? '#fff' : '#000')
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor(this.currentTheme === 'dark' ? '#1f1f1f' : '#fff')
      .justifyContent(FlexAlign.Start)

      // 内容区域
      Tabs({ index: this.currentIndex }) {
        TabContent() {
          CalculatorPage()
        }
        .tabBar('计算器')

        TabContent() {
          GraphPage()
        }
        .tabBar('图像')

        TabContent() {
          AdvancedMathPage()
        }
        .tabBar('高数')

        TabContent() {
          HistoryPage()
        }
        .tabBar('历史')

        TabContent() {
          SettingsPage()
        }
        .tabBar('设置')
      }
      .barMode(BarMode.Fixed)
      .barPosition(BarPosition.End)
      .onChange((index: number) => {
        this.currentIndex = index;
        Logger.info(`Tab switched to: ${index}`);
      })
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.currentTheme === 'dark' ? '#141414' : '#f5f5f5')
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

