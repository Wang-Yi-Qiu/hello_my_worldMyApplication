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
      steps.push(`∫[${from}, ${to}] ${expression} d${variable}`);
      
      // 简化实现：使用数值积分
      // 实际应该支持符号积分
      
      // 创建函数
      const f = (x: number): number => {
        try {
          // 简单的表达式求值
          // 实际应该使用 math.js 的 evaluate
          return eval(expression.replace(new RegExp(variable, 'g'), x.toString()));
        } catch {
          throw new Error('表达式求值失败');
        }
      };
      
      const value = this.numericalIntegral(f, from, to);
      
      steps.push(`使用辛普森法则进行数值积分`);
      steps.push(`积分值 ≈ ${value}`);
      
      return {
        success: true,
        value,
        steps
      };
    } catch (error) {
      Logger.error('Integral calculation error', error);
      return {
        success: false,
        error: ERROR_MESSAGES.CALCULATION_ERROR
      };
    }
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
   * 极限计算（数值方法）
   */
  limit(expression: string, variable: string, approachValue: number, 
        fromLeft: boolean = false, fromRight: boolean = false): LimitResult {
    try {
      Logger.info(`Computing limit of ${expression} as ${variable} -> ${approachValue}`);
      
      // 简化实现：使用数值逼近
      const f = (x: number): number => {
        return eval(expression.replace(new RegExp(variable, 'g'), x.toString()));
      };
      
      let result: number;
      
      if (fromLeft) {
        // 左极限
        result = f(approachValue - 1e-10);
      } else if (fromRight) {
        // 右极限
        result = f(approachValue + 1e-10);
      } else {
        // 双边极限
        const leftLimit = f(approachValue - 1e-10);
        const rightLimit = f(approachValue + 1e-10);
        
        if (Math.abs(leftLimit - rightLimit) < 1e-8) {
          result = (leftLimit + rightLimit) / 2;
        } else {
          return {
            success: false,
            error: '左右极限不相等，极限不存在'
          };
        }
      }
      
      return {
        success: true,
        limit: result.toString()
      };
    } catch (error) {
      Logger.error('Limit calculation error', error);
      return {
        success: false,
        error: ERROR_MESSAGES.CALCULATION_ERROR
      };
    }
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

