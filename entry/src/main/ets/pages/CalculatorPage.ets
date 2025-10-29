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
import { webview } from '@kit.ArkWeb';

// 明确声明用于退格匹配的配对类型，避免内联对象字面量类型
interface SpecialPair {
  display: string;
  expr: string;
}

@Component
export struct CalculatorPage {
  @StorageLink('currentTheme') currentTheme: string = 'light';
  @StorageLink('expressionFromHistory') expressionFromHistory: string = '';
  @StorageLink('enableEmotionFeedback') enableEmotionFeedback: boolean = true;
  @StorageLink('enableFortuneText') enableFortuneText: boolean = true;
  @StorageLink('enableEasterEgg') enableEasterEgg: boolean = true;
  @State expression: string = '';
  @State displayExpression: string = ''; // 用于显示的表达式（显示原始符号）
  @State result: string = '0';
  @State isError: boolean = false;
  @State justCalculated: boolean = false; // 标记是否刚完成一次计算，用于控制下一次数字输入是否重置
  @State emotionFeedback: EmotionFeedback | null = null;
  @State fortuneText: string = '';
  @State showEasterEgg: boolean = false;
  @State easterEggMessage: string = '';
  @State fortuneOpacity: number = 0;
  @State showScientificButtons: boolean = false;
  @StorageLink('needRefreshHistory') needRefreshHistory: boolean = false;
  @StorageLink('angleUnit') angleUnit: string = 'degree';
  @StorageLink('zeroSnapThreshold') zeroSnapThreshold: number = 1e-12;
  @StorageLink('asymptoteThreshold') asymptoteThreshold: number = 1e-12;
  @State private latexPreviewUrl: string = '';
  private latexWebController: webview.WebviewController = new webview.WebviewController();
  
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
      
      // 确保 AppStorage 中有默认的角度单位设置
      if (!AppStorage.has('angleUnit')) {
        AppStorage.setOrCreate('angleUnit', 'degree');
        Logger.info('Initialized angleUnit to degree in CalculatorPage');
      }
      
      // 从 AppStorage 读取角度单位设置并应用到引擎
      const angleUnit = AppStorage.get('angleUnit') as string || 'degree';
      this.angleUnit = angleUnit;
      this.engine.setAngleUnit(angleUnit as 'degree' | 'radian');
      Logger.info(`Angle unit set to: ${angleUnit}`);

      // 应用阈值设置
      const zeroSnap = (AppStorage.get('zeroSnapThreshold') as number) || 1e-12;
      const asymptote = (AppStorage.get('asymptoteThreshold') as number) || 1e-12;
      this.zeroSnapThreshold = zeroSnap;
      this.asymptoteThreshold = asymptote;
      this.engine.setThresholds({ zeroSnapThreshold: zeroSnap, asymptoteThreshold: asymptote });
      Logger.info(`Thresholds applied: zero=${zeroSnap}, asymptote=${asymptote}`);
    } catch (error) {
      this.errorHandler.handleError(error as Error, {
        component: 'CalculatorPage',
        action: 'aboutToAppear',
        timestamp: Date.now()
      });
    }
    
    // 监听历史记录回溯（通过@StorageLink装饰器自动处理）
    this.watchHistoryChanges();
    
    // 监听角度单位变化
    this.watchAngleUnitChanges();

    // 初始化 LaTeX 预览（空表达式时显示 0）
    this.updateLatexPreview(this.expression || '0', undefined);
  }
  
  private watchAngleUnitChanges(): void {
    setTimeout(() => {
      const value = AppStorage.get('angleUnit') as string || 'degree';
      this.angleUnit = value;
      this.engine.setAngleUnit(value as 'degree' | 'radian');
      Logger.info(`Angle unit updated to: ${value}`);
    }, 100);
  }

  private applyThresholdsFromStorage(): void {
    const zeroSnap = (AppStorage.get('zeroSnapThreshold') as number) || 1e-12;
    const asymptote = (AppStorage.get('asymptoteThreshold') as number) || 1e-12;
    this.zeroSnapThreshold = zeroSnap;
    this.asymptoteThreshold = asymptote;
    this.engine.setThresholds({ zeroSnapThreshold: zeroSnap, asymptoteThreshold: asymptote });
  }

  /**
   * 切换角度单位（DEG/RAD）
   */
  private toggleAngleUnit() {
    const next = this.angleUnit === 'degree' ? 'radian' : 'degree';
    this.angleUnit = next;
    AppStorage.setOrCreate('angleUnit', next);
    this.engine.setAngleUnit(next as 'degree' | 'radian');
    Logger.info(`Angle unit toggled to: ${next}`);
  }

  private watchHistoryChanges(): void {
    // 使用正则检查变化
    setTimeout(() => {
      const value = this.expressionFromHistory;
      if (value && value.trim() !== '') {
        Logger.info(`Expression from history: ${value}`);
        this.expression = value;
        this.displayExpression = value;
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
        // 传入原始按钮值，由 appendToExpression 内部完成转换与分支判断
        this.appendToExpression(value);
      }
      // 输入变更后同步 LaTeX 预览（传递可被 mathjs 解析的内部表达式）
      this.updateLatexPreview(this.expression || '0', undefined);
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
      case 'x²': return '^2';
      case 'π': return 'pi';
      case 'e': return 'e';
      case 'sin': return 'sin(';
      case 'cos': return 'cos(';
      case 'tan': return 'tan(';
      case 'lg': return 'log(';
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
    // 若刚完成计算：数字或小数点开始新输入；运算符/函数继续基于结果计算
    const isDigitInput = /^[0-9]$/.test(value);
    if (this.justCalculated) {
      if (isDigitInput || value === '.') {
        this.expression = '';
        this.displayExpression = '';
      }
      this.justCalculated = false;
    }
    // 小数点专用处理，支持 8.9 这类输入
    if (value === '.') {
      // 若开头或前一个是运算符/左括号，则补 0.
      if (this.expression.length === 0 || /[+\-*\/\(]$/.test(this.expression)) {
        this.expression += '0.';
        this.displayExpression += '0.';
        return;
      }
      // 若当前数字片段已包含小数点，则忽略
      const currentNumberMatch = this.expression.match(/(\d*\.?\d*)$/);
      if (currentNumberMatch && currentNumberMatch[0].includes('.')) {
        return;
      }
      this.expression += '.';
      this.displayExpression += '.';
      return;
    }
    // 如果表达式只包含数字（可能来自上次计算的结果），且输入的是运算符则追加
    const isNumber = /^\d+\.?\d*$/.test(this.expression);
    const isOperator = /[+\-*\/]/.test(value);
    const isFunction = /^(sin|cos|tan|lg|ln|sqrt|√)$/i.test(value);
    const isConstant = /^(pi|e)$/i.test(value);
    const isParenthesis = /^[()]$/.test(value);
    
    // 获取要追加的实际计算值和显示值
    const actualValue = this.convertDisplaySymbol(value); // 用于实际计算的符号
    // 函数型输入在显示侧也补上'('，以保持显示与内部表达式长度一致，便于退格
    const displayValue = isFunction
      ? (value === '√' ? '√(' : `${value}(`)
      : value; // 用于显示的用户界面符号
    
    // 数字输入：默认追加
    if (isDigitInput) {
      this.expression += actualValue;
      this.displayExpression += displayValue;
      return;
    }

    // 其他输入：按原规则处理（大多为追加）
    {
      // 输入运算符、常量、括号或其他符号时，追加
      // 特殊：x² 将前一个数字或右括号提升为幂
      if (value === 'x²') {
        // 若以数字或 ')' 结尾，则补上 ^2
        if (/[0-9)]$/.test(this.expression)) {
          this.expression += '^2';
          this.displayExpression += '²';
        } else {
          // 若无前置数字，默认对当前结果平方
          this.expression += '^2';
          this.displayExpression += '²';
        }
      } else {
        this.expression += actualValue;
        this.displayExpression += displayValue;
      }
    }
  }

  /**
   * 自动补全未闭合的括号
   */
  private balanceParentheses(expr: string): string {
    let open = 0;
    for (let i = 0; i < expr.length; i++) {
      if (expr[i] === '(') open++;
      if (expr[i] === ')') open = Math.max(0, open - 1);
    }
    return expr + ')'.repeat(open);
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

      // 计算前自动补全未闭合的括号
      const balanced = this.balanceParentheses(this.expression);
      Logger.info(`Calculating: ${balanced}`);
      
      // 保存原始表达式，用于历史记录
      const originalExpression = this.expression;
      
      const result: EvaluateResult = await this.engine.evaluate(balanced);
      
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
        const tempExpression = balanced;
        
        // 将结果设置为新的表达式，支持连续运算
        this.expression = this.result;
        this.displayExpression = this.result;
        this.justCalculated = true;
        
        // 计算后渲染最终 LaTeX（上方公式、下方结果）
        this.updateLatexPreview(tempExpression, this.result);

        // 保存到历史记录（使用原始表达式）
        await this.saveHistoryRecordWithExpression(originalExpression, this.result);
      } else {
        this.result = 'Error';
        this.isError = true;
        Logger.error('Calculation error:', result.error);
        this.justCalculated = false;
      }
    } catch (error) {
      this.result = 'Error';
      this.isError = true;
      this.justCalculated = false;
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
    this.displayExpression = '';
    this.result = '0';
    this.isError = false;
    this.justCalculated = false;
    this.updateLatexPreview('0', undefined);
  }

  /**
   * 退格
   */
  private backspace() {
    // 优先匹配多字符函数/常量的回退，确保显示与内部表达式同步
    if (this.displayExpression.length > 0) {
      const specialPairs: Array<SpecialPair> = [
        { display: 'sin(', expr: 'sin(' },
        { display: 'cos(', expr: 'cos(' },
        { display: 'tan(', expr: 'tan(' },
        { display: 'lg(',  expr: 'log(' },
        { display: 'ln(',  expr: 'ln(' },
        { display: '√(',   expr: 'sqrt(' }
      ];
      let matched = false;
      for (const pair of specialPairs) {
        if (this.displayExpression.endsWith(pair.display) && this.expression.endsWith(pair.expr)) {
          this.displayExpression = this.displayExpression.slice(0, -pair.display.length);
          this.expression = this.expression.slice(0, -pair.expr.length);
          matched = true;
          break;
        }
      }
      if (!matched) {
        // 处理 π 与 pi 的不同长度映射
        if (this.displayExpression.endsWith('π') && this.expression.endsWith('pi')) {
          this.displayExpression = this.displayExpression.slice(0, -1);
          this.expression = this.expression.slice(0, -2);
        } else {
          // 回退单字符（尽量保持一一对应）
          const lastChar = this.displayExpression.slice(-1);
          this.displayExpression = this.displayExpression.slice(0, -1);
          // 对于常规单字符，内部也删除一个字符；
          // 若内部为空则忽略
          if (this.expression.length > 0) {
            this.expression = this.expression.slice(0, -1);
          }
        }
      }
    }
    this.justCalculated = false;
    this.updateLatexPreview(this.expression || '0', undefined);
  }

  /**
   * 构建用于 KaTeX 渲染的 data URL（内含 mathjs 解析 toTex 与 KaTeX 渲染）
   * 上方渲染表达式公式，下方渲染计算结果（可选）
   */
  private buildKaTeXDataUrl(expression: string, result?: string): string {
    const angleMode = this.angleUnit === 'degree' ? 'DEG' : 'RAD';
    const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Formula</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.css" />
  <script defer src="https://cdn.jsdelivr.net/npm/katex@0.16.11/dist/katex.min.js"></script>
  <script src="https://unpkg.com/mathjs@11.11.0/lib/browser/math.min.js"></script>
  <style>
    body{margin:0;padding:8px;background:transparent;font-family:-apple-system,BlinkMacSystemFont,'HarmonyOS Sans','Segoe UI',Roboto,Helvetica,Arial}
    #expr{font-size:18px;color:#888;}
    #formula{font-size:22px;}
    #result{margin-top:6px;font-size:18px;color:#1890ff;}
  </style>
</head>
<body>
  <div id="expr"></div>
  <div id="formula"></div>
  <div id="result"></div>
  <script>
    (function(){
      const rawExpr = ${JSON.stringify(expression || '0')};
      const angleMode = ${JSON.stringify(angleMode)};
      function preprocessForDeg(expr){
        if(angleMode !== 'DEG') return expr;
        let s = expr;
        s = s.replace(/\bsin\(([^)]+)\)/g,'sin(($1 * pi / 180))')
             .replace(/\bcos\(([^)]+)\)/g,'cos(($1 * pi / 180))')
             .replace(/\btan\(([^)]+)\)/g,'tan(($1 * pi / 180))');
        s = s.replace(/\basin\(([^)]+)\)/g,'((180 / pi) * asin($1))')
             .replace(/\bacos\(([^)]+)\)/g,'((180 / pi) * acos($1))')
             .replace(/\batan\(([^)]+)\)/g,'((180 / pi) * atan($1))');
        return s;
      }
      function toLatex(expr){
        try{
          const node = math.parse(expr);
          return node.toTex({parenthesis:'auto',implicit:'hide'});
        }catch(e){
          return String(expr).replace(/\\/g,'\\\\');
        }
      }
      const exprForCalc = preprocessForDeg(rawExpr);
      const latex = toLatex(rawExpr);
      document.getElementById('expr').textContent = rawExpr;
      try{
        window.katex.render(latex, document.getElementById('formula'), {throwOnError:false});
      }catch(e){ document.getElementById('formula').textContent = rawExpr; }
      const rs = ${result !== undefined ? JSON.stringify(result) : 'null'};
      if(rs !== null){
        const latexEq = latex + ' = ' + String(rs).replace(/-/g,'-');
        try{ window.katex.render(latexEq, document.getElementById('result'), {throwOnError:false}); }
        catch(e){ document.getElementById('result').textContent = '= ' + rs; }
      }
    })();
  </script>
</body>
</html>`;
    return `data:text/html;charset=utf-8,${encodeURIComponent(html)}`;
  }

  /**
   * 更新 LaTeX 预览 WebView（表达式必填，结果可选）
   */
  private updateLatexPreview(expression: string, result?: string) {
    try {
      this.latexPreviewUrl = this.buildKaTeXDataUrl(expression, result);
      this.latexWebController.loadUrl(this.latexPreviewUrl);
    } catch (e) {
      Logger.error('updateLatexPreview error', e);
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
      // 顶部区域：科学 / C / DEG
      Row() {
        // 科学切换
        Button(this.showScientificButtons ? '基础' : '科学')
          .fontSize(14)
          .height(32)
          .borderRadius(AppTheme.BORDER_RADIUS_SMALL)
          .backgroundColor('#E8E8E8')
          .fontColor('#000000')
          .padding({ left: 10, right: 10 })
          .onClick(() => {
            this.showScientificButtons = !this.showScientificButtons;
          })

        // 清空
        Button('C')
          .fontSize(14)
          .height(32)
          .borderRadius(AppTheme.BORDER_RADIUS_SMALL)
          .backgroundColor('#FF9500')
          .fontColor('#FFFFFF')
          .padding({ left: 12, right: 12 })
          .margin({ left: 8 })
          .onClick(() => {
            this.clear();
          })

        Blank().layoutWeight(1)

        // 角度切换
        Button(this.angleUnit === 'degree' ? 'DEG' : 'RAD')
          .fontSize(14)
          .height(32)
          .borderRadius(AppTheme.BORDER_RADIUS_SMALL)
          .backgroundColor('#E8E8E8')
          .fontColor('#000000')
          .padding({ left: 12, right: 12 })
          .onClick(() => {
            this.toggleAngleUnit();
          })
      }
      .width('100%')
      .height(44)
      .padding({ left: AppTheme.SPACING_MEDIUM, right: AppTheme.SPACING_MEDIUM, top: AppTheme.SPACING_MEDIUM })
      .backgroundColor(Color.Transparent)
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
      .zIndex(1)
      .padding({ left: 12, right: 12, top: 0, bottom: 72 })
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  /**
   * 构建显示屏
   */
  @Builder buildDisplay() {
    Column() {
      // 上方小号表达式
      Text(this.displayExpression || '0')
        .fontSize(18)
        .fontColor('#A5A5A5')
        .width('100%')
        .textAlign(TextAlign.End)
        .padding({ bottom: 6 })
      // 可选 LaTeX（保持逻辑不改，只减小高度并透明）
      Web({ src: this.latexPreviewUrl, controller: this.latexWebController })
        .width('100%')
        .height(0)
        .backgroundColor(Color.Transparent)
        .hitTestBehavior(HitTestMode.Transparent)
        .zIndex(0)
      // 大号结果显示
      Text(this.result)
        .fontSize(64)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isError ? '#FF453A' : '#000000')
        .width('100%')
        .textAlign(TextAlign.End)
        .padding({ top: 6, bottom: 12 })
        .animation({ duration: 300, curve: Curve.EaseOut })
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
    .padding({ left: 12, right: 12, top: 0, bottom: 12 })
    .backgroundColor('#F5F5F5')
    .margin({ bottom: 8 })
  }

  /**
   * 构建按钮网格
   */
  @Builder buildButtonGrid() {
    Column() {
      // 第一行：科学, C, ⌫, ÷
      Row() {
        // 使用动态文本的切换按钮，确保文字随状态切换即时更新
        this.buildToggleButton()
        this.buildButton('C', 'function')
        this.buildButton('⌫', 'function')
        this.buildButton('÷', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 10 })

      // 第二行：7, 8, 9, ×
      Row() {
        this.buildButton('7', 'number')
        this.buildButton('8', 'number')
        this.buildButton('9', 'number')
        this.buildButton('×', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 10 })

      // 第三行：4, 5, 6, -
      Row() {
        this.buildButton('4', 'number')
        this.buildButton('5', 'number')
        this.buildButton('6', 'number')
        this.buildButton('-', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 10 })

      // 第四行：1, 2, 3, +
      Row() {
        this.buildButton('1', 'number')
        this.buildButton('2', 'number')
        this.buildButton('3', 'number')
        this.buildButton('+', 'operator')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 10 })

      // 第五行：0跨越1和2列，点，等号
      Row() {
        // 第1列和第2列（0按钮跨越两列）
        this.buildWideButtonForZero()
        
        // 第3列（对应数字3列）
        this.buildButton('.', 'number')
        
        // 第4列（对应运算符+列）
        this.buildButton('=', 'equals')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 6 })
    }
    .width('100%')
  }

  /**
   * 构建科学/基础模式切换按钮（使用动态 Text 绑定，避免文字不更新）
   */
  @Builder buildToggleButton() {
    Button() {
      Text(this.showScientificButtons ? '基础' : '科学')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getButtonTextColor('function'))
        .opacity(this.showScientificButtons ? 0.6 : 1)
    }
      .width('22%')
      .height(56)
      .borderRadius(AppTheme.BORDER_RADIUS_SMALL)
      .backgroundColor(this.getButtonColor('function', this.showScientificButtons))
      .onClick(() => {
        Logger.info('Toggle button clicked');
        this.showScientificButtons = !this.showScientificButtons;
        Logger.info(`Toggled scientific buttons to: ${this.showScientificButtons}`);
      })
      .stateStyles({
        pressed: {
          opacity: 0.7
        }
      })
  }

  /**
   * 构建科学计算按钮
   */
  @Builder buildScientificButtons() {
    Column() {
      // 第一行科学按钮：sin, cos, tan, π
      Row() {
        this.buildScientificButton('sin', 'scientific')
        this.buildScientificButton('cos', 'scientific')
        this.buildScientificButton('tan', 'scientific')
        this.buildScientificButton('π', 'scientific')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: AppTheme.SPACING_MINI })

      // 第二行科学按钮：lg, ln, √, e
      Row() {
        this.buildScientificButton('lg', 'scientific')
        this.buildScientificButton('ln', 'scientific')
        this.buildScientificButton('√', 'scientific')
        this.buildScientificButton('e', 'scientific')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: AppTheme.SPACING_MINI })

      // 第三行科学按钮：^, (, ), !
      Row() {
        this.buildScientificButton('^', 'scientific')
        this.buildScientificButton('(', 'scientific')
        this.buildScientificButton(')', 'scientific')
        this.buildScientificButton('!', 'scientific')
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

      // 第二行科学按钮：lg, ln, √, e
      Row() {
        this.buildScientificButton('lg', 'scientific')
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
      .fontSize(this.showScientificButtons ? Math.floor(14 * 0.98) : 14)
      .fontWeight(FontWeight.Medium)
      .width(this.showScientificButtons ? Math.floor(54 * 0.98) : 54)
      .height(this.showScientificButtons ? Math.floor(40 * 0.98) : 40)
      .borderRadius(AppTheme.BORDER_RADIUS_SMALL)
      .backgroundColor(this.getButtonColor(type, false, text))
      .fontColor(this.getButtonTextColor(type, text))
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
      .fontSize((this.showScientificButtons && !(type === 'scientific' || text === 'sin' || text === 'cos' || text === 'tan' || text === 'π' || text === 'lg' || text === 'ln' || text === '√' || text === 'e' || text === '^' || text === '(' || text === ')'|| text === '!'))
        ? Math.floor(18 * 0.9 * 0.98)
        : (this.showScientificButtons ? Math.floor(18 * 0.98) : 18))
      .fontWeight(FontWeight.Medium)
      .width('22%')
      .height(56)
      .borderRadius(AppTheme.BORDER_RADIUS_SMALL)
      .backgroundColor(this.getButtonColor(type, ((text === '科学' || text === '基础') && this.showScientificButtons), text))
      .fontColor(this.getButtonTextColor(type, text))
      .opacity((((text === '科学' || text === '基础') && this.showScientificButtons) ? 0.6 : 1))
      .onClick(() => {
        Logger.info(`Button click handler triggered for: ${text}`);
        if (text === '科学' || text === '基础') {
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
   * 构建宽按钮（0按钮跨越两列）
   */
  @Builder buildWideButtonForZero() {
    Button('0')
      .fontSize(18)
      .fontWeight(FontWeight.Medium)
      .width('47%')
      .height(56)
      .borderRadius(AppTheme.BORDER_RADIUS_SMALL)
      .backgroundColor(this.getButtonColor('number', false, '0'))
      .fontColor(this.getButtonTextColor('number', '0'))
      .onClick(() => {
        Logger.info(`Button click handler triggered for: 0`);
        this.handleButtonClick('0');
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
  private getButtonColor(type: string, isPressed?: boolean, text?: string): string {
    if (isPressed) {
      return '#1890FF';
    }
    
    switch (type) {
      case 'number':
        return '#E8E8E8';
      case 'operator':
        return '#1890FF';
      case 'function':
        return (text === 'C') ? '#FF9500' : (text === '⌫' ? '#E8E8E8' : '#E8E8E8');
      case 'equals':
        return '#FF9500';
      case 'scientific':
        return '#E8E8E8';
      default:
        return '#E8E8E8';
    }
  }

  /**
   * 获取按钮文字颜色
   */
  private getButtonTextColor(type: string, text?: string): string {
    switch (type) {
      case 'number':
        return '#000000';
      case 'operator':
      case 'equals':
        return '#FFFFFF';
      case 'function':
        return (text === 'C' || text === '⌫') ? '#FFFFFF' : '#000000';
      case 'scientific':
        return '#000000';
      default:
        return '#000000';
    }
  }
}