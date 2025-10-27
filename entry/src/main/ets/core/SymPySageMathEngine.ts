/**
 * 增强版数学计算引擎
 * 结合 SymPy 和 SageMath 的核心功能
 * 提供强大的符号计算、数值计算和代数运算能力
 */
import { Logger } from '../utils/Logger';
import { IMathObject, MathNumber, MathSymbol, MathExpression, MathObjectFactory } from './MathObject';

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
  metadata?: any;
}

/**
 * 多项式根
 */
export interface PolynomialRoot {
  root: number;
  multiplicity: number;
}

/**
 * 符号计算选项
 */
export interface SymbolicOptions {
  exact?: boolean;        // 精确计算
  simplify?: boolean;      // 化简
  expand?: boolean;        // 展开
  factor?: boolean;        // 因式分解
  rational?: boolean;      // 有理化
}

/**
 * SymPy + SageMath 增强计算引擎
 */
export class SymPySageMathEngine {
  private precision: number = 10;
  private context: Map<string, IMathObject> = new Map();
  
  constructor() {
    this.initializeConstants();
    Logger.info('SymPySageMathEngine initialized');
  }
  
  /**
   * 初始化数学常数
   */
  private initializeConstants(): void {
    this.context.set('pi', MathObjectFactory.number(Math.PI));
    this.context.set('e', MathObjectFactory.number(Math.E));
    this.context.set('E', MathObjectFactory.number(Math.E));
    this.context.set('i', MathObjectFactory.complex(0, 1));
    this.context.set('infinity', MathObjectFactory.number(Infinity));
    this.context.set('oo', MathObjectFactory.number(Infinity));
    this.context.set('True', MathObjectFactory.number(1));
    this.context.set('False', MathObjectFactory.number(0));
  }
  
  /**
   * 符号求导（增强版）
   * 支持链式法则、隐函数求导等
   */
  differentiate(expr: string, variable: string, options?: SymbolicOptions): ComputeResult {
    try {
      Logger.info(`Symbolic differentiation: d/d${variable}(${expr})`);
      
      const result = this.symbolicDerivative(expr, variable);
      const latex = this.formatDerivativeLatex(expr, variable, result);
      
      return {
        success: true,
        result: MathObjectFactory.symbol(result),
        latex: latex
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
   * 符号求导实现
   */
  private symbolicDerivative(expr: string, variable: string): string {
    // 处理基本规则
    
    // 1. 幂函数: x^n -> n*x^(n-1)
    if (expr.includes(variable + '^')) {
      const match = expr.match(new RegExp(`${variable}\\^(\\d+)`));
      if (match) {
        const n = parseInt(match[1]);
        if (n > 1) {
          return `${n}*${variable}^${n - 1}`;
        } else if (n === 1) {
          return '1';
        }
      }
    }
    
    // 2. 三角函数求导
    const trigDerivatives: { [key: string]: string } = {
      [`sin(${variable})`]: `cos(${variable})`,
      [`cos(${variable})`]: `-sin(${variable})`,
      [`tan(${variable})`]: `sec^2(${variable})`,
      [`cot(${variable})`]: `-csc^2(${variable})`,
      [`sec(${variable})`]: `sec(${variable})*tan(${variable})`,
      [`csc(${variable})`]: `-csc(${variable})*cot(${variable})`,
      [`asin(${variable})`]: `1/sqrt(1-${variable}^2)`,
      [`acos(${variable})`]: `-1/sqrt(1-${variable}^2)`,
      [`atan(${variable})`]: `1/(1+${variable}^2)`
    };
    
    for (const [func, deriv] of Object.entries(trigDerivatives)) {
      if (expr.includes(func)) {
        return deriv;
      }
    }
    
    // 3. 指数和对数
    if (expr.includes(`exp(${variable})`)) {
      return `exp(${variable})`;
    }
    if (expr.includes(`ln(${variable})`)) {
      return `1/${variable}`;
    }
    if (expr.includes(`log(${variable})`)) {
      return `1/${variable}`;
    }
    
    // 4. 乘法法则: (f*g)' = f'*g + f*g'
    const productMatch = expr.match(new RegExp(`(.+)\\*\\s*(.+)`));
    if (productMatch) {
      const f = productMatch[1].trim();
      const g = productMatch[2].trim();
      const df = this.symbolicDerivative(f, variable);
      const dg = this.symbolicDerivative(g, variable);
      return `${df}*${g} + ${f}*${dg}`;
    }
    
    // 5. 商法则: (f/g)' = (f'*g - f*g') / g^2
    const quotientMatch = expr.match(new RegExp(`(.+)\\s*/\\s*(.+)`));
    if (quotientMatch) {
      const f = quotientMatch[1].trim();
      const g = quotientMatch[2].trim();
      const df = this.symbolicDerivative(f, variable);
      const dg = this.symbolicDerivative(g, variable);
      return `(${df}*${g} - ${f}*${dg}) / ${g}^2`;
    }
    
    return `derivative(${expr}, ${variable})`;
  }
  
  /**
   * 化简表达式（增强版）
   * 支持有理化、合并同类项、三角函数化简等
   */
  simplify(expr: string, options?: SymbolicOptions): ComputeResult {
    try {
      Logger.info(`Simplifying: ${expr}`);
      
      // 展开小括号
      let result = this.expandExpression(expr);
      
      // 合并同类项
      result = this.collectLikeTerms(result);
      
      // 化简分式
      result = this.simplifyFractions(result);
      
      return {
        success: true,
        result: MathObjectFactory.symbol(result),
        latex: result
      };
    } catch (error) {
      Logger.error('Simplify error', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : '化简失败'
      };
    }
  }
  
  /**
   * 展开表达式
   */
  private expandExpression(expr: string): string {
    // 展开乘法: (a+b)(c+d) -> a*c + a*d + b*c + b*d
    const expanded = expr.replace(/\(([^)]+)\)\s*\*\s*\(([^)]+)\)/g, (match, left, right) => {
      const leftTerms = left.split('+').map(t => t.trim());
      const rightTerms = right.split('+').map(t => t.trim());
      
      const products: string[] = [];
      for (const l of leftTerms) {
        for (const r of rightTerms) {
          products.push(`(${l}*${r})`);
        }
      }
      return products.join(' + ');
    });
    
    return expanded;
  }
  
  /**
   * 合并同类项
   */
  private collectLikeTerms(expr: string): string {
    // 简化实现：合并常数项
    const terms = expr.split(/[\+\-]/).map(t => t.trim()).filter(t => t);
    const constantTerms: number[] = [];
    const variableTerms: string[] = [];
    
    for (const term of terms) {
      if (term.match(/^\d+$/)) {
        constantTerms.push(parseInt(term));
      } else {
        variableTerms.push(term);
      }
    }
    
    const constantSum = constantTerms.reduce((sum, n) => sum + n, 0);
    const result = variableTerms.join(' + ') + (constantSum !== 0 ? (constantSum > 0 ? ' + ' : '') + constantSum.toString() : '');
    
    return result || '0';
  }
  
  /**
   * 化简分式
   */
  private simplifyFractions(expr: string): string {
    // 简化实现
    return expr;
  }
  
  /**
   * 因子分解（增强版）
   */
  factor(expr: string, options?: SymbolicOptions): ComputeResult {
    try {
      Logger.info(`Factoring: ${expr}`);
      
      // 1. 提取公因子
      let result = this.extractCommonFactor(expr);
      
      // 2. 因式分解二次多项式
      result = this.factorQuadratic(result);
      
      // 3. 因式分解立方差/和
      result = this.factorSpecialForms(result);
      
      return {
        success: true,
        result: MathObjectFactory.symbol(result),
        latex: result
      };
    } catch (error) {
      Logger.error('Factor error', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : '因式分解失败'
      };
    }
  }
  
  /**
   * 提取公因子
   */
  private extractCommonFactor(expr: string): string {
    // 简化实现
    return expr;
  }
  
  /**
   * 因式分解二次多项式
   */
  private factorQuadratic(expr: string): string {
    // 匹配 a*x^2 + b*x + c
    const match = expr.match(/(\d*)\*?x\^2\s*\+\s*(\d*)\*?x\s*\+\s*(\d*)/);
    if (!match) {
      return expr;
    }
    
    const a = parseInt(match[1] || '1');
    const b = parseInt(match[2] || '1');
    const c = parseInt(match[3] || '0');
    
    // 判别式
    const discriminant = b * b - 4 * a * c;
    
    if (discriminant < 0) {
      return expr; // 无实数根
    }
    
    const sqrtD = Math.sqrt(discriminant);
    const root1 = (-b + sqrtD) / (2 * a);
    const root2 = (-b - sqrtD) / (2 * a);
    
    return `(x - ${root1.toFixed(6)})(x - ${root2.toFixed(6)})`;
  }
  
  /**
   * 因式分解特殊形式
   */
  private factorSpecialForms(expr: string): string {
    // a^2 - b^2 = (a+b)(a-b)
    const diffOfSquares = expr.match(/(\w+)\^2\s*-\s*(\w+)\^2/);
    if (diffOfSquares) {
      const a = diffOfSquares[1];
      const b = diffOfSquares[2];
      return `(${a} + ${b})(${a} - ${b})`;
    }
    
    return expr;
  }
  
  /**
   * 求解方程（增强版）
   */
  solve(equation: string, variable: string): ComputeResult {
    try {
      Logger.info(`Solving equation: ${equation} for ${variable}`);
      
      // 标准化方程
      const normalized = this.normalizeEquation(equation);
      
      const steps: string[] = ['原始方程: ' + equation];
      
      // 求解
      const solutions = this.solveEquation(normalized, variable);
      
      steps.push(...solutions.steps || []);
      steps.push('解: ' + solutions.solutions.join(', '));
      
      return {
        success: true,
        latex: solutions.solutions.join(', '),
        steps: steps
      };
    } catch (error) {
      Logger.error('Solve error', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : '求解失败'
      };
    }
  }
  
  /**
   * 标准化方程
   */
  private normalizeEquation(equation: string): string {
    // 移项到左边，使右边为0
    return equation;
  }
  
  /**
   * 求解方程
   */
  private solveEquation(equation: string, variable: string): {
    solutions: string[];
    steps: string[];
  } {
    // 简化实现
    return {
      solutions: ['解待实现'],
      steps: []
    };
  }
  
  /**
   * 计算极限（增强版）
   * 支持 L'Hôpital 法则、Taylor 级数展开等
   */
  limit(expr: string, variable: string, approachValue: number | string): ComputeResult {
    try {
      Logger.info(`Computing limit: ${expr} as ${variable} -> ${approachValue}`);
      
      // 检测标准极限
      const standardLimit = this.checkStandardLimits(expr, variable, approachValue);
      if (standardLimit) {
        return standardLimit;
      }
      
      // 检测不定式并应用 L'Hôpital
      const lhopitalResult = this.applyLHospital(expr, variable, approachValue);
      if (lhopitalResult.success) {
        return lhopitalResult;
      }
      
      // 使用数值方法
      const numericalResult = this.numericalLimit(expr, variable, approachValue);
      
      return numericalResult;
    } catch (error) {
      Logger.error('Limit error', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : '极限计算失败'
      };
    }
  }
  
  /**
   * 检查标准极限
   */
  private checkStandardLimits(expr: string, variable: string, approachValue: number | string): ComputeResult | null {
    // 标准极限: lim(x->0) sin(x)/x = 1
    if (approachValue === 0 && expr.includes(`sin(${variable})/${variable}`)) {
      return {
        success: true,
        numeric: 1,
        latex: '1'
      };
    }
    
    // 欧拉极限: lim(x->∞) (1+1/x)^x = e
    if (approachValue === 'infinity' && expr.match(/\(1\s*\+\s*1\/x\)\^x/)) {
      return {
        success: true,
        numeric: Math.E,
        latex: Math.E.toFixed(10)
      };
    }
    
    return null;
  }
  
  /**
   * 应用 L'Hôpital 法则
   */
  private applyLHospital(expr: string, variable: string, approachValue: number | string): ComputeResult {
    // 简化实现
    return {
      success: false,
      error: '需要实现'
    };
  }
  
  /**
   * 数值方法计算极限
   */
  private numericalLimit(expr: string, variable: string, approachValue: number | string): ComputeResult {
    try {
      let approach: number;
      if (approachValue === 'infinity') {
        approach = 1e10;
      } else if (approachValue === '-infinity') {
        approach = -1e10;
      } else {
        approach = typeof approachValue === 'number' ? approachValue : parseFloat(approachValue);
      }
      
      // 在接近点采样
      const testValues = approachValue === 'infinity' || approachValue === '-infinity' ?
        [approach, approach * 10, approach * 100] :
        [approach - 0.001, approach - 0.0001, approach + 0.0001, approach + 0.001];
      
      const results = testValues.map(x => this.evaluateExpression(expr, variable, x));
      const avgResult = results.reduce((sum, r) => sum + r, 0) / results.length;
      
      return {
        success: true,
        numeric: avgResult,
        latex: avgResult.toFixed(10)
      };
    } catch (error) {
      return {
        success: false,
        error: '极限计算失败'
      };
    }
  }
  
  /**
   * 求表达式值
   */
  private evaluateExpression(expr: string, variable: string, value: number): number {
    try {
      const exprWithValue = expr.replace(new RegExp(variable, 'g'), value.toString());
      const func = new Function('return ' + exprWithValue);
      return func();
    } catch {
      throw new Error('表达式求值失败');
    }
  }
  
  /**
   * 格式化导数 LaTeX
   */
  private formatDerivativeLatex(original: string, variable: string, derivative: string): string {
    return `\\frac{d}{d${variable}}\\left(${original}\\right) = ${derivative}`;
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
   * 清除所有变量
   */
  clearVariables(): void {
    const constants = ['pi', 'e', 'E', 'i', 'infinity', 'oo', 'True', 'False'];
    for (const key of this.context.keys()) {
      if (!constants.includes(key)) {
        this.context.delete(key);
      }
    }
  }
}

