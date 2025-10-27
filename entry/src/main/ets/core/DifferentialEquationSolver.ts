/**
 * 微分方程求解器
 * 参考 SymPy 和 SageMath 的微分方程求解功能
 * 支持常微分方程（ODE）的数值求解
 */
import { Logger } from '../utils/Logger';

/**
 * 微分方程类型
 */
export enum ODE_TYPE {
  FIRST_ORDER_LINEAR = 'first_order_linear',
  FIRST_ORDER_SEPARABLE = 'first_order_separable',
  FIRST_ORDER_EXACT = 'first_order_exact',
  SECOND_ORDER_CONSTANT_COEFF = 'second_order_constant_coeff',
  SECOND_ORDER_HOMOGENEOUS = 'second_order_homogeneous'
}

/**
 * 求解结果
 */
export interface ODESolution {
  success: boolean;
  solution?: string;
  steps?: string[];
  error?: string;
  method?: string;
}

/**
 * 初始条件
 */
export interface InitialCondition {
  x0: number;
  y0: number;
  dy0?: number; // 二阶方程的初始条件
}

/**
 * 微分方程求解器
 */
export class DifferentialEquationSolver {
  
  /**
   * 使用 Euler 方法求解 ODE
   * 求解 dy/dx = f(x, y), y(x0) = y0
   */
  eulerMethod(
    f: (x: number, y: number) => number,
    x0: number,
    y0: number,
    h: number,
    n: number
  ): Array<{ x: number, y: number }> {
    Logger.info(`Euler method: initial condition (${x0}, ${y0}), step=${h}, steps=${n}`);
    
    const points: Array<{ x: number, y: number }> = [{ x: x0, y: y0 }];
    let x = x0;
    let y = y0;
    
    for (let i = 0; i < n; i++) {
      y = y + h * f(x, y);
      x = x + h;
      points.push({ x, y });
    }
    
    return points;
  }
  
  /**
   * 使用改进的 Euler 方法（Heun 方法）
   */
  heunMethod(
    f: (x: number, y: number) => number,
    x0: number,
    y0: number,
    h: number,
    n: number
  ): Array<{ x: number, y: number }> {
    Logger.info(`Heun method: initial condition (${x0}, ${y0}), step=${h}, steps=${n}`);
    
    const points: Array<{ x: number, y: number }> = [{ x: x0, y: y0 }];
    let x = x0;
    let y = y0;
    
    for (let i = 0; i < n; i++) {
      const k1 = f(x, y);
      const k2 = f(x + h, y + h * k1);
      y = y + (h / 2) * (k1 + k2);
      x = x + h;
      points.push({ x, y });
    }
    
    return points;
  }
  
  /**
   * 使用经典 4阶 Runge-Kutta 方法
   */
  rungeKutta4(
    f: (x: number, y: number) => number,
    x0: number,
    y0: number,
    h: number,
    n: number
  ): Array<{ x: number, y: number }> {
    Logger.info(`RK4 method: initial condition (${x0}, ${y0}), step=${h}, steps=${n}`);
    
    const points: Array<{ x: number, y: number }> = [{ x: x0, y: y0 }];
    let x = x0;
    let y = y0;
    
    for (let i = 0; i < n; i++) {
      const k1 = h * f(x, y);
      const k2 = h * f(x + h / 2, y + k1 / 2);
      const k3 = h * f(x + h / 2, y + k2 / 2);
      const k4 = h * f(x + h, y + k3);
      
      y = y + (k1 + 2 * k2 + 2 * k3 + k4) / 6;
      x = x + h;
      
      points.push({ x, y });
    }
    
    return points;
  }
  
  /**
   * 求解一阶线性微分方程
   * dy/dx + P(x)y = Q(x)
   */
  solveFirstOrderLinear(
    P: (x: number) => number,
    Q: (x: number) => number,
    x0: number,
    y0: number,
    xEnd: number,
    steps: number = 100
  ): ODESolution {
    try {
      Logger.info(`Solving first-order linear ODE`);
      
      const h = (xEnd - x0) / steps;
      
      // 使用 RK4 方法
      const f = (x: number, y: number) => Q(x) - P(x) * y;
      const solution = this.rungeKutta4(f, x0, y0, h, steps);
      
      return {
        success: true,
        solution: `Solved using RK4 method`,
        method: 'Runge-Kutta 4th order',
        steps: [
          '方程形式: dy/dx + P(x)y = Q(x)',
          '使用 RK4 方法进行数值求解',
          `起始点: (${x0}, ${y0})`,
          `最终点: (${solution[solution.length - 1].x.toFixed(4)}, ${solution[solution.length - 1].y.toFixed(4)})`
        ]
      };
    } catch (error) {
      Logger.error('First-order linear ODE solving error', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : '求解失败'
      };
    }
  }
  
  /**
   * 求解二阶常系数线性齐次方程
   * y'' + ay' + by = 0
   */
  solveSecondOrderConstantCoeff(
    a: number,
    b: number,
    initialCondition: InitialCondition
  ): ODESolution {
    try {
      Logger.info(`Solving second-order constant coefficient ODE: y'' + ${a}y' + ${b}y = 0`);
      
      const steps: string[] = [
        `特征方程: r² + ${a}r + ${b} = 0`
      ];
      
      // 求解特征方程
      const discriminant = a * a - 4 * b;
      steps.push(`判别式 Δ = ${discriminant}`);
      
      let generalSolution: string;
      
      if (discriminant > 0) {
        // 两个不同实根
        const r1 = (-a + Math.sqrt(discriminant)) / 2;
        const r2 = (-a - Math.sqrt(discriminant)) / 2;
        generalSolution = `y = C₁e^(${r1.toFixed(4)}x) + C₂e^(${r2.toFixed(4)}x)`;
        steps.push(`两个不同实根: r₁ = ${r1.toFixed(4)}, r₂ = ${r2.toFixed(4)}`);
      } else if (discriminant === 0) {
        // 重根
        const r = -a / 2;
        generalSolution = `y = e^(${r.toFixed(4)}x)(C₁ + C₂x)`;
        steps.push(`重根: r = ${r.toFixed(4)}`);
      } else {
        // 两个共轭复根
        const realPart = -a / 2;
        const imagPart = Math.sqrt(-discriminant) / 2;
        generalSolution = `y = e^(${realPart.toFixed(4)}x)(C₁cos(${imagPart.toFixed(4)}x) + C₂sin(${imagPart.toFixed(4)}x))`;
        steps.push(`两个共轭复根: ${realPart.toFixed(4)} ± ${imagPart.toFixed(4)}i`);
      }
      
      steps.push(`通解: ${generalSolution}`);
      
      return {
        success: true,
        solution: generalSolution,
        method: '特征方程法',
        steps: steps
      };
    } catch (error) {
      Logger.error('Second-order ODE solving error', error);
      return {
        success: false,
        error: error instanceof Error ? error.message : '求解失败'
      };
    }
  }
  
  /**
   * 使用数值方法求解二阶常微分方程
   */
  solveSecondOrderNumerical(
    f: (x: number, y: number, dy: number) => number,
    initialCondition: InitialCondition,
    xEnd: number,
    h: number = 0.1
  ): Array<{ x: number, y: number, dy: number }> {
    const { x0, y0, dy0 } = initialCondition;
    Logger.info(`Solving second-order ODE numerically`);
    
    if (dy0 === undefined) {
      throw new Error('二阶方程需要初始导数条件 dy0');
    }
    
    const points: Array<{ x: number, y: number, dy: number }> = [
      { x: x0, y: y0, dy: dy0 }
    ];
    
    let x = x0;
    let y = y0;
    let dy = dy0;
    
    const n = Math.floor((xEnd - x0) / h);
    
    for (let i = 0; i < n; i++) {
      const k1_dy = h * f(x, y, dy);
      const k1_d2y = h * ((dy + k1_dy / 2) - dy) / h;
      
      const k2_dy = h * f(x + h / 2, y + dy * h / 2, dy + k1_d2y / 2);
      const k2_d2y = h * ((dy + k2_dy / 2) - dy) / h;
      
      const k3_dy = h * f(x + h / 2, y + dy * h / 2 + k1_dy * h / 4, dy + k2_d2y / 2);
      const k3_d2y = h * ((dy + k3_dy / 2) - dy) / h;
      
      const k4_dy = h * f(x + h, y + dy * h + k2_dy * h / 2, dy + k3_d2y);
      const k4_d2y = h * ((dy + k4_dy / 2) - dy) / h;
      
      const d2y = (k1_d2y + 2 * k2_d2y + 2 * k3_d2y + k4_d2y) / 6;
      dy = dy + d2y;
      y = y + dy * h;
      x = x + h;
      
      points.push({ x, y, dy });
    }
    
    return points;
  }
  
  /**
   * 求解偏微分方程（热传导方程）- 简化实现
   * ∂u/∂t = α∂²u/∂x²
   */
  solveHeatEquation(
    alpha: number,
    xMin: number,
    xMax: number,
    tMax: number,
    initialCondition: (x: number) => number,
    boundaryCondition: { left: (t: number) => number, right: (t: number) => number },
    nx: number = 50,
    nt: number = 100
  ): Array<Array<number>> {
    Logger.info(`Solving heat equation with α = ${alpha}`);
    
    const dx = (xMax - xMin) / nx;
    const dt = tMax / nt;
    
    // 稳定性条件: dt < dx²/(2α)
    if (dt >= dx * dx / (2 * alpha)) {
      Logger.warn('Time step may cause instability');
    }
    
    const u: Array<Array<number>> = [];
    
    // 初始条件
    const u0: number[] = [];
    for (let i = 0; i <= nx; i++) {
      u0.push(initialCondition(xMin + i * dx));
    }
    u.push(u0);
    
    // 时间步进
    for (let n = 1; n < nt; n++) {
      const unew: number[] = [...u[n - 1]];
      
      // 边界条件
      unew[0] = boundaryCondition.left(n * dt);
      unew[nx] = boundaryCondition.right(n * dt);
      
      // 内部点
      for (let i = 1; i < nx; i++) {
        unew[i] = u[n - 1][i] + alpha * dt / (dx * dx) * (
          u[n - 1][i + 1] - 2 * u[n - 1][i] + u[n - 1][i - 1]
        );
      }
      
      u.push(unew);
    }
    
    return u;
  }
  
  /**
   * 求解波动方程（一维）- 简化实现
   * ∂²u/∂t² = c²∂²u/∂x²
   */
  solveWaveEquation(
    c: number,
    xMin: number,
    xMax: number,
    tMax: number,
    initialCondition: { u0: (x: number) => number, v0: (x: number) => number },
    boundaryCondition: { left: (t: number) => number, right: (t: number) => number },
    nx: number = 50,
    nt: number = 100
  ): Array<Array<number>> {
    Logger.info(`Solving wave equation with c = ${c}`);
    
    const dx = (xMax - xMin) / nx;
    const dt = tMax / nt;
    
    const r = c * dt / dx;
    
    // 稳定性条件
    if (r >= 1) {
      Logger.warn('CFL condition may not be satisfied');
    }
    
    const u: Array<Array<number>> = [];
    
    // 初始条件
    const u0: number[] = [];
    for (let i = 0; i <= nx; i++) {
      u0.push(initialCondition.u0(xMin + i * dx));
    }
    u.push(u0);
    
    // 第一个时间步
    const u1: number[] = [...u0];
    for (let i = 1; i < nx; i++) {
      u1[i] = u0[i] + dt * initialCondition.v0(xMin + i * dx);
    }
    u.push(u1);
    
    // 时间步进
    for (let n = 1; n < nt - 1; n++) {
      const unew: number[] = [...u[n]];
      
      // 边界条件
      unew[0] = boundaryCondition.left((n + 1) * dt);
      unew[nx] = boundaryCondition.right((n + 1) * dt);
      
      // 内部点
      for (let i = 1; i < nx; i++) {
        unew[i] = r * r * (u[n][i + 1] + u[n][i - 1]) +
                  2 * (1 - r * r) * u[n][i] - u[n - 1][i];
      }
      
      u.push(unew);
    }
    
    return u;
  }
}

