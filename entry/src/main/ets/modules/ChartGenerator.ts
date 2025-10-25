/**
 * 图表生成器
 * 用于生成函数图像数据
 * 增强版：支持多种坐标系统和高级绘图功能
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
  adaptive?: boolean; // 自适应采样
}

export interface DerivativeData {
  points: Point[];
  order: number; // 导数阶数
}

export interface TangentLine {
  point: Point; // 切点
  slope: number; // 斜率
  linePoints: Point[]; // 切线上的点
}

/**
 * 图表生成器类
 * 增强版：支持导数、积分、切线等高级功能
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
      let validPointsCount = 0;
      let infinitePointsCount = 0;
      
      for (let i = 0; i <= samples; i++) {
        const x = xMin + i * step;
        try {
          const y = f(x);
          
          // 检查是否为有限值
          if (isFinite(y)) {
            points.push({ x, y });
            yMin = Math.min(yMin, y);
            yMax = Math.max(yMax, y);
            validPointsCount++;
          } else {
            infinitePointsCount++;
          }
        } catch (error) {
          // 跳过无效点
          continue;
        }
      }
      
      Logger.info(`Generated ${validPointsCount} valid points, ${infinitePointsCount} infinite values`);
      
      // 如果指定了 Y 范围，使用指定值
      if (options.yMin !== undefined) yMin = options.yMin;
      if (options.yMax !== undefined) yMax = options.yMax;
      
      // 如果计算出的 Y 范围太大或太小，给出警告
      const computedYRange = yMax - yMin;
      if (validPointsCount > 0 && computedYRange > 1e10) {
        Logger.warn(`Very large Y range: [${yMin}, ${yMax}], might need adjustment`);
      }
      
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
  
  /**
   * 生成函数的数值导数数据
   * @param f 原函数
   * @param options 绘图选项
   * @param order 导数阶数（1或2）
   * @param h 数值微分步长
   */
  generateDerivativeData(
    f: (x: number) => number,
    options: PlotOptions = {},
    order: number = 1,
    h: number = 0.001
  ): DerivativeData {
    try {
      const xMin = options.xMin ?? -10;
      const xMax = options.xMax ?? 10;
      const samples = options.samples ?? this.defaultSamples;
      
      Logger.info(`Generating ${order}-order derivative data`);
      
      const points: Point[] = [];
      const step = (xMax - xMin) / samples;
      
      for (let i = 0; i <= samples; i++) {
        const x = xMin + i * step;
        try {
          let y: number;
          
          if (order === 1) {
            // 一阶导数（中心差分）
            y = (f(x + h) - f(x - h)) / (2 * h);
          } else if (order === 2) {
            // 二阶导数
            y = (f(x + h) - 2 * f(x) + f(x - h)) / (h * h);
          } else {
            throw new Error('只支持1阶和2阶导数');
          }
          
          if (isFinite(y)) {
            points.push({ x, y });
          }
        } catch (error) {
          continue;
        }
      }
      
      Logger.info(`Generated ${points.length} derivative points`);
      
      return {
        points,
        order
      };
    } catch (error) {
      Logger.error('Derivative data generation error', error);
      throw error;
    }
  }
  
  /**
   * 生成切线数据
   * @param f 函数
   * @param x0 切点的x坐标
   * @param xRange 切线的x范围
   * @param h 数值微分步长
   */
  generateTangentLine(
    f: (x: number) => number,
    x0: number,
    xRange: [number, number],
    h: number = 0.001
  ): TangentLine {
    try {
      Logger.info(`Generating tangent line at x=${x0}`);
      
      // 计算切点
      const y0 = f(x0);
      
      // 计算斜率（数值导数）
      const slope = (f(x0 + h) - f(x0 - h)) / (2 * h);
      
      // 生成切线上的点
      const linePoints: Point[] = [];
      const samples = 100;
      const step = (xRange[1] - xRange[0]) / samples;
      
      for (let i = 0; i <= samples; i++) {
        const x = xRange[0] + i * step;
        const y = y0 + slope * (x - x0); // 切线方程
        linePoints.push({ x, y });
      }
      
      return {
        point: { x: x0, y: y0 },
        slope,
        linePoints
      };
    } catch (error) {
      Logger.error('Tangent line generation error', error);
      throw error;
    }
  }
  
  /**
   * 生成法线数据
   * @param f 函数
   * @param x0 法线点的x坐标
   * @param xRange 法线的x范围
   * @param yRange y范围（用于垂直线情况）
   * @param h 数值微分步长
   */
  generateNormalLine(
    f: (x: number) => number,
    x0: number,
    xRange: [number, number],
    yRange: [number, number] = [-10, 10],
    h: number = 0.001
  ): TangentLine {
    try {
      Logger.info(`Generating normal line at x=${x0}`);
      
      // 计算点
      const y0 = f(x0);
      
      // 计算切线斜率
      const tangentSlope = (f(x0 + h) - f(x0 - h)) / (2 * h);
      
      // 法线斜率（切线斜率的负倒数）
      const normalSlope = tangentSlope !== 0 ? -1 / tangentSlope : Infinity;
      
      // 生成法线上的点
      const linePoints: Point[] = [];
      const samples = 100;
      
      if (isFinite(normalSlope)) {
        const step = (xRange[1] - xRange[0]) / samples;
        for (let i = 0; i <= samples; i++) {
          const x = xRange[0] + i * step;
          const y = y0 + normalSlope * (x - x0);
          linePoints.push({ x, y });
        }
      } else {
        // 垂直线
        const step = (yRange[1] - yRange[0]) / samples;
        for (let i = 0; i <= samples; i++) {
          const y = yRange[0] + i * step;
          linePoints.push({ x: x0, y });
        }
      }
      
      return {
        point: { x: x0, y: y0 },
        slope: normalSlope,
        linePoints
      };
    } catch (error) {
      Logger.error('Normal line generation error', error);
      throw error;
    }
  }
  
  /**
   * 自适应采样生成函数数据
   * 在曲率大的地方增加采样点
   */
  generateAdaptiveFunctionData(
    f: (x: number) => number,
    options: PlotOptions = {}
  ): ChartData {
    try {
      const xMin = options.xMin ?? -10;
      const xMax = options.xMax ?? 10;
      const minSamples = 100;
      
      Logger.info('Generating adaptive function data');
      
      const points: Point[] = [];
      let yMin = Infinity;
      let yMax = -Infinity;
      
      // 初始粗采样
      const initialSamples = minSamples;
      const initialStep = (xMax - xMin) / initialSamples;
      
      const initialPoints: Point[] = [];
      for (let i = 0; i <= initialSamples; i++) {
        const x = xMin + i * initialStep;
        try {
          const y = f(x);
          if (isFinite(y)) {
            initialPoints.push({ x, y });
          }
        } catch (error) {
          continue;
        }
      }
      
      // 自适应细化
      for (let i = 0; i < initialPoints.length - 1; i++) {
        const p1 = initialPoints[i];
        const p2 = initialPoints[i + 1];
        
        points.push(p1);
        yMin = Math.min(yMin, p1.y);
        yMax = Math.max(yMax, p1.y);
        
        // 计算曲率（简化版）
        const dx = p2.x - p1.x;
        const dy = p2.y - p1.y;
        const distance = Math.sqrt(dx * dx + dy * dy);
        
        // 如果两点距离较大，插入中间点
        if (distance > (xMax - xMin) / 50) {
          const midX = (p1.x + p2.x) / 2;
          try {
            const midY = f(midX);
            if (isFinite(midY)) {
              points.push({ x: midX, y: midY });
              yMin = Math.min(yMin, midY);
              yMax = Math.max(yMax, midY);
            }
          } catch (error) {
            // 忽略
          }
        }
      }
      
      // 添加最后一个点
      if (initialPoints.length > 0) {
        const lastPoint = initialPoints[initialPoints.length - 1];
        points.push(lastPoint);
        yMin = Math.min(yMin, lastPoint.y);
        yMax = Math.max(yMax, lastPoint.y);
      }
      
      Logger.info(`Adaptive sampling generated ${points.length} points`);
      
      return {
        points,
        xRange: [xMin, xMax],
        yRange: [yMin, yMax]
      };
    } catch (error) {
      Logger.error('Adaptive function data generation error', error);
      throw error;
    }
  }
  
  /**
   * 生成隐函数图像数据（等高线）
   * F(x, y) = 0
   * @param F 二元函数
   * @param xRange x范围
   * @param yRange y范围
   * @param samples 采样数
   * @param tolerance 容差
   */
  generateImplicitFunctionData(
    F: (x: number, y: number) => number,
    xRange: [number, number],
    yRange: [number, number],
    samples: number = 100,
    tolerance: number = 0.1
  ): Point[] {
    try {
      Logger.info('Generating implicit function data');
      
      const points: Point[] = [];
      const xStep = (xRange[1] - xRange[0]) / samples;
      const yStep = (yRange[1] - yRange[0]) / samples;
      
      // 扫描网格，查找满足条件的点
      for (let i = 0; i <= samples; i++) {
        for (let j = 0; j <= samples; j++) {
          const x = xRange[0] + i * xStep;
          const y = yRange[0] + j * yStep;
          
          try {
            const value = F(x, y);
            
            // 如果函数值接近零，认为是解
            if (Math.abs(value) < tolerance) {
              points.push({ x, y });
            }
          } catch (error) {
            continue;
          }
        }
      }
      
      Logger.info(`Generated ${points.length} implicit function points`);
      return points;
    } catch (error) {
      Logger.error('Implicit function data generation error', error);
      throw error;
    }
  }
  
  /**
   * 生成向量场数据
   * @param fx x方向的向量函数
   * @param fy y方向的向量函数
   * @param xRange x范围
   * @param yRange y范围
   * @param gridSize 网格大小
   */
  generateVectorField(
    fx: (x: number, y: number) => number,
    fy: (x: number, y: number) => number,
    xRange: [number, number],
    yRange: [number, number],
    gridSize: number = 20
  ): Array<{ start: Point; end: Point; magnitude: number }> {
    try {
      Logger.info('Generating vector field data');
      
      const vectors: Array<{ start: Point; end: Point; magnitude: number }> = [];
      const xStep = (xRange[1] - xRange[0]) / gridSize;
      const yStep = (yRange[1] - yRange[0]) / gridSize;
      
      // 计算缩放因子（使箭头长度适中）
      const scale = Math.min(xStep, yStep) * 0.8;
      
      for (let i = 0; i <= gridSize; i++) {
        for (let j = 0; j <= gridSize; j++) {
          const x = xRange[0] + i * xStep;
          const y = yRange[0] + j * yStep;
          
          try {
            const vx = fx(x, y);
            const vy = fy(x, y);
            
            if (isFinite(vx) && isFinite(vy)) {
              const magnitude = Math.sqrt(vx * vx + vy * vy);
              
              // 归一化并缩放
              const normalizedVx = magnitude > 0 ? (vx / magnitude) * scale : 0;
              const normalizedVy = magnitude > 0 ? (vy / magnitude) * scale : 0;
              
              vectors.push({
                start: { x, y },
                end: { x: x + normalizedVx, y: y + normalizedVy },
                magnitude
              });
            }
          } catch (error) {
            continue;
          }
        }
      }
      
      Logger.info(`Generated ${vectors.length} vectors`);
      return vectors;
    } catch (error) {
      Logger.error('Vector field generation error', error);
      throw error;
    }
  }
  
  /**
   * 生成填充区域（用于积分可视化）
   * @param f 函数
   * @param a 积分下限
   * @param b 积分上限
   * @param baseline 基线（默认为0）
   * @param samples 采样数
   */
  generateFilledRegion(
    f: (x: number) => number,
    a: number,
    b: number,
    baseline: number = 0,
    samples: number = 100
  ): Point[] {
    try {
      Logger.info(`Generating filled region from ${a} to ${b}`);
      
      const points: Point[] = [];
      const step = (b - a) / samples;
      
      // 起始点（基线）
      points.push({ x: a, y: baseline });
      
      // 函数曲线上的点
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
      
      // 结束点（基线）
      points.push({ x: b, y: baseline });
      
      return points;
    } catch (error) {
      Logger.error('Filled region generation error', error);
      throw error;
    }
  }
}

