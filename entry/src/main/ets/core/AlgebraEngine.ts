/**
 * 代数计算引擎
 * 参考 SageMath 的代数系统
 * 支持多项式、矩阵、向量、线性代数等
 */
import { Logger } from '../utils/Logger';
import { IMathObject, MathNumber, MathObjectFactory } from './MathObject';

/**
 * 矩阵类
 */
export class Matrix {
  private data: number[][];
  public rows: number;
  public cols: number;
  
  constructor(data: number[][]) {
    this.data = data;
    this.rows = data.length;
    this.cols = data[0]?.length || 0;
    
    // 验证矩阵格式
    for (const row of data) {
      if (row.length !== this.cols) {
        throw new Error('矩阵行长度不一致');
      }
    }
  }
  
  /**
   * 获取元素
   */
  get(i: number, j: number): number {
    return this.data[i][j];
  }
  
  /**
   * 设置元素
   */
  set(i: number, j: number, value: number): void {
    this.data[i][j] = value;
  }
  
  /**
   * 矩阵加法
   */
  add(other: Matrix): Matrix {
    if (this.rows !== other.rows || this.cols !== other.cols) {
      throw new Error('矩阵维度不匹配');
    }
    
    const result: number[][] = [];
    for (let i = 0; i < this.rows; i++) {
      result[i] = [];
      for (let j = 0; j < this.cols; j++) {
        result[i][j] = this.data[i][j] + other.data[i][j];
      }
    }
    
    return new Matrix(result);
  }
  
  /**
   * 矩阵减法
   */
  subtract(other: Matrix): Matrix {
    if (this.rows !== other.rows || this.cols !== other.cols) {
      throw new Error('矩阵维度不匹配');
    }
    
    const result: number[][] = [];
    for (let i = 0; i < this.rows; i++) {
      result[i] = [];
      for (let j = 0; j < this.cols; j++) {
        result[i][j] = this.data[i][j] - other.data[i][j];
      }
    }
    
    return new Matrix(result);
  }
  
  /**
   * 矩阵乘法
   */
  multiply(other: Matrix): Matrix {
    if (this.cols !== other.rows) {
      throw new Error('矩阵维度不匹配');
    }
    
    const result: number[][] = [];
    for (let i = 0; i < this.rows; i++) {
      result[i] = [];
      for (let j = 0; j < other.cols; j++) {
        let sum = 0;
        for (let k = 0; k < this.cols; k++) {
          sum += this.data[i][k] * other.data[k][j];
        }
        result[i][j] = sum;
      }
    }
    
    return new Matrix(result);
  }
  
  /**
   * 标量乘法
   */
  scale(scalar: number): Matrix {
    const result: number[][] = [];
    for (let i = 0; i < this.rows; i++) {
      result[i] = [];
      for (let j = 0; j < this.cols; j++) {
        result[i][j] = this.data[i][j] * scalar;
      }
    }
    
    return new Matrix(result);
  }
  
  /**
   * 转置
   */
  transpose(): Matrix {
    const result: number[][] = [];
    for (let j = 0; j < this.cols; j++) {
      result[j] = [];
      for (let i = 0; i < this.rows; i++) {
        result[j][i] = this.data[i][j];
      }
    }
    
    return new Matrix(result);
  }
  
  /**
   * 行列式（仅方阵）
   */
  determinant(): number {
    if (this.rows !== this.cols) {
      throw new Error('只有方阵才有行列式');
    }
    
    return this.computeDeterminant(this.data);
  }
  
  /**
   * 递归计算行列式
   */
  private computeDeterminant(matrix: number[][]): number {
    const n = matrix.length;
    
    if (n === 1) {
      return matrix[0][0];
    }
    
    if (n === 2) {
      return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];
    }
    
    let det = 0;
    for (let j = 0; j < n; j++) {
      const minor = this.getMinor(matrix, 0, j);
      const cofactor = Math.pow(-1, j) * matrix[0][j];
      det += cofactor * this.computeDeterminant(minor);
    }
    
    return det;
  }
  
  /**
   * 获取余子式
   */
  private getMinor(matrix: number[][], row: number, col: number): number[][] {
    const result: number[][] = [];
    for (let i = 0; i < matrix.length; i++) {
      if (i === row) continue;
      const newRow: number[] = [];
      for (let j = 0; j < matrix[i].length; j++) {
        if (j === col) continue;
        newRow.push(matrix[i][j]);
      }
      result.push(newRow);
    }
    return result;
  }
  
  /**
   * 逆矩阵
   */
  inverse(): Matrix {
    if (this.rows !== this.cols) {
      throw new Error('只有方阵才有逆矩阵');
    }
    
    const det = this.determinant();
    if (Math.abs(det) < 1e-10) {
      throw new Error('矩阵不可逆');
    }
    
    // 使用高斯-约当消元法
    const n = this.rows;
    const augmented: number[][] = [];
    
    // 构造增广矩阵 [A|I]
    for (let i = 0; i < n; i++) {
      augmented[i] = [...this.data[i]];
      for (let j = 0; j < n; j++) {
        augmented[i].push(i === j ? 1 : 0);
      }
    }
    
    // 高斯-约当消元
    for (let i = 0; i < n; i++) {
      // 主元归一化
      const pivot = augmented[i][i];
      if (Math.abs(pivot) < 1e-10) {
        throw new Error('矩阵不可逆');
      }
      
      for (let j = 0; j < 2 * n; j++) {
        augmented[i][j] /= pivot;
      }
      
      // 消元
      for (let k = 0; k < n; k++) {
        if (k !== i) {
          const factor = augmented[k][i];
          for (let j = 0; j < 2 * n; j++) {
            augmented[k][j] -= factor * augmented[i][j];
          }
        }
      }
    }
    
    // 提取逆矩阵
    const result: number[][] = [];
    for (let i = 0; i < n; i++) {
      result[i] = augmented[i].slice(n);
    }
    
    return new Matrix(result);
  }
  
  /**
   * 秩
   */
  rank(): number {
    const matrix = this.data.map(row => [...row]);
    const m = this.rows;
    const n = this.cols;
    let rank = 0;
    
    for (let col = 0; col < n && rank < m; col++) {
      // 找主元
      let pivotRow = rank;
      for (let row = rank + 1; row < m; row++) {
        if (Math.abs(matrix[row][col]) > Math.abs(matrix[pivotRow][col])) {
          pivotRow = row;
        }
      }
      
      if (Math.abs(matrix[pivotRow][col]) < 1e-10) {
        continue;
      }
      
      // 交换行
      [matrix[rank], matrix[pivotRow]] = [matrix[pivotRow], matrix[rank]];
      
      // 消元
      for (let row = rank + 1; row < m; row++) {
        const factor = matrix[row][col] / matrix[rank][col];
        for (let c = col; c < n; c++) {
          matrix[row][c] -= factor * matrix[rank][c];
        }
      }
      
      rank++;
    }
    
    return rank;
  }
  
  /**
   * 特征值（仅2x2和3x3矩阵）
   */
  eigenvalues(): number[] {
    if (this.rows !== this.cols) {
      throw new Error('只有方阵才有特征值');
    }
    
    if (this.rows === 2) {
      return this.eigenvalues2x2();
    } else if (this.rows === 3) {
      return this.eigenvalues3x3();
    } else {
      throw new Error('暂不支持该维度矩阵的特征值计算');
    }
  }
  
  /**
   * 2x2矩阵特征值
   */
  private eigenvalues2x2(): number[] {
    const a = this.data[0][0];
    const b = this.data[0][1];
    const c = this.data[1][0];
    const d = this.data[1][1];
    
    // 特征方程: λ² - (a+d)λ + (ad-bc) = 0
    const trace = a + d;
    const det = a * d - b * c;
    
    const discriminant = trace * trace - 4 * det;
    
    if (discriminant >= 0) {
      const sqrt = Math.sqrt(discriminant);
      return [
        (trace + sqrt) / 2,
        (trace - sqrt) / 2
      ];
    } else {
      // 复特征值
      const real = trace / 2;
      const imag = Math.sqrt(-discriminant) / 2;
      // 简化：只返回实部
      return [real, real];
    }
  }
  
  /**
   * 3x3矩阵特征值（简化实现）
   */
  private eigenvalues3x3(): number[] {
    // 使用数值方法（QR算法的简化版本）
    // 完整实现需要更复杂的算法
    throw new Error('3x3矩阵特征值计算功能开发中');
  }
  
  /**
   * 转换为字符串
   */
  toString(): string {
    let result = '[\n';
    for (let i = 0; i < this.rows; i++) {
      result += '  [' + this.data[i].join(', ') + ']';
      if (i < this.rows - 1) result += ',';
      result += '\n';
    }
    result += ']';
    return result;
  }
  
  /**
   * 转换为 LaTeX
   */
  toLatex(): string {
    let result = '\\begin{bmatrix}\n';
    for (let i = 0; i < this.rows; i++) {
      result += '  ' + this.data[i].join(' & ');
      if (i < this.rows - 1) result += ' \\\\';
      result += '\n';
    }
    result += '\\end{bmatrix}';
    return result;
  }
  
  /**
   * 克隆
   */
  clone(): Matrix {
    return new Matrix(this.data.map(row => [...row]));
  }
}

/**
 * 向量类
 */
export class Vector {
  private data: number[];
  public dimension: number;
  
  constructor(data: number[]) {
    this.data = data;
    this.dimension = data.length;
  }
  
  /**
   * 获取元素
   */
  get(i: number): number {
    return this.data[i];
  }
  
  /**
   * 设置元素
   */
  set(i: number, value: number): void {
    this.data[i] = value;
  }
  
  /**
   * 向量加法
   */
  add(other: Vector): Vector {
    if (this.dimension !== other.dimension) {
      throw new Error('向量维度不匹配');
    }
    
    const result: number[] = [];
    for (let i = 0; i < this.dimension; i++) {
      result[i] = this.data[i] + other.data[i];
    }
    
    return new Vector(result);
  }
  
  /**
   * 向量减法
   */
  subtract(other: Vector): Vector {
    if (this.dimension !== other.dimension) {
      throw new Error('向量维度不匹配');
    }
    
    const result: number[] = [];
    for (let i = 0; i < this.dimension; i++) {
      result[i] = this.data[i] - other.data[i];
    }
    
    return new Vector(result);
  }
  
  /**
   * 标量乘法
   */
  scale(scalar: number): Vector {
    const result: number[] = [];
    for (let i = 0; i < this.dimension; i++) {
      result[i] = this.data[i] * scalar;
    }
    
    return new Vector(result);
  }
  
  /**
   * 点积
   */
  dot(other: Vector): number {
    if (this.dimension !== other.dimension) {
      throw new Error('向量维度不匹配');
    }
    
    let sum = 0;
    for (let i = 0; i < this.dimension; i++) {
      sum += this.data[i] * other.data[i];
    }
    
    return sum;
  }
  
  /**
   * 叉积（仅3维向量）
   */
  cross(other: Vector): Vector {
    if (this.dimension !== 3 || other.dimension !== 3) {
      throw new Error('叉积仅适用于3维向量');
    }
    
    const result = [
      this.data[1] * other.data[2] - this.data[2] * other.data[1],
      this.data[2] * other.data[0] - this.data[0] * other.data[2],
      this.data[0] * other.data[1] - this.data[1] * other.data[0]
    ];
    
    return new Vector(result);
  }
  
  /**
   * 模长
   */
  magnitude(): number {
    return Math.sqrt(this.dot(this));
  }
  
  /**
   * 归一化
   */
  normalize(): Vector {
    const mag = this.magnitude();
    if (mag === 0) {
      throw new Error('零向量无法归一化');
    }
    return this.scale(1 / mag);
  }
  
  /**
   * 转换为字符串
   */
  toString(): string {
    return '[' + this.data.join(', ') + ']';
  }
  
  /**
   * 转换为 LaTeX
   */
  toLatex(): string {
    return '\\begin{pmatrix} ' + this.data.join(' \\\\ ') + ' \\end{pmatrix}';
  }
  
  /**
   * 克隆
   */
  clone(): Vector {
    return new Vector([...this.data]);
  }
}

/**
 * 多项式类
 */
export class Polynomial {
  private coefficients: number[]; // 系数数组，从低次到高次
  public degree: number;
  
  constructor(coefficients: number[]) {
    // 移除高次零系数
    while (coefficients.length > 1 && coefficients[coefficients.length - 1] === 0) {
      coefficients.pop();
    }
    
    this.coefficients = coefficients;
    this.degree = coefficients.length - 1;
  }
  
  /**
   * 获取系数
   */
  getCoefficient(degree: number): number {
    return this.coefficients[degree] || 0;
  }
  
  /**
   * 多项式加法
   */
  add(other: Polynomial): Polynomial {
    const maxLen = Math.max(this.coefficients.length, other.coefficients.length);
    const result: number[] = [];
    
    for (let i = 0; i < maxLen; i++) {
      result[i] = this.getCoefficient(i) + other.getCoefficient(i);
    }
    
    return new Polynomial(result);
  }
  
  /**
   * 多项式减法
   */
  subtract(other: Polynomial): Polynomial {
    const maxLen = Math.max(this.coefficients.length, other.coefficients.length);
    const result: number[] = [];
    
    for (let i = 0; i < maxLen; i++) {
      result[i] = this.getCoefficient(i) - other.getCoefficient(i);
    }
    
    return new Polynomial(result);
  }
  
  /**
   * 多项式乘法
   */
  multiply(other: Polynomial): Polynomial {
    const result: number[] = new Array(this.degree + other.degree + 1).fill(0);
    
    for (let i = 0; i <= this.degree; i++) {
      for (let j = 0; j <= other.degree; j++) {
        result[i + j] += this.coefficients[i] * other.coefficients[j];
      }
    }
    
    return new Polynomial(result);
  }
  
  /**
   * 多项式求值
   */
  evaluate(x: number): number {
    let result = 0;
    let power = 1;
    
    for (let i = 0; i <= this.degree; i++) {
      result += this.coefficients[i] * power;
      power *= x;
    }
    
    return result;
  }
  
  /**
   * 多项式求导
   */
  derivative(): Polynomial {
    if (this.degree === 0) {
      return new Polynomial([0]);
    }
    
    const result: number[] = [];
    for (let i = 1; i <= this.degree; i++) {
      result[i - 1] = i * this.coefficients[i];
    }
    
    return new Polynomial(result);
  }
  
  /**
   * 多项式积分
   */
  integrate(): Polynomial {
    const result: number[] = [0]; // 常数项为0
    
    for (let i = 0; i <= this.degree; i++) {
      result[i + 1] = this.coefficients[i] / (i + 1);
    }
    
    return new Polynomial(result);
  }
  
  /**
   * 转换为字符串
   */
  toString(variable: string = 'x'): string {
    if (this.degree === 0) {
      return this.coefficients[0].toString();
    }
    
    const terms: string[] = [];
    
    for (let i = this.degree; i >= 0; i--) {
      const coef = this.coefficients[i];
      if (coef === 0) continue;
      
      let term = '';
      
      // 系数
      if (i === 0 || Math.abs(coef) !== 1) {
        term += Math.abs(coef).toString();
      }
      
      // 变量
      if (i > 0) {
        if (term && Math.abs(coef) !== 1) term += '*';
        term += variable;
        if (i > 1) term += '^' + i;
      }
      
      // 符号
      if (terms.length > 0) {
        term = (coef > 0 ? ' + ' : ' - ') + term;
      } else if (coef < 0) {
        term = '-' + term;
      }
      
      terms.push(term);
    }
    
    return terms.join('');
  }
  
  /**
   * 转换为 LaTeX
   */
  toLatex(variable: string = 'x'): string {
    if (this.degree === 0) {
      return this.coefficients[0].toString();
    }
    
    const terms: string[] = [];
    
    for (let i = this.degree; i >= 0; i--) {
      const coef = this.coefficients[i];
      if (coef === 0) continue;
      
      let term = '';
      
      // 系数
      if (i === 0 || Math.abs(coef) !== 1) {
        term += Math.abs(coef).toString();
      }
      
      // 变量
      if (i > 0) {
        term += variable;
        if (i > 1) term += '^{' + i + '}';
      }
      
      // 符号
      if (terms.length > 0) {
        term = (coef > 0 ? ' + ' : ' - ') + term;
      } else if (coef < 0) {
        term = '-' + term;
      }
      
      terms.push(term);
    }
    
    return terms.join('');
  }
}

/**
 * 代数引擎类
 */
export class AlgebraEngine {
  
  /**
   * 创建矩阵
   */
  createMatrix(data: number[][]): Matrix {
    return new Matrix(data);
  }
  
  /**
   * 创建单位矩阵
   */
  createIdentityMatrix(n: number): Matrix {
    const data: number[][] = [];
    for (let i = 0; i < n; i++) {
      data[i] = [];
      for (let j = 0; j < n; j++) {
        data[i][j] = i === j ? 1 : 0;
      }
    }
    return new Matrix(data);
  }
  
  /**
   * 创建零矩阵
   */
  createZeroMatrix(rows: number, cols: number): Matrix {
    const data: number[][] = [];
    for (let i = 0; i < rows; i++) {
      data[i] = new Array(cols).fill(0);
    }
    return new Matrix(data);
  }
  
  /**
   * 创建向量
   */
  createVector(data: number[]): Vector {
    return new Vector(data);
  }
  
  /**
   * 创建多项式
   */
  createPolynomial(coefficients: number[]): Polynomial {
    return new Polynomial(coefficients);
  }
  
  /**
   * 求解线性方程组 Ax = b
   */
  solveLinearSystem(A: Matrix, b: Vector): Vector {
    if (A.rows !== A.cols) {
      throw new Error('系数矩阵必须是方阵');
    }
    if (A.rows !== b.dimension) {
      throw new Error('矩阵和向量维度不匹配');
    }
    
    // 使用高斯消元法
    const n = A.rows;
    const augmented: number[][] = [];
    
    // 构造增广矩阵 [A|b]
    for (let i = 0; i < n; i++) {
      augmented[i] = [];
      for (let j = 0; j < n; j++) {
        augmented[i][j] = A.get(i, j);
      }
      augmented[i][n] = b.get(i);
    }
    
    // 前向消元
    for (let i = 0; i < n; i++) {
      // 找主元
      let maxRow = i;
      for (let k = i + 1; k < n; k++) {
        if (Math.abs(augmented[k][i]) > Math.abs(augmented[maxRow][i])) {
          maxRow = k;
        }
      }
      
      // 交换行
      [augmented[i], augmented[maxRow]] = [augmented[maxRow], augmented[i]];
      
      // 检查主元
      if (Math.abs(augmented[i][i]) < 1e-10) {
        throw new Error('方程组无唯一解');
      }
      
      // 消元
      for (let k = i + 1; k < n; k++) {
        const factor = augmented[k][i] / augmented[i][i];
        for (let j = i; j <= n; j++) {
          augmented[k][j] -= factor * augmented[i][j];
        }
      }
    }
    
    // 回代
    const x: number[] = new Array(n);
    for (let i = n - 1; i >= 0; i--) {
      x[i] = augmented[i][n];
      for (let j = i + 1; j < n; j++) {
        x[i] -= augmented[i][j] * x[j];
      }
      x[i] /= augmented[i][i];
    }
    
    return new Vector(x);
  }
  
  /**
   * 最大公约数
   */
  gcd(a: number, b: number): number {
    a = Math.abs(Math.floor(a));
    b = Math.abs(Math.floor(b));
    
    while (b !== 0) {
      const temp = b;
      b = a % b;
      a = temp;
    }
    
    return a;
  }
  
  /**
   * 最小公倍数
   */
  lcm(a: number, b: number): number {
    return Math.abs(a * b) / this.gcd(a, b);
  }
  
  /**
   * 阶乘
   */
  factorial(n: number): number {
    if (n < 0 || !Number.isInteger(n)) {
      throw new Error('阶乘仅适用于非负整数');
    }
    
    if (n === 0 || n === 1) return 1;
    
    let result = 1;
    for (let i = 2; i <= n; i++) {
      result *= i;
    }
    
    return result;
  }
  
  /**
   * 组合数 C(n, k)
   */
  combination(n: number, k: number): number {
    if (k < 0 || k > n) return 0;
    if (k === 0 || k === n) return 1;
    
    // 优化：C(n,k) = C(n, n-k)
    k = Math.min(k, n - k);
    
    let result = 1;
    for (let i = 0; i < k; i++) {
      result *= (n - i);
      result /= (i + 1);
    }
    
    return result;
  }
  
  /**
   * 排列数 P(n, k)
   */
  permutation(n: number, k: number): number {
    if (k < 0 || k > n) return 0;
    
    let result = 1;
    for (let i = 0; i < k; i++) {
      result *= (n - i);
    }
    
    return result;
  }
}

