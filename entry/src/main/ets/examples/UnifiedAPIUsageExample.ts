/**
 * 统一数学 API 使用示例
 * 展示如何使用新的强大计算系统
 */
import { getMathAPI, compute, diff, integrate, limit, simplify, expand, solve } from '../core/UnifiedMathAPI';
import { Logger } from '../utils/Logger';

/**
 * 基础计算示例
 */
export function basicComputationExamples() {
  Logger.info('=== 基础计算示例 ===');
  
  // 简单算术
  let result = compute('2 + 3 * 4');
  Logger.info(`2 + 3 * 4 = ${result.result?.toString()}`);
  
  // 三角函数
  result = compute('sin(pi/2)');
  Logger.info(`sin(π/2) = ${result.result?.toString()}`);
  
  // 幂运算
  result = compute('2^10');
  Logger.info(`2^10 = ${result.result?.toString()}`);
  
  // 复杂表达式
  result = compute('(sqrt(16) + 2^3) / (5 - 1)');
  Logger.info(`(√16 + 2³) / (5 - 1) = ${result.result?.toString()}`);
}

/**
 * 符号计算示例
 */
export function symbolicComputationExamples() {
  Logger.info('=== 符号计算示例 ===');
  
  const api = getMathAPI();
  
  // 化简
  let result = simplify('x + x + x');
  Logger.info(`化简 x + x + x: ${result.result?.toString()}`);
  
  // 展开
  result = expand('(x+1)(x+2)');
  Logger.info(`展开 (x+1)(x+2): ${result.result?.toString()}`);
  
  // 展开二项式
  result = expand('(x+y)^2');
  Logger.info(`展开 (x+y)²: ${result.result?.toString()}`);
  
  // 展开三项式
  result = expand('(a+b+c)^2');
  Logger.info(`展开 (a+b+c)²: ${result.result?.toString()}`);
}

/**
 * 微积分示例
 */
export function calculusExamples() {
  Logger.info('=== 微积分示例 ===');
  
  const api = getMathAPI();
  
  // 求导
  let result = diff('x^2', 'x');
  Logger.info(`d/dx(x²) = ${result.result?.toString()}`);
  
  result = diff('sin(x)', 'x');
  Logger.info(`d/dx(sin(x)) = ${result.result?.toString()}`);
  
  result = diff('x^3 + 2*x^2 + x + 1', 'x');
  Logger.info(`d/dx(x³ + 2x² + x + 1) = ${result.result?.toString()}`);
  
  // 链式法则
  result = diff('sin(x^2)', 'x');
  Logger.info(`d/dx(sin(x²)) = ${result.result?.toString()}`);
  
  // 积分
  result = integrate('x^2', 'x');
  Logger.info(`∫x² dx = ${result.result?.toString()}`);
  
  result = integrate('sin(x)', 'x');
  Logger.info(`∫sin(x) dx = ${result.result?.toString()}`);
  
  // 定积分
  result = integrate('x^2', 'x', 0, 1);
  Logger.info(`∫[0,1] x² dx = ${result.numeric}`);
  
  // 极限
  result = limit('sin(x)/x', 'x', 0);
  Logger.info(`lim(x→0) sin(x)/x = ${result.result?.toString()}`);
  
  result = limit('1/x', 'x', 'infinity');
  Logger.info(`lim(x→∞) 1/x = ${result.result?.toString()}`);
  
  result = limit('(1+1/x)^x', 'x', 'infinity');
  Logger.info(`lim(x→∞) (1+1/x)^x = ${result.result?.toString()}`);
}

/**
 * 线性代数示例
 */
export function linearAlgebraExamples() {
  Logger.info('=== 线性代数示例 ===');
  
  const api = getMathAPI();
  
  // 创建矩阵
  const A = api.matrix([[1, 2], [3, 4]]);
  Logger.info(`矩阵 A:\n${A.toString()}`);
  
  const B = api.matrix([[5, 6], [7, 8]]);
  Logger.info(`矩阵 B:\n${B.toString()}`);
  
  // 矩阵加法
  const C = A.add(B);
  Logger.info(`A + B:\n${C.toString()}`);
  
  // 矩阵乘法
  const D = A.multiply(B);
  Logger.info(`A × B:\n${D.toString()}`);
  
  // 矩阵转置
  const AT = A.transpose();
  Logger.info(`A^T:\n${AT.toString()}`);
  
  // 行列式
  const det = api.det(A);
  Logger.info(`det(A) = ${det}`);
  
  // 逆矩阵
  try {
    const Ainv = api.inv(A);
    Logger.info(`A^(-1):\n${Ainv.toString()}`);
  } catch (e) {
    Logger.error('矩阵不可逆', e);
  }
  
  // 向量
  const v1 = api.vector([1, 2, 3]);
  const v2 = api.vector([4, 5, 6]);
  Logger.info(`向量 v1: ${v1.toString()}`);
  Logger.info(`向量 v2: ${v2.toString()}`);
  
  // 向量点积
  const dotProduct = v1.dot(v2);
  Logger.info(`v1 · v2 = ${dotProduct}`);
  
  // 向量叉积（3维）
  const crossProduct = v1.cross(v2);
  Logger.info(`v1 × v2 = ${crossProduct.toString()}`);
  
  // 向量模长
  const magnitude = v1.magnitude();
  Logger.info(`|v1| = ${magnitude}`);
  
  // 求解线性方程组
  const coeffMatrix = api.matrix([[2, 1], [1, 3]]);
  const constVector = api.vector([5, 6]);
  const solution = api.solveLinear(coeffMatrix, constVector);
  Logger.info(`线性方程组解: ${solution.toString()}`);
}

/**
 * 多项式示例
 */
export function polynomialExamples() {
  Logger.info('=== 多项式示例 ===');
  
  const api = getMathAPI();
  
  // 创建多项式: 1 + 2x + 3x²
  const p1 = api.polynomial([1, 2, 3]);
  Logger.info(`p1(x) = ${p1.toString()}`);
  
  // 创建多项式: 2 + x
  const p2 = api.polynomial([2, 1]);
  Logger.info(`p2(x) = ${p2.toString()}`);
  
  // 多项式加法
  const p3 = p1.add(p2);
  Logger.info(`p1 + p2 = ${p3.toString()}`);
  
  // 多项式乘法
  const p4 = p1.multiply(p2);
  Logger.info(`p1 × p2 = ${p4.toString()}`);
  
  // 多项式求值
  const value = p1.evaluate(2);
  Logger.info(`p1(2) = ${value}`);
  
  // 多项式求导
  const p1_derivative = p1.derivative();
  Logger.info(`p1'(x) = ${p1_derivative.toString()}`);
  
  // 多项式积分
  const p1_integral = p1.integrate();
  Logger.info(`∫p1(x)dx = ${p1_integral.toString()}`);
}

/**
 * 数论示例
 */
export function numberTheoryExamples() {
  Logger.info('=== 数论示例 ===');
  
  const api = getMathAPI();
  
  // 最大公约数
  const gcd = api.gcd(12, 18);
  Logger.info(`gcd(12, 18) = ${gcd}`);
  
  // 最小公倍数
  const lcm = api.lcm(12, 18);
  Logger.info(`lcm(12, 18) = ${lcm}`);
  
  // 阶乘
  const factorial = api.factorial(5);
  Logger.info(`5! = ${factorial}`);
  
  // 组合数
  const combination = api.combination(5, 2);
  Logger.info(`C(5, 2) = ${combination}`);
  
  // 排列数
  const permutation = api.permutation(5, 2);
  Logger.info(`P(5, 2) = ${permutation}`);
}

/**
 * 高级功能示例
 */
export function advancedExamples() {
  Logger.info('=== 高级功能示例 ===');
  
  const api = getMathAPI();
  
  // 设置变量
  api.setVar('a', 5);
  api.setVar('b', 3);
  
  let result = compute('a + b');
  Logger.info(`a + b = ${result.result?.toString()} (a=5, b=3)`);
  
  // 泰勒级数展开
  result = api.taylor('sin(x)', 'x', 0, 5);
  Logger.info(`sin(x) 的泰勒展开 (5阶): ${result.result?.toString()}`);
  
  // 三角化简
  result = api.trigSimplify('sin(x)^2 + cos(x)^2');
  Logger.info(`化简 sin²(x) + cos²(x): ${result.result?.toString()}`);
  
  // 设置精度
  api.setPrecision(15);
  result = compute('pi');
  Logger.info(`π (15位精度) = ${result.numeric}`);
  
  // 设置角度单位
  api.setAngleUnit('radian');
  result = compute('sin(pi/2)');
  Logger.info(`sin(π/2) [弧度] = ${result.result?.toString()}`);
  
  api.setAngleUnit('degree');
  result = compute('sin(90)');
  Logger.info(`sin(90°) [角度] = ${result.result?.toString()}`);
  
  // 清除变量
  api.clearAllVars();
}

/**
 * 复数计算示例
 */
export function complexNumberExamples() {
  Logger.info('=== 复数计算示例 ===');
  
  const api = getMathAPI();
  
  // 设置定义域为复数
  api.setDomain('complex');
  
  // 创建复数
  const z1 = api.create.complex(3, 4);  // 3 + 4i
  const z2 = api.create.complex(1, -2); // 1 - 2i
  
  Logger.info(`z1 = ${z1.toString()}`);
  Logger.info(`z2 = ${z2.toString()}`);
  
  // 复数加法
  const z3 = z1.add(z2);
  Logger.info(`z1 + z2 = ${z3.toString()}`);
  
  // 复数乘法
  const z4 = z1.multiply(z2);
  Logger.info(`z1 × z2 = ${z4.toString()}`);
  
  // 复数除法
  const z5 = z1.divide(z2);
  Logger.info(`z1 / z2 = ${z5.toString()}`);
  
  // 共轭复数
  const z1_conj = z1.conjugate();
  Logger.info(`z1的共轭 = ${z1_conj.toString()}`);
  
  // 模
  const magnitude = z1.magnitude();
  Logger.info(`|z1| = ${magnitude}`);
  
  // 幅角
  const argument = z1.argument();
  Logger.info(`arg(z1) = ${argument} 弧度`);
}

/**
 * 实际应用示例
 */
export function practicalExamples() {
  Logger.info('=== 实际应用示例 ===');
  
  const api = getMathAPI();
  
  // 1. 物理：自由落体运动
  Logger.info('\n--- 物理：自由落体 ---');
  api.setVar('g', 9.8);  // 重力加速度
  api.setVar('t', 2);    // 时间
  
  let result = compute('0.5 * g * t^2');
  Logger.info(`下落距离 s = 1/2 × g × t² = ${result.numeric} 米`);
  
  result = compute('g * t');
  Logger.info(`速度 v = g × t = ${result.numeric} m/s`);
  
  // 2. 金融：复利计算
  Logger.info('\n--- 金融：复利计算 ---');
  api.setVar('P', 10000);  // 本金
  api.setVar('r', 0.05);   // 年利率
  api.setVar('n', 10);     // 年数
  
  result = compute('P * (1 + r)^n');
  Logger.info(`10年后本息和 = ${result.numeric?.toFixed(2)} 元`);
  
  // 3. 统计：正态分布
  Logger.info('\n--- 统计：标准差 ---');
  const data = api.vector([2, 4, 4, 4, 5, 5, 7, 9]);
  const n = data.dimension;
  
  // 计算均值
  let sum = 0;
  for (let i = 0; i < n; i++) {
    sum += data.get(i);
  }
  const mean = sum / n;
  Logger.info(`均值 = ${mean}`);
  
  // 计算方差
  let variance = 0;
  for (let i = 0; i < n; i++) {
    variance += Math.pow(data.get(i) - mean, 2);
  }
  variance /= n;
  Logger.info(`方差 = ${variance}`);
  Logger.info(`标准差 = ${Math.sqrt(variance)}`);
  
  // 4. 工程：傅里叶级数（简化）
  Logger.info('\n--- 工程：周期函数分析 ---');
  api.setVar('omega', 2 * Math.PI);  // 角频率
  api.setVar('t', 0.5);
  
  result = compute('sin(omega * t)');
  Logger.info(`正弦波 y = sin(ωt) 在 t=0.5 时的值 = ${result.numeric}`);
  
  // 5. 几何：圆的面积和周长
  Logger.info('\n--- 几何：圆 ---');
  api.setVar('r', 5);  // 半径
  
  result = compute('pi * r^2');
  Logger.info(`面积 A = πr² = ${result.numeric} 平方单位`);
  
  result = compute('2 * pi * r');
  Logger.info(`周长 C = 2πr = ${result.numeric} 单位`);
  
  api.clearAllVars();
}

/**
 * 运行所有示例
 */
export function runAllExamples() {
  try {
    basicComputationExamples();
    symbolicComputationExamples();
    calculusExamples();
    linearAlgebraExamples();
    polynomialExamples();
    numberTheoryExamples();
    advancedExamples();
    complexNumberExamples();
    practicalExamples();
    
    Logger.info('\n=== 所有示例运行完成 ===');
  } catch (error) {
    Logger.error('运行示例时出错', error);
  }
}

