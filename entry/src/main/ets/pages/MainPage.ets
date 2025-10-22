/**
 * 主页面
 * 包含 TabBar 导航的主界面
 */
import { Logger } from '../utils/Logger';
import { CalculatorPage } from './CalculatorPage';
import { HistoryPage } from './HistoryPage';
import { AdvancedMathPage } from './AdvancedMathPage';
import { GraphPage } from './GraphPage';
import { SettingsPage } from './SettingsPage';

@Entry
@Component
struct MainPage {
  @State currentIndex: number = 0;

  aboutToAppear() {
    Logger.info('MainPage loaded');
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('智能计算器')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000')
      }
      .width('100%')
      .height(56)
      .padding({ left: 20, right: 20 })
      .backgroundColor('#fff')
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
    .backgroundColor('#f5f5f5')
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

