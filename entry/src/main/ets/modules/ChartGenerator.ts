/**
 * 图表生成器
 * 用于生成函数图像数据
 */
import { Logger } from '../utils/Logger';

export interface Point {
  x: number;
  y: number;
}

export interface ChartData {
  points: Point[];
  xRange: [number, number];
  yRange: [number, number];
}

export interface PlotOptions {
  xMin?: number;
  xMax?: number;
  yMin?: number;
  yMax?: number;
  samples?: number;
  color?: string;
}

/**
 * 图表生成器类
 */
export class ChartGenerator {
  private defaultSamples: number = 500;
  
  /**
   * 生成函数曲线数据
   */
  generateFunctionData(f: (x: number) => number, options: PlotOptions = {}): ChartData {
    try {
      const xMin = options.xMin ?? -10;
      const xMax = options.xMax ?? 10;
      const samples = options.samples ?? this.defaultSamples;
      
      Logger.info(`Generating function data with ${samples} samples from ${xMin} to ${xMax}`);
      
      const points: Point[] = [];
      const step = (xMax - xMin) / samples;
      
      let yMin = Infinity;
      let yMax = -Infinity;
      
      for (let i = 0; i <= samples; i++) {
        const x = xMin + i * step;
        try {
          const y = f(x);
          
          // 过滤无效值
          if (isFinite(y)) {
            points.push({ x, y });
            yMin = Math.min(yMin, y);
            yMax = Math.max(yMax, y);
          }
        } catch (error) {
          // 跳过无效点
          continue;
        }
      }
      
      // 如果指定了 Y 范围，使用指定值
      if (options.yMin !== undefined) yMin = options.yMin;
      if (options.yMax !== undefined) yMax = options.yMax;
      
      return {
        points,
        xRange: [xMin, xMax],
        yRange: [yMin, yMax]
      };
    } catch (error) {
      Logger.error('Function data generation error', error);
      throw error;
    }
  }
  
  /**
   * 生成多个函数的数据
   */
  generateMultipleFunctions(functions: Array<(x: number) => number>, 
                           options: PlotOptions = {}): ChartData[] {
    return functions.map(f => this.generateFunctionData(f, options));
  }
  
  /**
   * 生成参数方程数据
   * x = fx(t), y = fy(t)
   */
  generateParametricData(fx: (t: number) => number, 
                         fy: (t: number) => number,
                         tMin: number = 0,
                         tMax: number = 2 * Math.PI,
                         samples: number = 500): ChartData {
    try {
      Logger.info(`Generating parametric data from t=${tMin} to t=${tMax}`);
      
      const points: Point[] = [];
      const step = (tMax - tMin) / samples;
      
      let xMin = Infinity;
      let xMax = -Infinity;
      let yMin = Infinity;
      let yMax = -Infinity;
      
      for (let i = 0; i <= samples; i++) {
        const t = tMin + i * step;
        try {
          const x = fx(t);
          const y = fy(t);
          
          if (isFinite(x) && isFinite(y)) {
            points.push({ x, y });
            xMin = Math.min(xMin, x);
            xMax = Math.max(xMax, x);
            yMin = Math.min(yMin, y);
            yMax = Math.max(yMax, y);
          }
        } catch (error) {
          continue;
        }
      }
      
      return {
        points,
        xRange: [xMin, xMax],
        yRange: [yMin, yMax]
      };
    } catch (error) {
      Logger.error('Parametric data generation error', error);
      throw error;
    }
  }
  
  /**
   * 生成极坐标函数数据
   * r = f(θ)
   */
  generatePolarData(f: (theta: number) => number,
                   thetaMin: number = 0,
                   thetaMax: number = 2 * Math.PI,
                   samples: number = 500): ChartData {
    try {
      Logger.info('Generating polar function data');
      
      const points: Point[] = [];
      const step = (thetaMax - thetaMin) / samples;
      
      let xMin = Infinity;
      let xMax = -Infinity;
      let yMin = Infinity;
      let yMax = -Infinity;
      
      for (let i = 0; i <= samples; i++) {
        const theta = thetaMin + i * step;
        try {
          const r = f(theta);
          
          if (isFinite(r)) {
            // 极坐标转直角坐标
            const x = r * Math.cos(theta);
            const y = r * Math.sin(theta);
            
            points.push({ x, y });
            xMin = Math.min(xMin, x);
            xMax = Math.max(xMax, x);
            yMin = Math.min(yMin, y);
            yMax = Math.max(yMax, y);
          }
        } catch (error) {
          continue;
        }
      }
      
      return {
        points,
        xRange: [xMin, xMax],
        yRange: [yMin, yMax]
      };
    } catch (error) {
      Logger.error('Polar data generation error', error);
      throw error;
    }
  }
  
  /**
   * 计算定积分的区域点
   */
  generateIntegralRegion(f: (x: number) => number,
                         a: number,
                         b: number,
                         samples: number = 100): Point[] {
    try {
      Logger.info(`Generating integral region from ${a} to ${b}`);
      
      const points: Point[] = [];
      const step = (b - a) / samples;
      
      // 添加底边起点
      points.push({ x: a, y: 0 });
      
      // 添加函数曲线上的点
      for (let i = 0; i <= samples; i++) {
        const x = a + i * step;
        try {
          const y = f(x);
          if (isFinite(y)) {
            points.push({ x, y });
          }
        } catch (error) {
          continue;
        }
      }
      
      // 添加底边终点
      points.push({ x: b, y: 0 });
      
      return points;
    } catch (error) {
      Logger.error('Integral region generation error', error);
      throw error;
    }
  }
  
  /**
   * 生成坐标轴数据
   */
  generateAxes(xRange: [number, number], yRange: [number, number]): {
    xAxis: Point[];
    yAxis: Point[];
  } {
    return {
      xAxis: [
        { x: xRange[0], y: 0 },
        { x: xRange[1], y: 0 }
      ],
      yAxis: [
        { x: 0, y: yRange[0] },
        { x: 0, y: yRange[1] }
      ]
    };
  }
  
  /**
   * 生成网格线数据
   */
  generateGrid(xRange: [number, number], 
               yRange: [number, number],
               xStep: number = 1,
               yStep: number = 1): {
    verticalLines: Point[][];
    horizontalLines: Point[][];
  } {
    const verticalLines: Point[][] = [];
    const horizontalLines: Point[][] = [];
    
    // 垂直网格线
    for (let x = Math.ceil(xRange[0] / xStep) * xStep; x <= xRange[1]; x += xStep) {
      verticalLines.push([
        { x, y: yRange[0] },
        { x, y: yRange[1] }
      ]);
    }
    
    // 水平网格线
    for (let y = Math.ceil(yRange[0] / yStep) * yStep; y <= yRange[1]; y += yStep) {
      horizontalLines.push([
        { x: xRange[0], y },
        { x: xRange[1], y }
      ]);
    }
    
    return { verticalLines, horizontalLines };
  }
}

