/**
 * 定积分修复验证测试
 * 测试 sin(x) 在 [0, π] 的积分计算
 */

import { CalculusEngine, IntegralResult } from './entry/src/main/ets/modules/CalculusEngine';

/**
 * 测试定积分计算
 */
function testDefiniteIntegral() {
  console.log('=== 定积分修复验证测试 ===\n');
  
  const engine = new CalculusEngine();
  
  // 测试用例 1: sin(x) 在 [0, π]
  console.log('测试 1: ∫[0, π] sin(x) dx');
  console.log('理论值: 2.0');
  const test1: IntegralResult = engine.definiteIntegral('sin(x)', 'x', 0, Math.PI);
  console.log('计算结果:', test1);
  if (test1.success && test1.value) {
    console.log(`数值: ${test1.value.toFixed(6)}`);
    console.log(`误差: ${Math.abs(test1.value - 2.0).toFixed(6)}`);
    console.log(test1.value >= 1.99 && test1.value <= 2.01 ? '✅ 通过' : '❌ 失败');
  } else {
    console.log('❌ 计算失败:', test1.error);
  }
  console.log('步骤:', test1.steps);
  console.log('\n---\n');
  
  // 测试用例 2: cos(x) 在 [0, π/2]
  console.log('测试 2: ∫[0, π/2] cos(x) dx');
  console.log('理论值: 1.0');
  const test2: IntegralResult = engine.definiteIntegral('cos(x)', 'x', 0, Math.PI / 2);
  console.log('计算结果:', test2);
  if (test2.success && test2.value) {
    console.log(`数值: ${test2.value.toFixed(6)}`);
    console.log(`误差: ${Math.abs(test2.value - 1.0).toFixed(6)}`);
    console.log(test2.value >= 0.99 && test2.value <= 1.01 ? '✅ 通过' : '❌ 失败');
  } else {
    console.log('❌ 计算失败:', test2.error);
  }
  console.log('\n---\n');
  
  // 测试用例 3: x^2 在 [0, 1]
  console.log('测试 3: ∫[0, 1] x^2 dx');
  console.log('理论值: 1/3 ≈ 0.333333');
  const test3: IntegralResult = engine.definiteIntegral('x^2', 'x', 0, 1);
  console.log('计算结果:', test3);
  if (test3.success && test3.value) {
    console.log(`数值: ${test3.value.toFixed(6)}`);
    console.log(`误差: ${Math.abs(test3.value - 1/3).toFixed(6)}`);
    console.log(test3.value >= 0.33 && test3.value <= 0.34 ? '✅ 通过' : '❌ 失败');
  } else {
    console.log('❌ 计算失败:', test3.error);
  }
  console.log('\n---\n');
  
  // 测试用例 4: exp(x) 在 [0, 1]
  console.log('测试 4: ∫[0, 1] exp(x) dx');
  console.log('理论值: e - 1 ≈ 1.718282');
  const test4: IntegralResult = engine.definiteIntegral('exp(x)', 'x', 0, 1);
  console.log('计算结果:', test4);
  if (test4.success && test4.value) {
    const expected = Math.E - 1;
    console.log(`数值: ${test4.value.toFixed(6)}`);
    console.log(`误差: ${Math.abs(test4.value - expected).toFixed(6)}`);
    console.log(Math.abs(test4.value - expected) < 0.01 ? '✅ 通过' : '❌ 失败');
  } else {
    console.log('❌ 计算失败:', test4.error);
  }
  console.log('\n---\n');
  
  // 测试用例 5: x*sin(x) 在 [0, π]
  console.log('测试 5: ∫[0, π] x*sin(x) dx');
  console.log('理论值: π ≈ 3.141593');
  const test5: IntegralResult = engine.definiteIntegral('x*sin(x)', 'x', 0, Math.PI);
  console.log('计算结果:', test5);
  if (test5.success && test5.value) {
    console.log(`数值: ${test5.value.toFixed(6)}`);
    console.log(`误差: ${Math.abs(test5.value - Math.PI).toFixed(6)}`);
    console.log(Math.abs(test5.value - Math.PI) < 0.01 ? '✅ 通过' : '❌ 失败');
  } else {
    console.log('❌ 计算失败:', test5.error);
  }
  console.log('\n---\n');
  
  console.log('=== 测试完成 ===');
}

/**
 * 测试表达式求值（内部方法测试）
 */
function testExpressionEvaluation() {
  console.log('\n=== 表达式求值测试 ===\n');
  
  const engine = new CalculusEngine();
  
  // 由于 evaluateExpression 是私有方法，我们通过定积分来间接测试
  const testCases = [
    { expr: 'sin(x)', x: 0, expected: 0 },
    { expr: 'sin(x)', x: Math.PI / 2, expected: 1 },
    { expr: 'cos(x)', x: 0, expected: 1 },
    { expr: 'cos(x)', x: Math.PI, expected: -1 },
    { expr: 'x^2', x: 2, expected: 4 },
    { expr: 'x^2', x: 3, expected: 9 },
    { expr: 'exp(x)', x: 0, expected: 1 },
    { expr: 'exp(x)', x: 1, expected: Math.E },
  ];
  
  console.log('通过单点积分测试表达式求值:');
  testCases.forEach((tc, index) => {
    // 使用很小的区间来测试单点值
    const result = engine.definiteIntegral(tc.expr, 'x', tc.x, tc.x + 0.0001);
    if (result.success) {
      // 积分值 ≈ f(x) * 0.0001
      const fValue = result.value! / 0.0001;
      const error = Math.abs(fValue - tc.expected);
      console.log(`${index + 1}. ${tc.expr} at x=${tc.x}: ${fValue.toFixed(6)} (期望: ${tc.expected.toFixed(6)}, 误差: ${error.toFixed(6)}) ${error < 0.01 ? '✅' : '❌'}`);
    } else {
      console.log(`${index + 1}. ${tc.expr} at x=${tc.x}: ❌ 失败 - ${result.error}`);
    }
  });
  
  console.log('\n=== 测试完成 ===');
}

// 运行测试
testDefiniteIntegral();
testExpressionEvaluation();

export { testDefiniteIntegral, testExpressionEvaluation };

