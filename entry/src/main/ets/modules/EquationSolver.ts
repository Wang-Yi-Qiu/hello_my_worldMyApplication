/**
 * 方程求解器
 * 支持线性方程、二次方程、方程组等
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

/**
 * 方程求解器类
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
}

