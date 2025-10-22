/**
 * 计算器页面
 * 主要的计算器界面，支持基础和高级数学运算
 */
import { Logger } from '../utils/Logger';
import { ExpressionEngine, EvaluateResult } from '../modules/ExpressionEngine';
import { DataManager } from '../modules/DataManager';

@Entry
@Component
export struct CalculatorPage {
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
  handleButtonClick(value: string) {
    Logger.debug(`Button clicked: ${value}`);

    switch (value) {
      case 'C':
        // 清除
        this.expression = '';
        this.result = '0';
        this.isError = false;
        break;
      
      case 'DEL':
        // 删除最后一个字符
        this.expression = this.expression.slice(0, -1);
        break;
      
      case '=':
        // 计算
        this.calculateResult();
        break;
      
      default:
        // 添加字符
        this.expression += value;
        break;
    }
  }

  /**
   * 计算表达式
   */
  calculateResult() {
    if (!this.expression) {
      return;
    }

    Logger.info(`Calculating: ${this.expression}`);
    
    const evalResult: EvaluateResult = this.engine.evaluate(this.expression);
    
    if (evalResult.success && evalResult.result) {
      this.result = evalResult.result;
      this.isError = false;
      
      // 保存到历史记录
      this.saveToHistory(this.expression, evalResult.result);
      
      // 将结果作为新的表达式（可以继续计算）
      this.expression = evalResult.result;
    } else {
      this.result = evalResult.error || '错误';
      this.isError = true;
    }
  }

  /**
   * 保存到历史记录
   */
  async saveToHistory(expression: string, result: string) {
    try {
      await this.dataManager.saveHistory({
        expression,
        result,
        calc_type: 'basic'
      });
      Logger.info('Saved to history');
    } catch (error) {
      Logger.error('Failed to save history', error);
    }
  }

  build() {
    Column() {
      // 显示区域
      Column() {
        // 表达式显示（计算式子）
        Text(this.expression || '0')
          .fontSize(20)
          .fontColor('#999')
          .width('100%')
          .textAlign(TextAlign.End)
          .margin({ top: 20, bottom: 15 })
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .minHeight(60)
        
        // 结果显示
        Text(this.result)
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isError ? '#ff4d4f' : '#000')
          .width('100%')
          .textAlign(TextAlign.End)
          .margin({ bottom: 10 })
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 20 })
      .height('30%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.End)
      .backgroundColor('#f5f5f5')

      // 按钮区域
      Column() {
        // 第一行：C, DEL, /, *
        this.buildButtonRow(['C', 'DEL', '/', '*']);
        
        // 第二行：7, 8, 9, -
        this.buildButtonRow(['7', '8', '9', '-']);
        
        // 第三行：4, 5, 6, +
        this.buildButtonRow(['4', '5', '6', '+']);
        
        // 第四行：1, 2, 3, =
        this.buildButtonRow(['1', '2', '3', '=']);
        
        // 第五行：0, ., ()
        Row() {
          this.buildButton('0', 2);
          this.buildButton('.');
          this.buildButton('( )');
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .layoutWeight(1)
      .padding(10)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#fff')
  }

  /**
   * 构建按钮行
   */
  @Builder buildButtonRow(buttons: string[]) {
    Row() {
      ForEach(buttons, (button: string) => {
        this.buildButton(button);
      }, (button: string) => button)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 10 })
  }

  /**
   * 构建单个按钮
   */
  @Builder buildButton(label: string, flex: number = 1) {
    Button(label)
      .fontSize(24)
      .fontWeight(FontWeight.Medium)
      .backgroundColor(this.getButtonColor(label))
      .fontColor(this.getButtonTextColor(label))
      .borderRadius(12)
      .layoutWeight(flex)
      .height(70)
      .margin({ left: 5, right: 5 })
      .onClick(() => {
        if (label === '( )') {
          // 智能括号
          this.handleButtonClick(this.expression.split('(').length > this.expression.split(')').length ? ')' : '(');
        } else {
          this.handleButtonClick(label);
        }
      })
  }

  /**
   * 获取按钮背景色
   */
  getButtonColor(label: string): string {
    if (label === 'C' || label === 'DEL') {
      return '#ff4d4f';
    } else if (['+', '-', '*', '/', '='].includes(label)) {
      return '#1890ff';
    } else {
      return '#e8e8e8';
    }
  }

  /**
   * 获取按钮文字颜色
   */
  getButtonTextColor(label: string): string {
    if (label === 'C' || label === 'DEL' || ['+', '-', '*', '/', '='].includes(label)) {
      return '#fff';
    } else {
      return '#000';
    }
  }
}

