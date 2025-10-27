/**
 * 数学表达式词法分析器
 * 将数学表达式字符串分解为标记（tokens）
 */

export enum TokenType {
  NUMBER = 'NUMBER',
  OPERATOR = 'OPERATOR',
  FUNCTION = 'FUNCTION',
  LEFT_PAREN = 'LEFT_PAREN',
  RIGHT_PAREN = 'RIGHT_PAREN',
  COMMA = 'COMMA',
  IDENTIFIER = 'IDENTIFIER',
  CONSTANT = 'CONSTANT',
  EOF = 'EOF'
}

export interface Token {
  type: TokenType;
  value: string;
  position: number;
  length: number;
}

export class LexicalAnalyzer {
  private input: string;
  private position: number;
  private currentChar: string | null;

  constructor(input: string) {
    this.input = input.trim();
    this.position = 0;
    this.currentChar = this.input.length > 0 ? this.input[0] : null;
  }

  /**
   * 获取下一个标记
   */
  public getNextToken(): Token {
    while (this.currentChar !== null) {
      // 跳过空白字符
      if (this.isWhitespace(this.currentChar)) {
        this.skipWhitespace();
        continue;
      }

      // 数字
      if (this.isDigit(this.currentChar) || this.currentChar === '.') {
        return this.readNumber();
      }

      // 标识符或函数
      if (this.isLetter(this.currentChar)) {
        return this.readIdentifier();
      }

      // 运算符
      if (this.isOperator(this.currentChar)) {
        return this.readOperator();
      }

      // 括号
      if (this.currentChar === '(') {
        const token = this.createToken(TokenType.LEFT_PAREN, this.currentChar);
        this.advance();
        return token;
      }

      if (this.currentChar === ')') {
        const token = this.createToken(TokenType.RIGHT_PAREN, this.currentChar);
        this.advance();
        return token;
      }

      // 逗号
      if (this.currentChar === ',') {
        const token = this.createToken(TokenType.COMMA, this.currentChar);
        this.advance();
        return token;
      }

      // 未知字符
      throw new Error(`Unexpected character: ${this.currentChar} at position ${this.position}`);
    }

    return this.createToken(TokenType.EOF, '');
  }

  /**
   * 获取所有标记
   */
  public getAllTokens(): Token[] {
    const tokens: Token[] = [];
    let token = this.getNextToken();
    
    while (token.type !== TokenType.EOF) {
      tokens.push(token);
      token = this.getNextToken();
    }
    
    tokens.push(token); // 添加EOF标记
    return tokens;
  }

  /**
   * 读取数字
   */
  private readNumber(): Token {
    let value = '';
    const startPos = this.position;

    // 读取整数部分
    while (this.currentChar !== null && this.isDigit(this.currentChar)) {
      value += this.currentChar;
      this.advance();
    }

    // 读取小数部分
    if (this.currentChar === '.') {
      value += this.currentChar;
      this.advance();
      
      while (this.currentChar !== null && this.isDigit(this.currentChar)) {
        value += this.currentChar;
        this.advance();
      }
    }

    // 读取科学计数法
    const expChar = this.currentChar;
    if (expChar === 'e' || expChar === 'E') {
      value += expChar;
      this.advance();
      
      // 检查科学计数法的符号
      const signChar = this.currentChar;
      if (signChar !== null && (signChar === '+' || signChar === '-')) {
        value += signChar;
        this.advance();
      }
      
      while (this.currentChar !== null && this.isDigit(this.currentChar)) {
        value += this.currentChar;
        this.advance();
      }
    }

    return this.createToken(TokenType.NUMBER, value);
  }

  /**
   * 读取标识符或函数
   */
  private readIdentifier(): Token {
    let value = '';
    const startPos = this.position;

    while (this.currentChar !== null && 
           (this.isLetter(this.currentChar) || this.isDigit(this.currentChar) || this.currentChar === '_')) {
      value += this.currentChar;
      this.advance();
    }

    // 检查是否是数学常数
    if (this.isMathConstant(value)) {
      return this.createToken(TokenType.CONSTANT, value);
    }

    // 检查是否是数学函数
    if (this.isMathFunction(value)) {
      return this.createToken(TokenType.FUNCTION, value);
    }

    return this.createToken(TokenType.IDENTIFIER, value);
  }

  /**
   * 读取运算符
   */
  private readOperator(): Token {
    const value = this.currentChar!;
    const token = this.createToken(TokenType.OPERATOR, value);
    this.advance();
    return token;
  }

  /**
   * 跳过空白字符
   */
  private skipWhitespace(): void {
    while (this.currentChar !== null && this.isWhitespace(this.currentChar)) {
      this.advance();
    }
  }

  /**
   * 前进到下一个字符
   */
  private advance(): void {
    this.position++;
    if (this.position >= this.input.length) {
      this.currentChar = null;
    } else {
      this.currentChar = this.input[this.position];
    }
  }

  /**
   * 创建标记
   */
  private createToken(type: TokenType, value: string): Token {
    return {
      type,
      value,
      position: this.position - value.length,
      length: value.length
    };
  }

  /**
   * 检查是否是数字
   */
  private isDigit(char: string): boolean {
    return /[0-9]/.test(char);
  }

  /**
   * 检查是否是字母
   */
  private isLetter(char: string): boolean {
    return /[a-zA-Z]/.test(char);
  }

  /**
   * 检查是否是运算符
   */
  private isOperator(char: string): boolean {
    return /[+\-*/^%]/.test(char);
  }

  /**
   * 检查是否是空白字符
   */
  private isWhitespace(char: string): boolean {
    return /\s/.test(char);
  }

  /**
   * 检查是否是数学常数
   */
  private isMathConstant(value: string): boolean {
    const constants = ['pi', 'e', 'infinity', 'nan'];
    return constants.includes(value.toLowerCase());
  }

  /**
   * 检查是否是数学函数
   */
  private isMathFunction(value: string): boolean {
    const functions = [
      'sin', 'cos', 'tan', 'asin', 'acos', 'atan',
      'sinh', 'cosh', 'tanh', 'asinh', 'acosh', 'atanh',
      'sqrt', 'cbrt', 'log', 'ln', 'log10', 'log2',
      'exp', 'pow', 'abs', 'ceil', 'floor', 'round',
      'min', 'max', 'sign', 'trunc', 'factorial'
    ];
    return functions.includes(value.toLowerCase());
  }

  /**
   * 重置分析器
   */
  public reset(): void {
    this.position = 0;
    this.currentChar = this.input.length > 0 ? this.input[0] : null;
  }

  /**
   * 获取当前位置
   */
  public getPosition(): number {
    return this.position;
  }

  /**
   * 检查是否还有更多字符
   */
  public hasMore(): boolean {
    return this.currentChar !== null;
  }
}
