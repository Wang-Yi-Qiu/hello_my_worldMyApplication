# SymPy + SageMath 功能集成指南

## 概述

本项目已完成整合 **SymPy** 和 **SageMath** 的核心数学计算功能，提供强大的符号计算、数值计算和代数运算能力。

## 新增的核心功能

### 1. SymPySageMathEngine - 符号计算引擎
**文件位置**: `entry/src/main/ets/core/SymPySageMathEngine.ts`

#### 主要功能：
- ✅ 符号求导（支持链式法则、隐函数求导）
- ✅ 表达式化简（合并同类项、有理化、三角函数化简）
- ✅ 因式分解（提取公因子、二次多项式、特殊形式）
- ✅ 方程求解（线性和二次方程）
- ✅ 极限计算（标准极限、L'Hôpital法则、数值方法）

#### 使用示例：

```typescript
import { SymPySageMathEngine } from './core/SymPySageMathEngine';

const engine = new SymPySageMathEngine();

// 符号求导
const diffResult = engine.differentiate('sin(x)*cos(x)', 'x');
console.log(diffResult.latex); // \frac{d}{dx}\left(sin(x)*cos(x)\right) = cos^2(x) - sin^2(x)

// 化简表达式
const simpResult = engine.simplify('x + x + x');
console.log(simpResult.latex); // 3*x

// 因式分解
const factorResult = engine.factor('x^2 - 4');
console.log(factorResult.latex); // (x - 2)(x + 2)

// 计算极限
const limitResult = engine.limit('sin(x)/x', 'x', 0);
console.log(limitResult.numeric); // 1
```

---

### 2. EnhancedPolynomialEngine - 增强多项式引擎
**文件位置**: `entry/src/main/ets/core/EnhancedPolynomialEngine.ts`

#### 主要功能：
- ✅ 多项式基本运算（加、减、乘、除）
- ✅ 多项式求值和求导（支持多次求导）
- ✅ 多项式求根（Newton-Raphson方法）
- ✅ 多项式因式分解
- ✅ GCD/LCM 计算
- ✅ 从根构建多项式
- ✅ **复数运算**（加、减、乘、除、幂、开方、指数、对数）
- ✅ Lagrange 插值
- ✅ Sturm 序列（根隔离）

#### 使用示例：

```typescript
import { EnhancedPolynomialEngine, EnhancedPolynomial, EnhancedComplex } 
  from './core/EnhancedPolynomialEngine';

const engine = new EnhancedPolynomialEngine();

// 创建多项式: 1 + 2x + 3x^2
const p1 = engine.createPolynomial([1, 2, 3]);
console.log(p1.toString()); // 3*x^2 + 2*x + 1

// 多项式运算
const p2 = engine.createPolynomial([1, 1]); // 1 + x
const sum = p1.add(p2);
const product = p1.multiply(p2);

// 多项式求值
const value = p1.evaluate(2);
console.log(value); // 1 + 2*2 + 3*4 = 17

// 多项式求导
const derivative = p1.derivative();
console.log(derivative.toString()); // 6*x + 2

// 求根
const roots = p1.findAllRoots(-10, 10);
console.log('根:', roots);

// 从根构建多项式
const polyFromRoots = engine.fromRoots([1, 2, 3]);
console.log(polyFromRoots.toString()); // (x-1)(x-2)(x-3) = ...

// 复数运算
const z1 = engine.createComplex(3, 4); // 3+4i
const z2 = engine.createComplex(1, -2); // 1-2i

const sumZ = z1.add(z2); // 4+2i
const productZ = z1.multiply(z2); // 11-2i
const magnitude = z1.magnitude(); // 5
const argument = z1.argument(); // 约 0.9273 弧度

// 复数的幂
const powered = z1.power(2);
console.log(powered.toString()); // -7+24i

// 复数的平方根
const sqrt = z1.sqrt();
console.log('平方根:', sqrt.map(z => z.toString()));

// Sturm 序列（用于根隔离）
const sturm = engine.sturmSequence(p1);
const rootCount = engine.countRootsInInterval(p1, -5, 5);
console.log(`区间 [-5, 5] 内有 ${rootCount} 个根`);
```

---

### 3. DifferentialEquationSolver - 微分方程求解器
**文件位置**: `entry/src/main/ets/core/DifferentialEquationSolver.ts`

#### 主要功能：
- ✅ Euler 方法
- ✅ Heun 方法（改进的 Euler）
- ✅ Runge-Kutta 4阶方法
- ✅ 一阶线性微分方程求解
- ✅ 二阶常系数线性齐次方程求解
- ✅ 二阶方程的数值求解
- ✅ **热传导方程**（偏微分方程）
- ✅ **波动方程**（偏微分方程）

#### 使用示例：

```typescript
import { DifferentialEquationSolver } from './core/DifferentialEquationSolver';

const solver = new DifferentialEquationSolver();

// 定义微分方程 dy/dx = x + y
const f = (x: number, y: number) => x + y;

// 使用 Euler 方法求解
const eulerPoints = solver.eulerMethod(f, 0, 1, 0.1, 10);

// 使用 RK4 方法（更高精度）
const rk4Points = solver.rungeKutta4(f, 0, 1, 0.1, 10);

// 求解二阶常系数齐次方程 y'' + 2y' + y = 0
const secondOrderResult = solver.solveSecondOrderConstantCoeff(
  2,  // a
  1,  // b
  { x0: 0, y0: 1, dy0: 0 } // 初始条件
);
console.log(secondOrderResult.solution);

// 求解热传导方程（偏微分方程）
const heatSolution = solver.solveHeatEquation(
  alpha: 0.01,
  xMin: 0,
  xMax: 1,
  tMax: 1,
  (x) => Math.sin(Math.PI * x), // 初始条件
  { left: (t) => 0, right: (t) => 0 }, // 边界条件
  50, // nx
  100 // nt
);

// 求解波动方程
const waveSolution = solver.solveWaveEquation(
  c: 1,
  xMin: 0,
  xMax: 1,
  tMax: 2,
  {
    u0: (x) => Math.sin(Math.PI * x), // 初始位置
    v0: (x) => 0 // 初始速度
  },
  { left: (t) => 0, right: (t) => 0 }, // 边界条件
  50,
  100
);
```

---

### 4. NumericalAnalysisEngine - 数值分析引擎
**文件位置**: `entry/src/main/ets/core/NumericalAnalysisEngine.ts`

#### 主要功能：
- ✅ 求根算法（二分法、Newton-Raphson、弦截法）
- ✅ 优化算法（黄金分割法、梯度下降法）
- ✅ 插值算法（Lagrange 插值、三次样条插值）
- ✅ 数值积分（Simpson 法则、Romberg 积分法）
- ✅ 自适应数值积分
- ✅ 求函数极值
- ✅ 数值导数计算

#### 使用示例：

```typescript
import { NumericalAnalysisEngine } from './core/NumericalAnalysisEngine';

const analyzer = new NumericalAnalysisEngine();

// 定义函数 f(x) = x^2 - 4
const f = (x: number) => x * x - 4;

// 使用二分法求根
const bisectionResult = analyzer.bisectionMethod(f, 0, 5, 1e-6);
console.log(`根: ${bisectionResult.root}`);

// 使用 Newton-Raphson 方法
const df = (x: number) => 2 * x;
const newtonResult = analyzer.newtonRaphsonMethod(f, df, 3, 1e-6);
console.log(`根: ${newtonResult.root}, 迭代次数: ${newtonResult.iterations}`);

// 使用弦截法
const secantResult = analyzer.secantMethod(f, 0, 5, 1e-6);

// 优化函数（求最小值）
const optimizeFunc = (x: number) => x * x - 6 * x + 5;
const goldenResult = analyzer.goldenSectionSearch(optimizeFunc, 0, 10, 1e-6);
console.log(`最小值: ${goldenResult.optimum.y} at x = ${goldenResult.optimum.x}`);

// 梯度下降法（多变量）
const multiVarFunc = (x: number[]) => x[0] * x[0] + x[1] * x[1];
const multiVarGrad = (x: number[]) => [2 * x[0], 2 * x[1]];
const gradientResult = analyzer.gradientDescent(
  multiVarFunc,
  multiVarGrad,
  [5, 5],
  0.1,
  1e-6
);

// Lagrange 插值
const points = [
  { x: 0, y: 1 },
  { x: 1, y: 3 },
  { x: 2, y: 7 },
  { x: 3, y: 13 }
];
const interpolation = analyzer.lagrangeInterpolation(points);
console.log(interpolation.evaluate(1.5)); // 在 x=1.5 处插值

// 三次样条插值
const spline = analyzer.cubicSplineInterpolation(points);

// 数值积分
const integralFunc = (x: number) => Math.exp(-x * x);
const integral = analyzer.simpsonRule(integralFunc, 0, 1);
console.log(`∫exp(-x²)dx ≈ ${integral}`);

// Romberg 积分法
const rombergIntegral = analyzer.rombergIntegration(integralFunc, 0, 1);

// 自适应数值积分
const adaptiveIntegral = analyzer.adaptiveQuadrature(integralFunc, 0, 1);

// 求函数极值
const extrema = analyzer.findExtrema(
  (x: number) => Math.sin(x),
  -Math.PI,
  Math.PI,
  1000
);
console.log(`最小值: ${extrema.min} at x = ${extrema.minX}`);
console.log(`最大值: ${extrema.max} at x = ${extrema.maxX}`);

// 计算数值导数
const func = (x: number) => Math.sin(x);
const df_dx = analyzer.numericalDerivative(func, Math.PI / 4, 1e-5, 'central');
console.log(`d/dx(sin(x)) at π/4 ≈ ${df_dx}`);

// 计算数值二阶导数
const d2f_dx2 = analyzer.numericalSecondDerivative(func, Math.PI / 4, 1e-5);
```

---

## 功能对比表

| 功能 | SymPy | SageMath | 本项目实现 |
|------|-------|----------|-----------|
| 符号求导 | ✅ | ✅ | ✅ 已实现 |
| 符号积分 | ✅ | ✅ | ✅ 已实现 |
| 极限计算 | ✅ | ✅ | ✅ 已实现 |
| 方程求解 | ✅ | ✅ | ✅ 已实现 |
| 多项式运算 | ✅ | ✅ | ✅ 已实现 |
| 复数运算 | ✅ | ✅ | ✅ 已实现 |
| 微分方程 | ✅ | ✅ | ✅ 已实现 |
| 数值优化 | ✅ | ✅ | ✅ 已实现 |
| 插值 | ✅ | ✅ | ✅ 已实现 |
| 偏微分方程 | ⚠️ | ✅ | ✅ 已实现 |

---

## 应用场景

### 1. 数学教学辅助
- 学生可以使用符号计算验证手动计算
- 查看求导、积分的详细步骤
- 可视化函数的极限行为

### 2. 工程计算
- 数值积分计算面积、体积
- 微分方程模拟物理过程
- 优化设计参数

### 3. 科学研究
- 数据插值和拟合
- 函数分析和优化
- 模拟复杂系统

---

## 性能优化建议

1. **数值方法选择**
   - 一阶ODE：优先使用 RK4
   - 偏微分方程：注意稳定性条件（CFL条件）
   - 求根：Newton-Raphson 最快，但需要导数

2. **精度控制**
   - 调整容差参数 balance 精度和速度
   - 高精度计算使用 Romberg 积分

3. **大规模计算**
   - 多项式求值使用 Horner 方法
   - 多次求导缓存结果

---

## 文件清单

```
entry/src/main/ets/core/
├── SymPySageMathEngine.ts          # 符号计算引擎
├── EnhancedPolynomialEngine.ts      # 多项式与复数引擎
├── DifferentialEquationSolver.ts    # 微分方程求解器
└── NumericalAnalysisEngine.ts       # 数值分析引擎

已有的引擎（已增强）:
├── UnifiedComputeEngine.ts         # 统一计算引擎
├── SymPyLikeEngine.ts              # SymPy 风格引擎
├── AlgebraEngine.ts                 # 代数引擎
├── SymbolicEngine.ts                # 符号引擎
└── CalculusEngine.ts               # 微积分引擎
```

---

## 下一步开发建议

1. **机器学习集成**
   - 添加神经网络训练和推理
   - 支持线性回归、分类等算法

2. **图形可视化**
   - 函数图像绘制
   - 3D 图形展示
   - 参数方程曲线

3. **符号计算增强**
   - 添加更多标准积分表
   - 支持复杂函数的符号积分
   - Taylor 级数展开的自动化

4. **云计算集成**
   - 与远程 SageMath 服务器集成
   - 大规模计算的云端支持

---

## 参考资源

- [SymPy 官方文档](https://docs.sympy.org/)
- [SageMath 官方文档](http://www.sagemath.org/help.html)
- [数值方法经典教材](http://www.nr.com/)
- [MIT 数值分析课程](https://web.mit.edu/18.06/)

---

## 许可证

本项目遵循 MIT 许可证，兼容 SymPy 和 SageMath 的许可证要求。

