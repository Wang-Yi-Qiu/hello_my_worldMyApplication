import { CalcKey } from '../components/CalcKey'
import { TextEmit, TextEmitEvent, VoidEmit, VoidEmitEvent } from '../models/Events'

/**
 * BasicCalculatorPage
 * - 模仿苹果基础计算器：四列数字区，右侧运算列，顶部功能行
 * - 使用百分比 + aspectRatio 实现圆形/胶囊自适应
 */
@Component
export struct BasicCalculatorPage {
  @Prop onPress: TextEmitEvent = new TextEmit()
  @Prop onToggle: VoidEmitEvent = new VoidEmit()

  @Builder renderKey(text: string, type: 'number' | 'operator' | 'function' | 'accent' = 'number', wide: boolean = false) {
    CalcKey({ text, type, wide, onTap: new TextEmit((t: string) => { if (this.onPress && this.onPress.emit) { this.onPress.emit(t) } }) })
      .margin({ bottom: 10 })
  }

  build() {
    Column() {
      // 顶部功能行：删除、清空、百分比、除
      Row() {
        this.renderKey('⌫', 'function')
        this.renderKey('AC', 'function')
        this.renderKey('%', 'function')
        this.renderKey('÷', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 2 })

      // 第二行：7 8 9 ×
      Row() {
        this.renderKey('7')
        this.renderKey('8')
        this.renderKey('9')
        this.renderKey('×', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 第三行：4 5 6 -
      Row() {
        this.renderKey('4')
        this.renderKey('5')
        this.renderKey('6')
        this.renderKey('-', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 第四行：1 2 3 +
      Row() {
        this.renderKey('1')
        this.renderKey('2')
        this.renderKey('3')
        this.renderKey('+', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      // 第五行：+/− 0 . =
      Row() {
        // 左下角是“+/−”位置，苹果为切换正负；此处用“±”
        this.renderKey('±', 'function')
        this.renderKey('0', 'number', true)
        this.renderKey('.', 'number')
        this.renderKey('=', 'accent')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding({ left: 12, right: 12, bottom: 12 })
  }
}


