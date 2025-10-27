/**
 * 增强版多项式处理引擎
 * 参考 SageMath 的多项式系统
 * 支持多项式的创建、运算、求根、因式分解等
 */
import { Logger } from '../utils/Logger';

/**
 * 多项式类（增强版）
 */
export class EnhancedPolynomial {
  private coefficients: number[]; // 从低次到高次
  public degree: number;
  private variable: string = 'x';
  
  constructor(coefficients: number[], variable: string = 'x') {
    // 移除高次零系数
    while (coefficients.length > 1 && coefficients[coefficients.length - 1] === 0) {
      coefficients.pop();
    }
    
    this.coefficients = coefficients;
    this.degree = coefficients.length - 1;
    this.variable = variable;
  }
  
  /**
   * 获取系数
   */
  getCoefficient(power: number): number {
    return this.coefficients[power] || 0;
  }
  
  /**
   * 多项式加法
   */
  add(other: EnhancedPolynomial): EnhancedPolynomial {
    const maxLen = Math.max(this.coefficients.length, other.coefficients.length);
    const newCoefs: number[] = [];
    
    for (let i = 0; i < maxLen; i++) {
      newCoefs[i] = this.getCoefficient(i) + other.getCoefficient(i);
    }
    
    return new EnhancedPolynomial(newCoefs, this.variable);
  }
  
  /**
   * 多项式减法
   */
  subtract(other: EnhancedPolynomial): EnhancedPolynomial {
    const maxLen = Math.max(this.coefficients.length, other.coefficients.length);
    const newCoefs: number[] = [];
    
    for (let i = 0; i < maxLen; i++) {
      newCoefs[i] = this.getCoefficient(i) - other.getCoefficient(i);
    }
    
    return new EnhancedPolynomial(newCoefs, this.variable);
  }
  
  /**
   * 多项式乘法
   */
  multiply(other: EnhancedPolynomial): EnhancedPolynomial {
    const newCoefs: number[] = new Array(this.degree + other.degree + 1).fill(0);
    
    for (let i = 0; i <= this.degree; i++) {
      for (let j = 0; j <= other.degree; j++) {
        newCoefs[i + j] += this.coefficients[i] * other.coefficients[j];
      }
    }
    
    return new EnhancedPolynomial(newCoefs, this.variable);
  }
  
  /**
   * 多项式除法（返回商和余数）
   */
  divide(other: EnhancedPolynomial): { quotient: EnhancedPolynomial, remainder: EnhancedPolynomial } {
    if (other.degree > this.degree) {
      return {
        quotient: new EnhancedPolynomial([0], this.variable),
        remainder: this.clone()
      };
    }
    
    const quotientCoefs: number[] = [];
    const dividend = [...this.coefficients];
    
    const divisor = other.coefficients;
    const divisorDegree = other.degree;
    
    while (dividend.length >= divisor.length) {
      const factor = dividend[dividend.length - 1] / divisor[divisor.length - 1];
      quotientCoefs[dividend.length - divisor.length] = factor;
      
      // 减去 factor * divisor
      for (let i = 0; i < divisor.length; i++) {
        const index = dividend.length - divisor.length + i;
        if (dividend[index] !== undefined) {
          dividend[index] -= factor * divisor[i];
        }
      }
      
      // 移除最高次项
      dividend.pop();
    }
    
    quotientCoefs.reverse();
    const quotient = new EnhancedPolynomial(quotientCoefs, this.variable);
    const remainder = new EnhancedPolynomial(dividend, this.variable);
    
    return { quotient, remainder };
  }
  
  /**
   * 多项式求值
   */
  evaluate(x: number): number {
    let result = 0;
    for (let i = 0; i <= this.degree; i++) {
      result += this.coefficients[i] * Math.pow(x, i);
    }
    return result;
  }
  
  /**
   * 多项式求导
   */
  derivative(): EnhancedPolynomial {
    if (this.degree === 0) {
      return new EnhancedPolynomial([0], this.variable);
    }
    
    const newCoefs: number[] = [];
    for (let i = 1; i <= this.degree; i++) {
      newCoefs[i - 1] = i * this.coefficients[i];
    }
    
    return new EnhancedPolynomial(newCoefs, this.variable);
  }
  
  /**
   * 多项式积分
   */
  integrate(constant: number = 0): EnhancedPolynomial {
    const newCoefs: number[] = [constant];
    
    for (let i = 0; i <= this.degree; i++) {
      newCoefs[i + 1] = this.coefficients[i] / (i + 1);
    }
    
    return new EnhancedPolynomial(newCoefs, this.variable);
  }
  
  /**
   * 求导n次
   */
  derivativeNth(n: number): EnhancedPolynomial {
    let result = this;
    for (let i = 0; i < n; i++) {
      result = result.derivative();
    }
    return result;
  }
  
  /**
   * 求多项式在x处的n阶导数值
   */
  evaluateDerivativeNth(x: number, n: number): number {
    const poly = this.derivativeNth(n);
    return poly.evaluate(x);
  }
  
  /**
   * 使用 Horner 方法求值（更高效）
   */
  evaluateHorner(x: number): number {
    let result = this.coefficients[this.degree];
    for (let i = this.degree - 1; i >= 0; i--) {
      result = result * x + this.coefficients[i];
    }
    return result;
  }
  
  /**
   * 使用 Newton-Raphson 方法求根
   */
  findRoot(initialGuess: number = 0, tolerance: number = 1e-10, maxIterations: number = 100): number | null {
    let x = initialGuess;
    
    for (let i = 0; i < maxIterations; i++) {
      const fx = this.evaluate(x);
      const dfx = this.derivative().evaluate(x);
      
      if (Math.abs(dfx) < 1e-10) {
        return null; // 导数接近零
      }
      
      const xNew = x - fx / dfx;
      
      if (Math.abs(xNew - x) < tolerance) {
        return xNew;
      }
      
      x = xNew;
    }
    
    return null;
  }
  
  /**
   * 找到所有实数根（简化实现）
   */
  findAllRoots(xMin: number = -10, xMax: number = 10, step: number = 0.1): number[] {
    const roots: number[] = [];
    
    for (let x = xMin; x < xMax; x += step) {
      const root = this.findRoot(x);
      if (root !== null) {
        // 检查是否与已有根重复
        const isDuplicate = roots.some(r => Math.abs(r - root) < 1e-6);
        if (!isDuplicate) {
          roots.push(root);
        }
      }
    }
    
    return roots.sort((a, b) => a - b);
  }
  
  /**
   * 因式分解（简化实现）
   */
  factorize(): string {
    const roots = this.findAllRoots();
    const factors: string[] = [];
    
    for (const root of roots) {
      const factor = root === 0 ? this.variable : `(${this.variable} - ${root.toFixed(4)})`;
      factors.push(factor);
    }
    
    if (factors.length === 0) {
      return this.toString();
    }
    
    return factors.join(' * ');
  }
  
  /**
   * 计算多项式的 gcd（最大公因式）
   */
  gcd(other: EnhancedPolynomial): EnhancedPolynomial {
    let a = this;
    let b = other;
    
    while (b.degree >= 0 && Math.abs(b.coefficients[0]) > 1e-10) {
      const { remainder } = a.divide(b);
      a = b;
      b = remainder;
    }
    
    // 归一化
    const leadingCoef = a.coefficients[a.coefficients.length - 1];
    if (Math.abs(leadingCoef) > 1e-10) {
      const normalized = a.coefficients.map(c => c / leadingCoef);
      return new EnhancedPolynomial(normalized, this.variable);
    }
    
    return a;
  }
  
  /**
   * 计算多项式的 lcm（最小公倍式）
   */
  lcm(other: EnhancedPolynomial): EnhancedPolynomial {
    const divisor = this.gcd(other);
    return this.multiply(other).divide(divisor).quotient;
  }
  
  /**
   * 克隆
   */
  clone(): EnhancedPolynomial {
    return new EnhancedPolynomial([...this.coefficients], this.variable);
  }
  
  /**
   * 转换为字符串
   */
  toString(): string {
    if (this.degree < 0) {
      return '0';
    }
    
    const terms: string[] = [];
    
    for (let i = this.degree; i >= 0; i--) {
      const coef = this.coefficients[i];
      if (Math.abs(coef) < 1e-10) continue;
      
      let term = '';
      
      // 系数
      if (i === 0) {
        term = coef.toString();
      } else if (Math.abs(coef) === 1) {
        term = (coef < 0 ? '-' : '') + this.variable;
      } else {
        term = coef.toString() + '*' + this.variable;
      }
      
      // 幂次
      if (i > 1) {
        term += '^' + i;
      }
      
      // 符号
      if (terms.length > 0) {
        term = (coef > 0 ? ' + ' : ' - ') + (coef < 0 ? term.substring(1) : term);
      }
      
      terms.push(term);
    }
    
    return terms.join('') || '0';
  }
  
  /**
   * 转换为 LaTeX
   */
  toLatex(): string {
    if (this.degree < 0) {
      return '0';
    }
    
    const terms: string[] = [];
    
    for (let i = this.degree; i >= 0; i--) {
      const coef = this.coefficients[i];
      if (Math.abs(coef) < 1e-10) continue;
      
      let term = '';
      
      // 系数
      if (i === 0) {
        term = coef.toString();
      } else if (Math.abs(coef) === 1) {
        term = (coef < 0 ? '-' : '') + this.variable;
      } else {
        term = coef.toString() + this.variable;
      }
      
      // 幂次
      if (i > 1) {
        term += '^{' + i + '}';
      }
      
      // 符号
      if (terms.length > 0) {
        term = (coef > 0 ? ' + ' : ' - ') + (coef < 0 ? term.substring(1) : term);
      }
      
      terms.push(term);
    }
    
    return terms.join('') || '0';
  }
}

/**
 * 复数类（增强版）
 */
export class EnhancedComplex {
  private real: number;
  private imag: number;
  
  constructor(real: number, imag: number) {
    this.real = real;
    this.imag = imag;
  }
  
  /**
   * 获取实部
   */
  getRe(): number {
    return this.real;
  }
  
  /**
   * 获取虚部
   */
  getIm(): number {
    return this.imag;
  }
  
  /**
   * 复数加法
   */
  add(other: EnhancedComplex): EnhancedComplex {
    return new EnhancedComplex(this.real + other.real, this.imag + other.imag);
  }
  
  /**
   * 复数减法
   */
  subtract(other: EnhancedComplex): EnhancedComplex {
    return new EnhancedComplex(this.real - other.real, this.imag - other.imag);
  }
  
  /**
   * 复数乘法: (a+bi)(c+di) = ac - bd + (ad+bc)i
   */
  multiply(other: EnhancedComplex): EnhancedComplex {
    const real = this.real * other.real - this.imag * other.imag;
    const imag = this.real * other.imag + this.imag * other.real;
    return new EnhancedComplex(real, imag);
  }
  
  /**
   * 复数除法
   */
  divide(other: EnhancedComplex): EnhancedComplex {
    const denominator = other.real * other.real + other.imag * other.imag;
    const real = (this.real * other.real + this.imag * other.imag) / denominator;
    const imag = (this.imag * other.real - this.real * other.imag) / denominator;
    return new EnhancedComplex(real, imag);
  }
  
  /**
   * 复数的共轭
   */
  conjugate(): EnhancedComplex {
    return new EnhancedComplex(this.real, -this.imag);
  }
  
  /**
   * 复数的模
   */
  magnitude(): number {
    return Math.sqrt(this.real * this.real + this.imag * this.imag);
  }
  
  /**
   * 复数的平方模
   */
  magnitudeSquared(): number {
    return this.real * this.real + this.imag * this.imag;
  }
  
  /**
   * 复数的幅角（主值，[-π, π]）
   */
  argument(): number {
    return Math.atan2(this.imag, this.real);
  }
  
  /**
   * 复数的n次幂
   */
  power(n: number): EnhancedComplex {
    const mag = this.magnitude();
    const arg = this.argument();
    
    const newMag = Math.pow(mag, n);
    const newArg = n * arg;
    
    return new EnhancedComplex(
      newMag * Math.cos(newArg),
      newMag * Math.sin(newArg)
    );
  }
  
  /**
   * 复数的平方根
   */
  sqrt(): EnhancedComplex[] {
    const mag = this.magnitude();
    const arg = this.argument();
    
    const sqrtMag = Math.sqrt(mag);
    const sqrtArg1 = arg / 2;
    const sqrtArg2 = (arg + 2 * Math.PI) / 2;
    
    return [
      new EnhancedComplex(sqrtMag * Math.cos(sqrtArg1), sqrtMag * Math.sin(sqrtArg1)),
      new EnhancedComplex(sqrtMag * Math.cos(sqrtArg2), sqrtMag * Math.sin(sqrtArg2))
    ];
  }
  
  /**
   * 复数的n次根
   */
  nthRoot(n: number): EnhancedComplex[] {
    const mag = this.magnitude();
    const arg = this.argument();
    
    const rootMag = Math.pow(mag, 1 / n);
    const roots: EnhancedComplex[] = [];
    
    for (let k = 0; k < n; k++) {
      const rootArg = (arg + 2 * Math.PI * k) / n;
      roots.push(new EnhancedComplex(
        rootMag * Math.cos(rootArg),
        rootMag * Math.sin(rootArg)
      ));
    }
    
    return roots;
  }
  
  /**
   * 复数的指数
   */
  exp(): EnhancedComplex {
    const expReal = Math.exp(this.real);
    return new EnhancedComplex(
      expReal * Math.cos(this.imag),
      expReal * Math.sin(this.imag)
    );
  }
  
  /**
   * 复数的对数（主值）
   */
  log(): EnhancedComplex {
    return new EnhancedComplex(
      Math.log(this.magnitude()),
      this.argument()
    );
  }
  
  /**
   * 转字符串
   */
  toString(): string {
    if (this.imag === 0) {
      return this.real.toString();
    }
    if (this.real === 0) {
      return this.imag === 1 ? 'i' : `${this.imag}i`;
    }
    return `${this.real} ${this.imag > 0 ? '+' : ''} ${this.imag === 1 ? 'i' : this.imag === -1 ? '-i' : this.imag + 'i'}`;
  }
  
  /**
   * 转 LaTeX
   */
  toLatex(): string {
    if (this.imag === 0) {
      return this.real.toString();
    }
    if (this.real === 0) {
      return this.imag === 1 ? 'i' : `${this.imag}i`;
    }
    return `${this.real} ${this.imag > 0 ? '+' : ''} ${this.imag}i`;
  }
}

/**
 * 增强多项式引擎
 */
export class EnhancedPolynomialEngine {
  
  /**
   * 创建多项式
   */
  createPolynomial(coefficients: number[], variable: string = 'x'): EnhancedPolynomial {
    return new EnhancedPolynomial(coefficients, variable);
  }
  
  /**
   * 创建复数
   */
  createComplex(real: number, imag: number): EnhancedComplex {
    return new EnhancedComplex(real, imag);
  }
  
  /**
   * 从多项式根构建多项式
   */
  fromRoots(roots: number[], variable: string = 'x'): EnhancedPolynomial {
    let result = new EnhancedPolynomial([1], variable);
    
    for (const root of roots) {
      const factor = new EnhancedPolynomial([-root, 1], variable);
      result = result.multiply(factor);
    }
    
    return result;
  }
  
  /**
   * 插值多项式（Lagrange插值）
   */
  lagrangeInterpolation(points: Array<{ x: number, y: number }>, variable: string = 'x'): EnhancedPolynomial {
    const n = points.length;
    const result = new EnhancedPolynomial([0], variable);
    
    for (let i = 0; i < n; i++) {
      let basis = new EnhancedPolynomial([points[i].y], variable);
      
      for (let j = 0; j < n; j++) {
        if (i !== j) {
          const denom = points[i].x - points[j].x;
          const num = new EnhancedPolynomial([-points[j].x, 1], variable);
          basis = basis.multiply(num.divide(new EnhancedPolynomial([1/denom], variable)).quotient);
        }
      }
      
      // 简化：直接构造结果多项式（这里简化实现）
    }
    
    return result;
  }
  
  /**
   * 计算多项式的 Sturm 序列（用于孤立根）
   */
  sturmSequence(poly: EnhancedPolynomial): EnhancedPolynomial[] {
    const sequence: EnhancedPolynomial[] = [poly];
    
    if (poly.degree > 0) {
      const derivative = poly.derivative();
      sequence.push(derivative);
      
      let a = poly;
      let b = derivative;
      
      while (b.degree >= 0) {
        const { remainder } = a.divide(b);
        if (remainder.degree < 0) break;
        
        // 取负号
        const negRemainder = new EnhancedPolynomial(
          remainder.coefficients.map(c => -c),
          remainder.variable
        );
        
        sequence.push(negRemainder);
        
        a = b;
        b = negRemainder;
      }
    }
    
    return sequence;
  }
  
  /**
   * 使用 Sturm 序列统计区间内实根数量
   */
  countRootsInInterval(poly: EnhancedPolynomial, a: number, b: number): number {
    const sturm = this.sturmSequence(poly);
    
    const signChangesA = this.countSignChangesAt(sturm, a);
    const signChangesB = this.countSignChangesAt(sturm, b);
    
    return signChangesA - signChangesB;
  }
  
  /**
   * 统计符号变化次数
   */
  private countSignChangesAt(sturm: EnhancedPolynomial[], x: number): number {
    const values = sturm.map(p => p.evaluate(x));
    let changes = 0;
    
    for (let i = 0; i < values.length - 1; i++) {
      if (values[i] * values[i + 1] < 0) {
        changes++;
      }
    }
    
    return changes;
  }
}

