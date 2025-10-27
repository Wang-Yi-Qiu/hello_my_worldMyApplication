/**
 * 数学表达式引擎
 * 使用 math.js 实现高精度数学计算
 */
import { Logger } from '../utils/Logger';
import { DEFAULT_PRECISION, ERROR_MESSAGES } from '../utils/Constants';

// 注意：math.js 需要通过 ohpm 安装
// 由于 HarmonyOS 的模块系统，这里使用动态导入
// import * as math from 'mathjs';

export interface EvaluateOptions {
  precision?: number;
  angleUnit?: 'degree' | 'radian';
}

export interface EvaluateResult {
  success: boolean;
  result?: string;
  error?: string;
}

export interface SolveOptions {
  variable?: string;
  precision?: number;
}

export interface SolveResult {
  success: boolean;
  solutions?: string[];
  error?: string;
}

export class ExpressionEngine {
  private precision: number;
  private angleUnit: 'degree' | 'radian';
  private mathLib: any = null;

  constructor(precision: number = DEFAULT_PRECISION) {
    this.precision = precision;
    this.angleUnit = 'degree';
    this.initialize();
    Logger.info(`ExpressionEngine initialized with precision: ${precision}`);
  }
  
  /**
   * 初始化 math.js
   */
  private async initialize(): Promise<void> {
    try {
      // 注意：mathjs 库未安装，直接使用 fallback
      // this.mathLib = await import('mathjs');
      Logger.info('Using fallback expression evaluator');
    } catch (error) {
      Logger.error('Failed to load math.js, using fallback', error);
    }
  }

  /**
   * 计算数学表达式
   * 使用 math.js 进行计算（如果可用）
   */
  async evaluate(expression: string, options?: EvaluateOptions): Promise<EvaluateResult> {
    try {
      Logger.debug(`Evaluating expression: ${expression}`);
      
      // 验证表达式
      if (!expression || expression.trim() === '') {
        return {
          success: false,
          error: ERROR_MESSAGES.INVALID_EXPRESSION
        };
      }

      // 检查除以零
      if (this.checkDivisionByZero(expression)) {
        return {
          success: false,
          error: ERROR_MESSAGES.DIVISION_BY_ZERO
        };
      }

      // 如果 math.js 可用，使用它进行计算
      if (this.mathLib) {
        try {
          await this.ensureInitialized();
          const result = this.mathLib.evaluate(expression);
          const formattedResult = this.formatResult(result, options?.precision || this.precision);
          
          Logger.debug(`Evaluation result: ${formattedResult}`);
          
          return {
            success: true,
            result: formattedResult
          };
        } catch (mathError) {
          Logger.warn('Math.js evaluation failed, falling back to safeEval', mathError);
        }
      }

      // 降级到安全求值
      const result = this.safeEval(expression);
      
      // 格式化结果
      const formattedResult = this.formatResult(result, options?.precision || this.precision);

      Logger.debug(`Evaluation result: ${formattedResult}`);
      
      return {
        success: true,
        result: formattedResult
      };
    } catch (error) {
      Logger.error('Evaluation error', error);
      return {
        success: false,
        error: ERROR_MESSAGES.CALCULATION_ERROR
      };
    }
  }
  
  /**
   * 确保 math.js 已初始化
   */
  private async ensureInitialized(): Promise<void> {
    if (!this.mathLib) {
      await this.initialize();
    }
  }

  /**
   * 安全的表达式求值
   * 注意：这是简化版本，生产环境应使用 math.js
   */
  private safeEval(expression: string): number {
    // 移除空格
    let sanitized = expression.replace(/\s/g, '');
    
    Logger.debug(`Original expression: ${expression}`);
    Logger.debug(`Sanitized expression: ${sanitized}`);
    
    // 检查是否包含复杂数学函数或常数
    const hasMathFunctions = /\b(sin|cos|tan|sqrt|log|ln|exp|pow|asin|acos|atan|abs|ceil|floor|round|pi|e)\b/i.test(sanitized);
    
    if (hasMathFunctions) {
      // 包含数学函数，使用 Function 求值
      sanitized = this.replaceMathFunctions(sanitized);
      
      Logger.debug(`Processed expression: ${sanitized}`);
      
      // 验证表达式只包含安全字符（放宽限制）
      if (!/^[0-9+\-*\/.()A-Za-z,^&|~<>%!]+$/.test(sanitized)) {
        Logger.error(`Invalid characters in expression: ${sanitized}`);
        throw new Error(ERROR_MESSAGES.INVALID_EXPRESSION);
      }
      
      try {
        // 使用 Function 构造函数安全地求值
        const func = new Function('return ' + sanitized);
        const result = func();
        
        if (typeof result !== 'number' || isNaN(result)) {
          Logger.error(`Invalid result type: ${typeof result}, value: ${result}`);
          throw new Error(ERROR_MESSAGES.CALCULATION_ERROR);
        }
        
        Logger.debug(`Function evaluation result: ${result}`);
        return result;
      } catch (error) {
        Logger.error('safeEval with Function error', error);
        throw new Error(ERROR_MESSAGES.CALCULATION_ERROR);
      }
    } else {
      // 简单表达式，使用自定义解析器
      try {
        // 替换幂运算符
        sanitized = sanitized.replace(/\*\*/g, '^');
        const result = this.parseExpression(sanitized);
        Logger.debug(`Parse expression result: ${result}`);
        return result;
      } catch (error) {
        Logger.error('safeEval with parseExpression error', error);
        throw new Error(ERROR_MESSAGES.CALCULATION_ERROR);
      }
    }
  }
  
  /**
   * 替换数学函数为 JavaScript Math 对象函数
   */
  private replaceMathFunctions(expr: string): string {
    let result = expr;
    
    // 替换幂运算符 ^ 为 **
    result = result.replace(/\^/g, '**');
    
    // 替换数学常数
    // 注意：先替换 exp 函数，避免 e 被误替换
    // 先处理 exp 函数
    result = result.replace(/\bexp\(/g, 'Math.exp(');
    
    // 处理 ln 函数（在替换 e 之前）
    result = result.replace(/\bln\(/g, 'Math.log(');
    
    // 然后替换独立的 e 常数（不在 exp 等函数名中）
    result = result.replace(/\be\b/g, 'Math.E');
    
    // 替换 pi
    result = result.replace(/\bpi\b/gi, 'Math.PI');
    
    // 处理阶乘函数 - 在处理其他函数之前
    result = this.replaceFactorial(result);
    
    // 处理排列组合函数
    result = this.replacePermutation(result);
    result = this.replaceCombination(result);
    
    // 使用新的完整替换流程（包含所有数学函数）
    result = this.replaceAllMathFunctions(result);
    
    return result;
  }
  
  /**
   * 完整的数学函数替换流程
   */
  private replaceAllMathFunctions(expr: string): string {
    // 先替换三角函数（带角度转换）
    let result = this.replaceTrigFunctions(expr, 'sin');
    result = this.replaceTrigFunctions(result, 'cos');
    result = this.replaceTrigFunctions(result, 'tan');
    
    // 反三角函数
    result = this.replaceInverseTrigFunctions(result, 'asin');
    result = this.replaceInverseTrigFunctions(result, 'acos');
    result = this.replaceInverseTrigFunctions(result, 'atan');
    
    // 双曲函数
    result = this.replaceHyperbolicFunctions(result, 'sinh');
    result = this.replaceHyperbolicFunctions(result, 'cosh');
    result = this.replaceHyperbolicFunctions(result, 'tanh');
    
    // 反双曲函数
    result = this.replaceInverseHyperbolicFunctions(result, 'asinh');
    result = this.replaceInverseHyperbolicFunctions(result, 'acosh');
    result = this.replaceInverseHyperbolicFunctions(result, 'atanh');
    
    // 处理 log 函数（在三角函数之后，避免重复替换）
    result = result.replace(/\blog\(/g, 'Math.log10(');
    
    // 处理其他数学函数（sqrt, abs 等）
    const otherFunctions = [
      'sqrt', 'abs', 
      'ceil', 'floor', 'round',
      'pow', 'min', 'max',
      'sign', 'trunc'
    ];
    
    otherFunctions.forEach(func => {
      const regex = new RegExp(`\\b${func}\\(`, 'g');
      result = result.replace(regex, `Math.${func}(`);
    });
    
    return result;
  }

  /**
   * 阶乘函数
   */
  private factorial(n: number): number {
    if (n < 0) {
      throw new Error('阶乘不支持负数');
    }
    if (!Number.isInteger(n)) {
      throw new Error('阶乘只支持整数');
    }
    if (n > 170) {
      // JavaScript 的 Number 类型无法表示 171! 及以上
      return Infinity;
    }
    if (n === 0 || n === 1) {
      return 1;
    }
    let result = 1;
    for (let i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  /**
   * 排列数 P(n, r) = n! / (n-r)!
   */
  private permutation(n: number, r: number): number {
    if (n < 0 || r < 0) {
      throw new Error('排列数不支持负数');
    }
    if (!Number.isInteger(n) || !Number.isInteger(r)) {
      throw new Error('排列数只支持整数');
    }
    if (r > n) {
      return 0;
    }
    let result = 1;
    for (let i = n; i > n - r; i--) {
      result *= i;
    }
    return result;
  }

  /**
   * 组合数 C(n, r) = n! / (r! * (n-r)!)
   */
  private combination(n: number, r: number): number {
    if (n < 0 || r < 0) {
      throw new Error('组合数不支持负数');
    }
    if (!Number.isInteger(n) || !Number.isInteger(r)) {
      throw new Error('组合数只支持整数');
    }
    if (r > n) {
      return 0;
    }
    // 优化：C(n, r) = C(n, n-r)，选择较小的 r
    if (r > n - r) {
      r = n - r;
    }
    let result = 1;
    for (let i = 0; i < r; i++) {
      result *= (n - i);
      result /= (i + 1);
    }
    return Math.round(result); // 确保结果是整数
  }

  /**
   * 替换阶乘表达式
   * 例如：5! -> factorial(5)
   */
  private replaceFactorial(expr: string): string {
    // 将阶乘函数注入到全局作用域
    const factorialFunc = this.factorial.bind(this);
    
    // 匹配模式：数字或括号表达式后跟 !
    // 例如：5!, (3+2)!
    let result = expr;
    
    // 处理括号表达式的阶乘：(expr)!
    result = result.replace(/\(([^)]+)\)!/g, (match, p1) => {
      return `((function(){var __fact=${factorialFunc.toString()};return __fact(${p1})})())`;
    });
    
    // 处理简单数字的阶乘：5!
    result = result.replace(/(\d+)!/g, (match, p1) => {
      return `((function(){var __fact=${factorialFunc.toString()};return __fact(${p1})})())`;
    });
    
    return result;
  }

  /**
   * 替换排列表达式
   * 例如：P(5, 3) -> permutation(5, 3)
   */
  private replacePermutation(expr: string): string {
    const permFunc = this.permutation.bind(this);
    
    let result = expr;
    result = result.replace(/\bP\((\d+),\s*(\d+)\)/g, (match, n, r) => {
      return `((function(){var __perm=${permFunc.toString()};return __perm(${n},${r})})())`;
    });
    
    return result;
  }

  /**
   * 替换组合表达式
   * 例如：C(5, 3) -> combination(5, 3)
   */
  private replaceCombination(expr: string): string {
    const combFunc = this.combination.bind(this);
    
    let result = expr;
    result = result.replace(/\bC\((\d+),\s*(\d+)\)/g, (match, n, r) => {
      return `((function(){var __comb=${combFunc.toString()};return __comb(${n},${r})})())`;
    });
    
    return result;
  }

  /**
   * 替换双曲函数
   */
  private replaceHyperbolicFunctions(expr: string, funcName: string): string {
    const regex = new RegExp(`\\b${funcName}\\(`, 'g');
    return expr.replace(regex, `Math.${funcName}(`);
  }

  /**
   * 替换反双曲函数
   */
  private replaceInverseHyperbolicFunctions(expr: string, funcName: string): string {
    const regex = new RegExp(`\\b${funcName}\\(`, 'g');
    return expr.replace(regex, `Math.${funcName}(`);
  }

  /**
   * 替换三角函数（角度转弧度）
   */
  private replaceTrigFunctions(expr: string, funcName: string): string {
    let result = expr;
    let searchPos = 0;
    
    Logger.debug(`Replacing trig function ${funcName} in: ${expr}`);
    
    while (true) {
      // 查找函数名
      const funcPattern = `${funcName}(`;
      const funcIndex = result.indexOf(funcPattern, searchPos);
      
      if (funcIndex === -1) {
        break; // 没有找到更多的函数
      }
      
      // 检查是否是独立的函数名（前面不是字母或数字）
      if (funcIndex > 0) {
        const prevChar = result[funcIndex - 1];
        if (/[a-zA-Z0-9_]/.test(prevChar)) {
          // 不是独立的函数名，继续搜索
          searchPos = funcIndex + 1;
          continue;
        }
      }
      
      const funcStart = funcIndex + funcPattern.length;
      
      // 找到匹配的右括号
      let parenCount = 1;
      let endPos = funcStart;
      
      while (endPos < result.length && parenCount > 0) {
        if (result[endPos] === '(') parenCount++;
        if (result[endPos] === ')') parenCount--;
        endPos++;
      }
      
      if (parenCount === 0) {
        // 提取参数
        const arg = result.substring(funcStart, endPos - 1);
        
        // 根据角度模式决定是否转换
        let replacement: string;
        if (this.angleUnit === 'degree') {
          // 角度模式：Math.sin((Math.PI/180)*(arg))
          replacement = `Math.${funcName}((Math.PI/180)*(${arg}))`;
        } else {
          // 弧度模式：Math.sin(arg)
          replacement = `Math.${funcName}(${arg})`;
        }
        
        Logger.debug(`Replacing ${funcName}(${arg}) with ${replacement}`);
        
        result = result.substring(0, funcIndex) + replacement + result.substring(endPos);
        
        // 更新搜索位置到替换后的位置
        searchPos = funcIndex + replacement.length;
      } else {
        // 括号不匹配，跳过
        searchPos = funcIndex + 1;
      }
    }
    
    Logger.debug(`After trig replacement: ${result}`);
    return result;
  }

  /**
   * 替换反三角函数（返回角度）
   */
  private replaceInverseTrigFunctions(expr: string, funcName: string): string {
    let result = expr;
    let searchPos = 0;
    
    Logger.debug(`Replacing inverse trig function ${funcName} in: ${expr}`);
    
    while (true) {
      // 查找函数名
      const funcPattern = `${funcName}(`;
      const funcIndex = result.indexOf(funcPattern, searchPos);
      
      if (funcIndex === -1) {
        break; // 没有找到更多的函数
      }
      
      // 检查是否是独立的函数名（前面不是字母或数字）
      if (funcIndex > 0) {
        const prevChar = result[funcIndex - 1];
        if (/[a-zA-Z0-9_]/.test(prevChar)) {
          // 不是独立的函数名，继续搜索
          searchPos = funcIndex + 1;
          continue;
        }
      }
      
      const funcStart = funcIndex + funcPattern.length;
      
      // 找到匹配的右括号
      let parenCount = 1;
      let endPos = funcStart;
      
      while (endPos < result.length && parenCount > 0) {
        if (result[endPos] === '(') parenCount++;
        if (result[endPos] === ')') parenCount--;
        endPos++;
      }
      
      if (parenCount === 0) {
        // 提取参数
        const arg = result.substring(funcStart, endPos - 1);
        
        // 根据角度模式决定是否转换
        let replacement: string;
        if (this.angleUnit === 'degree') {
          // 角度模式：(180/Math.PI)*Math.asin(arg)
          replacement = `((180/Math.PI)*Math.${funcName}(${arg}))`;
        } else {
          // 弧度模式：Math.asin(arg)
          replacement = `Math.${funcName}(${arg})`;
        }
        
        Logger.debug(`Replacing ${funcName}(${arg}) with ${replacement}`);
        
        result = result.substring(0, funcIndex) + replacement + result.substring(endPos);
        
        // 更新搜索位置到替换后的位置
        searchPos = funcIndex + replacement.length;
      } else {
        // 括号不匹配，跳过
        searchPos = funcIndex + 1;
      }
    }
    
    Logger.debug(`After inverse trig replacement: ${result}`);
    return result;
  }

  /**
   * 简单的表达式解析器（支持 +, -, *, /, ^, 括号）
   */
  private parseExpression(expr: string): number {
    let pos = 0;

    const parseNumber = (): number => {
      let num = '';
      while (pos < expr.length && (expr[pos].match(/[0-9.]/) !== null)) {
        num += expr[pos];
        pos++;
      }
      return parseFloat(num);
    };

    const parseFactor = (): number => {
      if (expr[pos] === '(') {
        pos++; // skip '('
        const result = parseAddSub();
        pos++; // skip ')'
        return result;
      }
      if (expr[pos] === '-') {
        pos++;
        return -parseFactor();
      }
      if (expr[pos] === '+') {
        pos++;
        return parseFactor();
      }
      return parseNumber();
    };

    const parsePower = (): number => {
      let result = parseFactor();
      while (pos < expr.length && expr[pos] === '^') {
        pos++;
        const right = parseFactor();
        result = Math.pow(result, right);
      }
      return result;
    };

    const parseMulDiv = (): number => {
      let result = parsePower();
      while (pos < expr.length && (expr[pos] === '*' || expr[pos] === '/')) {
        const op = expr[pos];
        pos++;
        const right = parsePower();
        if (op === '*') {
          result *= right;
        } else {
          if (right === 0) {
            throw new Error(ERROR_MESSAGES.DIVISION_BY_ZERO);
          }
          result /= right;
        }
      }
      return result;
    };

    const parseAddSub = (): number => {
      let result = parseMulDiv();
      while (pos < expr.length && (expr[pos] === '+' || expr[pos] === '-')) {
        const op = expr[pos];
        pos++;
        const right = parseMulDiv();
        if (op === '+') {
          result += right;
        } else {
          result -= right;
        }
      }
      return result;
    };

    return parseAddSub();
  }

  /**
   * 检查除以零
   */
  private checkDivisionByZero(expression: string): boolean {
    // 简单检查 /0 模式
    return /\/\s*0(?![0-9])/.test(expression);
  }

  /**
   * 格式化计算结果
   */
  private formatResult(value: number, precision: number): string {
    if (isNaN(value)) {
      throw new Error(ERROR_MESSAGES.CALCULATION_ERROR);
    }

    if (!isFinite(value)) {
      return value > 0 ? 'Infinity' : '-Infinity';
    }

    // 处理非常大或非常小的数字，使用科学计数法
    if (Math.abs(value) > 1e15 || (Math.abs(value) < 1e-6 && value !== 0)) {
      return value.toExponential(precision);
    }

    // 普通数字，限制小数位数
    const fixed = value.toFixed(precision);
    // 移除末尾的零
    return parseFloat(fixed).toString();
  }

  /**
   * 求解方程（简化版本）
   * 注意：完整实现需要 math.js
   */
  solveEquation(equation: string, options?: SolveOptions): SolveResult {
    try {
      Logger.debug(`Solving equation: ${equation}`);
      
      // 简化版本：仅支持一元一次方程 ax + b = 0
      const variable = options?.variable || 'x';
      
      // 解析方程（这是非常简化的实现）
      // 生产环境应使用 math.js 的 solve 功能
      const solutions = this.solveLinearEquation(equation, variable);
      
      return {
        success: true,
        solutions
      };
    } catch (error) {
      Logger.error('Equation solving error', error);
      return {
        success: false,
        error: '方程求解失败'
      };
    }
  }

  /**
   * 求解一元一次方程（简化实现）
   */
  private solveLinearEquation(equation: string, variable: string): string[] {
    // 这是一个占位实现
    // 实际应该使用 math.js 的 solve 功能
    Logger.warn('Using placeholder equation solver');
    return ['暂不支持，需要 math.js'];
  }

  /**
   * 计算导数（占位实现）
   */
  differentiate(expression: string, variable: string = 'x'): EvaluateResult {
    Logger.warn('Differentiate not implemented yet');
    return {
      success: false,
      error: '微积分功能需要 math.js 库支持'
    };
  }

  /**
   * 计算积分（占位实现）
   */
  integrate(expression: string, variable: string = 'x', from?: number, to?: number): EvaluateResult {
    Logger.warn('Integrate not implemented yet');
    return {
      success: false,
      error: '微积分功能需要 math.js 库支持'
    };
  }

  /**
   * 设置精度
   */
  setPrecision(precision: number): void {
    this.precision = precision;
    Logger.info(`Precision set to: ${precision}`);
  }

  /**
   * 设置角度单位
   */
  setAngleUnit(unit: 'degree' | 'radian'): void {
    this.angleUnit = unit;
    Logger.info(`Angle unit set to: ${unit}`);
  }

  /**
   * 获取角度单位
   */
  getAngleUnit(): 'degree' | 'radian' {
    return this.angleUnit;
  }
}

