/**
 * 统一计算引擎
 * 参考 SageMath 的架构，整合所有计算功能
 * 使用 math.js 提供强大的计算能力
 */
import { Logger } from '../utils/Logger';
import { 
  IMathObject, 
  MathObject, 
  MathNumber, 
  MathComplex, 
  MathSymbol, 
  MathExpression,
  MathObjectFactory,
  MathObjectType 
} from './MathObject';
import { SymPyLikeEngine, ComputeResult as SymPyResult } from './SymPyLikeEngine';

/**
 * 计算结果接口
 */
export interface ComputeResult {
  success: boolean;
  result?: IMathObject;
  latex?: string;
  numeric?: number;
  error?: string;
  steps?: string[];
  metadata?: Map<string, any>;
}

/**
 * 计算选项
 */
export interface ComputeOptions {
  precision?: number;
  simplify?: boolean;
  symbolic?: boolean;
  numeric?: boolean;
  steps?: boolean;
  angleUnit?: 'degree' | 'radian';
  domain?: 'real' | 'complex';
}

/**
 * 统一计算引擎类
 */
export class UnifiedComputeEngine {
  private precision: number;
  private angleUnit: 'degree' | 'radian';
  private domain: 'real' | 'complex';
  private context: Map<string, IMathObject>;
  private symPyEngine: SymPyLikeEngine;
  
  constructor(precision: number = 10) {
    this.precision = precision;
    this.angleUnit = 'degree';
    this.domain = 'real';
    this.context = new Map();
    this.symPyEngine = new SymPyLikeEngine();
    
    // 初始化数学常数
    this.initializeConstants();
    
    Logger.info('UnifiedComputeEngine initialized with SymPy-like engine');
  }
  
  /**
   * 初始化数学常数
   */
  private initializeConstants(): void {
    this.context.set('pi', MathObjectFactory.number(Math.PI));
    this.context.set('e', MathObjectFactory.number(Math.E));
    this.context.set('i', MathObjectFactory.complex(0, 1));
    this.context.set('infinity', MathObjectFactory.number(Infinity));
  }
  
  /**
   * 主计算接口
   * 使用 SymPy 风格引擎进行计算
   */
  async compute(input: string | IMathObject, options?: ComputeOptions): Promise<ComputeResult> {
    try {
      const inputStr = typeof input === 'string' ? input : input.toString();
      Logger.debug(`Computing: ${inputStr}`);
      
      // 使用 SymPy 风格引擎
      const symPyResult = await this.symPyEngine.evaluate(inputStr);
      
      if (!symPyResult.success) {
        return {
          success: false,
          error: symPyResult.error || '计算失败'
        };
      }
      
      // 应用选项
      const opts = this.mergeOptions(options);
      const steps: string[] = [];
      
      if (opts.steps) {
        steps.push(`原始表达式: ${inputStr}`);
        steps.push(`计算结果: ${symPyResult.display}`);
      }
      
      return {
        success: true,
        result: symPyResult.result,
        latex: symPyResult.latex,
        numeric: symPyResult.value,
        steps: opts.steps ? steps : undefined
      };
    } catch (error) {
      Logger.error('Compute error', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : '计算错误'
      };
    }
  }
  
  /**
   * 解析字符串为数学对象
   */
  parse(input: string): IMathObject {
    // 简化的解析器实现
    // 实际应该使用完整的表达式解析器
    
    input = input.trim();
    
    // 尝试解析为数字
    const num = parseFloat(input);
    if (!isNaN(num)) {
      return MathObjectFactory.number(num);
    }
    
    // 检查是否为符号
    if (/^[a-zA-Z_][a-zA-Z0-9_]*$/.test(input)) {
      return MathObjectFactory.symbol(input);
    }
    
    // 解析表达式
    return this.parseExpression(input);
  }
  
  /**
   * 解析表达式（递归下降解析器）
   */
  private parseExpression(input: string): IMathObject {
    // 移除空格
    input = input.replace(/\s+/g, '');
    
    // 解析加减法
    return this.parseAddSub(input);
  }
  
  private parseAddSub(input: string): IMathObject {
    const terms = this.splitByOperator(input, ['+', '-']);
    if (terms.length === 1) {
      return this.parseMulDiv(terms[0].value);
    }
    
    let result = this.parseMulDiv(terms[0].value);
    for (let i = 1; i < terms.length; i++) {
      const term = this.parseMulDiv(terms[i].value);
      if (terms[i].operator === '+') {
        result = MathObjectFactory.add(result, term);
      } else {
        result = MathObjectFactory.subtract(result, term);
      }
    }
    return result;
  }
  
  private parseMulDiv(input: string): IMathObject {
    const factors = this.splitByOperator(input, ['*', '/']);
    if (factors.length === 1) {
      return this.parsePower(factors[0].value);
    }
    
    let result = this.parsePower(factors[0].value);
    for (let i = 1; i < factors.length; i++) {
      const factor = this.parsePower(factors[i].value);
      if (factors[i].operator === '*') {
        result = MathObjectFactory.multiply(result, factor);
      } else {
        result = MathObjectFactory.divide(result, factor);
      }
    }
    return result;
  }
  
  private parsePower(input: string): IMathObject {
    const parts = this.splitByOperator(input, ['^']);
    if (parts.length === 1) {
      return this.parsePrimary(parts[0].value);
    }
    
    // 右结合
    let result = this.parsePrimary(parts[parts.length - 1].value);
    for (let i = parts.length - 2; i >= 0; i--) {
      const base = this.parsePrimary(parts[i].value);
      result = MathObjectFactory.power(base, result);
    }
    return result;
  }
  
  private parsePrimary(input: string): IMathObject {
    // 处理括号
    if (input.startsWith('(') && input.endsWith(')')) {
      return this.parseExpression(input.slice(1, -1));
    }
    
    // 处理函数调用
    const funcMatch = input.match(/^([a-zA-Z]+)\((.+)\)$/);
    if (funcMatch) {
      const funcName = funcMatch[1];
      const arg = this.parseExpression(funcMatch[2]);
      
      switch (funcName) {
        case 'sin':
          return MathObjectFactory.sin(arg);
        case 'cos':
          return MathObjectFactory.cos(arg);
        case 'tan':
          return MathObjectFactory.tan(arg);
        case 'sqrt':
          return MathObjectFactory.sqrt(arg);
        case 'log':
          return MathObjectFactory.log(arg);
        case 'ln':
          return MathObjectFactory.ln(arg);
        case 'exp':
          return MathObjectFactory.exp(arg);
        default:
          return MathObjectFactory.expression(funcName, arg);
      }
    }
    
    // 处理负号
    if (input.startsWith('-')) {
      const operand = this.parsePrimary(input.slice(1));
      return MathObjectFactory.multiply(MathObjectFactory.number(-1), operand);
    }
    
    // 尝试解析为数字
    const num = parseFloat(input);
    if (!isNaN(num)) {
      return MathObjectFactory.number(num);
    }
    
    // 解析为符号
    return MathObjectFactory.symbol(input);
  }
  
  /**
   * 按运算符分割字符串
   */
  private splitByOperator(input: string, operators: string[]): Array<{operator: string, value: string}> {
    const result: Array<{operator: string, value: string}> = [];
    let current = '';
    let depth = 0;
    let lastOp = '';
    
    for (let i = 0; i < input.length; i++) {
      const char = input[i];
      
      if (char === '(') {
        depth++;
        current += char;
      } else if (char === ')') {
        depth--;
        current += char;
      } else if (depth === 0 && operators.includes(char)) {
        if (current) {
          result.push({ operator: lastOp, value: current });
          current = '';
        }
        lastOp = char;
      } else {
        current += char;
      }
    }
    
    if (current) {
      result.push({ operator: lastOp, value: current });
    }
    
    return result;
  }
  
  /**
   * 合并选项
   */
  private mergeOptions(options?: ComputeOptions): Required<ComputeOptions> {
    return {
      precision: options?.precision ?? this.precision,
      simplify: options?.simplify ?? true,
      symbolic: options?.symbolic ?? false,
      numeric: options?.numeric ?? true,
      steps: options?.steps ?? false,
      angleUnit: options?.angleUnit ?? this.angleUnit,
      domain: options?.domain ?? this.domain
    };
  }
  
  /**
   * 求导
   * 使用 SymPy 风格引擎
   */
  async differentiate(expr: string | IMathObject, variable: string = 'x', options?: ComputeOptions): Promise<ComputeResult> {
    try {
      const exprStr = typeof expr === 'string' ? expr : expr.toString();
      
      // 使用 SymPy 风格引擎求导
      const symPyResult = await this.symPyEngine.differentiate(exprStr, variable);
      
      if (!symPyResult.success) {
        return {
          success: false,
          error: symPyResult.error || '求导失败'
        };
      }
      
      const opts = this.mergeOptions(options);
      const steps: string[] = [];
      
      if (opts.steps) {
        steps.push(`原始函数: ${exprStr}`);
        steps.push(`导数结果: ${symPyResult.display}`);
      }
      
      return {
        success: true,
        result: symPyResult.result,
        latex: symPyResult.latex,
        numeric: symPyResult.value,
        steps: opts.steps ? steps : undefined
      };
    } catch (error) {
      Logger.error('Differentiate error', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : '求导失败'
      };
    }
  }
  
  /**
   * 计算导数（符号求导）
   */
  private computeDerivative(expr: IMathObject, variable: IMathObject): IMathObject {
    // 常数的导数为 0
    if (expr.isConstant()) {
      return MathObjectFactory.number(0);
    }
    
    // 变量的导数
    if (expr instanceof MathSymbol) {
      return expr.equals(variable) ? MathObjectFactory.number(1) : MathObjectFactory.number(0);
    }
    
    // 表达式的导数
    if (expr instanceof MathExpression) {
      return this.differentiateExpression(expr, variable);
    }
    
    return MathObjectFactory.number(0);
  }
  
  /**
   * 对表达式求导
   */
  private differentiateExpression(expr: MathExpression, variable: IMathObject): IMathObject {
    const { operator, operands } = expr;
    
    switch (operator) {
      case '+':
        // (f + g)' = f' + g'
        return MathObjectFactory.add(
          ...operands.map(op => this.computeDerivative(op, variable))
        );
        
      case '-':
        if (operands.length === 1) {
          // (-f)' = -f'
          return MathObjectFactory.multiply(
            MathObjectFactory.number(-1),
            this.computeDerivative(operands[0], variable)
          );
        }
        // (f - g)' = f' - g'
        return MathObjectFactory.subtract(
          this.computeDerivative(operands[0], variable),
          this.computeDerivative(operands[1], variable)
        );
        
      case '*':
        // 乘法法则: (f * g)' = f' * g + f * g'
        if (operands.length === 2) {
          const f = operands[0];
          const g = operands[1];
          const df = this.computeDerivative(f, variable);
          const dg = this.computeDerivative(g, variable);
          
          return MathObjectFactory.add(
            MathObjectFactory.multiply(df, g),
            MathObjectFactory.multiply(f, dg)
          );
        }
        break;
        
      case '/':
        // 商法则: (f / g)' = (f' * g - f * g') / g^2
        const f = operands[0];
        const g = operands[1];
        const df = this.computeDerivative(f, variable);
        const dg = this.computeDerivative(g, variable);
        
        return MathObjectFactory.divide(
          MathObjectFactory.subtract(
            MathObjectFactory.multiply(df, g),
            MathObjectFactory.multiply(f, dg)
          ),
          MathObjectFactory.power(g, MathObjectFactory.number(2))
        );
        
      case '^':
        // 幂法则: (f^n)' = n * f^(n-1) * f'
        const base = operands[0];
        const exponent = operands[1];
        
        if (exponent.isConstant()) {
          const df = this.computeDerivative(base, variable);
          return MathObjectFactory.multiply(
            MathObjectFactory.multiply(
              exponent,
              MathObjectFactory.power(
                base,
                MathObjectFactory.subtract(exponent, MathObjectFactory.number(1))
              )
            ),
            df
          );
        }
        break;
        
      case 'sin':
        // (sin(f))' = cos(f) * f'
        const sinArg = operands[0];
        const dSinArg = this.computeDerivative(sinArg, variable);
        return MathObjectFactory.multiply(
          MathObjectFactory.cos(sinArg),
          dSinArg
        );
        
      case 'cos':
        // (cos(f))' = -sin(f) * f'
        const cosArg = operands[0];
        const dCosArg = this.computeDerivative(cosArg, variable);
        return MathObjectFactory.multiply(
          MathObjectFactory.multiply(MathObjectFactory.number(-1), MathObjectFactory.sin(cosArg)),
          dCosArg
        );
        
      case 'tan':
        // (tan(f))' = sec^2(f) * f' = (1/cos^2(f)) * f'
        const tanArg = operands[0];
        const dTanArg = this.computeDerivative(tanArg, variable);
        return MathObjectFactory.multiply(
          MathObjectFactory.divide(
            MathObjectFactory.number(1),
            MathObjectFactory.power(MathObjectFactory.cos(tanArg), MathObjectFactory.number(2))
          ),
          dTanArg
        );
        
      case 'ln':
        // (ln(f))' = f' / f
        const lnArg = operands[0];
        const dLnArg = this.computeDerivative(lnArg, variable);
        return MathObjectFactory.divide(dLnArg, lnArg);
        
      case 'exp':
        // (e^f)' = e^f * f'
        const expArg = operands[0];
        const dExpArg = this.computeDerivative(expArg, variable);
        return MathObjectFactory.multiply(
          MathObjectFactory.exp(expArg),
          dExpArg
        );
        
      case 'sqrt':
        // (sqrt(f))' = f' / (2 * sqrt(f))
        const sqrtArg = operands[0];
        const dSqrtArg = this.computeDerivative(sqrtArg, variable);
        return MathObjectFactory.divide(
          dSqrtArg,
          MathObjectFactory.multiply(
            MathObjectFactory.number(2),
            MathObjectFactory.sqrt(sqrtArg)
          )
        );
    }
    
    // 未知运算符，返回符号导数
    return MathObjectFactory.expression('derivative', expr, variable);
  }
  
  /**
   * 积分
   * 使用 SymPy 风格引擎
   */
  async integrate(expr: string | IMathObject, variable: string = 'x', 
            from?: number, to?: number, options?: ComputeOptions): Promise<ComputeResult> {
    try {
      const exprStr = typeof expr === 'string' ? expr : expr.toString();
      
      if (from !== undefined && to !== undefined) {
        // 定积分（数值方法）
        const symPyResult = await this.symPyEngine.integrateDefinite(exprStr, variable, from, to);
        
        if (!symPyResult.success) {
          return {
            success: false,
            error: symPyResult.error || '定积分计算失败'
          };
        }
        
        return {
          success: true,
          result: symPyResult.result,
          latex: symPyResult.latex,
          numeric: symPyResult.value
        };
      } else {
        // 不定积分（符号方法）
        const symPyResult = await this.symPyEngine.integrate(exprStr, variable);
        
        if (!symPyResult.success) {
          return {
            success: false,
            error: symPyResult.error || '积分失败'
          };
        }
        
        const opts = this.mergeOptions(options);
        
        return {
          success: true,
          result: symPyResult.result,
          latex: symPyResult.latex
        };
      }
    } catch (error) {
      Logger.error('Integrate error', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : '积分失败'
      };
    }
  }
  
  /**
   * 计算不定积分（符号积分）
   */
  private computeIntegral(expr: IMathObject, variable: IMathObject): IMathObject {
    // 常数的积分
    if (expr.isConstant()) {
      return MathObjectFactory.multiply(expr, variable);
    }
    
    // 变量的积分: ∫x dx = x^2/2
    if (expr instanceof MathSymbol && expr.equals(variable)) {
      return MathObjectFactory.divide(
        MathObjectFactory.power(variable, MathObjectFactory.number(2)),
        MathObjectFactory.number(2)
      );
    }
    
    // 表达式的积分
    if (expr instanceof MathExpression) {
      return this.integrateExpression(expr, variable);
    }
    
    // 未知情况，返回符号积分
    return MathObjectFactory.expression('integral', expr, variable);
  }
  
  /**
   * 对表达式积分
   */
  private integrateExpression(expr: MathExpression, variable: IMathObject): IMathObject {
    const { operator, operands } = expr;
    
    switch (operator) {
      case '+':
        // ∫(f + g) dx = ∫f dx + ∫g dx
        return MathObjectFactory.add(
          ...operands.map(op => this.computeIntegral(op, variable))
        );
        
      case '-':
        if (operands.length === 2) {
          // ∫(f - g) dx = ∫f dx - ∫g dx
          return MathObjectFactory.subtract(
            this.computeIntegral(operands[0], variable),
            this.computeIntegral(operands[1], variable)
          );
        }
        break;
        
      case '*':
        // 检查是否为常数乘以函数
        if (operands.length === 2) {
          if (operands[0].isConstant()) {
            // ∫(c * f) dx = c * ∫f dx
            return MathObjectFactory.multiply(
              operands[0],
              this.computeIntegral(operands[1], variable)
            );
          }
          if (operands[1].isConstant()) {
            // ∫(f * c) dx = c * ∫f dx
            return MathObjectFactory.multiply(
              operands[1],
              this.computeIntegral(operands[0], variable)
            );
          }
        }
        break;
        
      case '^':
        // 幂函数积分: ∫x^n dx = x^(n+1)/(n+1)
        if (operands[0].equals(variable) && operands[1].isConstant()) {
          const n = operands[1];
          const nPlusOne = MathObjectFactory.add(n, MathObjectFactory.number(1));
          return MathObjectFactory.divide(
            MathObjectFactory.power(variable, nPlusOne),
            nPlusOne
          );
        }
        break;
    }
    
    // 未知情况，返回符号积分
    return MathObjectFactory.expression('integral', expr, variable);
  }
  
  /**
   * 数值积分（辛普森法则）
   */
  private numericalIntegrate(expr: IMathObject, variable: string, 
                            from: number, to: number, options?: ComputeOptions): ComputeResult {
    const n = 1000; // 分段数
    const h = (to - from) / n;
    
    const context = new Map(this.context);
    const varSymbol = MathObjectFactory.symbol(variable);
    
    const f = (x: number): number => {
      context.set(variable, MathObjectFactory.number(x));
      const result = expr.evaluate(context);
      if (result instanceof MathNumber) {
        return Number(result.value);
      }
      throw new Error('无法求值为数值');
    };
    
    let sum = f(from) + f(to);
    for (let i = 1; i < n; i++) {
      const x = from + i * h;
      sum += (i % 2 === 0 ? 2 : 4) * f(x);
    }
    
    const value = (h / 3) * sum;
    
    return {
      success: true,
      result: MathObjectFactory.number(value),
      latex: value.toFixed(this.precision),
      numeric: value
    };
  }
  
  /**
   * 求极限
   * 使用增强的 CalculusEngine 进行极限计算
   */
  limit(expr: string | IMathObject, variable: string, approachValue: number | string,
        direction?: 'left' | 'right', options?: ComputeOptions): ComputeResult {
    try {
      // 导入 CalculusEngine
      const { CalculusEngine } = require('../modules/CalculusEngine');
      const calculusEngine = new CalculusEngine();
      
      // 转换表达式为字符串
      const expression = typeof expr === 'string' ? expr : expr.toString();
      
      // 处理无穷大
      let approach: number;
      if (approachValue === 'infinity' || approachValue === 'inf') {
        approach = Infinity;
      } else if (approachValue === '-infinity' || approachValue === '-inf') {
        approach = -Infinity;
      } else {
        approach = typeof approachValue === 'number' ? approachValue : parseFloat(approachValue);
      }
      
      // 使用 CalculusEngine 计算极限
      const limitResult = calculusEngine.limit(
        expression, 
        variable, 
        approach,
        direction === 'left',
        direction === 'right'
      );
      
      if (!limitResult.success) {
        return {
          success: false,
          error: limitResult.error,
          steps: limitResult.steps
        };
      }
      
      // 解析结果
      const limitValue = limitResult.limit || '0';
      let numericValue: number | undefined;
      
      if (limitValue === '+∞' || limitValue === 'Infinity') {
        numericValue = Infinity;
      } else if (limitValue === '-∞' || limitValue === '-Infinity') {
        numericValue = -Infinity;
      } else {
        numericValue = parseFloat(limitValue);
      }
      
      const result = MathObjectFactory.number(numericValue);
      
      return {
        success: true,
        result: result,
        latex: this.formatLimitLatex(expression, variable, approach, limitValue),
        numeric: numericValue,
        steps: limitResult.steps
      };
    } catch (error) {
      Logger.error('Limit error', error);
      
      // 降级到简单的数值方法
      try {
        const mathObj = typeof expr === 'string' ? this.parse(expr) : expr;
        const approach = typeof approachValue === 'number' ? approachValue : 
                        approachValue === 'infinity' ? Infinity : 
                        approachValue === '-infinity' ? -Infinity : 
                        parseFloat(approachValue);
        const result = this.numericalLimit(mathObj, variable, approach, direction);
        
        return {
          success: true,
          result: result,
          latex: result.toLatex(),
          numeric: result instanceof MathNumber ? Number(result.value) : undefined
        };
      } catch (fallbackError) {
        return {
          success: false,
          error: error instanceof Error ? error.message : '极限计算失败'
        };
      }
    }
  }
  
  /**
   * 格式化极限的 LaTeX 表示
   */
  private formatLimitLatex(expression: string, variable: string, 
                          approach: number, limitValue: string): string {
    const approachStr = approach === Infinity ? '\\infty' : 
                       approach === -Infinity ? '-\\infty' : 
                       approach.toString();
    const limitStr = limitValue === '+∞' ? '+\\infty' : 
                    limitValue === '-∞' ? '-\\infty' : 
                    limitValue;
    
    return `\\lim_{${variable} \\to ${approachStr}} ${expression} = ${limitStr}`;
  }
  
  /**
   * 数值方法计算极限（降级方案）
   */
  private numericalLimit(expr: IMathObject, variable: string, 
                        approach: number, direction?: 'left' | 'right'): IMathObject {
    const context = new Map(this.context);
    
    const evaluate = (x: number): number => {
      context.set(variable, MathObjectFactory.number(x));
      const result = expr.evaluate(context);
      if (result instanceof MathNumber) {
        return Number(result.value);
      }
      throw new Error('无法求值为数值');
    };
    
    let testValue: number;
    if (approach === Infinity) {
      testValue = evaluate(1e10);
    } else if (approach === -Infinity) {
      testValue = evaluate(-1e10);
    } else {
      const epsilon = 1e-10;
      if (direction === 'left') {
        testValue = evaluate(approach - epsilon);
      } else if (direction === 'right') {
        testValue = evaluate(approach + epsilon);
      } else {
        const leftValue = evaluate(approach - epsilon);
        const rightValue = evaluate(approach + epsilon);
        if (Math.abs(leftValue - rightValue) < 1e-6) {
          testValue = (leftValue + rightValue) / 2;
        } else {
          throw new Error('左右极限不相等，极限不存在 (DNE)');
        }
      }
    }
    
    return MathObjectFactory.number(testValue);
  }
  
  /**
   * 设置变量
   */
  setVariable(name: string, value: number | IMathObject): void {
    if (typeof value === 'number') {
      this.context.set(name, MathObjectFactory.number(value));
    } else {
      this.context.set(name, value);
    }
  }
  
  /**
   * 获取变量
   */
  getVariable(name: string): IMathObject | undefined {
    return this.context.get(name);
  }
  
  /**
   * 清除变量
   */
  clearVariable(name: string): void {
    this.context.delete(name);
  }
  
  /**
   * 清除所有变量（保留常数）
   */
  clearAllVariables(): void {
    const constants = ['pi', 'e', 'i', 'infinity'];
    for (const key of this.context.keys()) {
      if (!constants.includes(key)) {
        this.context.delete(key);
      }
    }
  }
  
  /**
   * 设置精度
   */
  setPrecision(precision: number): void {
    this.precision = precision;
  }
  
  /**
   * 设置角度单位
   */
  setAngleUnit(unit: 'degree' | 'radian'): void {
    this.angleUnit = unit;
  }
  
  /**
   * 设置定义域
   */
  setDomain(domain: 'real' | 'complex'): void {
    this.domain = domain;
  }
}

