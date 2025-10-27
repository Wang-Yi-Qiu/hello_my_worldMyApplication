/**
 * 后端 API 使用示例
 * 展示如何在 HarmonyOS 应用中调用后端计算服务
 */
import { backendAPI } from '../services/BackendAPIService';
import { Logger } from '../utils/Logger';

/**
 * 示例：健康检查
 */
export async function checkBackendHealth(): Promise<void> {
  Logger.info('=== 检查后端服务健康状态 ===');
  
  const response = await backendAPI.healthCheck();
  
  if (response.success) {
    Logger.info('后端服务运行正常');
    Logger.info('Service:', response.data);
  } else {
    Logger.error('后端服务不可用:', response.error);
  }
}

/**
 * 示例：多项式求根
 */
export async function findPolynomialRootsExample(): Promise<void> {
  Logger.info('=== 多项式求根示例 ===');
  
  // x^2 - 5x + 6 = 0 的根
  const response = await backendAPI.findPolynomialRoots({
    coefficients: [6, -5, 1],  // 从低次到高次
    variable: 'x'
  });
  
  if (response.success && response.data) {
    Logger.info(`找到 ${response.data.num_roots} 个根:`);
    response.data.roots.forEach((root, index) => {
      Logger.info(`  根 ${index + 1}: ${root.real} + ${root.imag}i`);
    });
  } else {
    Logger.error('求根失败:', response.error);
  }
}

/**
 * 示例：复数运算
 */
export async function complexOperationExample(): Promise<void> {
  Logger.info('=== 复数运算示例 ===');
  
  // (3+4i) * (1-2i)
  const response = await backendAPI.complexOperation({
    real1: 3,
    imag1: 4,
    real2: 1,
    imag2: -2,
    operation: 'multiply'
  });
  
  if (response.success && response.data) {
    Logger.info(`复数运算结果: ${response.data.real} + ${response.data.imag}i`);
  }
  
  // 计算模长
  const magnitudeResponse = await backendAPI.complexOperation({
    real1: 3,
    imag1: 4,
    operation: 'magnitude'
  });
  
  if (magnitudeResponse.success && magnitudeResponse.data) {
    Logger.info(`模长: ${magnitudeResponse.data.magnitude}`);
  }
}

/**
 * 示例：微分方程求解
 */
export async function solveODEExample(): Promise<void> {
  Logger.info('=== 微分方程求解示例 ===');
  
  // 求解 y'' + 2y' + y = 0
  const response = await backendAPI.solveODE({
    equationType: 'second_order_constant',
    parameters: { a: 2, b: 1 },
    initialCondition: { y0: 1, dy0: 0 },
    timeRange: [0, 10]
  });
  
  if (response.success && response.data) {
    Logger.info('微分方程类型:', response.data.equation_type);
    Logger.info('通解:', response.data.general_solution);
    if (response.data.discriminant !== undefined) {
      Logger.info('判别式:', response.data.discriminant);
    }
  }
}

/**
 * 示例：函数优化
 */
export async function optimizationExample(): Promise<void> {
  Logger.info('=== 函数优化示例 ===');
  
  // 优化函数 f(x) = x^2 - 4x + 3
  const response = await backendAPI.optimize({
    functionCode: 'x**2 - 4*x + 3',
    initialGuess: [5.0],
    method: 'BFGS'
  });
  
  if (response.success && response.data) {
    Logger.info('最优解: x =', response.data.optimal_point);
    Logger.info('最优值:', response.data.optimal_value);
  }
}

/**
 * 示例：符号求导
 */
export async function differentiateExample(): Promise<void> {
  Logger.info('=== 符号求导示例 ===');
  
  // d/dx(x^2)
  const response = await backendAPI.differentiate('x**2', 'x');
  
  if (response.success && response.data) {
    Logger.info('导数:', response.data.result);
    Logger.info('LaTeX:', response.data.latex);
  }
}

/**
 * 示例：定积分
 */
export async function integrateExample(): Promise<void> {
  Logger.info('=== 定积分示例 ===');
  
  // ∫[0,1] x^2 dx
  const response = await backendAPI.integrate('x**2', 0, 1, 'x');
  
  if (response.success && response.data) {
    Logger.info('积分结果:', response.data.result);
    if (response.data.error_estimate) {
      Logger.info('误差估计:', response.data.error_estimate);
    }
  }
}

/**
 * 示例：数值求根
 */
export async function findRootExample(): Promise<void> {
  Logger.info('=== 数值求根示例 ===');
  
  // 求解 x^2 - 4 = 0
  const response = await backendAPI.findRoot('x**2 - 4', 'newton', 3);
  
  if (response.success && response.data) {
    Logger.info('求解方法:', response.data.method);
    Logger.info('根:', response.data.root);
    Logger.info('函数值:', response.data.value_at_root);
  }
}

/**
 * 运行所有示例
 */
export async function runAllBackendExamples(): Promise<void> {
  try {
    // 1. 检查后端服务
    await checkBackendHealth();
    
    // 2. 多项式求根
    await findPolynomialRootsExample();
    
    // 3. 复数运算
    await complexOperationExample();
    
    // 4. 微分方程
    await solveODEExample();
    
    // 5. 函数优化
    await optimizationExample();
    
    // 6. 符号求导
    await differentiateExample();
    
    // 7. 定积分
    await integrateExample();
    
    // 8. 数值求根
    await findRootExample();
    
    Logger.info('\n=== 所有后端示例运行完成 ===');
  } catch (error) {
    Logger.error('运行示例时出错', error);
  }
}

