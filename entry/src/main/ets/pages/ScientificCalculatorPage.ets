import { CalcKey } from '../components/CalcKey'
import { TextEmit, TextEmitEvent } from '../models/Events'
import display from '@ohos.display'

/**
 * ScientificCalculatorPage
 * - 纵向：在基础键盘上方增加三行科学键
 * - 横向：网格更密集，显示更多科学功能
 */
@Component
export struct ScientificCalculatorPage {
  @Prop onPress: TextEmitEvent = new TextEmit()

  @Builder renderKey(text: string, type: 'number' | 'operator' | 'function' | 'accent' = 'number', wide: boolean = false) {
    CalcKey({ text, type, wide, onTap: new TextEmit((t: string) => { if (this.onPress && this.onPress.emit) { this.onPress.emit(t) } }) })
      .margin({ bottom: 10 })
  }

  /** 简易的方向判断：根据宽高决定布局 */
  private isLandscape(): boolean {
    const disp = display.getDefaultDisplaySync()
    const dw = px2vp(disp.width)
    const dh = px2vp(disp.height)
    return dw > dh
  }

  @Builder scientificRowsPortrait() {
    Column() {
      Row() {
        this.renderKey('(', 'function')
        this.renderKey(')', 'function')
        this.renderKey('mc', 'function')
        this.renderKey('m+', 'function')
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      Row() {
        this.renderKey('sin', 'function')
        this.renderKey('cos', 'function')
        this.renderKey('tan', 'function')
        this.renderKey('π', 'function')
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      Row() {
        this.renderKey('x²', 'function')
        this.renderKey('√x', 'function')
        this.renderKey('ln', 'function')
        this.renderKey('lg', 'function')
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    }
  }

  @Builder scientificGridLandscape() {
    // 横屏：5 列科学键
    Column() {
      Row() {
        this.renderKey('(', 'function')
        this.renderKey(')', 'function')
        this.renderKey('mc', 'function')
        this.renderKey('m+', 'function')
        this.renderKey('m-', 'function')
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      Row() {
        this.renderKey('2nd', 'function')
        this.renderKey('x²', 'function')
        this.renderKey('x³', 'function')
        this.renderKey('xʸ', 'function')
        this.renderKey('eˣ', 'function')
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      Row() {
        this.renderKey('1/x', 'function')
        this.renderKey('²√x', 'function')
        this.renderKey('³√x', 'function')
        this.renderKey('ʸ√x', 'function')
        this.renderKey('10ˣ', 'function')
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      Row() {
        this.renderKey('x!', 'function')
        this.renderKey('sin', 'function')
        this.renderKey('cos', 'function')
        this.renderKey('tan', 'function')
        this.renderKey('e', 'function')
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)

      Row() {
        this.renderKey('sinh', 'function')
        this.renderKey('cosh', 'function')
        this.renderKey('tanh', 'function')
        this.renderKey('π', 'function')
        this.renderKey('Rad', 'function')
      }.width('100%').justifyContent(FlexAlign.SpaceBetween)
    }
  }

  build() {
    Column() {
      // 科学键区域
      if (this.isLandscape()) {
        this.scientificGridLandscape()
      } else {
        this.scientificRowsPortrait()
      }
    }
    .width('100%')
    .padding({ left: 12, right: 12, bottom: 8 })
  }
}


