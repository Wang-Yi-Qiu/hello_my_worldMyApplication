/**
 * 通用圆形/胶囊按键组件（苹果计算器风格）
 * - 自适应正方形：通过 aspectRatio(1) 保证宽高一致
 * - 圆角：borderRadius(height/2)
 * - 支持三种类型：number/operator/function
 */
import { TextEmit, TextEmitEvent } from '../models/Events'

@Component
export struct CalcKey {
  /** 按键显示文本（或图标） */
  @Prop text: string = ''
  /** 类型：影响配色 */
  @Prop type: 'number' | 'operator' | 'function' | 'accent' = 'number'
  /** 是否加宽（如 0 键） */
  @Prop wide: boolean = false
  /** 点击回调 */
  @Prop onTap: TextEmitEvent = new TextEmit()

  private getBg(): string {
    switch (this.type) {
      case 'operator':
      case 'accent':
        return '#FF9500' // 苹果橙色
      case 'function':
        return '#A5A5A5' // 功能灰
      default:
        return '#333333' // 数字深灰（适配浅色背景时请在父级控制）
    }
  }

  private getFg(): string {
    return this.type === 'number' ? '#FFFFFF' : '#FFFFFF'
  }

  build() {
    // 使用容器包裹：通过宽度百分比 + aspectRatio 实现等宽高圆形
    Row() {
      Text(this.text)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getFg())
        .textAlign(TextAlign.Center)
        .width('100%')
    }
    .width(this.wide ? '48.5%' : '23%')
    .aspectRatio(this.wide ? 2 : 1) // 0 键为胶囊形状
    .borderRadius(9999)
    .backgroundColor(this.getBg())
    .justifyContent(FlexAlign.Center)
    .onClick(() => { if (this.onTap && this.onTap.emit) { this.onTap.emit(this.text) } })
  }
}


