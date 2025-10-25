/**
 * 计算器页面 - 现代深色主题风格
 * 主要的计算器界面，支持基础、科学和程序员模式
 */
import { AppTheme } from '../utils/AppTheme';
import { Logger } from '../utils/Logger';
import { ExpressionEngine, EvaluateResult } from '../modules/ExpressionEngine';
import { DataManager } from '../modules/DataManager';
import { Note, NoteManager, NoteExpression } from '../models/Note';
import { promptAction } from '@kit.ArkUI';

// 计算器模式
enum CalculatorMode {
  BASIC = '基础',
  SCIENTIFIC = '科学',
  PROGRAMMER = '程序员',
  NOTES = '数学笔记',
  CONVERTER = '转换'
}

// 按钮配置接口
interface ButtonConfig {
  label: string;
  type: string;
}

@Component
export struct CalculatorPage {
  @StorageLink('currentTheme') currentTheme: string = 'light';
  @State expression: string = '';
  @State result: string = '0';
  @State isError: boolean = false;
  @State currentMode: CalculatorMode = CalculatorMode.BASIC;
  @State showModeMenu: boolean = false;
  @State notes: Note[] = [];
  @State currentNote: Note | null = null;
  @State showNotesList: boolean = true;
  @State noteTitle: string = '';
  @State noteContent: string = '';
  @State programmerBase: 'DEC' | 'HEX' | 'OCT' | 'BIN' = 'DEC'; // 程序员模式的进制
  @State angleMode: 'DEG' | 'RAD' = 'DEG'; // 角度模式：度数或弧度
  @State showAdvancedFunctions: boolean = false; // 显示高级函数面板
  private engine: ExpressionEngine = new ExpressionEngine();
  private dataManager: DataManager = new DataManager();

  async aboutToAppear() {
    Logger.info('CalculatorPage loaded');
    await this.loadNotes();
  }

  /**
   * 加载笔记列表
   */
  async loadNotes() {
    this.notes = await NoteManager.getAllNotes();
    Logger.info(`Loaded ${this.notes.length} notes`);
  }

  /**
   * 处理按钮点击
   */
  handleButtonClick(value: string) {
    Logger.debug(`Button clicked: ${value}`);

    // 程序员模式特殊处理
    if (this.currentMode === CalculatorMode.PROGRAMMER) {
      this.handleProgrammerButtonClick(value);
      return;
    }

    switch (value) {
      case 'AC':
      case 'C':
        // 清除全部
        this.expression = '';
        this.result = '0';
        this.isError = false;
        break;
      
      case '⌫':
        // 删除最后一个字符
        this.expression = this.expression.slice(0, -1);
        if (!this.expression) {
          this.result = '0';
        }
        break;
      
      case '=':
        // 计算
        this.calculateResult();
        break;
      
      case '+/-':
        // 正负号切换
        if (this.expression) {
          // 如果表达式以负号开头，去掉负号
          if (this.expression.startsWith('-')) {
            this.expression = this.expression.substring(1);
          } else {
            // 否则在开头添加负号
            this.expression = '-' + this.expression;
          }
        } else if (this.result && this.result !== '0') {
          // 如果没有表达式但有结果，切换结果的正负
          if (this.result.startsWith('-')) {
            this.result = this.result.substring(1);
            this.expression = this.result;
          } else {
            this.result = '-' + this.result;
            this.expression = this.result;
          }
        }
        break;
      
      case 'sin':
      case 'cos':
      case 'tan':
      case 'ln':
      case 'log':
        // 三角函数和对数函数
        this.expression += value + '(';
        break;
      
      case '√':
        // 平方根
        this.expression += 'sqrt(';
        break;
      
      case 'x²':
        // 平方
        this.expression += '^2';
        break;
      
      case 'xʸ':
      case '^':
        // 幂次方
        this.expression += '^';
        break;
      
      case 'π':
        // 圆周率
        this.expression += 'π';
        break;
      
      case 'e':
        // 自然常数
        this.expression += 'e';
        break;
      
      case '%':
        // 百分号 - 除以100
        if (this.expression) {
          this.expression += '/100';
        }
        break;
      
      case '!':
        // 阶乘
        this.expression += '!';
        break;
      
      case 'rad':
      case 'deg':
        // 角度/弧度模式切换
        this.angleMode = this.angleMode === 'DEG' ? 'RAD' : 'DEG';
        promptAction.showToast({ message: `已切换到${this.angleMode === 'DEG' ? '角度' : '弧度'}模式` });
        break;
      
      case 'asin':
      case 'acos':
      case 'atan':
        // 反三角函数
        this.expression += value + '(';
        break;
      
      case 'sinh':
      case 'cosh':
      case 'tanh':
        // 双曲函数
        this.expression += value + '(';
        break;
      
      case 'asinh':
      case 'acosh':
      case 'atanh':
        // 反双曲函数
        this.expression += value + '(';
        break;
      
      case 'P':
        // 排列
        this.expression += 'P(';
        break;
      
      case 'C':
        // 组合
        this.expression += 'C(';
        break;
      
      case 'abs':
        // 绝对值
        this.expression += 'abs(';
        break;
      
      case '^':
        // 幂运算符
        this.expression += '^';
        break;
      
      case 'MOD':
        // 取模运算
        this.expression += '%';
        break;
      
      default:
        // 添加字符
        if (this.result !== '0' || this.expression) {
          this.expression += value;
        } else {
          this.expression = value;
        }
        break;
    }
  }

  /**
   * 处理程序员模式按钮点击
   */
  handleProgrammerButtonClick(value: string) {
    Logger.debug(`Programmer button clicked: ${value}`);

    switch (value) {
      case 'AC':
        // 清除全部
        this.expression = '';
        this.result = '0';
        this.isError = false;
        break;
      
      case '⌫':
        // 删除最后一个字符
        this.expression = this.expression.slice(0, -1);
        if (!this.expression) {
          this.result = '0';
        }
        break;
      
      case '=':
        // 计算
        this.calculateProgrammerResult();
        break;
      
      // 十六进制字母
      case 'A':
      case 'B':
      case 'C':
      case 'D':
      case 'E':
      case 'F':
        this.expression += value;
        break;
      
      // 位运算操作符
      case 'LSH':
        this.expression += '<<';
        break;
      
      case 'RSH':
        this.expression += '>>';
        break;
      
      case 'OR':
        this.expression += '|';
        break;
      
      case 'XOR':
        this.expression += '^';
        break;
      
      case 'NOT':
        this.expression += '~';
        break;
      
      case 'AND':
        this.expression += '&';
        break;
      
      case 'MOD':
        this.expression += '%';
        break;
      
      // 基本运算符和数字
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
      case '.':
      case '(':
      case ')':
      case '+':
      case '-':
      case '×':
      case '÷':
      case '%':
      case '^':
        // 添加字符
        let char: string = value;
        if (value === '×') char = '*';
        if (value === '÷') char = '/';
        
        if (this.result !== '0' || this.expression) {
          this.expression += char;
        } else {
          this.expression = char;
        }
        break;
      
      default:
        // 其他字符直接添加
        if (this.result !== '0' || this.expression) {
          this.expression += value;
        } else {
          this.expression = value;
        }
        break;
    }
  }

  /**
   * 计算程序员模式表达式
   */
  calculateProgrammerResult() {
    if (!this.expression) {
      return;
    }

    Logger.info(`Calculating programmer expression: ${this.expression}`);
    
    try {
      // 解析并计算表达式
      const result = this.evaluateProgrammerExpression(this.expression);
      
      // 确保结果是整数
      const intResult = Math.floor(result);
      
      this.result = intResult.toString();
      this.isError = false;
      
      // 保存到历史记录
      this.saveToHistory(this.expression, this.result);
      
      // 将结果作为新的表达式（可以继续计算）
      this.expression = this.result;
    } catch (error) {
      Logger.error('Programmer calculation error', error);
      this.result = '计算错误';
      this.isError = true;
    }
  }

  /**
   * 计算程序员表达式
   * 支持十六进制数字和位运算
   */
  evaluateProgrammerExpression(expr: string): number {
    // 移除空格
    let sanitized = expr.replace(/\s/g, '');
    
    // 替换运算符
    sanitized = sanitized.replace(/×/g, '*');
    sanitized = sanitized.replace(/÷/g, '/');
    
    // 将十六进制字母转换为数字
    // 查找所有十六进制数字模式（包含A-F的数字序列）
    sanitized = this.convertHexNumbers(sanitized);
    
    Logger.debug(`Sanitized programmer expression: ${sanitized}`);
    
    // 使用 Function 安全地求值
    // 验证表达式只包含安全字符（包括位运算符）
    if (!/^[0-9+\-*\/.()&|^~<>x%]+$/.test(sanitized)) {
      Logger.error(`Invalid characters in programmer expression: ${sanitized}`);
      throw new Error('表达式包含无效字符');
    }
    
    try {
      // 使用 Function 构造函数安全地求值
      // 注意：在程序员模式下，^ 是 XOR 运算符，不是幂运算
      const func = new Function('return ' + sanitized) as () => number;
      const result: number = func();
      
      if (typeof result !== 'number' || isNaN(result)) {
        throw new Error('计算结果无效');
      }
      
      return result;
    } catch (error) {
      Logger.error('evaluateProgrammerExpression error', error);
      throw new Error('计算错误');
    }
  }

  /**
   * 转换十六进制数字
   * 例如：1A + 2B -> 0x1A + 0x2B
   */
  convertHexNumbers(expr: string): string {
    // 匹配包含A-F的数字序列
    // 正则：数字开头，包含至少一个A-F字母的数字序列
    const hexPattern = /\b([0-9]*[A-F]+[0-9A-F]*)\b/gi;
    
    return expr.replace(hexPattern, (match) => {
      // 验证是否是有效的十六进制数
      if (/^[0-9A-F]+$/i.test(match)) {
        return '0x' + match;
      }
      return match;
    });
  }

  /**
   * 计算表达式
   */
  calculateResult() {
    if (!this.expression) {
      return;
    }

    Logger.info(`Calculating: ${this.expression}`);
    
    // 替换特殊符号
    // 注意：不在这里替换 π 和 e，让 ExpressionEngine 处理
    let processedExpression = this.expression
      .replace(/×/g, '*')
      .replace(/÷/g, '/');
    
    // 将 π 替换为 pi（ExpressionEngine 会处理）
    processedExpression = processedExpression.replace(/π/g, 'pi');
    
    const evalResult: EvaluateResult = this.engine.evaluate(processedExpression);
    
    if (evalResult.success && evalResult.result) {
      this.result = evalResult.result;
      this.isError = false;
      
      // 保存到历史记录
      this.saveToHistory(this.expression, evalResult.result);
      
      // 将结果作为新的表达式（可以继续计算）
      this.expression = evalResult.result;
    } else {
      this.result = evalResult.error || '计算错误';
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
        calc_type: this.currentMode === CalculatorMode.BASIC ? 'basic' : 'scientific'
      });
      Logger.info('Saved to history');
    } catch (error) {
      Logger.error('Failed to save history', error);
    }
  }

  build() {
    Column() {
      // 顶部模式切换栏
      Row() {
        // 模式切换按钮组
        Row() {
          this.buildModeTab('标准', CalculatorMode.BASIC);
          this.buildModeTab('科学', CalculatorMode.SCIENTIFIC);
          this.buildModeTab('程序员', CalculatorMode.PROGRAMMER);
        }
        .height(44)
        .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
        .borderRadius(22)
        .padding(4)
        
        Blank()
        
        // 右上角功能按钮
        Row() {
          // 历史记录按钮
          Button() {
            Text('⏱')
              .fontSize(20)
              .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
          }
          .width(40)
          .height(40)
          .backgroundColor('transparent')
          .onClick(() => {
            promptAction.showToast({ message: '历史记录' });
          })
          
          // 菜单按钮
          Button() {
            Text('☰')
              .fontSize(20)
              .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
          }
          .width(40)
          .height(40)
          .backgroundColor('transparent')
          .onClick(() => {
            this.showModeMenu = !this.showModeMenu;
          })
        }
      }
      .width('100%')
      .height(60)
      .padding({ left: 16, right: 16 })
      .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
      .justifyContent(FlexAlign.SpaceBetween)

      // 显示区域
      Column() {
        // 表达式显示（计算过程）
        Text(this.expression || '0')
          .fontSize(this.currentMode === CalculatorMode.PROGRAMMER ? 20 : 26)
          .fontColor(AppTheme.PRIMARY_COLOR)
          .width('100%')
          .textAlign(TextAlign.End)
          .margin({ bottom: 8 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontWeight(FontWeight.Medium)
        
        // 结果显示（大号数字）
        Text(this.result)
          .fontSize(this.currentMode === CalculatorMode.PROGRAMMER ? 48 : 60)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isError ? AppTheme.ERROR_COLOR : AppTheme.SUCCESS_COLOR)
          .width('100%')
          .textAlign(TextAlign.End)
          .letterSpacing(2)
        
        // 程序员模式额外显示
        if (this.currentMode === CalculatorMode.PROGRAMMER) {
          this.buildProgrammerDisplay();
        }
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 16, bottom: 16 })
      .height(this.currentMode === CalculatorMode.PROGRAMMER ? 240 : 
              this.currentMode === CalculatorMode.SCIENTIFIC ? 180 : 200)
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.End)
      .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))

      // 按钮区域
      Column() {
        if (this.currentMode === CalculatorMode.BASIC) {
          this.buildBasicButtons();
        } else if (this.currentMode === CalculatorMode.SCIENTIFIC) {
          this.buildScientificButtons();
        } else if (this.currentMode === CalculatorMode.PROGRAMMER) {
          this.buildProgrammerButtons();
        } else if (this.currentMode === CalculatorMode.NOTES) {
          this.buildNotesView();
        }
      }
      .width('100%')
      .padding({ 
        left: 16, 
        right: 16, 
        bottom: 20, 
        top: this.currentMode === CalculatorMode.SCIENTIFIC || this.currentMode === CalculatorMode.PROGRAMMER ? 4 : 12 
      })
      .layoutWeight(1)
      .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
  }

  /**
   * 构建模式标签页
   */
  @Builder buildModeTab(label: string, mode: CalculatorMode) {
    Text(label)
      .fontSize(14)
      .fontColor(this.currentMode === mode ? '#FFFFFF' : AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
      .padding({ left: 16, right: 16 })
      .height(36)
      .backgroundColor(this.currentMode === mode ? AppTheme.PRIMARY_COLOR : 'transparent')
      .borderRadius(18)
      .textAlign(TextAlign.Center)
      .onClick(() => {
        this.currentMode = mode;
        promptAction.showToast({ message: `已切换到${label}模式` });
      })
  }

  /**
   * 构建程序员模式显示
   */
  @Builder buildProgrammerDisplay() {
    Column() {
      Row() {
        Text('HEX')
          .fontSize(12)
          .fontColor(this.programmerBase === 'HEX' ? AppTheme.PRIMARY_COLOR : AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
          .fontWeight(this.programmerBase === 'HEX' ? FontWeight.Bold : FontWeight.Normal)
          .width(50)
          .onClick(() => {
            this.programmerBase = 'HEX';
            promptAction.showToast({ message: '切换到十六进制' });
          })
        Text(this.convertToHex(this.result))
          .fontSize(14)
          .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .margin({ top: 12 })
      
      Row() {
        Text('DEC')
          .fontSize(12)
          .fontColor(this.programmerBase === 'DEC' ? AppTheme.PRIMARY_COLOR : AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
          .fontWeight(this.programmerBase === 'DEC' ? FontWeight.Bold : FontWeight.Normal)
          .width(50)
          .onClick(() => {
            this.programmerBase = 'DEC';
            promptAction.showToast({ message: '切换到十进制' });
          })
        Text(this.result)
          .fontSize(14)
          .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .margin({ top: 8 })
      
      Row() {
        Text('OCT')
          .fontSize(12)
          .fontColor(this.programmerBase === 'OCT' ? AppTheme.PRIMARY_COLOR : AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
          .fontWeight(this.programmerBase === 'OCT' ? FontWeight.Bold : FontWeight.Normal)
          .width(50)
          .onClick(() => {
            this.programmerBase = 'OCT';
            promptAction.showToast({ message: '切换到八进制' });
          })
        Text(this.convertToOct(this.result))
          .fontSize(14)
          .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
          .layoutWeight(1)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .margin({ top: 8 })
      
      Row() {
        Text('BIN')
          .fontSize(12)
          .fontColor(this.programmerBase === 'BIN' ? AppTheme.PRIMARY_COLOR : AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
          .fontWeight(this.programmerBase === 'BIN' ? FontWeight.Bold : FontWeight.Normal)
          .width(50)
          .onClick(() => {
            this.programmerBase = 'BIN';
            promptAction.showToast({ message: '切换到二进制' });
          })
        Text(this.convertToBin(this.result))
          .fontSize(14)
          .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
          .layoutWeight(1)
          .textAlign(TextAlign.End)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
  }

  /**
   * 转换为十六进制
   */
  convertToHex(value: string): string {
    try {
      const num = parseInt(value);
      if (isNaN(num)) return '0';
      return num.toString(16).toUpperCase();
    } catch {
      return '0';
    }
  }

  /**
   * 转换为八进制
   */
  convertToOct(value: string): string {
    try {
      const num = parseInt(value);
      if (isNaN(num)) return '0';
      return num.toString(8);
    } catch {
      return '0';
    }
  }

  /**
   * 转换为二进制
   */
  convertToBin(value: string): string {
    try {
      const num = parseInt(value);
      if (isNaN(num)) return '0';
      return num.toString(2);
    } catch {
      return '0';
    }
  }

  /**
   * 构建模式菜单项
   */
  @Builder buildModeMenuItem(mode: CalculatorMode, icon: string, isSelected: boolean) {
    Row() {
      if (isSelected) {
        Text('✓')
          .fontSize(18)
          .fontColor('#1890FF')
          .width(24)
      } else {
        Text('')
          .width(24)
      }
      
      Text(icon)
        .fontSize(18)
        .fontColor('#666666')
        .width(36)
      
      Text(mode)
        .fontSize(16)
        .fontColor('#333333')
        .layoutWeight(1)
    }
    .width('100%')
    .height(44)
    .borderRadius(8)
    .backgroundColor(isSelected ? '#F0F7FF' : 'transparent')
    .onClick(() => {
      this.currentMode = mode;
      this.showModeMenu = false;
    })
  }

  /**
   * 构建基础模式按钮
   */
  @Builder buildBasicButtons() {
    Column() {
      // 第一行：AC, ⌫, %, ÷
      this.buildButtonRow([
        { label: 'AC', type: 'clear' } as ButtonConfig,
        { label: '⌫', type: 'function' } as ButtonConfig,
        { label: '%', type: 'function' } as ButtonConfig,
        { label: '÷', type: 'operator' } as ButtonConfig
      ]);
      
      // 第二行：7, 8, 9, ×
      this.buildButtonRow([
        { label: '7', type: 'number' } as ButtonConfig,
        { label: '8', type: 'number' } as ButtonConfig,
        { label: '9', type: 'number' } as ButtonConfig,
        { label: '×', type: 'operator' } as ButtonConfig
      ]);
      
      // 第三行：4, 5, 6, -
      this.buildButtonRow([
        { label: '4', type: 'number' } as ButtonConfig,
        { label: '5', type: 'number' } as ButtonConfig,
        { label: '6', type: 'number' } as ButtonConfig,
        { label: '-', type: 'operator' } as ButtonConfig
      ]);
      
      // 第四行：1, 2, 3, +
      this.buildButtonRow([
        { label: '1', type: 'number' } as ButtonConfig,
        { label: '2', type: 'number' } as ButtonConfig,
        { label: '3', type: 'number' } as ButtonConfig,
        { label: '+', type: 'operator' } as ButtonConfig
      ]);
      
      // 第五行：+/-, 0, ., = (完美矩形布局)
      this.buildButtonRow([
        { label: '+/-', type: 'function' } as ButtonConfig,
        { label: '0', type: 'number' } as ButtonConfig,
        { label: '.', type: 'number' } as ButtonConfig,
        { label: '=', type: 'equals' } as ButtonConfig
      ]);
    }
  }

  /**
   * 构建科学模式按钮
   * 优化的4列网格布局，紧凑排列
   */
  @Builder buildScientificButtons() {
    Column() {
      // 角度模式切换按钮
      Row() {
        Button(this.angleMode === 'DEG' ? 'DEG' : 'RAD')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .borderRadius(16)
          .height(32)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.angleMode = this.angleMode === 'DEG' ? 'RAD' : 'DEG';
            promptAction.showToast({ message: `已切换到${this.angleMode === 'DEG' ? '角度' : '弧度'}模式` });
          })
        
        Blank()
        
        // 高级函数切换按钮
        Button(this.showAdvancedFunctions ? '基础' : '高级')
          .fontSize(12)
          .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
          .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
          .borderRadius(16)
          .height(32)
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.showAdvancedFunctions = !this.showAdvancedFunctions;
          })
      }
      .width('100%')
      .margin({ bottom: 8 })
      
      if (!this.showAdvancedFunctions) {
        // 基础科学函数
        // 第一行：sin, cos, tan, ln
        Row() {
          this.buildScientificButton('sin', 'function', 23);
          this.buildScientificButton('cos', 'function', 23);
          this.buildScientificButton('tan', 'function', 23);
          this.buildScientificButton('ln', 'function', 23);
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 6 })
        
        // 第二行：√, ^, (, )
        Row() {
          this.buildScientificButton('√', 'function', 23);
          this.buildScientificButton('^', 'function', 23);
          this.buildScientificButton('(', 'function', 23);
          this.buildScientificButton(')', 'function', 23);
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 6 })
      } else {
        // 高级科学函数
        // 第一行：asin, acos, atan, !
        Row() {
          this.buildScientificButton('asin', 'function', 23);
          this.buildScientificButton('acos', 'function', 23);
          this.buildScientificButton('atan', 'function', 23);
          this.buildScientificButton('!', 'function', 23);
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 6 })
        
        // 第二行：sinh, cosh, tanh, abs
        Row() {
          this.buildScientificButton('sinh', 'function', 23);
          this.buildScientificButton('cosh', 'function', 23);
          this.buildScientificButton('tanh', 'function', 23);
          this.buildScientificButton('abs', 'function', 23);
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 6 })
      }
      
      // 第三行：AC, ⌫, %, ÷
      Row() {
        this.buildScientificButton('AC', 'clear', 23);
        this.buildScientificButton('⌫', 'function', 23);
        this.buildScientificButton('%', 'function', 23);
        this.buildScientificButton('÷', 'operator', 23);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 6 })
      
      // 第四行：7, 8, 9, ×
      Row() {
        this.buildScientificButton('7', 'number', 23);
        this.buildScientificButton('8', 'number', 23);
        this.buildScientificButton('9', 'number', 23);
        this.buildScientificButton('×', 'operator', 23);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 6 })
      
      // 第五行：4, 5, 6, -
      Row() {
        this.buildScientificButton('4', 'number', 23);
        this.buildScientificButton('5', 'number', 23);
        this.buildScientificButton('6', 'number', 23);
        this.buildScientificButton('-', 'operator', 23);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 6 })
      
      // 第六行：1, 2, 3, +
      Row() {
        this.buildScientificButton('1', 'number', 23);
        this.buildScientificButton('2', 'number', 23);
        this.buildScientificButton('3', 'number', 23);
        this.buildScientificButton('+', 'operator', 23);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 6 })
      
      // 第七行：+/-, 0, ., = (完美矩形布局)
      Row() {
        this.buildScientificButton('+/-', 'function', 23);
        this.buildScientificButton('0', 'number', 23);
        this.buildScientificButton('.', 'number', 23);
        this.buildScientificButton('=', 'equals', 23);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 6 })
      
      // 第八行：π, e, log, x² (完美矩形布局)
      Row() {
        this.buildScientificButton('π', 'constant', 23);
        this.buildScientificButton('e', 'constant', 23);
        this.buildScientificButton('log', 'function', 23);
        this.buildScientificButton('x²', 'function', 23);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
  }

  /**
   * 构建科学计算器按钮
   */
  @Builder buildScientificButton(label: string, type: string, widthPercent: number) {
    Button(label)
      .fontSize(this.getButtonFontSize(label))
      .fontWeight(type === 'equals' ? FontWeight.Bold : FontWeight.Normal)
      .backgroundColor(this.getButtonColor(type))
      .fontColor(this.getButtonTextColor(type))
      .borderRadius(22)
      .width(`${widthPercent}%`)
      .height(48)  // 更紧凑的按钮高度
      .padding(0)
      .onClick(() => {
        this.handleButtonClick(label);
      })
  }

  /**
   * 构建程序员模式按钮 - 完美6x6矩阵布局
   */
  @Builder buildProgrammerButtons() {
    Column() {
      // 第一行：LSH, RSH, (, ), ⌫, AC
      Row() {
        this.buildProgrammerButton('LSH', 'bitwise', 15);
        this.buildProgrammerButton('RSH', 'bitwise', 15);
        this.buildProgrammerButton('(', 'function', 15);
        this.buildProgrammerButton(')', 'function', 15);
        this.buildProgrammerButton('⌫', 'function', 15);
        this.buildProgrammerButton('AC', 'clear', 15);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 8 })
      
      // 第二行：OR, A, B, 7, 8, 9
      Row() {
        this.buildProgrammerButton('OR', 'bitwise', 15);
        this.buildProgrammerButton('A', 'hex', 15);
        this.buildProgrammerButton('B', 'hex', 15);
        this.buildProgrammerButton('7', 'number', 15);
        this.buildProgrammerButton('8', 'number', 15);
        this.buildProgrammerButton('9', 'number', 15);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 8 })
      
      // 第三行：XOR, C, D, 4, 5, 6
      Row() {
        this.buildProgrammerButton('XOR', 'bitwise', 15);
        this.buildProgrammerButton('C', 'hex', 15);
        this.buildProgrammerButton('D', 'hex', 15);
        this.buildProgrammerButton('4', 'number', 15);
        this.buildProgrammerButton('5', 'number', 15);
        this.buildProgrammerButton('6', 'number', 15);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 8 })
      
      // 第四行：NOT, E, F, 1, 2, 3
      Row() {
        this.buildProgrammerButton('NOT', 'bitwise', 15);
        this.buildProgrammerButton('E', 'hex', 15);
        this.buildProgrammerButton('F', 'hex', 15);
        this.buildProgrammerButton('1', 'number', 15);
        this.buildProgrammerButton('2', 'number', 15);
        this.buildProgrammerButton('3', 'number', 15);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 8 })
      
      // 第五行：AND, +, -, 0, ., ×
      Row() {
        this.buildProgrammerButton('AND', 'bitwise', 15);
        this.buildProgrammerButton('+', 'operator', 15);
        this.buildProgrammerButton('-', 'operator', 15);
        this.buildProgrammerButton('0', 'number', 15);
        this.buildProgrammerButton('.', 'number', 15);
        this.buildProgrammerButton('×', 'operator', 15);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 8 })
      
      // 第六行：=, (空位保持6x6矩阵对齐)
      Row() {
        this.buildProgrammerButton('=', 'equals', 15);
        // 空占位保持对齐
        Row().width('15%')
        Row().width('15%')
        Row().width('15%')
        Row().width('15%')
        Row().width('15%')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
  }

  /**
   * 构建程序员模式按钮
   */
  @Builder buildProgrammerButton(label: string, type: string, widthPercent: number) {
    Button(label)
      .fontSize(this.getButtonFontSize(label))
      .fontWeight(FontWeight.Normal)
      .backgroundColor(this.getButtonColor(type))
      .fontColor(this.getButtonTextColor(type))
      .borderRadius(24)
      .width(`${widthPercent}%`)
      .height(52)
      .padding(0)
      .onClick(() => {
        this.handleButtonClick(label);
      })
  }

  /**
   * 构建按钮行
   */
  @Builder buildButtonRow(buttons: Array<ButtonConfig>, count: number = 4) {
    Row() {
      ForEach(buttons, (button: ButtonConfig) => {
        this.buildRoundButton(button.label, button.type, 1);
      }, (button: ButtonConfig) => button.label)
    }
    .width('100%')
    .height(64)
    .justifyContent(FlexAlign.SpaceBetween)
    .margin({ bottom: 8 })
  }

  /**
   * 获取按钮宽度
   * widthMultiplier: 按钮宽度倍数（1 = 标准宽度，1.5 = 1.5倍宽度，2 = 2倍宽度）
   */
  getButtonWidth(widthMultiplier: number = 1): string {
    // 基础模式 - 4列布局，每列22%，间距2%
    // 标准宽度：22%
    // 2倍宽度：22% + 2%(间距) + 22% = 46%
    const baseWidth = 22;
    const gapWidth = 2;
    
    if (widthMultiplier === 1) {
      return `${baseWidth}%`;  // 标准宽度
    } else if (widthMultiplier === 2) {
      return `${baseWidth * 2 + gapWidth}%`;  // 2倍宽度（占两个按钮位置+间距）
    } else {
      // 自定义倍数：baseWidth * multiplier + gapWidth * (multiplier - 1)
      const width = baseWidth * widthMultiplier + gapWidth * (widthMultiplier - 1);
      return `${width}%`;
    }
  }

  /**
   * 构建按钮
   * widthMultiplier: 按钮宽度倍数（1 = 标准宽度，1.5 = 1.5倍宽度，2 = 2倍宽度）
   */
  @Builder buildRoundButton(label: string, type: string, widthMultiplier: number = 1) {
    if (type === 'empty') {
      // 空占位
      Row()
        .width('22%')
        .height(56)
    } else {
      Button(label)
        .fontSize(this.getButtonFontSize(label))
        .fontWeight(type === 'operator' || type === 'equals' ? FontWeight.Medium : FontWeight.Normal)
        .backgroundColor(this.getButtonColor(type))
        .fontColor(this.getButtonTextColor(type))
        .borderRadius(28)
        .width(this.getButtonWidth(widthMultiplier))
        .height(56)
        .padding(0)
        .onClick(() => {
          this.handleButtonClick(label);
        })
    }
  }

  /**
   * 获取按钮字体大小
   */
  getButtonFontSize(label: string): number {
    const isProgrammer = this.currentMode === CalculatorMode.PROGRAMMER;
    const isScientific = this.currentMode === CalculatorMode.SCIENTIFIC;
    
    if (isProgrammer) {
      // 程序员模式下的字体大小
      if (label.length > 2) {
        return 12;  // 长文本（如 LSH, RSH, XOR, NOT, AND）
      }
      if (label.length === 2) {
        return 14;  // 两个字符（如 AC, OR）
      }
      return 18;  // 普通字体（单个字符）
    } else if (isScientific) {
      // 科学模式下的字体大小
      if (label.length > 2) {
        return 14;  // 长文本（如 sin, cos, tan, log）
      }
      if (label.length === 2) {
        return 16;  // 两个字符（如 xʸ, x², AC, ln, +/-）
      }
      return 20;  // 普通字体（单个字符）
    } else {
      // 基础模式下的字体大小
      if (label.length > 2) {
        return 18;
      }
      if (label.length === 2) {
        return 20;
      }
      return 24;
    }
  }

  /**
   * 获取按钮背景色 - 根据主题
   */
  getButtonColor(type: string): string {
    const isDark = this.currentTheme === 'dark';
    switch (type) {
      case 'operator':
        return AppTheme.PRIMARY_COLOR;
      case 'equals':
        return AppTheme.SUCCESS_COLOR;
      case 'clear':
      case 'bitwise':
        return AppTheme.ERROR_COLOR;
      case 'number':
      case 'function':
      case 'constant':
      case 'backspace':
      case 'hex':
      default:
        return isDark ? AppTheme.CARD_BG_DARK : AppTheme.DIVIDER_COLOR_LIGHT;
    }
  }

  /**
   * 获取按钮文字颜色
   */
  getButtonTextColor(type: string): string {
    const isDark = this.currentTheme === 'dark';
    switch (type) {
      case 'operator':
      case 'equals':
      case 'clear':
      case 'bitwise':
        return '#FFFFFF'; // Use white text for colored buttons for contrast
      case 'number':
      case 'function':
      case 'constant':
      case 'backspace':
      case 'hex':
      default:
        return AppTheme.getPrimaryTextColor(isDark);
    }
  }

  /**
   * 构建笔记视图
   */
  @Builder buildNotesView() {
    Column() {
      if (this.showNotesList) {
        // 笔记列表视图
        this.buildNotesList();
      } else {
        // 笔记编辑视图
        this.buildNoteEditor();
      }
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 构建笔记列表
   */
  @Builder buildNotesList() {
    Column() {
      // 标题栏
      Row() {
        Text('数学笔记')
          .fontSize(AppTheme.FONT_SIZE_TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
          .layoutWeight(1)
        
        Button('新建笔记')
          .fontSize(AppTheme.FONT_SIZE_MEDIUM)
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .fontColor('#FFFFFF')
          .borderRadius(AppTheme.BORDER_RADIUS_SMALL)
          .height(36)
          .onClick(() => {
            this.createNewNote();
          })
      }
      .width('100%')
      .padding({ 
        left: AppTheme.SPACING_MEDIUM, 
        right: AppTheme.SPACING_MEDIUM, 
        top: AppTheme.SPACING_MEDIUM, 
        bottom: AppTheme.SPACING_NORMAL 
      })
      
      // 笔记列表
      if (this.notes.length === 0) {
        Column() {
          Text('📝')
            .fontSize(48)
            .margin({ bottom: 12 })
          Text('暂无笔记')
            .fontSize(AppTheme.FONT_SIZE_NORMAL)
            .fontColor(AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
          Text('点击"新建笔记"开始记录')
            .fontSize(AppTheme.FONT_SIZE_MEDIUM)
            .fontColor(AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
            .margin({ top: AppTheme.SPACING_SMALL })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 12 }) {
          ForEach(this.notes, (note: Note) => {
            ListItem() {
              this.buildNoteItem(note);
            }
          }, (note: Note) => note.id)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
  }

  /**
   * 构建笔记项
   */
  @Builder buildNoteItem(note: Note) {
    Column() {
      Row() {
        Column() {
          Text(note.title)
            .fontSize(AppTheme.FONT_SIZE_NORMAL)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          
          if (note.content) {
            Text(note.content)
              .fontSize(AppTheme.FONT_SIZE_MEDIUM)
              .fontColor(AppTheme.getSecondaryTextColor(this.currentTheme === 'dark'))
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: AppTheme.SPACING_MINI })
          }
          
          Row() {
            Text(`${note.expressions.length} 个表达式`)
              .fontSize(AppTheme.FONT_SIZE_SMALL)
              .fontColor(AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
            
            Text('•')
              .fontSize(AppTheme.FONT_SIZE_SMALL)
              .fontColor(AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
              .margin({ left: AppTheme.SPACING_SMALL, right: AppTheme.SPACING_SMALL })
            
            Text(this.formatDate(note.updated_at))
              .fontSize(AppTheme.FONT_SIZE_SMALL)
              .fontColor(AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
          }
          .margin({ top: AppTheme.SPACING_SMALL })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        
        Image($r('app.media.startIcon'))
          .width(20)
          .height(20)
          .fillColor(AppTheme.getTertiaryTextColor(this.currentTheme === 'dark'))
      }
      .width('100%')
      .padding(AppTheme.SPACING_MEDIUM)
    }
    .width('100%')
    .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
    .borderRadius(AppTheme.BORDER_RADIUS_MEDIUM)
    .onClick(() => {
      this.openNote(note);
    })
  }

  /**
   * 构建笔记编辑器
   */
  @Builder buildNoteEditor() {
    Column() {
      // 顶部工具栏
      Row() {
        Button('< 返回')
          .fontSize(AppTheme.FONT_SIZE_MEDIUM)
          .fontColor(AppTheme.PRIMARY_COLOR)
          .backgroundColor('transparent')
          .onClick(() => {
            this.closeNoteEditor();
          })
        
        Blank()
        
        Button('保存')
          .fontSize(AppTheme.FONT_SIZE_MEDIUM)
          .backgroundColor(AppTheme.PRIMARY_COLOR)
          .fontColor('#FFFFFF')
          .borderRadius(AppTheme.BORDER_RADIUS_SMALL)
          .height(36)
          .onClick(() => {
            this.saveCurrentNote();
          })
        
        Button('删除')
          .fontSize(AppTheme.FONT_SIZE_MEDIUM)
          .backgroundColor(AppTheme.ERROR_COLOR)
          .fontColor('#FFFFFF')
          .borderRadius(AppTheme.BORDER_RADIUS_SMALL)
          .height(36)
          .margin({ left: AppTheme.SPACING_SMALL })
          .onClick(() => {
            this.deleteCurrentNote();
          })
      }
      .width('100%')
      .padding(AppTheme.SPACING_MEDIUM)
      .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
      
      Scroll() {
        Column() {
          // 标题输入
          TextInput({ placeholder: '笔记标题', text: this.noteTitle })
            .fontSize(AppTheme.FONT_SIZE_TITLE)
            .fontWeight(FontWeight.Bold)
            .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
            .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
            .onChange((value: string) => {
              this.noteTitle = value;
            })
            .margin({ bottom: AppTheme.SPACING_NORMAL })
          
          // 内容输入
          TextArea({ placeholder: '在这里记录你的数学思考...', text: this.noteContent })
            .fontSize(AppTheme.FONT_SIZE_NORMAL)
            .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
            .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
            .height(150)
            .onChange((value: string) => {
              this.noteContent = value;
            })
            .margin({ bottom: AppTheme.SPACING_MEDIUM })
          
          // 表达式区域
          Text('计算表达式')
            .fontSize(AppTheme.FONT_SIZE_NORMAL)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
            .margin({ bottom: AppTheme.SPACING_SMALL })
          
          // 添加表达式按钮
          Row() {
            TextInput({ placeholder: '输入数学表达式', text: this.expression })
              .layoutWeight(1)
              .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
              .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
              .margin({ right: AppTheme.SPACING_SMALL })
              .onChange((value: string) => {
                this.expression = value;
              })
            
            Button('计算并添加')
              .fontSize(AppTheme.FONT_SIZE_MEDIUM)
              .backgroundColor(AppTheme.PRIMARY_COLOR)
              .fontColor('#FFFFFF')
              .onClick(() => {
                this.addExpressionToNote();
              })
          }
          .width('100%')
          .margin({ bottom: AppTheme.SPACING_MEDIUM })
          
          // 表达式列表
          if (this.currentNote && this.currentNote.expressions.length > 0) {
            Column({ space: 8 }) {
              ForEach(this.currentNote.expressions, (expr: NoteExpression) => {
                this.buildExpressionItem(expr);
              }, (expr: NoteExpression) => expr.id)
            }
            .width('100%')
          }
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
      .backgroundColor(AppTheme.getBackgroundColor(this.currentTheme === 'dark'))
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 构建表达式项
   */
  @Builder buildExpressionItem(expr: NoteExpression) {
    Row() {
      Column() {
        Text(expr.expression)
          .fontSize(AppTheme.FONT_SIZE_MEDIUM)
          .fontColor(AppTheme.getPrimaryTextColor(this.currentTheme === 'dark'))
          .fontFamily('monospace')
        
        Text(`= ${expr.result}`)
          .fontSize(AppTheme.FONT_SIZE_NORMAL)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.SUCCESS_COLOR)
          .fontFamily('monospace')
          .margin({ top: AppTheme.SPACING_MINI })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      
      Button('删除')
        .fontSize(AppTheme.FONT_SIZE_SMALL)
        .backgroundColor('transparent')
        .fontColor(AppTheme.ERROR_COLOR)
        .borderRadius(AppTheme.BORDER_RADIUS_MINI)
        .height(28)
        .onClick(() => {
          this.removeExpressionFromNote(expr.id);
        })
    }
    .width('100%')
    .padding(AppTheme.SPACING_NORMAL)
    .backgroundColor(AppTheme.getCardBackground(this.currentTheme === 'dark'))
    .borderRadius(AppTheme.BORDER_RADIUS_SMALL)
  }

  /**
   * 创建新笔记
   */
  createNewNote() {
    this.currentNote = NoteManager.createNote();
    this.noteTitle = this.currentNote.title;
    this.noteContent = this.currentNote.content;
    this.showNotesList = false;
    Logger.info('Created new note');
  }

  /**
   * 打开笔记
   */
  openNote(note: Note) {
    this.currentNote = note;
    this.noteTitle = note.title;
    this.noteContent = note.content;
    this.showNotesList = false;
    Logger.info(`Opened note: ${note.id}`);
  }

  /**
   * 关闭笔记编辑器
   */
  async closeNoteEditor() {
    this.showNotesList = true;
    this.currentNote = null;
    this.noteTitle = '';
    this.noteContent = '';
    this.expression = '';
    this.result = '0';
    await this.loadNotes();
  }

  /**
   * 保存当前笔记
   */
  async saveCurrentNote() {
    if (!this.currentNote) {
      return;
    }
    
    this.currentNote.title = this.noteTitle || '未命名笔记';
    this.currentNote.content = this.noteContent;
    this.currentNote.updated_at = Date.now();
    
    const success = await NoteManager.saveNote(this.currentNote);
    if (success) {
      promptAction.showToast({ message: '笔记已保存' });
      await this.loadNotes();
      Logger.info('Note saved successfully');
    } else {
      promptAction.showToast({ message: '保存失败' });
    }
  }

  /**
   * 删除当前笔记
   */
  async deleteCurrentNote() {
    if (!this.currentNote) {
      return;
    }
    
    const success = await NoteManager.deleteNote(this.currentNote.id);
    if (success) {
      promptAction.showToast({ message: '笔记已删除' });
      await this.closeNoteEditor();
      Logger.info('Note deleted successfully');
    } else {
      promptAction.showToast({ message: '删除失败' });
    }
  }

  /**
   * 添加表达式到笔记
   */
  addExpressionToNote() {
    if (!this.currentNote || !this.expression) {
      promptAction.showToast({ message: '请输入表达式' });
      return;
    }
    
    // 计算表达式
    this.calculateResult();
    
    if (!this.isError && this.result !== '0') {
      this.currentNote = NoteManager.addExpression(
        this.currentNote,
        this.expression,
        this.result
      );
      
      // 清空表达式输入
      this.expression = '';
      this.result = '0';
      
      promptAction.showToast({ message: '表达式已添加' });
      Logger.info('Expression added to note');
    }
  }

  /**
   * 从笔记中删除表达式
   */
  removeExpressionFromNote(expressionId: string) {
    if (!this.currentNote) {
      return;
    }
    
    this.currentNote = NoteManager.removeExpression(this.currentNote, expressionId);
    promptAction.showToast({ message: '表达式已删除' });
  }

  /**
   * 格式化日期
   */
  formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    
    // 小于1分钟
    if (diff < 60000) {
      return '刚刚';
    }
    
    // 小于1小时
    if (diff < 3600000) {
      const minutes = Math.floor(diff / 60000);
      return `${minutes}分钟前`;
    }
    
    // 小于24小时
    if (diff < 86400000) {
      const hours = Math.floor(diff / 3600000);
      return `${hours}小时前`;
    }
    
    // 小于7天
    if (diff < 604800000) {
      const days = Math.floor(diff / 86400000);
      return `${days}天前`;
    }
    
    // 显示日期
    const month = date.getMonth() + 1;
    const day = date.getDate();
    return `${month}月${day}日`;
  }
}


