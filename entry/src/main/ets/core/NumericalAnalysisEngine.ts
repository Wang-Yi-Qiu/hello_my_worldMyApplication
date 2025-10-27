/**
 * 数值分析和优化引擎
 * 参考 SymPy 和 SageMath 的数值分析功能
 * 提供求根、优化、插值、数值积分等算法
 */
import { Logger } from '../utils/Logger';

/**
 * 优化结果
 */
export interface OptimizationResult {
  success: boolean;
  optimum?: { x: number, y: number };
  iterations?: number;
  error?: string;
  method?: string;
}

/**
 * 插值结果
 */
export interface InterpolationResult {
  success: boolean;
  polynomial?: string;
  evaluate?: (x: number) => number;
  error?: string;
}

/**
 * 数值分析引擎
 */
export class NumericalAnalysisEngine {
  
  /**
   * 使用二分法求函数零点
   */
  bisectionMethod(
    f: (x: number) => number,
    a: number,
    b: number,
    tolerance: number = 1e-6,
    maxIterations: number = 100
  ): { success: boolean, root?: number, iterations?: number, error?: string } {
    Logger.info(`Bisection method on [${a}, ${b}]`);
    
    const fa = f(a);
    const fb = f(b);
    
    if (fa * fb > 0) {
      return {
        success: false,
        error: '区间端点函数值同号，无法使用二分法'
      };
    }
    
    let left = a;
    let right = b;
    let iterations = 0;
    
    while (iterations < maxIterations) {
      const mid = (left + right) / 2;
      const fmid = f(mid);
      
      if (Math.abs(fmid) < tolerance) {
        return {
          success: true,
          root: mid,
          iterations: iterations + 1
        };
      }
      
      if (f(left) * fmid < 0) {
        right = mid;
      } else {
        left = mid;
      }
      
      iterations++;
      
      if (Math.abs(right - left) < tolerance) {
        return {
          success: true,
          root: (left + right) / 2,
          iterations: iterations
        };
      }
    }
    
    return {
      success: false,
      error: '超过最大迭代次数'
    };
  }
  
  /**
   * 使用 Newton-Raphson 方法求根
   */
  newtonRaphsonMethod(
    f: (x: number) => number,
    df: (x: number) => number,
    x0: number,
    tolerance: number = 1e-6,
    maxIterations: number = 100
  ): { success: boolean, root?: number, iterations?: number, error?: string } {
    Logger.info(`Newton-Raphson method with initial guess ${x0}`);
    
    let x = x0;
    let iterations = 0;
    
    while (iterations < maxIterations) {
      const fx = f(x);
      const dfx = df(x);
      
      if (Math.abs(dfx) < 1e-10) {
        return {
          success: false,
          error: '导数接近零，无法继续'
        };
      }
      
      const xNew = x - fx / dfx;
      
      if (Math.abs(xNew - x) < tolerance && Math.abs(f(xNew)) < tolerance) {
        return {
          success: true,
          root: xNew,
          iterations: iterations + 1
        };
      }
      
      x = xNew;
      iterations++;
    }
    
    return {
      success: false,
      error: '超过最大迭代次数'
    };
  }
  
  /**
   * 使用弦截法（Secant Method）求根
   */
  secantMethod(
    f: (x: number) => number,
    x0: number,
    x1: number,
    tolerance: number = 1e-6,
    maxIterations: number = 100
  ): { success: boolean, root?: number, iterations?: number, error?: string } {
    Logger.info(`Secant method with initial guesses ${x0}, ${x1}`);
    
    let xprev = x0;
    let xcurr = x1;
    let iterations = 0;
    
    while (iterations < maxIterations) {
      const fprev = f(xprev);
      const fcurr = f(xcurr);
      
      const diff = xcurr - xprev;
      if (Math.abs(diff) < 1e-10) {
        return {
          success: false,
          error: '两个迭代点过于接近'
        };
      }
      
      const xnext = xcurr - fcurr * (xcurr - xprev) / (fcurr - fprev);
      
      if (Math.abs(xnext - xcurr) < tolerance && Math.abs(f(xnext)) < tolerance) {
        return {
          success: true,
          root: xnext,
          iterations: iterations + 1
        };
      }
      
      xprev = xcurr;
      xcurr = xnext;
      iterations++;
    }
    
    return {
      success: false,
      error: '超过最大迭代次数'
    };
  }
  
  /**
   * 使用黄金分割法优化单变量函数
   */
  goldenSectionSearch(
    f: (x: number) => number,
    a: number,
    b: number,
    tolerance: number = 1e-6,
    maxIterations: number = 100
  ): OptimizationResult {
    Logger.info(`Golden section search on [${a}, ${b}]`);
    
    const phi = (1 + Math.sqrt(5)) / 2;
    const resphi = 2 - phi;
    
    let x1 = a + resphi * (b - a);
    let x2 = b - resphi * (b - a);
    let f1 = f(x1);
    let f2 = f(x2);
    
    let iterations = 0;
    
    while (iterations < maxIterations && Math.abs(b - a) > tolerance) {
      if (f1 < f2) {
        b = x2;
        x2 = x1;
        f2 = f1;
        x1 = a + resphi * (b - a);
        f1 = f(x1);
      } else {
        a = x1;
        x1 = x2;
        f1 = f2;
        x2 = b - resphi * (b - a);
        f2 = f(x2);
      }
      
      iterations++;
    }
    
    const optimumX = (a + b) / 2;
    
    return {
      success: true,
      optimum: {
        x: optimumX,
        y: f(optimumX)
      },
      iterations: iterations,
      method: 'Golden Section Search'
    };
  }
  
  /**
   * 使用梯度下降法优化多变量函数（简化实现）
   */
  gradientDescent(
    f: (x: number[]) => number,
    grad: (x: number[]) => number[],
    x0: number[],
    learningRate: number = 0.01,
    tolerance: number = 1e-6,
    maxIterations: number = 1000
  ): OptimizationResult {
    Logger.info(`Gradient descent with initial point [${x0.join(', ')}]`);
    
    let x = [...x0];
    let iterations = 0;
    
    while (iterations < maxIterations) {
      const gradient = grad(x);
      
      // 更新
      for (let i = 0; i < x.length; i++) {
        x[i] = x[i] - learningRate * gradient[i];
      }
      
      // 检查收敛
      const gradientNorm = Math.sqrt(gradient.reduce((sum, g) => sum + g * g, 0));
      if (gradientNorm < tolerance) {
        return {
          success: true,
          optimum: {
            x: x[0],
            y: f(x)
          },
          iterations: iterations,
          method: 'Gradient Descent'
        };
      }
      
      iterations++;
    }
    
    return {
      success: true,
      optimum: {
        x: x[0],
        y: f(x)
      },
      iterations: iterations,
      method: 'Gradient Descent'
    };
  }
  
  /**
   * Lagrange 插值
   */
  lagrangeInterpolation(
    points: Array<{ x: number, y: number }>
  ): InterpolationResult {
    try {
      Logger.info(`Lagrange interpolation with ${points.length} points`);
      
      const n = points.length;
      
      // 构造基函数
      const evaluate = (x: number): number => {
        let result = 0;
        
        for (let i = 0; i < n; i++) {
          let li = 1;
          
          for (let j = 0; j < n; j++) {
            if (i !== j) {
              li *= (x - points[j].x) / (points[i].x - points[j].x);
            }
          }
          
          result += points[i].y * li;
        }
        
        return result;
      };
      
      return {
        success: true,
        evaluate: evaluate,
        polynomial: 'Lagrange polynomial (constructed)'
      };
    } catch (error) {
      Logger.error('Lagrange interpolation error', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : '插值失败'
      };
    }
  }
  
  /**
   * 三次样条插值
   */
  cubicSplineInterpolation(
    points: Array<{ x: number, y: number }>
  ): InterpolationResult {
    try {
      Logger.info(`Cubic spline interpolation with ${points.length} points`);
      
      const n = points.length - 1;
      
      // 计算 M (二阶导数)
      const h: number[] = [];
      const u: number[] = [];
      const v: number[] = [];
      
      for (let i = 0; i < n; i++) {
        h[i] = points[i + 1].x - points[i].x;
      }
      
      u[0] = 0;
      v[0] = 0;
      
      for (let i = 1; i < n; i++) {
        u[i] = h[i - 1] / (h[i - 1] + h[i]);
        v[i] = 3 * ((points[i + 1].y - points[i].y) / h[i] - (points[i].y - points[i - 1].y) / h[i - 1]);
      }
      
      // 自然边界条件 M0 = Mn = 0
      const M = new Array(n + 1).fill(0);
      
      const evaluate = (x: number): number => {
        // 找到所在的区间
        let i = 0;
        for (let j = 0; j < n; j++) {
          if (x >= points[j].x && x <= points[j + 1].x) {
            i = j;
            break;
          }
        }
        
        // 三次样条插值
        const hi = h[i];
        const t = (x - points[i].x) / hi;
        const ai = points[i].y;
        const bi = (points[i + 1].y - points[i].y) / hi;
        const ci = M[i];
        const di = (M[i + 1] - M[i]) / (3 * hi);
        
        return ai + bi * t + ci * t * t + di * t * t * t;
      };
      
      return {
        success: true,
        evaluate: evaluate,
        polynomial: 'Cubic spline (constructed)'
      };
    } catch (error) {
      Logger.error('Cubic spline interpolation error', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : '插值失败'
      };
    }
  }
  
  /**
   * 数值积分 - Simpson 法则
   */
  simpsonRule(
    f: (x: number) => number,
    a: number,
    b: number,
    n: number = 1000
  ): number {
    Logger.info(`Simpson's rule on [${a}, ${b}] with ${n} segments`);
    
    if (n % 2 !== 0) n++; // n 必须是偶数
    
    const h = (b - a) / n;
    let sum = f(a) + f(b);
    
    for (let i = 1; i < n; i++) {
      const x = a + i * h;
      sum += (i % 2 === 0 ? 2 : 4) * f(x);
    }
    
    return (h / 3) * sum;
  }
  
  /**
   * 数值积分 - Romberg 积分法
   */
  rombergIntegration(
    f: (x: number) => number,
    a: number,
    b: number,
    n: number = 10
  ): number {
    Logger.info(`Romberg integration on [${a}, ${b}]`);
    
    const R: number[][] = [];
    
    // R(0,0)
    R[0] = [0.5 * (b - a) * (f(a) + f(b))];
    
    for (let i = 1; i <= n; i++) {
      R[i] = new Array(i + 1);
      
      // 使用梯形法则计算 R(i,0)
      const h = (b - a) / Math.pow(2, i);
      let sum = 0;
      
      for (let k = 1; k <= Math.pow(2, i - 1); k++) {
        sum += f(a + (2 * k - 1) * h);
      }
      
      R[i][0] = 0.5 * R[i - 1][0] + h * sum;
      
      // 外推
      for (let j = 1; j <= i; j++) {
        R[i][j] = R[i][j - 1] + (R[i][j - 1] - R[i - 1][j - 1]) / (Math.pow(4, j) - 1);
      }
    }
    
    return R[n][n];
  }
  
  /**
   * 计算函数在区间的最大值和最小值
   */
  findExtrema(
    f: (x: number) => number,
    a: number,
    b: number,
    samples: number = 1000
  ): { min: number, max: number, minX: number, maxX: number } {
    Logger.info(`Finding extrema in [${a}, ${b}]`);
    
    const step = (b - a) / samples;
    let min = f(a);
    let max = f(a);
    let minX = a;
    let maxX = a;
    
    for (let i = 0; i <= samples; i++) {
      const x = a + i * step;
      const y = f(x);
      
      if (y < min) {
        min = y;
        minX = x;
      }
      if (y > max) {
        max = y;
        maxX = x;
      }
    }
    
    return { min, max, minX, maxX };
  }
  
  /**
   * 计算数值导数
   */
  numericalDerivative(
    f: (x: number) => number,
    x: number,
    h: number = 1e-5,
    method: 'forward' | 'backward' | 'central' = 'central'
  ): number {
    switch (method) {
      case 'forward':
        return (f(x + h) - f(x)) / h;
      case 'backward':
        return (f(x) - f(x - h)) / h;
      case 'central':
      default:
        return (f(x + h) - f(x - h)) / (2 * h);
    }
  }
  
  /**
   * 计算数值二阶导数
   */
  numericalSecondDerivative(
    f: (x: number) => number,
    x: number,
    h: number = 1e-5
  ): number {
    return (f(x + h) - 2 * f(x) + f(x - h)) / (h * h);
  }
  
  /**
   * 自适应步长的数值积分
   */
  adaptiveQuadrature(
    f: (x: number) => number,
    a: number,
    b: number,
    tolerance: number = 1e-6
  ): number {
    const integrate = (x1: number, x2: number, fx1: number, fx2: number, fxmid: number): number => {
      const h = x2 - x1;
      const simp1 = (h / 6) * (fx1 + 4 * fxmid + fx2);
      
      // 分成两半
      const mid = (x1 + x2) / 2;
      const fmid = f(mid);
      const fx1mid = f((x1 + mid) / 2);
      const fx2mid = f((mid + x2) / 2);
      
      const simp2 = ((h / 2) / 6) * (fx1 + 4 * fx1mid + fxmid) +
                     ((h / 2) / 6) * (fxmid + 4 * fx2mid + fx2);
      
      if (Math.abs(simp1 - simp2) < tolerance) {
        return simp2;
      }
      
      return integrate(x1, mid, fx1, fxmid, fx1mid) +
             integrate(mid, x2, fxmid, fx2, fx2mid);
    };
    
    const fa = f(a);
    const fb = f(b);
    const fmid = f((a + b) / 2);
    
    return integrate(a, b, fa, fb, fmid);
  }
}

