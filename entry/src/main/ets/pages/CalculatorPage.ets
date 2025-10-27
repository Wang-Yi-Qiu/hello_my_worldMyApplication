/**
 * 计算器页面 - 简化版
 * 只支持基础计算功能
 */
import { AppTheme } from '../utils/AppTheme';
import { Logger } from '../utils/Logger';
import { ExpressionEngine, EvaluateResult } from '../modules/ExpressionEngine';
import { DataManager } from '../modules/DataManager';
import { promptAction } from '@kit.ArkUI';

@Component
export struct CalculatorPage {
  @StorageLink('currentTheme') currentTheme: string = 'light';
  @State expression: string = '';
  @State result: string = '0';
  @State isError: boolean = false;
  private engine: ExpressionEngine = new ExpressionEngine();
  private dataManager: DataManager = new DataManager();

  aboutToAppear() {
    Logger.info('CalculatorPage loaded');
  }

  /**
   * 处理按钮点击
   */
  private handleButtonClick(value: string) {
    try {
      if (value === '=') {
        this.calculate();
      } else if (value === 'C') {
        this.clear();
      } else if (value === '⌫') {
        this.backspace();
      } else {
        this.appendToExpression(value);
      }
    } catch (error) {
      Logger.error('Button click error:', error);
    }
  }

  /**
   * 添加到表达式
   */
  private appendToExpression(value: string) {
    if (this.isError) {
      this.clear();
    }
    this.expression += value;
  }

  /**
   * 计算表达式
   */
  private async calculate() {
    try {
      if (!this.expression.trim()) {
        return;
      }

      Logger.info(`Calculating: ${this.expression}`);
      
      const result: EvaluateResult = this.engine.evaluate(this.expression);
      
      if (result.success) {
        this.result = result.result;
        this.isError = false;
        
        // 保存到历史记录
        await this.dataManager.addHistoryRecord({
          expression: this.expression,
          result: this.result,
          timestamp: new Date().getTime()
        });
        
        this.expression = '';
      } else {
        this.result = 'Error';
        this.isError = true;
        Logger.error('Calculation error:', result.error);
      }
    } catch (error) {
      this.result = 'Error';
      this.isError = true;
      Logger.error('Calculation error:', error);
    }
  }

  /**
   * 清空
   */
  private clear() {
    this.expression = '';
    this.result = '0';
    this.isError = false;
  }

  /**
   * 退格
   */
  private backspace() {
    if (this.expression.length > 0) {
      this.expression = this.expression.slice(0, -1);
    }
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text('计算器')
          .fontSize(AppTheme.FONT_SIZE_LARGE)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
      }
      .width('100%')
      .height(56)
      .padding({ left: AppTheme.SPACING_LARGE })
      .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
      .justifyContent(FlexAlign.Start)

      // 计算器主体
      Column() {
        // 显示屏
        this.buildDisplay()
        
        // 按钮区域
        this.buildButtonGrid()
      }
      .layoutWeight(1)
      .padding(AppTheme.SPACING_MEDIUM)
      .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
  }

  /**
   * 构建显示屏
   */
  @Builder buildDisplay() {
    Column() {
      // 表达式显示
      Text(this.expression || '0')
        .fontSize(AppTheme.FONT_SIZE_MEDIUM)
        .fontColor(AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
        .width('100%')
        .textAlign(TextAlign.End)
        .padding({ bottom: AppTheme.SPACING_MINI })
      
      // 结果显示
      Text(this.result)
        .fontSize(AppTheme.FONT_SIZE_EXTRA_LARGE)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isError ? '#F44336' : AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
        .width('100%')
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding(AppTheme.SPACING_LARGE)
    .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
    .borderRadius(AppTheme.BORDER_RADIUS_MEDIUM)
    .margin({ bottom: AppTheme.SPACING_LARGE })
  }

  /**
   * 构建按钮网格
   */
  @Builder buildButtonGrid() {
    Column() {
      // 第一行：C, ⌫, ÷
      Row() {
        this.buildButton('C', 'function')
        this.buildButton('⌫', 'function')
        this.buildButton('÷', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: AppTheme.SPACING_MINI })

      // 第二行：7, 8, 9, ×
      Row() {
        this.buildButton('7', 'number')
        this.buildButton('8', 'number')
        this.buildButton('9', 'number')
        this.buildButton('×', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: AppTheme.SPACING_MINI })

      // 第三行：4, 5, 6, -
      Row() {
        this.buildButton('4', 'number')
        this.buildButton('5', 'number')
        this.buildButton('6', 'number')
        this.buildButton('-', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: AppTheme.SPACING_MINI })

      // 第四行：1, 2, 3, +
      Row() {
        this.buildButton('1', 'number')
        this.buildButton('2', 'number')
        this.buildButton('3', 'number')
        this.buildButton('+', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: AppTheme.SPACING_MINI })

      // 第五行：0, ., =
      Row() {
        this.buildButton('0', 'number')
        this.buildButton('.', 'number')
        this.buildButton('=', 'equals')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
  }

  /**
   * 构建按钮
   */
  @Builder buildButton(text: string, type: string) {
    Button(text)
      .fontSize(AppTheme.FONT_SIZE_LARGE)
      .fontWeight(FontWeight.Medium)
      .width(80)
      .height(80)
      .borderRadius(40)
      .backgroundColor(this.getButtonColor(type))
      .fontColor(this.getButtonTextColor(type))
      .onClick(() => {
        this.handleButtonClick(text);
      })
  }

  /**
   * 获取按钮颜色
   */
  private getButtonColor(type: string): string {
    switch (type) {
      case 'number':
        return AppTheme.getCardBackground(this.currentTheme === 'dark');
      case 'operator':
        return AppTheme.PRIMARY_COLOR;
      case 'function':
        return '#FF9800';
      case 'equals':
        return AppTheme.PRIMARY_COLOR;
      default:
        return AppTheme.getCardBackground(this.currentTheme === 'dark');
    }
  }

  /**
   * 获取按钮文字颜色
   */
  private getButtonTextColor(type: string): string {
    switch (type) {
      case 'number':
        return AppTheme.getPrimaryTextColor(this.currentTheme === 'dark');
      case 'operator':
      case 'function':
      case 'equals':
        return '#FFFFFF';
      default:
        return AppTheme.getPrimaryTextColor(this.currentTheme === 'dark');
    }
  }
}