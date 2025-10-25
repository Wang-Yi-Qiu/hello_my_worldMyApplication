/**
 * 数学符号键盘组件
 * 提供常用数学符号的快捷输入
 */
import { Logger } from '../utils/Logger';

export interface MathSymbol {
  display: string;      // 显示的符号（也是插入到输入框的内容）
  latex: string;        // LaTeX 代码（用于渲染）
  description: string;  // 描述
  insertText?: string;  // 可选：插入到输入框的文本，如果不指定则使用 display
}

@Component
export struct MathSymbolKeyboard {
  @Link inputText: string;
  @State currentCategory: string = 'basic';
  
  // 基础运算符号
  private basicSymbols: MathSymbol[] = [
    { display: '+', latex: '+', description: '加', insertText: '+' },
    { display: '−', latex: '-', description: '减', insertText: '-' },
    { display: '×', latex: '\\times', description: '乘', insertText: '*' },
    { display: '÷', latex: '\\div', description: '除', insertText: '/' },
    { display: '=', latex: '=', description: '等于', insertText: '=' },
    { display: '≠', latex: '\\neq', description: '不等于', insertText: '!=' },
    { display: '<', latex: '<', description: '小于', insertText: '<' },
    { display: '>', latex: '>', description: '大于', insertText: '>' },
    { display: '≤', latex: '\\leq', description: '小于等于', insertText: '<=' },
    { display: '≥', latex: '\\geq', description: '大于等于', insertText: '>=' },
  ];
  
  // 幂和根号
  private powerSymbols: MathSymbol[] = [
    { display: 'x²', latex: '^{2}', description: '平方', insertText: '^2' },
    { display: 'x³', latex: '^{3}', description: '立方', insertText: '^3' },
    { display: 'xⁿ', latex: '^{n}', description: '幂', insertText: '^' },
    { display: '√', latex: '\\sqrt{}', description: '平方根', insertText: 'sqrt()' },
    { display: '∛', latex: '\\sqrt[3]{}', description: '立方根', insertText: 'cbrt()' },
    { display: 'ⁿ√', latex: '\\sqrt[n]{}', description: 'n次根', insertText: 'nthRoot()' },
  ];
  
  // 微积分符号
  private calculusSymbols: MathSymbol[] = [
    { display: '∫', latex: '\\int', description: '积分', insertText: '∫() dx' },
    { display: '∫ᵃᵇ', latex: '\\int_{a}^{b}', description: '定积分', insertText: '∫()[a,b]' },
    { display: '∬', latex: '\\iint', description: '二重积分', insertText: '∬() dxdy' },
    { display: 'd/dx', latex: '\\frac{d}{dx}', description: '导数', insertText: 'd()/dx' },
    { display: '∂/∂x', latex: '\\frac{\\partial}{\\partial x}', description: '偏导数', insertText: '∂()/∂x' },
    { display: 'lim', latex: '\\lim_{x \\to a}', description: '极限', insertText: 'lim(x->a) ()' },
    { display: '∑', latex: '\\sum_{i=1}^{n}', description: '求和', insertText: '∑(i=1 to n) ()' },
    { display: '∏', latex: '\\prod_{i=1}^{n}', description: '求积', insertText: '∏(i=1 to n) ()' },
  ];
  
  // 希腊字母
  private greekSymbols: MathSymbol[] = [
    { display: 'α', latex: '\\alpha', description: 'alpha', insertText: 'α' },
    { display: 'β', latex: '\\beta', description: 'beta', insertText: 'β' },
    { display: 'γ', latex: '\\gamma', description: 'gamma', insertText: 'γ' },
    { display: 'δ', latex: '\\delta', description: 'delta', insertText: 'δ' },
    { display: 'ε', latex: '\\epsilon', description: 'epsilon', insertText: 'ε' },
    { display: 'θ', latex: '\\theta', description: 'theta', insertText: 'θ' },
    { display: 'λ', latex: '\\lambda', description: 'lambda', insertText: 'λ' },
    { display: 'μ', latex: '\\mu', description: 'mu', insertText: 'μ' },
    { display: 'π', latex: '\\pi', description: 'pi', insertText: 'π' },
    { display: 'σ', latex: '\\sigma', description: 'sigma', insertText: 'σ' },
    { display: 'φ', latex: '\\phi', description: 'phi', insertText: 'φ' },
    { display: 'ω', latex: '\\omega', description: 'omega', insertText: 'ω' },
  ];
  
  // 函数
  private functionSymbols: MathSymbol[] = [
    { display: 'sin', latex: '\\sin', description: '正弦', insertText: 'sin()' },
    { display: 'cos', latex: '\\cos', description: '余弦', insertText: 'cos()' },
    { display: 'tan', latex: '\\tan', description: '正切', insertText: 'tan()' },
    { display: 'log', latex: '\\log', description: '对数', insertText: 'log()' },
    { display: 'ln', latex: '\\ln', description: '自然对数', insertText: 'ln()' },
    { display: 'exp', latex: '\\exp', description: '指数', insertText: 'exp()' },
  ];
  
  // 分数和括号
  private structureSymbols: MathSymbol[] = [
    { display: 'a/b', latex: '\\frac{a}{b}', description: '分数', insertText: '/' },
    { display: '( )', latex: '()', description: '圆括号', insertText: '()' },
    { display: '[ ]', latex: '[]', description: '方括号', insertText: '[]' },
    { display: '{ }', latex: '\\{\\}', description: '花括号', insertText: '{}' },
    { display: '| |', latex: '||', description: '绝对值', insertText: 'abs()' },
  ];
  
  build() {
    Column() {
      // 分类标签
      Scroll() {
        Row() {
          this.buildCategoryTab('基础', 'basic');
          this.buildCategoryTab('幂根', 'power');
          this.buildCategoryTab('微积分', 'calculus');
          this.buildCategoryTab('希腊', 'greek');
          this.buildCategoryTab('函数', 'function');
          this.buildCategoryTab('结构', 'structure');
        }
        .width('100%')
        .height(44)
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .backgroundColor('#F8F8F8')
      
      // 符号网格
      Scroll() {
        Grid() {
          ForEach(this.getCurrentSymbols(), (symbol: MathSymbol, index: number) => {
            GridItem() {
              this.buildSymbolButton(symbol);
            }
          }, (symbol: MathSymbol, index: number) => `${this.currentCategory}_${index}`)
        }
        .columnsTemplate('1fr 1fr 1fr 1fr 1fr')
        .rowsGap(10)
        .columnsGap(10)
        .width('100%')
        .padding(12)
      }
      .height(200)
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#10000000', offsetX: 0, offsetY: 2 })
  }
  
  /**
   * 构建分类标签
   */
  @Builder buildCategoryTab(label: string, category: string) {
    Column() {
      Text(label)
        .fontSize(13)
        .fontColor(this.currentCategory === category ? '#1890FF' : '#666666')
        .fontWeight(this.currentCategory === category ? FontWeight.Medium : FontWeight.Normal)
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .textAlign(TextAlign.Center)
        .backgroundColor(this.currentCategory === category ? '#E6F7FF' : 'transparent')
        .borderRadius(16)
    }
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentCategory = category;
    })
  }
  
  /**
   * 构建符号按钮
   */
  @Builder buildSymbolButton(symbol: MathSymbol) {
    Column() {
      Text(symbol.display)
        .fontSize(22)
        .fontColor('#333333')
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: 2 })
      
      Text(symbol.description)
        .fontSize(9)
        .fontColor('#999999')
    }
    .width('100%')
    .height(64)
    .backgroundColor('#F8F8F8')
    .borderRadius(10)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.insertSymbol(symbol);
    })
    .stateStyles({
      pressed: {
        .backgroundColor('#E8E8E8')
      }
    })
  }
  
  /**
   * 获取当前分类的符号
   */
  private getCurrentSymbols(): MathSymbol[] {
    switch (this.currentCategory) {
      case 'basic':
        return this.basicSymbols;
      case 'power':
        return this.powerSymbols;
      case 'calculus':
        return this.calculusSymbols;
      case 'greek':
        return this.greekSymbols;
      case 'function':
        return this.functionSymbols;
      case 'structure':
        return this.structureSymbols;
      default:
        return this.basicSymbols;
    }
  }
  
  /**
   * 插入符号到输入框
   */
  private insertSymbol(symbol: MathSymbol) {
    // 使用 insertText（如果存在）或 display 作为插入的文本
    const textToInsert = symbol.insertText || symbol.display;
    Logger.info(`Inserting symbol: ${textToInsert}`);
    
    // 在当前光标位置插入符号
    // 简化实现：直接追加到末尾
    if (this.inputText) {
      this.inputText += textToInsert;
    } else {
      this.inputText = textToInsert;
    }
  }
}

