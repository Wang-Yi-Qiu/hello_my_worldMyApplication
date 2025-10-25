/**
 * 微积分计算引擎
 * 支持导数、积分、极限等运算
 */
import { Logger } from '../utils/Logger';
import { ERROR_MESSAGES } from '../utils/Constants';

export interface DerivativeResult {
  success: boolean;
  derivative?: string;
  error?: string;
  steps?: string[];
}

export interface IntegralResult {
  success: boolean;
  integral?: string;
  value?: number;
  error?: string;
  steps?: string[];
}

export interface LimitResult {
  success: boolean;
  limit?: string;
  error?: string;
  steps?: string[];
}

/**
 * 微积分引擎类
 */
export class CalculusEngine {
  
  /**
   * 数值求导（使用中心差分法）
   */
  numericalDerivative(f: (x: number) => number, x: number, h: number = 1e-5): number {
    return (f(x + h) - f(x - h)) / (2 * h);
  }
  
  /**
   * 符号求导（简化实现，支持基本函数）
   */
  symbolicDerivative(expression: string, variable: string = 'x'): DerivativeResult {
    try {
      Logger.info(`Computing derivative of ${expression} with respect to ${variable}`);
      
      const steps: string[] = [];
      steps.push(`原函数: f(${variable}) = ${expression}`);
      
      // 简化的符号求导实现
      // 实际应该使用 math.js 的 derivative 功能
      
      // 幂函数：x^n -> n*x^(n-1)
      const powerMatch = expression.match(/(\d*)\*?x\^(\d+)/);
      if (powerMatch) {
        const coef = powerMatch[1] ? parseInt(powerMatch[1]) : 1;
        const power = parseInt(powerMatch[2]);
        const newCoef = coef * power;
        const newPower = power - 1;
        
        const derivative = newPower === 0 ? `${newCoef}` :
                          newPower === 1 ? `${newCoef}x` :
                          `${newCoef}x^${newPower}`;
        
        steps.push(`使用幂函数求导法则: (x^n)' = n*x^(n-1)`);
        steps.push(`f'(${variable}) = ${derivative}`);
        
        return {
          success: true,
          derivative,
          steps
        };
      }
      
      // 线性函数：ax + b -> a
      const linearMatch = expression.match(/(\d*)\*?x\s*\+?\s*(\d*)/);
      if (linearMatch) {
        const coef = linearMatch[1] ? parseInt(linearMatch[1]) : 1;
        
        steps.push(`使用线性函数求导法则`);
        steps.push(`f'(${variable}) = ${coef}`);
        
        return {
          success: true,
          derivative: coef.toString(),
          steps
        };
      }
      
      // 常数函数
      if (!expression.includes(variable)) {
        steps.push(`常数函数的导数为 0`);
        steps.push(`f'(${variable}) = 0`);
        
        return {
          success: true,
          derivative: '0',
          steps
        };
      }
      
      return {
        success: false,
        error: '暂不支持该函数的符号求导，请使用 math.js 完整版'
      };
    } catch (error) {
      Logger.error('Derivative calculation error', error);
      return {
        success: false,
        error: ERROR_MESSAGES.CALCULATION_ERROR
      };
    }
  }
  
  /**
   * 数值积分（使用辛普森法则）
   */
  numericalIntegral(f: (x: number) => number, a: number, b: number, n: number = 1000): number {
    if (n % 2 !== 0) n++; // 确保 n 是偶数
    
    const h = (b - a) / n;
    let sum = f(a) + f(b);
    
    for (let i = 1; i < n; i++) {
      const x = a + i * h;
      sum += (i % 2 === 0 ? 2 : 4) * f(x);
    }
    
    return (h / 3) * sum;
  }
  
  /**
   * 定积分计算
   */
  definiteIntegral(expression: string, variable: string, from: number, to: number): IntegralResult {
    try {
      Logger.info(`Computing integral of ${expression} from ${from} to ${to}`);
      
      const steps: string[] = [];
      const fromStr = from === Math.PI ? 'π' : from.toString();
      const toStr = to === Math.PI ? 'π' : to.toString();
      steps.push(`计算定积分: ∫[${fromStr}, ${toStr}] ${expression} d${variable}`);
      steps.push(`被积函数: f(${variable}) = ${expression}`);
      steps.push(`积分区间: [${fromStr}, ${toStr}]`);
      
      // 创建函数 - 使用安全的表达式求值
      const f = (x: number): number => {
        try {
          return this.evaluateExpression(expression, variable, x);
        } catch (error) {
          Logger.error(`Failed to evaluate expression at x=${x}`, error);
          throw new Error('表达式求值失败');
        }
      };
      
      // 验证函数在区间端点是否有效
      try {
        const testFrom = f(from);
        const testTo = f(to);
        if (!isFinite(testFrom) || !isFinite(testTo)) {
          steps.push(`警告: 函数在区间端点存在奇点`);
        }
      } catch (error) {
        return {
          success: false,
          error: '函数在积分区间内无法求值，请检查表达式',
          steps
        };
      }
      
      // 使用辛普森法则进行数值积分
      const value = this.numericalIntegral(f, from, to);
      
      steps.push(`使用辛普森法则进行数值积分（1000个分段）`);
      steps.push(`积分结果: ≈ ${value.toFixed(6)}`);
      
      return {
        success: true,
        value,
        steps
      };
    } catch (error) {
      Logger.error('Integral calculation error', error);
      return {
        success: false,
        error: '积分计算失败: ' + (error instanceof Error ? error.message : '未知错误')
      };
    }
  }
  
  /**
   * 安全的表达式求值方法
   * 支持常见的数学函数和运算符
   */
  private evaluateExpression(expression: string, variable: string, value: number): number {
    // 预处理表达式
    let expr = expression.trim();
    
    // 替换变量为实际值
    // 使用简化的替换策略，将变量替换为带括号的值
    // 这样可以避免运算优先级问题
    
    // 创建一个临时占位符，避免重复替换
    const placeholder = `__VAR_${Math.random().toString(36).substr(2, 9)}__`;
    
    // 1. 先将所有独立的变量替换为占位符
    // 匹配：前面不是字母 + 变量 + 后面不是字母
    expr = expr.replace(
      new RegExp(`([^a-zA-Z]|^)${variable}([^a-zA-Z]|$)`, 'g'),
      `$1${placeholder}$2`
    );
    
    // 2. 将占位符替换为实际值（带括号）
    expr = expr.replace(new RegExp(placeholder, 'g'), `(${value})`);
    
    // 3. 处理表达式就是变量本身的情况
    if (expr === variable) {
      expr = `(${value})`;
    }
    
    // 替换数学常数
    expr = expr.replace(/\bπ\b/g, Math.PI.toString());
    expr = expr.replace(/\bpi\b/gi, Math.PI.toString());
    expr = expr.replace(/\be\b/g, Math.E.toString());
    
    // 替换数学函数为 Math 对象方法
    expr = this.replaceMathFunctions(expr);
    
    // 替换幂运算符
    expr = expr.replace(/\^/g, '**');
    
    // 添加调试日志
    Logger.info(`Evaluating expression: ${expr} (original: ${expression}, ${variable}=${value})`);
    
    // 验证表达式安全性（只包含数字、运算符、Math 对象和其方法）
    // 允许：数字、空格、运算符、括号、Math、字母（用于 Math.sin 等）
    const safePattern = /^[\d\s+\-*\/.()Matha-z,]+$/i;
    if (!safePattern.test(expr)) {
      Logger.error(`Unsafe expression: ${expr}`);
      throw new Error(`表达式包含不安全的字符: ${expr}`);
    }
    
    try {
      // 使用 Function 构造函数安全地求值
      const func = new Function('return ' + expr);
      const result = func();
      
      if (typeof result !== 'number' || isNaN(result)) {
        Logger.error(`Invalid result: ${result} from expression: ${expr}`);
        throw new Error('表达式求值结果不是有效数字');
      }
      
      Logger.info(`Expression result: ${result}`);
      return result;
    } catch (error) {
      Logger.error(`Expression evaluation failed: ${expr}`, error);
      throw new Error(`无法计算表达式: ${expression} (${error instanceof Error ? error.message : '未知错误'})`);
    }
  }
  
  /**
   * 替换数学函数为 Math 对象方法
   */
  private replaceMathFunctions(expr: string): string {
    let result = expr;
    
    // 三角函数
    result = result.replace(/\bsin\s*\(/g, 'Math.sin(');
    result = result.replace(/\bcos\s*\(/g, 'Math.cos(');
    result = result.replace(/\btan\s*\(/g, 'Math.tan(');
    result = result.replace(/\basin\s*\(/g, 'Math.asin(');
    result = result.replace(/\bacos\s*\(/g, 'Math.acos(');
    result = result.replace(/\batan\s*\(/g, 'Math.atan(');
    
    // 双曲函数
    result = result.replace(/\bsinh\s*\(/g, 'Math.sinh(');
    result = result.replace(/\bcosh\s*\(/g, 'Math.cosh(');
    result = result.replace(/\btanh\s*\(/g, 'Math.tanh(');
    
    // 指数和对数函数
    result = result.replace(/\bexp\s*\(/g, 'Math.exp(');
    result = result.replace(/\bln\s*\(/g, 'Math.log(');
    result = result.replace(/\blog\s*\(/g, 'Math.log10(');
    result = result.replace(/\blog10\s*\(/g, 'Math.log10(');
    result = result.replace(/\blog2\s*\(/g, 'Math.log2(');
    
    // 其他函数
    result = result.replace(/\bsqrt\s*\(/g, 'Math.sqrt(');
    result = result.replace(/\babs\s*\(/g, 'Math.abs(');
    result = result.replace(/\bceil\s*\(/g, 'Math.ceil(');
    result = result.replace(/\bfloor\s*\(/g, 'Math.floor(');
    result = result.replace(/\bround\s*\(/g, 'Math.round(');
    result = result.replace(/\bpow\s*\(/g, 'Math.pow(');
    result = result.replace(/\bmin\s*\(/g, 'Math.min(');
    result = result.replace(/\bmax\s*\(/g, 'Math.max(');
    
    return result;
  }
  
  /**
   * 不定积分（符号积分）
   */
  indefiniteIntegral(expression: string, variable: string = 'x'): IntegralResult {
    try {
      Logger.info(`Computing indefinite integral of ${expression}`);
      
      const steps: string[] = [];
      steps.push(`∫ ${expression} d${variable}`);
      
      // 幂函数积分：x^n -> x^(n+1)/(n+1)
      const powerMatch = expression.match(/(\d*)\*?x\^(\d+)/);
      if (powerMatch) {
        const coef = powerMatch[1] ? parseInt(powerMatch[1]) : 1;
        const power = parseInt(powerMatch[2]);
        
        if (power === -1) {
          const integral = `${coef}*ln|${variable}| + C`;
          steps.push(`使用对数积分公式: ∫(1/x)dx = ln|x| + C`);
          steps.push(`结果: ${integral}`);
          
          return {
            success: true,
            integral,
            steps
          };
        }
        
        const newPower = power + 1;
        const newCoef = coef / newPower;
        const integral = `${newCoef}*${variable}^${newPower} + C`;
        
        steps.push(`使用幂函数积分法则: ∫x^n dx = x^(n+1)/(n+1) + C`);
        steps.push(`结果: ${integral}`);
        
        return {
          success: true,
          integral,
          steps
        };
      }
      
      // 线性函数积分
      const linearMatch = expression.match(/(\d*)\*?x/);
      if (linearMatch) {
        const coef = linearMatch[1] ? parseInt(linearMatch[1]) : 1;
        const integral = `${coef / 2}*${variable}^2 + C`;
        
        steps.push(`∫${coef}x dx = ${coef / 2}x² + C`);
        
        return {
          success: true,
          integral,
          steps
        };
      }
      
      // 常数积分
      if (!expression.includes(variable)) {
        const constant = parseFloat(expression);
        const integral = `${constant}*${variable} + C`;
        
        steps.push(`∫${constant} dx = ${constant}x + C`);
        
        return {
          success: true,
          integral,
          steps
        };
      }
      
      return {
        success: false,
        error: '暂不支持该函数的符号积分，请使用 math.js 完整版'
      };
    } catch (error) {
      Logger.error('Indefinite integral calculation error', error);
      return {
        success: false,
        error: ERROR_MESSAGES.CALCULATION_ERROR
      };
    }
  }
  
  /**
   * 极限计算（改进版，支持特殊情况检测）
   * 参考 SageMath/SymPy 的极限计算方法
   */
  limit(expression: string, variable: string, approachValue: number, 
        fromLeft: boolean = false, fromRight: boolean = false): LimitResult {
    try {
      Logger.info(`Computing limit of ${expression} as ${variable} -> ${approachValue}`);
      
      const steps: string[] = [];
      const approachStr = approachValue === Infinity ? '∞' : 
                         approachValue === -Infinity ? '-∞' : 
                         approachValue.toString();
      steps.push(`计算极限: lim(${variable}→${approachStr}) ${expression}`);
      
      // 第一步：检查常见的标准极限形式
      const standardResult = this.checkStandardLimits(expression, variable, approachValue);
      if (standardResult) {
        steps.push(`识别为标准极限形式`);
        steps.push(standardResult.reason);
        return {
          success: true,
          limit: standardResult.limit,
          steps: steps
        };
      }
      
      // 第二步：检查不定式并尝试应用洛必达法则
      const indeterminateResult = this.checkIndeterminateForms(expression, variable, approachValue, steps);
      if (indeterminateResult) {
        return indeterminateResult;
      }
      
      // 第三步：特殊情况检测：趋向无穷大时的振荡函数
      if (approachValue === Infinity || approachValue === -Infinity) {
        const oscillatingResult = this.checkOscillatingAtInfinity(expression, variable, approachValue);
        if (oscillatingResult) {
          steps.push(`检测到振荡函数在无穷远处的行为`);
          steps.push(oscillatingResult.reason);
          return {
            success: false,
            error: oscillatingResult.error,
            steps: steps
          };
        }
        
        // 检查多项式在无穷处的极限
        const polynomialResult = this.checkPolynomialAtInfinity(expression, variable, approachValue);
        if (polynomialResult) {
          steps.push(`检测到多项式函数`);
          steps.push(polynomialResult.reason);
          return {
            success: true,
            limit: polynomialResult.limit,
            steps: steps
          };
        }
        
        // 检查有理函数在无穷处的极限
        const rationalResult = this.checkRationalAtInfinity(expression, variable, approachValue);
        if (rationalResult) {
          steps.push(`检测到有理函数`);
          steps.push(rationalResult.reason);
          return {
            success: true,
            limit: rationalResult.limit,
            steps: steps
          };
        }
      }
      
      // 第四步：数值方法求极限
      const numericalResult = this.numericalLimit(expression, variable, approachValue, fromLeft, fromRight, steps);
      return numericalResult;
      
    } catch (error) {
      Logger.error('Limit calculation error', error);
      return {
        success: false,
        error: ERROR_MESSAGES.CALCULATION_ERROR
      };
    }
  }
  
  /**
   * 检查标准极限形式
   * 参考 SageMath 的标准极限库
   */
  private checkStandardLimits(expression: string, variable: string, approachValue: number): 
    { limit: string, reason: string } | null {
    
    // 标准极限 1: lim(x->0) sin(x)/x = 1
    if (approachValue === 0) {
      // 匹配 sin(x)/x, sin(ax)/x, sin(x)/(bx) 等形式
      const sinOverXPattern = new RegExp(
        `(?:Math\\.)?sin\\s*\\(\\s*(\\d*\\.?\\d*)\\*?${variable}\\s*\\)\\s*/\\s*(?:(\\d*\\.?\\d*)\\*?)?${variable}`,
        'i'
      );
      const match = expression.match(sinOverXPattern);
      if (match) {
        const a = match[1] ? parseFloat(match[1]) : 1;
        const b = match[2] ? parseFloat(match[2]) : 1;
        const limit = (a / b).toString();
        return {
          limit: limit,
          reason: `这是标准极限: lim(x→0) sin(${a === 1 ? '' : a}x)/${b === 1 ? '' : b}x = ${limit} (重要极限)`
        };
      }
      
      // 标准极限 2: lim(x->0) (1-cos(x))/x = 0
      const oneMinusCosOverXPattern = new RegExp(
        `\\(\\s*1\\s*-\\s*(?:Math\\.)?cos\\s*\\(\\s*${variable}\\s*\\)\\s*\\)\\s*/\\s*${variable}`,
        'i'
      );
      if (oneMinusCosOverXPattern.test(expression)) {
        return {
          limit: '0',
          reason: `这是标准极限: lim(x→0) (1-cos(x))/x = 0`
        };
      }
      
      // 标准极限 3: lim(x->0) (1-cos(x))/x^2 = 1/2
      const oneMinusCosOverX2Pattern = new RegExp(
        `\\(\\s*1\\s*-\\s*(?:Math\\.)?cos\\s*\\(\\s*${variable}\\s*\\)\\s*\\)\\s*/\\s*${variable}\\s*\\^\\s*2`,
        'i'
      );
      if (oneMinusCosOverX2Pattern.test(expression)) {
        return {
          limit: '0.5',
          reason: `这是标准极限: lim(x→0) (1-cos(x))/x² = 1/2`
        };
      }
      
      // 标准极限 4: lim(x->0) tan(x)/x = 1
      const tanOverXPattern = new RegExp(
        `(?:Math\\.)?tan\\s*\\(\\s*${variable}\\s*\\)\\s*/\\s*${variable}`,
        'i'
      );
      if (tanOverXPattern.test(expression)) {
        return {
          limit: '1',
          reason: `这是标准极限: lim(x→0) tan(x)/x = 1`
        };
      }
      
      // 标准极限 5: lim(x->0) (e^x - 1)/x = 1
      const expMinusOneOverXPattern = new RegExp(
        `\\(\\s*(?:Math\\.)?exp\\s*\\(\\s*${variable}\\s*\\)\\s*-\\s*1\\s*\\)\\s*/\\s*${variable}`,
        'i'
      );
      if (expMinusOneOverXPattern.test(expression)) {
        return {
          limit: '1',
          reason: `这是标准极限: lim(x→0) (e^x - 1)/x = 1`
        };
      }
      
      // 标准极限 6: lim(x->0) ln(1+x)/x = 1
      const lnOnePlusXOverXPattern = new RegExp(
        `(?:Math\\.)?log\\s*\\(\\s*1\\s*\\+\\s*${variable}\\s*\\)\\s*/\\s*${variable}`,
        'i'
      );
      if (lnOnePlusXOverXPattern.test(expression)) {
        return {
          limit: '1',
          reason: `这是标准极限: lim(x→0) ln(1+x)/x = 1`
        };
      }
    }
    
    // 标准极限 7: lim(x->∞) (1 + 1/x)^x = e
    if (approachValue === Infinity) {
      const eulerLimitPattern = new RegExp(
        `\\(\\s*1\\s*\\+\\s*1\\s*/\\s*${variable}\\s*\\)\\s*\\^\\s*${variable}`,
        'i'
      );
      if (eulerLimitPattern.test(expression)) {
        return {
          limit: Math.E.toString(),
          reason: `这是欧拉极限: lim(x→∞) (1 + 1/x)^x = e ≈ 2.71828`
        };
      }
    }
    
    return null;
  }
  
  /**
   * 检查不定式并尝试应用洛必达法则
   * 参考 SageMath 的 L'Hôpital 规则实现
   */
  private checkIndeterminateForms(expression: string, variable: string, 
                                  approachValue: number, steps: string[]): LimitResult | null {
    
    // 检查是否为分式形式 f(x)/g(x)
    const fractionMatch = expression.match(/^(.+?)\/(.+)$/);
    if (!fractionMatch) {
      return null;
    }
    
    const numerator = fractionMatch[1].trim();
    const denominator = fractionMatch[2].trim();
    
    // 计算分子和分母在该点的值
    const f = (x: number): number => {
      try {
        const expr = numerator.replace(new RegExp(variable, 'g'), x.toString());
        return eval(expr);
      } catch {
        return NaN;
      }
    };
    
    const g = (x: number): number => {
      try {
        const expr = denominator.replace(new RegExp(variable, 'g'), x.toString());
        return eval(expr);
      } catch {
        return NaN;
      }
    };
    
    // 测试点
    let testPoint: number;
    if (approachValue === Infinity) {
      testPoint = 1e10;
    } else if (approachValue === -Infinity) {
      testPoint = -1e10;
    } else {
      testPoint = approachValue;
    }
    
    const fValue = f(testPoint);
    const gValue = g(testPoint);
    
    // 检查是否为 0/0 型不定式
    if (Math.abs(fValue) < 1e-6 && Math.abs(gValue) < 1e-6) {
      steps.push(`检测到 0/0 型不定式`);
      steps.push(`尝试使用洛必达法则: lim f(x)/g(x) = lim f'(x)/g'(x)`);
      
      // 简化的导数计算（数值方法）
      const h = 1e-7;
      const fPrime = (x: number) => (f(x + h) - f(x - h)) / (2 * h);
      const gPrime = (x: number) => (g(x + h) - g(x - h)) / (2 * h);
      
      const fPrimeValue = fPrime(testPoint);
      const gPrimeValue = gPrime(testPoint);
      
      if (Math.abs(gPrimeValue) > 1e-10) {
        const limit = (fPrimeValue / gPrimeValue).toFixed(6);
        steps.push(`应用洛必达法则后: ${limit}`);
        return {
          success: true,
          limit: limit,
          steps: steps
        };
      }
    }
    
    // 检查是否为 ∞/∞ 型不定式
    if (!isFinite(fValue) && !isFinite(gValue) && 
        ((fValue > 0 && gValue > 0) || (fValue < 0 && gValue < 0))) {
      steps.push(`检测到 ∞/∞ 型不定式`);
      steps.push(`尝试使用洛必达法则`);
      
      // 对于 ∞/∞ 型，也可以尝试洛必达法则
      // 这里使用数值方法近似
      const h = 1e-7;
      const fPrime = (x: number) => (f(x + h) - f(x - h)) / (2 * h);
      const gPrime = (x: number) => (g(x + h) - g(x - h)) / (2 * h);
      
      const fPrimeValue = fPrime(testPoint);
      const gPrimeValue = gPrime(testPoint);
      
      if (Math.abs(gPrimeValue) > 1e-10 && isFinite(fPrimeValue) && isFinite(gPrimeValue)) {
        const limit = (fPrimeValue / gPrimeValue).toFixed(6);
        steps.push(`应用洛必达法则后: ${limit}`);
        return {
          success: true,
          limit: limit,
          steps: steps
        };
      }
    }
    
    return null;
  }
  
  /**
   * 检查振荡函数在无穷处的行为
   * 参考 SymPy 的 limit 算法
   */
  private checkOscillatingAtInfinity(expression: string, variable: string, approachValue: number): 
    { error: string, reason: string } | null {
    
    // 检测三角函数：sin, cos, tan
    const trigFunctions = ['sin', 'cos', 'tan'];
    for (const func of trigFunctions) {
      // 匹配 sin(x), sin(ax), sin(x+b) 等形式
      const pattern = new RegExp(`${func}\\s*\\(\\s*[^)]*${variable}[^)]*\\)`, 'i');
      if (pattern.test(expression)) {
        // 检查是否有衰减因子（如 1/x * sin(x)）
        const hasDecayFactor = expression.includes(`1/${variable}`) || 
                              expression.includes(`${variable}^-`) ||
                              expression.match(new RegExp(`${variable}\\s*\\^\\s*-`));
        
        if (!hasDecayFactor) {
          return {
            error: `函数 ${expression} 在 ${variable}→${approachValue === Infinity ? '∞' : '-∞'} 时振荡，极限不存在 (DNE)`,
            reason: `${func}(${variable}) 在无穷远处在 [-1, 1] 或 (-∞, +∞) 之间振荡，没有确定的极限值`
          };
        } else {
          // 有衰减因子，可能趋向于 0
          return null; // 继续使用数值方法
        }
      }
    }
    
    // 检测其他振荡表达式
    // 例如: (-1)^x, x*sin(x) 等
    if (expression.includes('(-1)^') && expression.includes(variable)) {
      return {
        error: `函数包含 (-1)^${variable}，在 ${variable}→∞ 时振荡，极限不存在 (DNE)`,
        reason: '(-1)^n 在 n→∞ 时在 -1 和 1 之间振荡'
      };
    }
    
    return null;
  }
  
  /**
   * 检查多项式在无穷处的极限
   */
  private checkPolynomialAtInfinity(expression: string, variable: string, approachValue: number): 
    { limit: string, reason: string } | null {
    
    // 匹配最高次项：例如 x^3, 2*x^2, -x^5
    const highestDegreeMatch = expression.match(new RegExp(`([+-]?\\d*\\.?\\d*)\\*?${variable}\\^(\\d+)`));
    
    if (highestDegreeMatch) {
      const coefficient = highestDegreeMatch[1] ? parseFloat(highestDegreeMatch[1]) : 1;
      const degree = parseInt(highestDegreeMatch[2]);
      
      let limit: string;
      if (approachValue === Infinity) {
        if (coefficient > 0) {
          limit = '+∞';
        } else if (coefficient < 0) {
          limit = '-∞';
        } else {
          return null;
        }
      } else { // -Infinity
        if (degree % 2 === 0) {
          // 偶次幂
          limit = coefficient > 0 ? '+∞' : '-∞';
        } else {
          // 奇次幂
          limit = coefficient > 0 ? '-∞' : '+∞';
        }
      }
      
      return {
        limit: limit,
        reason: `多项式的最高次项为 ${coefficient}${variable}^${degree}，主导了函数在无穷处的行为`
      };
    }
    
    return null;
  }
  
  /**
   * 检查有理函数在无穷处的极限
   */
  private checkRationalAtInfinity(expression: string, variable: string, approachValue: number): 
    { limit: string, reason: string } | null {
    
    // 匹配有理函数：(分子)/(分母)
    const rationalMatch = expression.match(/\(([^)]+)\)\s*\/\s*\(([^)]+)\)/);
    
    if (rationalMatch) {
      const numerator = rationalMatch[1];
      const denominator = rationalMatch[2];
      
      // 获取分子和分母的最高次数
      const numDegree = this.getPolynomialDegree(numerator, variable);
      const denDegree = this.getPolynomialDegree(denominator, variable);
      
      if (numDegree !== null && denDegree !== null) {
        let limit: string;
        let reason: string;
        
        if (numDegree > denDegree) {
          limit = '±∞';
          reason = `分子次数 (${numDegree}) > 分母次数 (${denDegree})，极限为无穷大`;
        } else if (numDegree < denDegree) {
          limit = '0';
          reason = `分子次数 (${numDegree}) < 分母次数 (${denDegree})，极限为 0`;
        } else {
          // 次数相等，极限为最高次项系数之比
          const numCoef = this.getLeadingCoefficient(numerator, variable, numDegree);
          const denCoef = this.getLeadingCoefficient(denominator, variable, denDegree);
          limit = (numCoef / denCoef).toFixed(6);
          reason = `分子和分母次数相等 (${numDegree})，极限为最高次项系数之比: ${numCoef}/${denCoef}`;
        }
        
        return { limit, reason };
      }
    }
    
    return null;
  }
  
  /**
   * 获取多项式的次数
   */
  private getPolynomialDegree(expression: string, variable: string): number | null {
    const matches = expression.match(new RegExp(`${variable}\\^(\\d+)`, 'g'));
    if (!matches) {
      // 检查是否有一次项
      if (expression.includes(variable)) {
        return 1;
      }
      return 0; // 常数
    }
    
    let maxDegree = 0;
    for (const match of matches) {
      const degree = parseInt(match.match(/\d+/)![0]);
      if (degree > maxDegree) {
        maxDegree = degree;
      }
    }
    return maxDegree;
  }
  
  /**
   * 获取最高次项的系数
   */
  private getLeadingCoefficient(expression: string, variable: string, degree: number): number {
    const pattern = new RegExp(`([+-]?\\d*\\.?\\d*)\\*?${variable}\\^${degree}`);
    const match = expression.match(pattern);
    
    if (match) {
      const coef = match[1];
      if (!coef || coef === '+' || coef === '') return 1;
      if (coef === '-') return -1;
      return parseFloat(coef);
    }
    
    return 1;
  }
  
  /**
   * 数值方法计算极限
   */
  private numericalLimit(expression: string, variable: string, approachValue: number,
                        fromLeft: boolean, fromRight: boolean, steps: string[]): LimitResult {
    
    const f = (x: number): number => {
      try {
        return eval(expression.replace(new RegExp(variable, 'g'), x.toString()));
      } catch {
        return NaN;
      }
    };
    
    let result: number;
    let limitStr: string;
    
    // 处理趋向无穷的情况
    if (approachValue === Infinity || approachValue === -Infinity) {
      // 使用多个点进行数值测试
      const testValues = approachValue === Infinity ? 
        [100, 1000, 10000, 100000] : 
        [-100, -1000, -10000, -100000];
      
      const results = testValues.map(x => f(x));
      steps.push(`测试点: ${testValues.join(', ')}`);
      steps.push(`函数值: ${results.map(r => r.toFixed(4)).join(', ')}`);
      
      // 检查是否收敛
      const lastTwo = results.slice(-2);
      if (Math.abs(lastTwo[0] - lastTwo[1]) < 1e-3 && isFinite(lastTwo[0])) {
        result = lastTwo[1];
        steps.push(`函数值趋于稳定，极限存在`);
      } else if (results.every(r => !isFinite(r) && r > 0)) {
        limitStr = '+∞';
        steps.push(`函数值趋向正无穷`);
        return { success: true, limit: limitStr, steps };
      } else if (results.every(r => !isFinite(r) && r < 0)) {
        limitStr = '-∞';
        steps.push(`函数值趋向负无穷`);
        return { success: true, limit: limitStr, steps };
      } else {
        // 检查是否振荡
        const variance = this.calculateVariance(results.filter(r => isFinite(r)));
        if (variance > 0.1) {
          return {
            success: false,
            error: `函数在 ${variable}→${approachValue === Infinity ? '∞' : '-∞'} 时不收敛，极限不存在 (DNE)`,
            steps: steps.concat([`函数值方差: ${variance.toFixed(4)}，表明函数振荡或发散`])
          };
        }
        result = results[results.length - 1];
      }
    } else {
      // 趋向有限值
      if (fromLeft) {
        result = f(approachValue - 1e-10);
        steps.push(`左极限: ${variable} → ${approachValue}⁻`);
      } else if (fromRight) {
        result = f(approachValue + 1e-10);
        steps.push(`右极限: ${variable} → ${approachValue}⁺`);
      } else {
        const leftLimit = f(approachValue - 1e-10);
        const rightLimit = f(approachValue + 1e-10);
        
        steps.push(`左极限: ${isFinite(leftLimit) ? leftLimit.toFixed(6) : (leftLimit > 0 ? '+∞' : '-∞')}`);
        steps.push(`右极限: ${isFinite(rightLimit) ? rightLimit.toFixed(6) : (rightLimit > 0 ? '+∞' : '-∞')}`);
        
        if (!isFinite(leftLimit) && !isFinite(rightLimit)) {
          if ((leftLimit > 0 && rightLimit > 0) || (leftLimit < 0 && rightLimit < 0)) {
            limitStr = leftLimit > 0 ? '+∞' : '-∞';
            steps.push(`左右极限都趋向${limitStr}`);
            return { success: true, limit: limitStr, steps };
          } else {
            return {
              success: false,
              error: '左右极限符号不同，极限不存在 (DNE)',
              steps: steps
            };
          }
        }
        
        if (!isFinite(leftLimit) || !isFinite(rightLimit)) {
          return {
            success: false,
            error: '左右极限不相等，极限不存在 (DNE)',
            steps: steps
          };
        }
        
        if (Math.abs(leftLimit - rightLimit) < 1e-6) {
          result = (leftLimit + rightLimit) / 2;
          steps.push(`左右极限相等，极限存在`);
        } else {
          return {
            success: false,
            error: `左右极限不相等，极限不存在 (DNE)`,
            steps: steps
          };
        }
      }
    }
    
    // 格式化结果
    if (!isFinite(result)) {
      limitStr = result > 0 ? '+∞' : '-∞';
    } else if (Math.abs(result) < 1e-10) {
      limitStr = '0';
    } else {
      limitStr = result.toFixed(6);
    }
    
    steps.push(`最终结果: ${limitStr}`);
    
    return {
      success: true,
      limit: limitStr,
      steps: steps
    };
  }
  
  /**
   * 计算方差（用于检测振荡）
   */
  private calculateVariance(values: number[]): number {
    if (values.length === 0) return 0;
    
    const mean = values.reduce((sum, val) => sum + val, 0) / values.length;
    const squaredDiffs = values.map(val => Math.pow(val - mean, 2));
    return squaredDiffs.reduce((sum, val) => sum + val, 0) / values.length;
  }
  
  /**
   * 泰勒级数展开（简化版本）
   */
  taylorSeries(expression: string, variable: string, center: number, terms: number = 5): string {
    // 占位实现
    Logger.warn('Taylor series not fully implemented yet');
    return `${expression} 的泰勒展开需要 math.js 支持`;
  }
}

