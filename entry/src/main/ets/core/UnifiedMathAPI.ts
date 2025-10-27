/**
 * 统一数学计算 API
 * 参考 SageMath 的设计理念，提供简洁统一的接口
 * 这是应用程序与计算引擎交互的主要入口
 */
import { Logger } from '../utils/Logger';
import { UnifiedComputeEngine, ComputeResult, ComputeOptions } from './UnifiedComputeEngine';
import { SymbolicEngine, SymbolicResult } from './SymbolicEngine';
import { AlgebraEngine, Matrix, Vector, Polynomial } from './AlgebraEngine';
import { IMathObject, MathObjectFactory } from './MathObject';

/**
 * 统一数学 API 类
 * 这是整个计算系统的门面（Facade）
 */
export class UnifiedMathAPI {
  private computeEngine: UnifiedComputeEngine;
  private symbolicEngine: SymbolicEngine;
  private algebraEngine: AlgebraEngine;
  
  constructor(precision: number = 10) {
    this.computeEngine = new UnifiedComputeEngine(precision);
    this.symbolicEngine = new SymbolicEngine();
    this.algebraEngine = new AlgebraEngine();
    
    Logger.info('UnifiedMathAPI initialized');
  }
  
  // ==================== 基础计算 ====================
  
  /**
   * 计算表达式
   * @example
   * await api.compute('2 + 3 * 4')
   * await api.compute('sin(pi/2)')
   * await api.compute('sqrt(16)')
   */
  async compute(expression: string, options?: ComputeOptions): Promise<ComputeResult> {
    return await this.computeEngine.compute(expression, options);
  }
  
  /**
   * 简化表达式
   * @example
   * api.simplify('x + x')  // 2x
   * api.simplify('x * 1')  // x
   */
  simplify(expression: string | IMathObject): SymbolicResult {
    const expr = typeof expression === 'string' 
      ? this.computeEngine.parse(expression) 
      : expression;
    return this.symbolicEngine.simplify(expr);
  }
  
  /**
   * 展开表达式
   * @example
   * api.expand('(x+1)(x+2)')  // x^2 + 3x + 2
   * api.expand('(x+y)^2')     // x^2 + 2xy + y^2
   */
  expand(expression: string | IMathObject): SymbolicResult {
    const expr = typeof expression === 'string' 
      ? this.computeEngine.parse(expression) 
      : expression;
    return this.symbolicEngine.expand(expr);
  }
  
  /**
   * 因式分解
   * @example
   * api.factor('x^2 - 1')  // (x-1)(x+1)
   */
  factor(expression: string | IMathObject): SymbolicResult {
    const expr = typeof expression === 'string' 
      ? this.computeEngine.parse(expression) 
      : expression;
    return this.symbolicEngine.factor(expr);
  }
  
  // ==================== 微积分 ====================
  
  /**
   * 求导
   * @example
   * await api.differentiate('x^2', 'x')      // 2x
   * await api.differentiate('sin(x)', 'x')   // cos(x)
   */
  async differentiate(expression: string | IMathObject, variable: string = 'x', options?: ComputeOptions): Promise<ComputeResult> {
    return await this.computeEngine.differentiate(expression, variable, options);
  }
  
  /**
   * 求导的简写
   */
  async diff(expression: string | IMathObject, variable: string = 'x', options?: ComputeOptions): Promise<ComputeResult> {
    return await this.differentiate(expression, variable, options);
  }
  
  /**
   * 积分
   * @example
   * await api.integrate('x^2', 'x')           // x^3/3 + C
   * await api.integrate('sin(x)', 'x', 0, pi) // 2
   */
  async integrate(expression: string | IMathObject, variable: string = 'x', 
            from?: number, to?: number, options?: ComputeOptions): Promise<ComputeResult> {
    return await this.computeEngine.integrate(expression, variable, from, to, options);
  }
  
  /**
   * 积分的简写
   */
  async int(expression: string | IMathObject, variable: string = 'x', 
      from?: number, to?: number, options?: ComputeOptions): Promise<ComputeResult> {
    return await this.integrate(expression, variable, from, to, options);
  }
  
  /**
   * 求极限
   * @example
   * api.limit('sin(x)/x', 'x', 0)              // 1
   * api.limit('1/x', 'x', 'infinity')          // 0
   * api.limit('1/x', 'x', 0, 'right')          // +∞
   */
  limit(expression: string | IMathObject, variable: string, approachValue: number | string,
        direction?: 'left' | 'right', options?: ComputeOptions): ComputeResult {
    return this.computeEngine.limit(expression, variable, approachValue, direction, options);
  }
  
  /**
   * 泰勒级数展开
   * @example
   * api.taylor('sin(x)', 'x', 0, 5)  // x - x^3/6 + x^5/120
   */
  taylor(expression: string | IMathObject, variable: string, point: number, order: number): SymbolicResult {
    const expr = typeof expression === 'string' 
      ? this.computeEngine.parse(expression) 
      : expression;
    return this.symbolicEngine.taylorSeries(expr, variable, point, order);
  }
  
  // ==================== 方程求解 ====================
  
  /**
   * 求解方程
   * @example
   * api.solve('x^2 - 4 = 0', 'x')  // [2, -2]
   * api.solve('2x + 3 = 7', 'x')   // [2]
   */
  solve(equation: string | IMathObject, variable: string): SymbolicResult {
    const expr = typeof equation === 'string' 
      ? this.computeEngine.parse(equation) 
      : equation;
    return this.symbolicEngine.solve(expr, variable);
  }
  
  // ==================== 线性代数 ====================
  
  /**
   * 创建矩阵
   * @example
   * api.matrix([[1, 2], [3, 4]])
   */
  matrix(data: number[][]): Matrix {
    return this.algebraEngine.createMatrix(data);
  }
  
  /**
   * 创建单位矩阵
   * @example
   * api.identity(3)  // 3x3单位矩阵
   */
  identity(n: number): Matrix {
    return this.algebraEngine.createIdentityMatrix(n);
  }
  
  /**
   * 创建零矩阵
   * @example
   * api.zeros(2, 3)  // 2x3零矩阵
   */
  zeros(rows: number, cols: number): Matrix {
    return this.algebraEngine.createZeroMatrix(rows, cols);
  }
  
  /**
   * 创建向量
   * @example
   * api.vector([1, 2, 3])
   */
  vector(data: number[]): Vector {
    return this.algebraEngine.createVector(data);
  }
  
  /**
   * 求解线性方程组
   * @example
   * const A = api.matrix([[2, 1], [1, 3]]);
   * const b = api.vector([5, 6]);
   * api.solveLinear(A, b)  // [1.6, 1.8]
   */
  solveLinear(A: Matrix, b: Vector): Vector {
    return this.algebraEngine.solveLinearSystem(A, b);
  }
  
  /**
   * 矩阵行列式
   * @example
   * api.det(api.matrix([[1, 2], [3, 4]]))  // -2
   */
  det(matrix: Matrix): number {
    return matrix.determinant();
  }
  
  /**
   * 矩阵的逆
   * @example
   * api.inv(api.matrix([[1, 2], [3, 4]]))
   */
  inv(matrix: Matrix): Matrix {
    return matrix.inverse();
  }
  
  /**
   * 矩阵的秩
   * @example
   * api.rank(api.matrix([[1, 2], [2, 4]]))  // 1
   */
  rank(matrix: Matrix): number {
    return matrix.rank();
  }
  
  /**
   * 矩阵的特征值
   * @example
   * api.eigenvalues(api.matrix([[1, 2], [2, 1]]))  // [3, -1]
   */
  eigenvalues(matrix: Matrix): number[] {
    return matrix.eigenvalues();
  }
  
  // ==================== 多项式 ====================
  
  /**
   * 创建多项式
   * @example
   * api.polynomial([1, 2, 3])  // 1 + 2x + 3x^2
   */
  polynomial(coefficients: number[]): Polynomial {
    return this.algebraEngine.createPolynomial(coefficients);
  }
  
  // ==================== 数论 ====================
  
  /**
   * 最大公约数
   * @example
   * api.gcd(12, 18)  // 6
   */
  gcd(a: number, b: number): number {
    return this.algebraEngine.gcd(a, b);
  }
  
  /**
   * 最小公倍数
   * @example
   * api.lcm(12, 18)  // 36
   */
  lcm(a: number, b: number): number {
    return this.algebraEngine.lcm(a, b);
  }
  
  /**
   * 阶乘
   * @example
   * api.factorial(5)  // 120
   */
  factorial(n: number): number {
    return this.algebraEngine.factorial(n);
  }
  
  /**
   * 组合数
   * @example
   * api.combination(5, 2)  // 10
   */
  combination(n: number, k: number): number {
    return this.algebraEngine.combination(n, k);
  }
  
  /**
   * 排列数
   * @example
   * api.permutation(5, 2)  // 20
   */
  permutation(n: number, k: number): number {
    return this.algebraEngine.permutation(n, k);
  }
  
  // ==================== 三角函数 ====================
  
  /**
   * 三角化简
   * @example
   * api.trigSimplify('sin(x)^2 + cos(x)^2')  // 1
   */
  trigSimplify(expression: string | IMathObject): SymbolicResult {
    const expr = typeof expression === 'string' 
      ? this.computeEngine.parse(expression) 
      : expression;
    return this.symbolicEngine.trigSimplify(expr);
  }
  
  // ==================== 对数和指数 ====================
  
  /**
   * 对数化简
   * @example
   * api.logSimplify('log(a*b)')  // log(a) + log(b)
   */
  logSimplify(expression: string | IMathObject): SymbolicResult {
    const expr = typeof expression === 'string' 
      ? this.computeEngine.parse(expression) 
      : expression;
    return this.symbolicEngine.logSimplify(expr);
  }
  
  // ==================== 变量管理 ====================
  
  /**
   * 设置变量
   * @example
   * api.setVar('x', 5)
   * api.compute('x + 3')  // 8
   */
  setVar(name: string, value: number | IMathObject): void {
    this.computeEngine.setVariable(name, value);
  }
  
  /**
   * 获取变量
   * @example
   * api.getVar('x')
   */
  getVar(name: string): IMathObject | undefined {
    return this.computeEngine.getVariable(name);
  }
  
  /**
   * 清除变量
   * @example
   * api.clearVar('x')
   */
  clearVar(name: string): void {
    this.computeEngine.clearVariable(name);
  }
  
  /**
   * 清除所有变量
   * @example
   * api.clearAllVars()
   */
  clearAllVars(): void {
    this.computeEngine.clearAllVariables();
  }
  
  // ==================== 配置 ====================
  
  /**
   * 设置精度
   * @example
   * api.setPrecision(15)
   */
  setPrecision(precision: number): void {
    this.computeEngine.setPrecision(precision);
  }
  
  /**
   * 设置角度单位
   * @example
   * api.setAngleUnit('radian')
   */
  setAngleUnit(unit: 'degree' | 'radian'): void {
    this.computeEngine.setAngleUnit(unit);
  }
  
  /**
   * 设置定义域
   * @example
   * api.setDomain('complex')
   */
  setDomain(domain: 'real' | 'complex'): void {
    this.computeEngine.setDomain(domain);
  }
  
  // ==================== 工具函数 ====================
  
  /**
   * 解析表达式
   * @example
   * api.parse('x^2 + 2x + 1')
   */
  parse(expression: string): IMathObject {
    return this.computeEngine.parse(expression);
  }
  
  /**
   * 创建数学对象
   */
  get create() {
    return MathObjectFactory;
  }
  
  /**
   * 获取计算引擎（高级用法）
   */
  get engines() {
    return {
      compute: this.computeEngine,
      symbolic: this.symbolicEngine,
      algebra: this.algebraEngine
    };
  }
}

/**
 * 创建全局 API 实例
 * 使用单例模式
 */
let globalAPI: UnifiedMathAPI | null = null;

export function getMathAPI(precision?: number): UnifiedMathAPI {
  if (!globalAPI) {
    globalAPI = new UnifiedMathAPI(precision);
  }
  return globalAPI;
}

/**
 * 重置全局 API
 */
export function resetMathAPI(): void {
  globalAPI = null;
}

/**
 * 便捷函数：直接计算
 */
export async function compute(expression: string, options?: ComputeOptions): Promise<ComputeResult> {
  return await getMathAPI().compute(expression, options);
}

/**
 * 便捷函数：求导
 */
export async function diff(expression: string, variable: string = 'x'): Promise<ComputeResult> {
  return await getMathAPI().differentiate(expression, variable);
}

/**
 * 便捷函数：积分
 */
export async function integrate(expression: string, variable: string = 'x', from?: number, to?: number): Promise<ComputeResult> {
  return await getMathAPI().integrate(expression, variable, from, to);
}

/**
 * 便捷函数：求极限
 */
export function limit(expression: string, variable: string, approachValue: number | string): ComputeResult {
  return getMathAPI().limit(expression, variable, approachValue);
}

/**
 * 便捷函数：化简
 */
export function simplify(expression: string): SymbolicResult {
  return getMathAPI().simplify(expression);
}

/**
 * 便捷函数：展开
 */
export function expand(expression: string): SymbolicResult {
  return getMathAPI().expand(expression);
}

/**
 * 便捷函数：因式分解
 */
export function factor(expression: string): SymbolicResult {
  return getMathAPI().factor(expression);
}

/**
 * 便捷函数：求解方程
 */
export function solve(equation: string, variable: string): SymbolicResult {
  return getMathAPI().solve(equation, variable);
}

