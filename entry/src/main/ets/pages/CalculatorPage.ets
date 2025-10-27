/**
 * 计算器页面 - 简化版
 * 只支持基础计算功能
 */
import { AppTheme } from '../utils/AppTheme';
import { Logger } from '../utils/Logger';
import { ExpressionEngine, EvaluateResult } from '../modules/ExpressionEngine';
import { DataManager } from '../modules/DataManager';
import { HistoryRecord, EmotionFeedback } from '../models/HistoryRecord';
import { PerformanceMonitor } from '../utils/PerformanceMonitor';
import { ErrorHandler } from '../utils/ErrorHandler';
import { EmotionFeedbackManager } from '../modules/EmotionFeedbackManager';

@Component
export struct CalculatorPage {
  @StorageLink('currentTheme') currentTheme: string = 'light';
  @StorageLink('expressionFromHistory') expressionFromHistory: string = '';
  @StorageLink('enableEmotionFeedback') enableEmotionFeedback: boolean = true;
  @StorageLink('enableFortuneText') enableFortuneText: boolean = true;
  @StorageLink('enableEasterEgg') enableEasterEgg: boolean = true;
  @State expression: string = '';
  @State result: string = '0';
  @State isError: boolean = false;
  @State emotionFeedback: EmotionFeedback | null = null;
  @State fortuneText: string = '';
  @State showEasterEgg: boolean = false;
  @State easterEggMessage: string = '';
  @State fortuneOpacity: number = 0;
  @State showScientificButtons: boolean = false;
  @StorageLink('needRefreshHistory') needRefreshHistory: boolean = false;
  
  private engine: ExpressionEngine = new ExpressionEngine();
  private dataManager: DataManager = new DataManager();
  private performanceMonitor: PerformanceMonitor = PerformanceMonitor.getInstance();
  private errorHandler: ErrorHandler = ErrorHandler.getInstance();
  private emotionManager: EmotionFeedbackManager = EmotionFeedbackManager.getInstance();

  async aboutToAppear() {
    Logger.info('CalculatorPage loaded');
    try {
      // WebView 计算器暂时禁用，使用内置 AST 引擎
      // await this.engine.initialize(context);
      Logger.info('ExpressionEngine initialized with AST only');
    } catch (error) {
      this.errorHandler.handleError(error as Error, {
        component: 'CalculatorPage',
        action: 'aboutToAppear',
        timestamp: Date.now()
      });
    }
    
    // 监听历史记录回溯（通过@StorageLink装饰器自动处理）
    this.watchHistoryChanges();
  }

  private watchHistoryChanges(): void {
    // 使用正则检查变化
    setTimeout(() => {
      const value = this.expressionFromHistory;
      if (value && value.trim() !== '') {
        Logger.info(`Expression from history: ${value}`);
        this.expression = value;
        // 清空历史回溯标记
        AppStorage.setOrCreate('expressionFromHistory', '');
      }
    }, 100);
  }

  /**
   * 处理按钮点击
   */
  private handleButtonClick(value: string) {
    try {
      Logger.info(`Button clicked: ${value}`);
      if (value === '=') {
        this.calculate();
      } else if (value === 'C') {
        this.clear();
      } else if (value === '⌫') {
        this.backspace();
      } else {
        // 转换显示符号为计算符号
        const convertedValue = this.convertDisplaySymbol(value);
        Logger.info(`Converted ${value} to ${convertedValue}`);
        this.appendToExpression(convertedValue);
      }
    } catch (error) {
      Logger.error('Button click error:', error);
    }
  }

  /**
   * 转换显示符号为计算符号
   */
  private convertDisplaySymbol(value: string): string {
    switch (value) {
      case '×': return '*';
      case '÷': return '/';
      case '√': return 'sqrt(';
      case 'π': return 'pi';
      case 'e': return 'e';
      case 'sin': return 'sin(';
      case 'cos': return 'cos(';
      case 'tan': return 'tan(';
      case 'log': return 'log(';
      case 'ln': return 'ln(';
      case '^': return '^';
      case '(': return '(';
      case ')': return ')';
      case '!': return '!';
      default: return value;
    }
  }

  /**
   * 添加到表达式
   */
  private appendToExpression(value: string) {
    if (this.isError) {
      this.clear();
    }
    // 如果表达式只包含数字（可能来自上次计算的结果），且输入的是运算符，则追加
    // 如果输入的是数字，且表达式也是数字，则替换（开始新计算）
    const isNumber = /^\d+\.?\d*$/.test(this.expression);
    const isOperator = /[+\-*\/]/.test(value);
    const isFunctionOrConstant = /(sin|cos|tan|log|ln|sqrt|pi|e|\(|\))/i.test(value);
    
    if (isNumber && !isOperator && !isFunctionOrConstant) {
      // 输入新数字时，替换旧表达式
      this.expression = value;
    } else {
      // 输入运算符、科学计算函数或其他符号时，追加
      this.expression += value;
    }
  }

  /**
   * 计算表达式
   */
  private async calculate() {
    const timerId = this.performanceMonitor.startTimer('calculation');
    
    try {
      if (!this.expression.trim()) {
        return;
      }

      Logger.info(`Calculating: ${this.expression}`);
      
      // 保存原始表达式，用于历史记录
      const originalExpression = this.expression;
      
      const result: EvaluateResult = await this.engine.evaluate(this.expression);
      
      if (result.success && result.result) {
        this.result = result.result;
        this.isError = false;
        
        // 只在启用时才检查彩蛋
        if (this.enableEasterEgg) {
          this.checkEasterEgg(parseFloat(this.result));
        }
        
        // 只在启用时才生成情绪反馈
        if (this.enableEmotionFeedback) {
          this.generateEmotionFeedback(parseFloat(this.result));
        }
        
        // 只在启用时才生成幸运提示
        if (this.enableFortuneText) {
          this.generateFortuneText(parseFloat(this.result));
        }
        
        // 将原始表达式设置回去，用于保存历史记录
        const tempExpression = this.expression;
        
        // 将结果设置为新的表达式，支持连续运算
        this.expression = this.result;
        
        // 保存到历史记录（使用原始表达式）
        await this.saveHistoryRecordWithExpression(originalExpression, this.result);
      } else {
        this.result = 'Error';
        this.isError = true;
        Logger.error('Calculation error:', result.error);
      }
    } catch (error) {
      this.result = 'Error';
      this.isError = true;
      this.errorHandler.handleError(error as Error, {
        component: 'CalculatorPage',
        action: 'calculate',
        timestamp: Date.now()
      });
      Logger.error('Calculation error:', error);
    } finally {
      this.performanceMonitor.endTimer(timerId);
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

  /**
   * 检查彩蛋
   */
  private checkEasterEgg(result: number) {
    const easterEggValues = [1314, 666, 888, 520, 100, 1000, 999, 88, 77, 99];
    
    // 检查特殊数字
    if (easterEggValues.includes(Math.round(result))) {
      this.showEasterEgg = true;
      this.easterEggMessage = this.getEasterEggMessage(Math.round(result));
      
      // 3秒后隐藏彩蛋
      setTimeout(() => {
        this.showEasterEgg = false;
      }, 3000);
    }
    
    // 检查数学常数
    if (Math.abs(result - Math.PI) < 0.0001) {
      this.showEasterEgg = true;
      this.easterEggMessage = '🥧 π！圆周率！';
      
      setTimeout(() => {
        this.showEasterEgg = false;
      }, 3000);
    } else if (Math.abs(result - Math.E) < 0.0001) {
      this.showEasterEgg = true;
      this.easterEggMessage = '📐 e！自然常数！';
      
      setTimeout(() => {
        this.showEasterEgg = false;
      }, 3000);
    }
  }

  /**
   * 获取彩蛋消息
   */
  private getEasterEggMessage(value: number): string {
    switch (value) {
      case 1314:
        return '💕 一生一世！';
      case 666:
        return '😈 恶魔数字！';
      case 888:
        return '💰 发发发！';
      case 520:
        return '💖 我爱你！';
      case 100:
        return '💯 满分！';
      case 1000:
        return '🎯 千里之行始于足下！';
      case 999:
        return '✨ 九九归一！';
      case 88:
        return '🎊 发发发！';
      case 77:
        return '🎉 77！';
      case 99:
        return '📈 久久归一！';
      default:
        return '🎉 恭喜！';
    }
  }

  /**
   * 生成情绪反馈
   */
  private generateEmotionFeedback(result: number) {
    this.emotionFeedback = this.emotionManager.generateFeedback(result);
  }

  /**
   * 生成幸运提示（基于智能规则匹配）
   */
  private generateFortuneText(result: number) {
    const num = Math.abs(Math.floor(result));
    
    // 基于结果特征生成不同类型的提示
    if (num % 2 === 0) {
      // 偶数代表平稳
      this.fortuneText = '偶数代表平稳的一天 🕊️';
    } else if (num % 5 === 0) {
      // 5的倍数代表好运
      this.fortuneText = '好运正在靠近 💫';
    } else if (num % 3 === 0) {
      // 3的倍数代表创造力
      this.fortuneText = '今天请相信直觉 💡';
    } else {
      // 使用模运算匹配默认提示列表
      const fortunes = [
        '今天的你超幸运 ✨',
        '注意财务，别乱花钱 💰',
        '爱情要靠主动 ❤️',
        '学习好运连连 📚',
        '努力的人最幸运 💪',
        '放松一下也没关系 🌿',
        '不要被小挫折击倒 🌈',
        '保持积极心态 ☀️'
      ];
      
      const index = num % fortunes.length;
      this.fortuneText = fortunes[index];
    }
    
    // 触发动画效果
    this.fortuneOpacity = 0;
    setTimeout(() => {
      this.fortuneOpacity = 1;
    }, 100);
  }

  /**
   * 使用指定表达式保存历史记录
   */
  private async saveHistoryRecordWithExpression(expression: string, result: string) {
    try {
      const historyRecord: HistoryRecord = {
        id: Date.now().toString(),
        expression: expression,
        result: parseFloat(result),
        timestamp: Date.now(),
        emotion: this.emotionFeedback || {
          id: 'default',
          condition: 'default',
          text: '',
          emoji: '',
          priority: 100,
          isEnabled: true
        },
        fortune: this.fortuneText,
        isEasterEgg: this.showEasterEgg
      };
      
      const saveResult = await this.dataManager.saveHistory(historyRecord);
      if (saveResult.success) {
        Logger.info(`History record saved: ${expression} = ${result}`);
        // 通知历史页面需要刷新
        AppStorage.setOrCreate('needRefreshHistory', true);
      } else {
        Logger.error(`Failed to save history: ${saveResult.error}`);
      }
    } catch (error) {
      this.errorHandler.handleError(error as Error, {
        component: 'CalculatorPage',
        action: 'saveHistoryRecordWithExpression',
        timestamp: Date.now()
      });
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
        
        // 科学计算按钮区域（可切换显示）
        if (this.showScientificButtons) {
          this.buildScientificButtonRow()
        }
        
        // 按钮区域
        this.buildButtonGrid()
      }
      .layoutWeight(1)
      .padding({ left: AppTheme.SPACING_MEDIUM, right: AppTheme.SPACING_MEDIUM, top: AppTheme.SPACING_MEDIUM, bottom: 72 })
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
      
      // 结果显示（带动画效果）
      Text(this.result)
        .fontSize(AppTheme.FONT_SIZE_LARGE)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isError ? '#F44336' : AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
        .width('100%')
        .textAlign(TextAlign.End)
        .padding({ bottom: AppTheme.SPACING_MINI })
        .animation({
          duration: 300,
          curve: Curve.EaseOut
        })
        .transition(TransitionEffect.OPACITY.animation({ duration: 300 }))
      
      // 情绪反馈显示（带动画效果，只在启用时显示）
      if (this.enableEmotionFeedback && this.emotionFeedback && this.emotionFeedback.text) {
        Row() {
          Text(this.emotionFeedback.emoji)
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .margin({ right: AppTheme.SPACING_MINI })
            .animation({
              duration: 500,
              curve: Curve.EaseOut,
              iterations: 3,
              playMode: PlayMode.Alternate
            })
          
          Text(this.emotionFeedback.text)
            .fontSize(AppTheme.FONT_SIZE_SMALL)
            .fontColor(AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ bottom: AppTheme.SPACING_MINI })
        .transition(TransitionEffect.OPACITY.animation({ duration: 400 }))
      }
      
      // 幸运提示显示（带动画效果，只在启用时显示）
      if (this.enableFortuneText && this.fortuneText) {
        Text(this.fortuneText)
          .fontSize(AppTheme.FONT_SIZE_SMALL)
          .fontColor('#FF9800')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ bottom: AppTheme.SPACING_MINI })
          .opacity(this.fortuneOpacity)
          .animation({
            duration: 500,
            curve: Curve.EaseOut
          })
      }
      
      // 彩蛋显示（只在启用时显示）
      if (this.enableEasterEgg && this.showEasterEgg) {
        Text(this.easterEggMessage)
          .fontSize(AppTheme.FONT_SIZE_MEDIUM)
          .fontColor('#FF5722')
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ bottom: AppTheme.SPACING_MINI })
          .animation({
            duration: 1000,
            curve: Curve.EaseInOut,
            iterations: -1,
            playMode: PlayMode.Alternate
          })
      }
    }
    .width('100%')
    .padding(AppTheme.SPACING_NORMAL)
    .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
    .borderRadius(AppTheme.BORDER_RADIUS_MEDIUM)
    .margin({ bottom: AppTheme.SPACING_NORMAL })
  }

  /**
   * 构建按钮网格
   */
  @Builder buildButtonGrid() {
    Column() {
      // 第一行：科学, C, ⌫, ÷
      Row() {
        this.buildButton('科学', 'function')
        this.buildButton('C', 'function')
        this.buildButton('⌫', 'function')
        this.buildButton('÷', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: AppTheme.SPACING_MINI })

      // 第二行：7, 8, 9, ×
      Row() {
        this.buildButton('7', 'number')
        this.buildButton('8', 'number')
        this.buildButton('9', 'number')
        this.buildButton('×', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: AppTheme.SPACING_MINI })

      // 第三行：4, 5, 6, -
      Row() {
        this.buildButton('4', 'number')
        this.buildButton('5', 'number')
        this.buildButton('6', 'number')
        this.buildButton('-', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: AppTheme.SPACING_MINI })

      // 第四行：1, 2, 3, +
      Row() {
        this.buildButton('1', 'number')
        this.buildButton('2', 'number')
        this.buildButton('3', 'number')
        this.buildButton('+', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: AppTheme.SPACING_MINI })

      // 第五行：0占据前两列，点在第3列，等号在第4列
      Row() {
        // 第一/二列：0按钮占据两个按钮的空间
        this.buildWideButton('0', 'number')
        // 添加固定宽度空白，让点对接到第3列
        Blank().width(6)
        // 第三列：小数点  
        this.buildButton('.', 'number')
        // 添加固定宽度空白，让等号对接到第4列
        Blank().width(6)
        // 第四列：等号
        this.buildButton('=', 'equals')
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: AppTheme.SPACING_MINI })
    }
    .width('100%')
  }

  /**
   * 构建科学计算按钮
   */
  @Builder buildScientificButtons() {
    Column() {
      // 第一行科学按钮：sin, cos, tan, π
      Row() {
        this.buildButton('sin', 'scientific')
        this.buildButton('cos', 'scientific')
        this.buildButton('tan', 'scientific')
        this.buildButton('π', 'scientific')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: AppTheme.SPACING_MINI })

      // 第二行科学按钮：log, ln, √, e
      Row() {
        this.buildButton('log', 'scientific')
        this.buildButton('ln', 'scientific')
        this.buildButton('√', 'scientific')
        this.buildButton('e', 'scientific')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: AppTheme.SPACING_MINI })

      // 第三行科学按钮：^, (, ), !
      Row() {
        this.buildButton('^', 'scientific')
        this.buildButton('(', 'scientific')
        this.buildButton(')', 'scientific')
        this.buildButton('!', 'scientific')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }

  /**
   * 构建科学计算按钮行（紧凑版）
   */
  @Builder buildScientificButtonRow() {
    Column() {
      // 第一行科学按钮：sin, cos, tan, π
      Row() {
        this.buildScientificButton('sin', 'scientific')
        this.buildScientificButton('cos', 'scientific')
        this.buildScientificButton('tan', 'scientific')
        this.buildScientificButton('π', 'scientific')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: AppTheme.SPACING_MINI })

      // 第二行科学按钮：log, ln, √, e
      Row() {
        this.buildScientificButton('log', 'scientific')
        this.buildScientificButton('ln', 'scientific')
        this.buildScientificButton('√', 'scientific')
        this.buildScientificButton('e', 'scientific')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
      .margin({ bottom: AppTheme.SPACING_MINI })

      // 第三行科学按钮：^, (, ), !
      Row() {
        this.buildScientificButton('^', 'scientific')
        this.buildScientificButton('(', 'scientific')
        this.buildScientificButton(')', 'scientific')
        this.buildScientificButton('!', 'scientific')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceEvenly)
    }
    .margin({ bottom: AppTheme.SPACING_MINI })
    .transition(TransitionEffect.OPACITY.animation({ duration: 300, curve: Curve.EaseInOut }))
  }

  /**
   * 构建科学计算按钮（更小的尺寸）
   */
  @Builder buildScientificButton(text: string, type: string) {
    Button(text)
      .fontSize(14)
      .fontWeight(FontWeight.Medium)
      .width(60)
      .height(45)
      .borderRadius(12)
      .backgroundColor(this.getButtonColor(type, false))
      .fontColor(this.getButtonTextColor(type))
      .onClick(() => {
        Logger.info(`Scientific button clicked: ${text}`);
        this.handleButtonClick(text);
      })
      .stateStyles({
        pressed: {
          opacity: 0.7
        }
      })
  }

  /**
   * 构建按钮
   */
  @Builder buildButton(text: string, type: string) {
    Button(text)
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .width(70)
      .height(70)
      .borderRadius(16)
      .backgroundColor(this.getButtonColor(type, text === '科学' && this.showScientificButtons))
      .fontColor(this.getButtonTextColor(type))
      .opacity(text === '科学' && this.showScientificButtons ? 0.6 : 1)
      .onClick(() => {
        Logger.info(`Button click handler triggered for: ${text}`);
        if (text === '科学') {
          this.showScientificButtons = !this.showScientificButtons;
          Logger.info(`Toggled scientific buttons to: ${this.showScientificButtons}`);
        } else {
          this.handleButtonClick(text);
        }
      })
      .stateStyles({
        pressed: {
          opacity: 0.7
        }
      })
  }

  /**
   * 构建宽按钮（用于0按钮）
   */
  @Builder buildWideButton(text: string, type: string) {
    Button(text)
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .width(146)
      .height(70)
      .borderRadius(16)
      .backgroundColor(this.getButtonColor(type, text === '科学' && this.showScientificButtons))
      .fontColor(this.getButtonTextColor(type))
      .opacity(text === '科学' && this.showScientificButtons ? 0.6 : 1)
      .onClick(() => {
        Logger.info(`Button click handler triggered for: ${text}`);
        if (text === '科学') {
          this.showScientificButtons = !this.showScientificButtons;
          Logger.info(`Toggled scientific buttons to: ${this.showScientificButtons}`);
        } else {
          this.handleButtonClick(text);
        }
      })
      .stateStyles({
        pressed: {
          opacity: 0.7
        }
      })
  }

  /**
   * 构建中等按钮（用于小数点等按钮）
   */
  @Builder buildMediumButton(text: string, type: string) {
    Button(text)
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .width(110)
      .height(70)
      .borderRadius(16)
      .backgroundColor(this.getButtonColor(type, false))
      .fontColor(this.getButtonTextColor(type))
      .onClick(() => {
        this.handleButtonClick(text);
      })
      .stateStyles({
        pressed: {
          opacity: 0.7
        }
      })
  }

  /**
   * 获取按钮颜色
   */
  private getButtonColor(type: string, isPressed?: boolean): string {
    if (isPressed) {
      return '#4CAF50'; // 激活状态的颜色
    }
    
    switch (type) {
      case 'number':
        return AppTheme.getCardBackground(this.currentTheme === 'dark');
      case 'operator':
        return AppTheme.PRIMARY_COLOR;
      case 'function':
        return '#FF9800';
      case 'equals':
        return AppTheme.PRIMARY_COLOR;
      case 'scientific':
        return '#9C27B0';
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
      case 'scientific':
        return '#FFFFFF';
      default:
        return AppTheme.getPrimaryTextColor(this.currentTheme === 'dark');
    }
  }
}