/**
 * 方程求解器
 * 支持线性方程、二次方程、方程组等
 * 增强版：支持图形分析功能
 */
import { Logger } from '../utils/Logger';
import { ERROR_MESSAGES } from '../utils/Constants';

export interface SolveResult {
  success: boolean;
  solutions?: string[];
  error?: string;
  steps?: string[];
}

export interface LinearSystemResult {
  success: boolean;
  solution?: Map<string, number>;
  error?: string;
}

export interface CriticalPoint {
  x: number;
  y: number;
  type: 'maximum' | 'minimum' | 'inflection';
}

export interface IntersectionPoint {
  x: number;
  y: number;
}

/**
 * 方程求解器类
 * 增强版：添加图形分析功能
 */
export class EquationSolver {
  
  /**
   * 求解一元一次方程 ax + b = 0
   */
  solveLinear(a: number, b: number): SolveResult {
    try {
      Logger.info(`Solving linear equation: ${a}x + ${b} = 0`);
      
      if (a === 0) {
        if (b === 0) {
          return {
            success: true,
            solutions: ['任意实数'],
            steps: [
              '0x + 0 = 0',
              '该方程恒成立',
              '解：x ∈ R'
            ]
          };
        } else {
          return {
            success: false,
            error: '方程无解',
            steps: [
              `0x + ${b} = 0`,
              `${b} = 0 (矛盾)`,
              '该方程无解'
            ]
          };
        }
      }
      
      const x = -b / a;
      
      return {
        success: true,
        solutions: [x.toString()],
        steps: [
          `${a}x + ${b} = 0`,
          `${a}x = ${-b}`,
          `x = ${x}`
        ]
      };
    } catch (error) {
      Logger.error('Linear equation solving error', error);
      return {
        success: false,
        error: ERROR_MESSAGES.CALCULATION_ERROR
      };
    }
  }
  
  /**
   * 求解一元二次方程 ax² + bx + c = 0
   */
  solveQuadratic(a: number, b: number, c: number): SolveResult {
    try {
      Logger.info(`Solving quadratic equation: ${a}x² + ${b}x + ${c} = 0`);
      
      if (a === 0) {
        // 退化为一次方程
        return this.solveLinear(b, c);
      }
      
      // 计算判别式 Δ = b² - 4ac
      const delta = b * b - 4 * a * c;
      
      const steps: string[] = [
        `${a}x² + ${b}x + ${c} = 0`,
        `判别式 Δ = b² - 4ac = ${b}² - 4×${a}×${c} = ${delta}`
      ];
      
      if (delta > 0) {
        // 两个不同实根
        const sqrtDelta = Math.sqrt(delta);
        const x1 = (-b + sqrtDelta) / (2 * a);
        const x2 = (-b - sqrtDelta) / (2 * a);
        
        steps.push('Δ > 0，方程有两个不同的实根');
        steps.push(`x₁ = (-b + √Δ) / 2a = ${x1}`);
        steps.push(`x₂ = (-b - √Δ) / 2a = ${x2}`);
        
        return {
          success: true,
          solutions: [x1.toString(), x2.toString()],
          steps
        };
      } else if (delta === 0) {
        // 两个相同实根
        const x = -b / (2 * a);
        
        steps.push('Δ = 0，方程有两个相同的实根');
        steps.push(`x = -b / 2a = ${x}`);
        
        return {
          success: true,
          solutions: [x.toString()],
          steps
        };
      } else {
        // 两个共轭复根
        const realPart = -b / (2 * a);
        const imagPart = Math.sqrt(-delta) / (2 * a);
        
        steps.push('Δ < 0，方程有两个共轭复根');
        steps.push(`x₁ = ${realPart} + ${imagPart}i`);
        steps.push(`x₂ = ${realPart} - ${imagPart}i`);
        
        return {
          success: true,
          solutions: [
            `${realPart} + ${imagPart}i`,
            `${realPart} - ${imagPart}i`
          ],
          steps
        };
      }
    } catch (error) {
      Logger.error('Quadratic equation solving error', error);
      return {
        success: false,
        error: ERROR_MESSAGES.CALCULATION_ERROR
      };
    }
  }
  
  /**
   * 求解一元三次方程（盛金公式）
   * ax³ + bx² + cx + d = 0
   */
  solveCubic(a: number, b: number, c: number, d: number): SolveResult {
    try {
      Logger.info(`Solving cubic equation: ${a}x³ + ${b}x² + ${c}x + ${d} = 0`);
      
      if (a === 0) {
        // 退化为二次方程
        return this.solveQuadratic(b, c, d);
      }
      
      // 转换为标准形式 x³ + px + q = 0
      const p = (3 * a * c - b * b) / (3 * a * a);
      const q = (2 * b * b * b - 9 * a * b * c + 27 * a * a * d) / (27 * a * a * a);
      
      // 判别式
      const delta = (q / 2) * (q / 2) + (p / 3) * (p / 3) * (p / 3);
      
      const steps: string[] = [
        `${a}x³ + ${b}x² + ${c}x + ${d} = 0`,
        '转换为标准形式',
        `判别式计算中...`
      ];
      
      if (delta > 0) {
        // 一个实根，两个共轭复根
        const u = Math.cbrt(-q / 2 + Math.sqrt(delta));
        const v = Math.cbrt(-q / 2 - Math.sqrt(delta));
        const x = u + v - b / (3 * a);
        
        steps.push('方程有一个实根和两个共轭复根');
        steps.push(`实根 x = ${x}`);
        
        return {
          success: true,
          solutions: [x.toString()],
          steps
        };
      } else if (delta === 0) {
        // 三个实根（至少两个相等）
        const x1 = 3 * q / p - b / (3 * a);
        const x2 = -3 * q / (2 * p) - b / (3 * a);
        
        steps.push('方程有三个实根（至少两个相等）');
        
        return {
          success: true,
          solutions: [x1.toString(), x2.toString()],
          steps
        };
      } else {
        // 三个不同实根（使用三角函数方法）
        const m = 2 * Math.sqrt(-p / 3);
        const theta = Math.acos(3 * q / (p * m)) / 3;
        const x1 = m * Math.cos(theta) - b / (3 * a);
        const x2 = m * Math.cos(theta + 2 * Math.PI / 3) - b / (3 * a);
        const x3 = m * Math.cos(theta + 4 * Math.PI / 3) - b / (3 * a);
        
        steps.push('方程有三个不同的实根');
        
        return {
          success: true,
          solutions: [x1.toString(), x2.toString(), x3.toString()],
          steps
        };
      }
    } catch (error) {
      Logger.error('Cubic equation solving error', error);
      return {
        success: false,
        error: ERROR_MESSAGES.CALCULATION_ERROR
      };
    }
  }
  
  /**
   * 求解二元一次方程组（克拉默法则）
   * a1*x + b1*y = c1
   * a2*x + b2*y = c2
   */
  solveLinearSystem2x2(a1: number, b1: number, c1: number,
                       a2: number, b2: number, c2: number): LinearSystemResult {
    try {
      Logger.info('Solving 2x2 linear system');
      
      // 计算主行列式 D
      const D = a1 * b2 - a2 * b1;
      
      if (D === 0) {
        // 方程组无唯一解
        if ((c1 * b2 - c2 * b1 === 0) && (a1 * c2 - a2 * c1 === 0)) {
          return {
            success: false,
            error: '方程组有无穷多解'
          };
        } else {
          return {
            success: false,
            error: '方程组无解'
          };
        }
      }
      
      // 计算 Dx 和 Dy
      const Dx = c1 * b2 - c2 * b1;
      const Dy = a1 * c2 - a2 * c1;
      
      // 计算解
      const x = Dx / D;
      const y = Dy / D;
      
      const solution = new Map<string, number>();
      solution.set('x', x);
      solution.set('y', y);
      
      return {
        success: true,
        solution
      };
    } catch (error) {
      Logger.error('Linear system solving error', error);
      return {
        success: false,
        error: ERROR_MESSAGES.CALCULATION_ERROR
      };
    }
  }
  
  /**
   * 求解三元一次方程组（高斯消元法）
   * a1*x + b1*y + c1*z = d1
   * a2*x + b2*y + c2*z = d2
   * a3*x + b3*y + c3*z = d3
   */
  solveLinearSystem3x3(coefficients: number[][]): LinearSystemResult {
    try {
      Logger.info('Solving 3x3 linear system using Gaussian elimination');
      
      // 复制矩阵，避免修改原数组
      const matrix = coefficients.map(row => [...row]);
      const n = 3;
      
      // 高斯消元（前向消元）
      for (let i = 0; i < n; i++) {
        // 找主元
        let maxRow = i;
        for (let k = i + 1; k < n; k++) {
          if (Math.abs(matrix[k][i]) > Math.abs(matrix[maxRow][i])) {
            maxRow = k;
          }
        }
        
        // 交换行
        [matrix[i], matrix[maxRow]] = [matrix[maxRow], matrix[i]];
        
        // 检查主元是否为零
        if (Math.abs(matrix[i][i]) < 1e-10) {
          return {
            success: false,
            error: '方程组无唯一解'
          };
        }
        
        // 消元
        for (let k = i + 1; k < n; k++) {
          const factor = matrix[k][i] / matrix[i][i];
          for (let j = i; j < n + 1; j++) {
            matrix[k][j] -= factor * matrix[i][j];
          }
        }
      }
      
      // 回代求解
      const solution = new Array(n).fill(0);
      for (let i = n - 1; i >= 0; i--) {
        solution[i] = matrix[i][n];
        for (let j = i + 1; j < n; j++) {
          solution[i] -= matrix[i][j] * solution[j];
        }
        solution[i] /= matrix[i][i];
      }
      
      const resultMap = new Map<string, number>();
      resultMap.set('x', solution[0]);
      resultMap.set('y', solution[1]);
      resultMap.set('z', solution[2]);
      
      return {
        success: true,
        solution: resultMap
      };
    } catch (error) {
      Logger.error('3x3 linear system solving error', error);
      return {
        success: false,
        error: ERROR_MESSAGES.CALCULATION_ERROR
      };
    }
  }
  
  /**
   * 使用牛顿法求函数零点
   * @param f 函数
   * @param df 导数函数
   * @param x0 初始猜测值
   * @param tolerance 容差
   * @param maxIterations 最大迭代次数
   */
  findZeroNewton(
    f: (x: number) => number,
    df: (x: number) => number,
    x0: number,
    tolerance: number = 1e-6,
    maxIterations: number = 100
  ): { success: boolean; root?: number; iterations?: number; error?: string } {
    try {
      Logger.info(`Finding zero using Newton's method, x0=${x0}`);
      
      let x = x0;
      let iteration = 0;
      
      while (iteration < maxIterations) {
        const fx = f(x);
        const dfx = df(x);
        
        // 检查导数是否为零
        if (Math.abs(dfx) < 1e-10) {
          return {
            success: false,
            error: '导数接近零，无法继续迭代'
          };
        }
        
        // 牛顿迭代公式
        const xNew = x - fx / dfx;
        
        // 检查收敛
        if (Math.abs(xNew - x) < tolerance && Math.abs(f(xNew)) < tolerance) {
          return {
            success: true,
            root: xNew,
            iterations: iteration + 1
          };
        }
        
        x = xNew;
        iteration++;
      }
      
      return {
        success: false,
        error: '超过最大迭代次数'
      };
    } catch (error) {
      Logger.error('Newton method error', error);
      return {
        success: false,
        error: ERROR_MESSAGES.CALCULATION_ERROR
      };
    }
  }
  
  /**
   * 使用二分法求函数零点
   * @param f 函数
   * @param a 区间左端点
   * @param b 区间右端点
   * @param tolerance 容差
   */
  findZeroBisection(
    f: (x: number) => number,
    a: number,
    b: number,
    tolerance: number = 1e-6
  ): { success: boolean; root?: number; iterations?: number; error?: string } {
    try {
      Logger.info(`Finding zero using bisection method in [${a}, ${b}]`);
      
      let fa = f(a);
      let fb = f(b);
      
      // 检查端点是否为根
      if (Math.abs(fa) < tolerance) {
        return { success: true, root: a, iterations: 0 };
      }
      if (Math.abs(fb) < tolerance) {
        return { success: true, root: b, iterations: 0 };
      }
      
      // 检查是否满足二分法条件
      if (fa * fb > 0) {
        return {
          success: false,
          error: '区间端点函数值同号，不满足二分法条件'
        };
      }
      
      let iteration = 0;
      const maxIterations = 100;
      
      while (iteration < maxIterations && Math.abs(b - a) > tolerance) {
        const c = (a + b) / 2;
        const fc = f(c);
        
        if (Math.abs(fc) < tolerance) {
          return {
            success: true,
            root: c,
            iterations: iteration + 1
          };
        }
        
        if (fa * fc < 0) {
          b = c;
          fb = fc;
        } else {
          a = c;
          fa = fc;
        }
        
        iteration++;
      }
      
      return {
        success: true,
        root: (a + b) / 2,
        iterations: iteration
      };
    } catch (error) {
      Logger.error('Bisection method error', error);
      return {
        success: false,
        error: ERROR_MESSAGES.CALCULATION_ERROR
      };
    }
  }
  
  /**
   * 查找函数在区间内的所有零点（近似）
   * @param f 函数
   * @param xMin 区间左端点
   * @param xMax 区间右端点
   * @param samples 采样点数
   */
  findAllZeros(
    f: (x: number) => number,
    xMin: number,
    xMax: number,
    samples: number = 100
  ): number[] {
    try {
      Logger.info(`Finding all zeros in [${xMin}, ${xMax}]`);
      
      const zeros: number[] = [];
      const step = (xMax - xMin) / samples;
      
      for (let i = 0; i < samples; i++) {
        const x1 = xMin + i * step;
        const x2 = xMin + (i + 1) * step;
        const f1 = f(x1);
        const f2 = f(x2);
        
        // 检查符号变化
        if (f1 * f2 < 0) {
          // 使用二分法精确求解
          const result = this.findZeroBisection(f, x1, x2);
          if (result.success && result.root !== undefined) {
            // 检查是否与已有零点重复
            const isDuplicate = zeros.some(z => Math.abs(z - result.root!) < 1e-4);
            if (!isDuplicate) {
              zeros.push(result.root);
            }
          }
        } else if (Math.abs(f1) < 1e-6) {
          // 检查端点
          const isDuplicate = zeros.some(z => Math.abs(z - x1) < 1e-4);
          if (!isDuplicate) {
            zeros.push(x1);
          }
        }
      }
      
      Logger.info(`Found ${zeros.length} zeros`);
      return zeros.sort((a, b) => a - b);
    } catch (error) {
      Logger.error('Find all zeros error', error);
      return [];
    }
  }
  
  /**
   * 查找函数的极值点（使用数值方法）
   * @param f 函数
   * @param xMin 区间左端点
   * @param xMax 区间右端点
   * @param samples 采样点数
   */
  findCriticalPoints(
    f: (x: number) => number,
    xMin: number,
    xMax: number,
    samples: number = 100
  ): CriticalPoint[] {
    try {
      Logger.info(`Finding critical points in [${xMin}, ${xMax}]`);
      
      const criticalPoints: CriticalPoint[] = [];
      const step = (xMax - xMin) / samples;
      const h = step / 10; // 用于数值导数的步长
      
      for (let i = 1; i < samples; i++) {
        const x = xMin + i * step;
        const y = f(x);
        
        // 计算数值导数（中心差分）
        const df = (f(x + h) - f(x - h)) / (2 * h);
        
        // 计算二阶导数
        const d2f = (f(x + h) - 2 * f(x) + f(x - h)) / (h * h);
        
        // 检查是否为极值点（导数接近零）
        if (Math.abs(df) < 0.1) {
          let type: 'maximum' | 'minimum' | 'inflection';
          
          if (d2f > 0) {
            type = 'minimum';
          } else if (d2f < 0) {
            type = 'maximum';
          } else {
            type = 'inflection';
          }
          
          // 检查是否与已有点重复
          const isDuplicate = criticalPoints.some(
            p => Math.abs(p.x - x) < step
          );
          
          if (!isDuplicate && isFinite(y)) {
            criticalPoints.push({ x, y, type });
          }
        }
      }
      
      Logger.info(`Found ${criticalPoints.length} critical points`);
      return criticalPoints;
    } catch (error) {
      Logger.error('Find critical points error', error);
      return [];
    }
  }
  
  /**
   * 查找两个函数的交点
   * @param f1 函数1
   * @param f2 函数2
   * @param xMin 区间左端点
   * @param xMax 区间右端点
   * @param samples 采样点数
   */
  findIntersections(
    f1: (x: number) => number,
    f2: (x: number) => number,
    xMin: number,
    xMax: number,
    samples: number = 100
  ): IntersectionPoint[] {
    try {
      Logger.info(`Finding intersections in [${xMin}, ${xMax}]`);
      
      // 定义差函数
      const diff = (x: number) => f1(x) - f2(x);
      
      // 查找差函数的零点
      const zeros = this.findAllZeros(diff, xMin, xMax, samples);
      
      // 转换为交点
      const intersections: IntersectionPoint[] = zeros.map(x => ({
        x,
        y: f1(x)
      }));
      
      Logger.info(`Found ${intersections.length} intersections`);
      return intersections;
    } catch (error) {
      Logger.error('Find intersections error', error);
      return [];
    }
  }
}

