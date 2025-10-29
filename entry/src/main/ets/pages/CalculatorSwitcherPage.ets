import { BasicCalculatorPage } from './BasicCalculatorPage'
import { ScientificCalculatorPage } from './ScientificCalculatorPage'
import { TextEmit, VoidEmit } from '../models/Events'
import display from '@ohos.display'

/**
 * CalculatorSwitcherPage
 * - 使用 @State 管理模式（基础/科学）
 * - 封装 toggle() 方法：按钮点击或方向变化时切换
 * - 仅负责界面装配与切换，不处理计算逻辑
 */
@Component
export struct CalculatorSwitcherPage {
  @State private scientific: boolean = false

  /** 对外暴露：切换基础/科学 */
  toggle(): void {
    this.scientific = !this.scientific
  }

  private isLandscape(): boolean {
    const disp = display.getDefaultDisplaySync()
    const dw = px2vp(disp.width)
    const dh = px2vp(disp.height)
    return dw > dh
  }

  aboutToAppear() {
    // 初次根据方向决定是否进入科学模式
    this.scientific = this.isLandscape()
  }

  build() {
    Column() {
      // 顶部切换按钮
      Row() {
        Button(this.scientific ? '基础' : '科学')
          .backgroundColor('#3A3A3C')
          .fontColor('#FFFFFF')
          .borderRadius(16)
          .padding({ left: 12, right: 12 })
          .height(32)
          .onClick(() => this.toggle())
      }
      .width('100%')
      .height(44)
      .justifyContent(FlexAlign.End)
      .padding({ left: 12, right: 12, top: 8, bottom: 4 })

      // 主体：根据状态渲染不同页面
      if (this.scientific) {
        ScientificCalculatorPage({ onPress: new TextEmit((t: string) => AppStorage.setOrCreate('key_press', t)) })
      } else {
        BasicCalculatorPage({ 
          onPress: new TextEmit((t: string) => AppStorage.setOrCreate('key_press', t)),
          onToggle: new VoidEmit((): void => this.toggle())
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}


