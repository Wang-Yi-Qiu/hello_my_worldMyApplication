/**
 * 应用入口页面 - Index
 * 作为应用的启动页面，可以显示欢迎界面或直接跳转到主页面
 */
import { AppTheme } from '../utils/AppTheme';
import { Logger } from '../utils/Logger';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @StorageLink('currentTheme') currentTheme: string = 'light';

  aboutToAppear() {
    Logger.info('Index page loaded');
    // 可以在这里添加欢迎页面的逻辑
    // 比如显示应用logo、加载动画等
  }

  build() {
    Column() {
      // 应用标题
      Text('智能计算器')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
        .margin({ bottom: 20 })

      // 应用描述
      Text('支持数学计算、微积分、方程求解等功能')
        .fontSize(16)
        .fontColor(AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
        .textAlign(TextAlign.Center)
        .margin({ bottom: 40 })

      // 进入应用按钮
      Button('开始使用')
        .fontSize(18)
        .fontColor(Color.White)
        .backgroundColor(AppTheme.PRIMARY_COLOR)
        .borderRadius(25)
        .width(200)
        .height(50)
        .onClick(() => {
          Logger.info('Navigate to MainPage');
          // 跳转到主页面
          try {
            router.pushUrl({
              url: 'pages/MainPage'
            });
            Logger.info('Successfully navigated to MainPage');
          } catch (err) {
            Logger.error('Failed to navigate to MainPage', err);
          }
        })

      // 版本信息
      Text('v1.0.0')
        .fontSize(12)
        .fontColor(AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
        .margin({ top: 60 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
  }
}
