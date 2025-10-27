/**
 * 数学表达式语法分析器
 * 将词法分析器产生的标记转换为抽象语法树（AST）
 */

import { LexicalAnalyzer, Token, TokenType } from './LexicalAnalyzer';

export enum ASTNodeType {
  NUMBER = 'NUMBER',
  BINARY_OP = 'BINARY_OP',
  UNARY_OP = 'UNARY_OP',
  FUNCTION_CALL = 'FUNCTION_CALL',
  IDENTIFIER = 'IDENTIFIER',
  CONSTANT = 'CONSTANT'
}

export interface ASTNode {
  type: ASTNodeType;
  value?: string | number;
  operator?: string;
  left?: ASTNode;
  right?: ASTNode;
  operand?: ASTNode;
  functionName?: string;
  arguments?: ASTNode[];
}

export class SyntaxAnalyzer {
  private lexer: LexicalAnalyzer;
  private currentToken: Token;

  constructor(input: string) {
    this.lexer = new LexicalAnalyzer(input);
    this.currentToken = this.lexer.getNextToken();
  }

  /**
   * 解析表达式并返回AST
   */
  public parse(): ASTNode {
    const ast = this.parseExpression();
    
    if (this.currentToken.type !== TokenType.EOF) {
      throw new Error(`Unexpected token: ${this.currentToken.value} at position ${this.currentToken.position}`);
    }
    
    return ast;
  }

  /**
   * 解析表达式（最低优先级）
   */
  private parseExpression(): ASTNode {
    let left = this.parseTerm();

    while (this.currentToken.type === TokenType.OPERATOR && 
           (this.currentToken.value === '+' || this.currentToken.value === '-')) {
      const operator = this.currentToken.value;
      this.advance();
      const right = this.parseTerm();
      
      left = {
        type: ASTNodeType.BINARY_OP,
        operator,
        left,
        right
      };
    }

    return left;
  }

  /**
   * 解析项（中等优先级）
   */
  private parseTerm(): ASTNode {
    let left = this.parseFactor();

    while (this.currentToken.type === TokenType.OPERATOR && 
           (this.currentToken.value === '*' || this.currentToken.value === '/' || this.currentToken.value === '%')) {
      const operator = this.currentToken.value;
      this.advance();
      const right = this.parseFactor();
      
      left = {
        type: ASTNodeType.BINARY_OP,
        operator,
        left,
        right
      };
    }

    return left;
  }

  /**
   * 解析因子（处理幂运算，右结合）
   */
  private parseFactor(): ASTNode {
    let node = this.parseUnary();

    // 处理幂运算（右结合）
    if (this.currentToken.type === TokenType.OPERATOR && this.currentToken.value === '^') {
      this.advance();
      const right = this.parseFactor(); // 右结合：递归调用 parseFactor
      
      node = {
        type: ASTNodeType.BINARY_OP,
        operator: '^',
        left: node,
        right
      };
    }

    return node;
  }

  /**
   * 解析幂运算（废弃，已被 parseFactor 替代）
   */
  private parsePower(): ASTNode {
    return this.parseUnary();
  }

  /**
   * 解析一元运算符
   */
  private parseUnary(): ASTNode {
    if (this.currentToken.type === TokenType.OPERATOR && 
        (this.currentToken.value === '+' || this.currentToken.value === '-')) {
      const operator = this.currentToken.value;
      this.advance();
      const operand = this.parseUnary();
      
      return {
        type: ASTNodeType.UNARY_OP,
        operator,
        operand
      };
    }

    return this.parsePrimary();
  }

  /**
   * 解析基本元素
   */
  private parsePrimary(): ASTNode {
    if (this.currentToken.type === TokenType.NUMBER) {
      const value = parseFloat(this.currentToken.value);
      this.advance();
      return {
        type: ASTNodeType.NUMBER,
        value
      };
    }

    if (this.currentToken.type === TokenType.CONSTANT) {
      const value = this.currentToken.value;
      this.advance();
      return {
        type: ASTNodeType.CONSTANT,
        value
      };
    }

    if (this.currentToken.type === TokenType.IDENTIFIER) {
      const value = this.currentToken.value;
      this.advance();
      return {
        type: ASTNodeType.IDENTIFIER,
        value
      };
    }

    if (this.currentToken.type === TokenType.FUNCTION) {
      return this.parseFunctionCall();
    }

    if (this.currentToken.type === TokenType.LEFT_PAREN) {
      this.advance(); // 跳过 '('
      const node = this.parseExpression();
      
      // 检查并跳过 ')' - 使用显式的类型比较
      this.expectToken(TokenType.RIGHT_PAREN);
      
      this.advance(); // 跳过 ')'
      return node;
    }

    throw new Error(`Unexpected token: ${this.currentToken.value} at position ${this.currentToken.position}`);
  }

  /**
   * 解析函数调用
   */
  private parseFunctionCall(): ASTNode {
    const functionName = this.currentToken.value;
    this.advance(); // 跳过函数名

    if (this.currentToken.type !== TokenType.LEFT_PAREN) {
      throw new Error(`Expected '(' after function ${functionName} at position ${this.currentToken.position}`);
    }

    this.advance(); // 跳过 '('

    const args: ASTNode[] = [];

    // 解析函数参数 - 使用辅助方法避免类型推断问题
    if (!this.checkToken(TokenType.RIGHT_PAREN)) {
      args.push(this.parseExpression());

      while (this.checkToken(TokenType.COMMA)) {
        this.advance(); // 跳过 ','
        args.push(this.parseExpression());
      }
    }

    // 检查并跳过 ')'
    this.expectToken(TokenType.RIGHT_PAREN);
    this.advance(); // 跳过 ')'

    return {
      type: ASTNodeType.FUNCTION_CALL,
      functionName,
      arguments: args
    };
  }

  /**
   * 前进到下一个标记
   */
  private advance(): void {
    this.currentToken = this.lexer.getNextToken();
  }

  /**
   * 检查当前token类型（避免类型推断问题）
   */
  private checkToken(expectedType: TokenType): boolean {
    return this.currentToken.type === expectedType;
  }

  /**
   * 期望指定的token类型，如果不是则抛出错误
   */
  private expectToken(expectedType: TokenType): void {
    if (this.currentToken.type !== expectedType) {
      throw new Error(`Expected ${TokenType[expectedType]} but found ${this.currentToken.value} at position ${this.currentToken.position}`);
    }
  }

  /**
   * 获取当前标记
   */
  public getCurrentToken(): Token {
    return this.currentToken;
  }

  /**
   * 检查语法错误
   */
  public validate(): boolean {
    try {
      this.parse();
      return true;
    } catch (error) {
      console.error('Syntax validation error:', error);
      return false;
    }
  }

  /**
   * 获取AST的字符串表示（用于调试）
   */
  public getASTString(node?: ASTNode): string {
    if (!node) {
      node = this.parse();
    }

    switch (node.type) {
      case ASTNodeType.NUMBER:
        return node.value?.toString() || '0';
      
      case ASTNodeType.CONSTANT:
        return node.value?.toString() || '';
      
      case ASTNodeType.IDENTIFIER:
        return node.value?.toString() || '';
      
      case ASTNodeType.BINARY_OP:
        const left = node.left ? this.getASTString(node.left) : '';
        const right = node.right ? this.getASTString(node.right) : '';
        return `(${left} ${node.operator} ${right})`;
      
      case ASTNodeType.UNARY_OP:
        const operand = node.operand ? this.getASTString(node.operand) : '';
        return `${node.operator}${operand}`;
      
      case ASTNodeType.FUNCTION_CALL:
        const args = node.arguments?.map(arg => this.getASTString(arg)).join(', ') || '';
        return `${node.functionName}(${args})`;
      
      default:
        return 'unknown';
    }
  }

  /**
   * 重置分析器
   */
  public reset(): void {
    this.lexer.reset();
    this.currentToken = this.lexer.getNextToken();
  }
}
