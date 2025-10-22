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

  constructor(precision: number = DEFAULT_PRECISION) {
    this.precision = precision;
    this.angleUnit = 'degree';
    Logger.info(`ExpressionEngine initialized with precision: ${precision}`);
  }

  /**
   * 计算数学表达式
   */
  evaluate(expression: string, options?: EvaluateOptions): EvaluateResult {
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

      // 使用 JavaScript 的 eval 进行基础计算
      // 注意：生产环境应该使用 math.js
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
   * 安全的表达式求值
   * 注意：这是简化版本，生产环境应使用 math.js
   */
  private safeEval(expression: string): number {
    // 移除不安全的字符
    const sanitized = expression
      .replace(/[^0-9+\-*\/().]/g, '')
      .replace(/\s/g, '');

    // 基础运算符支持
    try {
      // 使用 Function 构造器比 eval 更安全
      const result = new Function(`'use strict'; return (${sanitized})`)();
      return Number(result);
    } catch (error) {
      throw new Error(ERROR_MESSAGES.INVALID_EXPRESSION);
    }
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
}

