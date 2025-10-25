/**
 * 欢迎页面
 * 应用启动时显示，用于初始化和品牌展示
 */
import { Logger } from '../utils/Logger';
import { APP_NAME, APP_VERSION } from '../utils/Constants';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State message: string = `欢迎使用 ${APP_NAME}`;
  @State version: string = `版本 ${APP_VERSION}`;
  @State isLoading: boolean = true;

  aboutToAppear() {
    Logger.info('Welcome page loaded');
    
    // 模拟初始化过程
    setTimeout(() => {
      this.isLoading = false;
      Logger.info('Initialization complete');
      
      // 2秒后自动跳转到主页面（如果存在）
      setTimeout(() => {
        try {
          router.pushUrl({
            url: 'pages/MainPage'
          }, router.RouterMode.Standard);
        } catch (err) {
          Logger.warn('MainPage not available yet, staying on welcome page');
        }
      }, 2000);
    }, 1000);
  }

  build() {
    Column() {
      // Logo 区域
      Column() {
        Text('🧮')
          .fontSize(80)
          .margin({ bottom: 20 })
        
        Text(this.message)
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1890ff')
          .margin({ bottom: 10 })
        
        Text(this.version)
          .fontSize(16)
          .fontColor('#666')
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)

      // 加载指示器
      if (this.isLoading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .color('#1890ff')
          .margin({ bottom: 20 })
        
        Text('正在初始化...')
          .fontSize(14)
          .fontColor('#999')
      } else {
        Text('✓ 初始化完成')
          .fontSize(14)
          .fontColor('#52c41a')
      }

      // 底部信息
      Column() {
        Text('HarmonyOS 原生应用')
          .fontSize(12)
          .fontColor('#999')
          .margin({ bottom: 5 })
        
        Text('© 2025 SmartCalc Team')
          .fontSize(12)
          .fontColor('#999')
      }
      .margin({ bottom: 30 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f5f5f5')
    .padding(20)
  }
}
