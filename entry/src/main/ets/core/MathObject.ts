/**
 * 数学对象基类
 * 参考 SageMath 的对象模型设计
 * 所有数学实体（数字、表达式、矩阵、函数等）都继承自此类
 */
import { Logger } from '../utils/Logger';

/**
 * 数学对象类型枚举
 */
export enum MathObjectType {
  NUMBER = 'NUMBER',           // 数值
  EXPRESSION = 'EXPRESSION',   // 表达式
  POLYNOMIAL = 'POLYNOMIAL',   // 多项式
  RATIONAL = 'RATIONAL',       // 有理式
  MATRIX = 'MATRIX',           // 矩阵
  VECTOR = 'VECTOR',           // 向量
  FUNCTION = 'FUNCTION',       // 函数
  SET = 'SET',                 // 集合
  SEQUENCE = 'SEQUENCE',       // 序列
  SERIES = 'SERIES',           // 级数
  LIMIT = 'LIMIT',             // 极限
  DERIVATIVE = 'DERIVATIVE',   // 导数
  INTEGRAL = 'INTEGRAL',       // 积分
  EQUATION = 'EQUATION',       // 方程
  INEQUALITY = 'INEQUALITY',   // 不等式
  COMPLEX = 'COMPLEX',         // 复数
  SYMBOLIC = 'SYMBOLIC'        // 符号
}

/**
 * 数学对象接口
 */
export interface IMathObject {
  // 基本属性
  type: MathObjectType;
  value: any;
  
  // 基本操作
  toString(): string;
  toLatex(): string;
  simplify(): IMathObject;
  evaluate(context?: Map<string, any>): IMathObject;
  
  // 类型检查
  isNumeric(): boolean;
  isSymbolic(): boolean;
  isConstant(): boolean;
  
  // 比较操作
  equals(other: IMathObject): boolean;
  
  // 克隆
  clone(): IMathObject;
}

/**
 * 数学对象抽象基类
 */
export abstract class MathObject implements IMathObject {
  public type: MathObjectType;
  public value: any;
  protected metadata: Map<string, any>;
  
  constructor(type: MathObjectType, value: any) {
    this.type = type;
    this.value = value;
    this.metadata = new Map();
  }
  
  /**
   * 转换为字符串表示
   */
  abstract toString(): string;
  
  /**
   * 转换为 LaTeX 表示
   */
  abstract toLatex(): string;
  
  /**
   * 化简
   */
  abstract simplify(): IMathObject;
  
  /**
   * 求值
   */
  abstract evaluate(context?: Map<string, any>): IMathObject;
  
  /**
   * 是否为数值类型
   */
  isNumeric(): boolean {
    return this.type === MathObjectType.NUMBER || 
           this.type === MathObjectType.COMPLEX;
  }
  
  /**
   * 是否为符号类型
   */
  isSymbolic(): boolean {
    return this.type === MathObjectType.SYMBOLIC ||
           this.type === MathObjectType.EXPRESSION;
  }
  
  /**
   * 是否为常数
   */
  abstract isConstant(): boolean;
  
  /**
   * 相等性比较
   */
  abstract equals(other: IMathObject): boolean;
  
  /**
   * 克隆对象
   */
  abstract clone(): IMathObject;
  
  /**
   * 设置元数据
   */
  setMetadata(key: string, value: any): void {
    this.metadata.set(key, value);
  }
  
  /**
   * 获取元数据
   */
  getMetadata(key: string): any {
    return this.metadata.get(key);
  }
}

/**
 * 数值对象
 */
export class MathNumber extends MathObject {
  constructor(value: number | bigint) {
    super(MathObjectType.NUMBER, value);
  }
  
  toString(): string {
    return this.value.toString();
  }
  
  toLatex(): string {
    return this.value.toString();
  }
  
  simplify(): IMathObject {
    return this;
  }
  
  evaluate(context?: Map<string, any>): IMathObject {
    return this;
  }
  
  isConstant(): boolean {
    return true;
  }
  
  equals(other: IMathObject): boolean {
    if (other.type !== MathObjectType.NUMBER) {
      return false;
    }
    return this.value === other.value;
  }
  
  clone(): IMathObject {
    return new MathNumber(this.value);
  }
  
  // 数值运算
  add(other: MathNumber): MathNumber {
    if (typeof this.value === 'bigint' && typeof other.value === 'bigint') {
      return new MathNumber(this.value + other.value);
    }
    return new MathNumber(Number(this.value) + Number(other.value));
  }
  
  subtract(other: MathNumber): MathNumber {
    if (typeof this.value === 'bigint' && typeof other.value === 'bigint') {
      return new MathNumber(this.value - other.value);
    }
    return new MathNumber(Number(this.value) - Number(other.value));
  }
  
  multiply(other: MathNumber): MathNumber {
    if (typeof this.value === 'bigint' && typeof other.value === 'bigint') {
      return new MathNumber(this.value * other.value);
    }
    return new MathNumber(Number(this.value) * Number(other.value));
  }
  
  divide(other: MathNumber): MathNumber {
    if (Number(other.value) === 0) {
      throw new Error('Division by zero');
    }
    return new MathNumber(Number(this.value) / Number(other.value));
  }
  
  power(exponent: MathNumber): MathNumber {
    return new MathNumber(Math.pow(Number(this.value), Number(exponent.value)));
  }
}

/**
 * 复数对象
 */
export class MathComplex extends MathObject {
  public real: number;
  public imag: number;
  
  constructor(real: number, imag: number) {
    super(MathObjectType.COMPLEX, { real, imag });
    this.real = real;
    this.imag = imag;
  }
  
  toString(): string {
    if (this.imag === 0) {
      return this.real.toString();
    }
    if (this.real === 0) {
      return `${this.imag}i`;
    }
    const sign = this.imag >= 0 ? '+' : '';
    return `${this.real}${sign}${this.imag}i`;
  }
  
  toLatex(): string {
    if (this.imag === 0) {
      return this.real.toString();
    }
    if (this.real === 0) {
      return `${this.imag}i`;
    }
    const sign = this.imag >= 0 ? '+' : '';
    return `${this.real}${sign}${this.imag}i`;
  }
  
  simplify(): IMathObject {
    if (this.imag === 0) {
      return new MathNumber(this.real);
    }
    return this;
  }
  
  evaluate(context?: Map<string, any>): IMathObject {
    return this;
  }
  
  isConstant(): boolean {
    return true;
  }
  
  equals(other: IMathObject): boolean {
    if (other.type !== MathObjectType.COMPLEX) {
      return false;
    }
    const otherComplex = other as MathComplex;
    return this.real === otherComplex.real && this.imag === otherComplex.imag;
  }
  
  clone(): IMathObject {
    return new MathComplex(this.real, this.imag);
  }
  
  // 复数运算
  add(other: MathComplex): MathComplex {
    return new MathComplex(this.real + other.real, this.imag + other.imag);
  }
  
  subtract(other: MathComplex): MathComplex {
    return new MathComplex(this.real - other.real, this.imag - other.imag);
  }
  
  multiply(other: MathComplex): MathComplex {
    const real = this.real * other.real - this.imag * other.imag;
    const imag = this.real * other.imag + this.imag * other.real;
    return new MathComplex(real, imag);
  }
  
  divide(other: MathComplex): MathComplex {
    const denominator = other.real * other.real + other.imag * other.imag;
    if (denominator === 0) {
      throw new Error('Division by zero');
    }
    const real = (this.real * other.real + this.imag * other.imag) / denominator;
    const imag = (this.imag * other.real - this.real * other.imag) / denominator;
    return new MathComplex(real, imag);
  }
  
  conjugate(): MathComplex {
    return new MathComplex(this.real, -this.imag);
  }
  
  magnitude(): number {
    return Math.sqrt(this.real * this.real + this.imag * this.imag);
  }
  
  argument(): number {
    return Math.atan2(this.imag, this.real);
  }
}

/**
 * 符号对象
 */
export class MathSymbol extends MathObject {
  public name: string;
  
  constructor(name: string) {
    super(MathObjectType.SYMBOLIC, name);
    this.name = name;
  }
  
  toString(): string {
    return this.name;
  }
  
  toLatex(): string {
    // 特殊符号的 LaTeX 表示
    const specialSymbols: Map<string, string> = new Map([
      ['pi', '\\pi'],
      ['theta', '\\theta'],
      ['alpha', '\\alpha'],
      ['beta', '\\beta'],
      ['gamma', '\\gamma'],
      ['delta', '\\delta'],
      ['epsilon', '\\epsilon'],
      ['lambda', '\\lambda'],
      ['mu', '\\mu'],
      ['sigma', '\\sigma'],
      ['phi', '\\phi'],
      ['omega', '\\omega'],
      ['infinity', '\\infty']
    ]);
    
    return specialSymbols.get(this.name) || this.name;
  }
  
  simplify(): IMathObject {
    return this;
  }
  
  evaluate(context?: Map<string, any>): IMathObject {
    if (context && context.has(this.name)) {
      const value = context.get(this.name);
      if (typeof value === 'number') {
        return new MathNumber(value);
      }
      if (value instanceof MathObject) {
        return value;
      }
    }
    return this;
  }
  
  isConstant(): boolean {
    // 数学常数
    const constants = ['pi', 'e', 'infinity'];
    return constants.includes(this.name);
  }
  
  equals(other: IMathObject): boolean {
    if (other.type !== MathObjectType.SYMBOLIC) {
      return false;
    }
    return this.name === (other as MathSymbol).name;
  }
  
  clone(): IMathObject {
    return new MathSymbol(this.name);
  }
}

/**
 * 表达式对象
 */
export class MathExpression extends MathObject {
  public operator: string;
  public operands: IMathObject[];
  
  constructor(operator: string, operands: IMathObject[]) {
    super(MathObjectType.EXPRESSION, { operator, operands });
    this.operator = operator;
    this.operands = operands;
  }
  
  toString(): string {
    switch (this.operator) {
      case '+':
        return `(${this.operands.map(op => op.toString()).join(' + ')})`;
      case '-':
        if (this.operands.length === 1) {
          return `(-${this.operands[0].toString()})`;
        }
        return `(${this.operands[0].toString()} - ${this.operands[1].toString()})`;
      case '*':
        return `(${this.operands.map(op => op.toString()).join(' * ')})`;
      case '/':
        return `(${this.operands[0].toString()} / ${this.operands[1].toString()})`;
      case '^':
        return `(${this.operands[0].toString()}^${this.operands[1].toString()})`;
      default:
        return `${this.operator}(${this.operands.map(op => op.toString()).join(', ')})`;
    }
  }
  
  toLatex(): string {
    switch (this.operator) {
      case '+':
        return this.operands.map(op => op.toLatex()).join(' + ');
      case '-':
        if (this.operands.length === 1) {
          return `-${this.operands[0].toLatex()}`;
        }
        return `${this.operands[0].toLatex()} - ${this.operands[1].toLatex()}`;
      case '*':
        return this.operands.map(op => op.toLatex()).join(' \\cdot ');
      case '/':
        return `\\frac{${this.operands[0].toLatex()}}{${this.operands[1].toLatex()}}`;
      case '^':
        return `{${this.operands[0].toLatex()}}^{${this.operands[1].toLatex()}}`;
      case 'sqrt':
        return `\\sqrt{${this.operands[0].toLatex()}}`;
      case 'sin':
      case 'cos':
      case 'tan':
      case 'log':
      case 'ln':
      case 'exp':
        return `\\${this.operator}(${this.operands[0].toLatex()})`;
      default:
        return `${this.operator}(${this.operands.map(op => op.toLatex()).join(', ')})`;
    }
  }
  
  simplify(): IMathObject {
    // 先简化所有操作数
    const simplifiedOperands = this.operands.map(op => op.simplify());
    
    // 如果所有操作数都是数值，直接计算
    if (simplifiedOperands.every(op => op.isNumeric())) {
      try {
        const result = this.evaluateNumeric(simplifiedOperands);
        return result;
      } catch (e) {
        // 计算失败，返回简化后的表达式
      }
    }
    
    // 应用代数简化规则
    return this.applySimplificationRules(simplifiedOperands);
  }
  
  private evaluateNumeric(operands: IMathObject[]): IMathObject {
    const nums = operands.map(op => {
      if (op instanceof MathNumber) {
        return Number(op.value);
      }
      throw new Error('Not a number');
    });
    
    let result: number;
    switch (this.operator) {
      case '+':
        result = nums.reduce((a, b) => a + b, 0);
        break;
      case '-':
        result = nums.length === 1 ? -nums[0] : nums[0] - nums[1];
        break;
      case '*':
        result = nums.reduce((a, b) => a * b, 1);
        break;
      case '/':
        if (nums[1] === 0) throw new Error('Division by zero');
        result = nums[0] / nums[1];
        break;
      case '^':
        result = Math.pow(nums[0], nums[1]);
        break;
      case 'sqrt':
        result = Math.sqrt(nums[0]);
        break;
      case 'sin':
        result = Math.sin(nums[0]);
        break;
      case 'cos':
        result = Math.cos(nums[0]);
        break;
      case 'tan':
        result = Math.tan(nums[0]);
        break;
      case 'log':
        result = Math.log10(nums[0]);
        break;
      case 'ln':
        result = Math.log(nums[0]);
        break;
      case 'exp':
        result = Math.exp(nums[0]);
        break;
      default:
        throw new Error(`Unknown operator: ${this.operator}`);
    }
    
    return new MathNumber(result);
  }
  
  private applySimplificationRules(operands: IMathObject[]): IMathObject {
    // 代数简化规则
    switch (this.operator) {
      case '+':
        // 0 + x = x
        if (operands.length === 2) {
          if (operands[0] instanceof MathNumber && operands[0].value === 0) {
            return operands[1];
          }
          if (operands[1] instanceof MathNumber && operands[1].value === 0) {
            return operands[0];
          }
        }
        break;
      case '*':
        // 0 * x = 0
        if (operands.some(op => op instanceof MathNumber && op.value === 0)) {
          return new MathNumber(0);
        }
        // 1 * x = x
        if (operands.length === 2) {
          if (operands[0] instanceof MathNumber && operands[0].value === 1) {
            return operands[1];
          }
          if (operands[1] instanceof MathNumber && operands[1].value === 1) {
            return operands[0];
          }
        }
        break;
      case '^':
        // x^0 = 1
        if (operands[1] instanceof MathNumber && operands[1].value === 0) {
          return new MathNumber(1);
        }
        // x^1 = x
        if (operands[1] instanceof MathNumber && operands[1].value === 1) {
          return operands[0];
        }
        break;
    }
    
    return new MathExpression(this.operator, operands);
  }
  
  evaluate(context?: Map<string, any>): IMathObject {
    const evaluatedOperands = this.operands.map(op => op.evaluate(context));
    const expr = new MathExpression(this.operator, evaluatedOperands);
    return expr.simplify();
  }
  
  isConstant(): boolean {
    return this.operands.every(op => op.isConstant());
  }
  
  equals(other: IMathObject): boolean {
    if (other.type !== MathObjectType.EXPRESSION) {
      return false;
    }
    const otherExpr = other as MathExpression;
    if (this.operator !== otherExpr.operator) {
      return false;
    }
    if (this.operands.length !== otherExpr.operands.length) {
      return false;
    }
    return this.operands.every((op, i) => op.equals(otherExpr.operands[i]));
  }
  
  clone(): IMathObject {
    return new MathExpression(
      this.operator,
      this.operands.map(op => op.clone())
    );
  }
}

/**
 * 工厂函数：创建数学对象
 */
export class MathObjectFactory {
  static number(value: number | bigint): MathNumber {
    return new MathNumber(value);
  }
  
  static complex(real: number, imag: number): MathComplex {
    return new MathComplex(real, imag);
  }
  
  static symbol(name: string): MathSymbol {
    return new MathSymbol(name);
  }
  
  static expression(operator: string, ...operands: IMathObject[]): MathExpression {
    return new MathExpression(operator, operands);
  }
  
  static add(...operands: IMathObject[]): MathExpression {
    return new MathExpression('+', operands);
  }
  
  static subtract(a: IMathObject, b: IMathObject): MathExpression {
    return new MathExpression('-', [a, b]);
  }
  
  static multiply(...operands: IMathObject[]): MathExpression {
    return new MathExpression('*', operands);
  }
  
  static divide(a: IMathObject, b: IMathObject): MathExpression {
    return new MathExpression('/', [a, b]);
  }
  
  static power(base: IMathObject, exponent: IMathObject): MathExpression {
    return new MathExpression('^', [base, exponent]);
  }
  
  static sqrt(operand: IMathObject): MathExpression {
    return new MathExpression('sqrt', [operand]);
  }
  
  static sin(operand: IMathObject): MathExpression {
    return new MathExpression('sin', [operand]);
  }
  
  static cos(operand: IMathObject): MathExpression {
    return new MathExpression('cos', [operand]);
  }
  
  static tan(operand: IMathObject): MathExpression {
    return new MathExpression('tan', [operand]);
  }
  
  static log(operand: IMathObject): MathExpression {
    return new MathExpression('log', [operand]);
  }
  
  static ln(operand: IMathObject): MathExpression {
    return new MathExpression('ln', [operand]);
  }
  
  static exp(operand: IMathObject): MathExpression {
    return new MathExpression('exp', [operand]);
  }
}

