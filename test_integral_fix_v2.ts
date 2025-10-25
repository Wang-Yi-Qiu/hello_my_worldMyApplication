/**
 * 定积分修复验证测试 V2
 * 测试最新的修复方案
 */

import { CalculusEngine, IntegralResult } from './entry/src/main/ets/modules/CalculusEngine';

/**
 * 测试表达式替换逻辑
 */
function testVariableReplacement() {
  console.log('=== 变量替换测试 ===\n');
  
  const testCases = [
    { expr: 'sin(x)', variable: 'x', value: Math.PI, desc: '三角函数中的变量' },
    { expr: 'x^2', variable: 'x', value: 2, desc: '幂运算' },
    { expr: 'x*sin(x)', variable: 'x', value: 1.5, desc: '乘法和函数' },
    { expr: 'exp(x)', variable: 'x', value: 1, desc: '指数函数' },
    { expr: 'x', variable: 'x', value: 3.14, desc: '单独的变量' },
    { expr: 'cos(x)+x', variable: 'x', value: 0, desc: '加法组合' },
    { expr: '2*x', variable: 'x', value: 5, desc: '系数乘法' },
  ];
  
  testCases.forEach((tc, index) => {
    console.log(`测试 ${index + 1}: ${tc.desc}`);
    console.log(`  表达式: ${tc.expr}`);
    console.log(`  变量: ${tc.variable} = ${tc.value}`);
    
    // 模拟 evaluateExpression 的逻辑
    let expr = tc.expr.trim();
    const placeholder = `__VAR_${Math.random().toString(36).substr(2, 9)}__`;
    
    // 替换变量为占位符
    expr = expr.replace(
      new RegExp(`([^a-zA-Z]|^)${tc.variable}([^a-zA-Z]|$)`, 'g'),
      `$1${placeholder}$2`
    );
    
    // 替换占位符为值
    expr = expr.replace(new RegExp(placeholder, 'g'), `(${tc.value})`);
    
    // 处理单独变量的情况
    if (expr === tc.variable) {
      expr = `(${tc.value})`;
    }
    
    console.log(`  替换后: ${expr}`);
    console.log('');
  });
}

/**
 * 测试完整的定积分计算
 */
function testDefiniteIntegral() {
  console.log('\n=== 定积分计算测试 ===\n');
  
  const engine = new CalculusEngine();
  
  const testCases = [
    {
      name: 'sin(x) 在 [0, π]',
      expr: 'sin(x)',
      variable: 'x',
      from: 0,
      to: Math.PI,
      expected: 2.0,
      tolerance: 0.01
    },
    {
      name: 'cos(x) 在 [0, π/2]',
      expr: 'cos(x)',
      variable: 'x',
      from: 0,
      to: Math.PI / 2,
      expected: 1.0,
      tolerance: 0.01
    },
    {
      name: 'x^2 在 [0, 1]',
      expr: 'x^2',
      variable: 'x',
      from: 0,
      to: 1,
      expected: 1/3,
      tolerance: 0.01
    },
    {
      name: 'exp(x) 在 [0, 1]',
      expr: 'exp(x)',
      variable: 'x',
      from: 0,
      to: 1,
      expected: Math.E - 1,
      tolerance: 0.01
    }
  ];
  
  let passCount = 0;
  let failCount = 0;
  
  testCases.forEach((tc, index) => {
    console.log(`测试 ${index + 1}: ${tc.name}`);
    console.log(`  表达式: ∫[${tc.from}, ${tc.to}] ${tc.expr} d${tc.variable}`);
    console.log(`  期望值: ${tc.expected.toFixed(6)}`);
    
    const result: IntegralResult = engine.definiteIntegral(
      tc.expr,
      tc.variable,
      tc.from,
      tc.to
    );
    
    if (result.success && result.value !== undefined) {
      const error = Math.abs(result.value - tc.expected);
      const passed = error < tc.tolerance;
      
      console.log(`  计算值: ${result.value.toFixed(6)}`);
      console.log(`  误差: ${error.toFixed(6)}`);
      console.log(`  状态: ${passed ? '✅ 通过' : '❌ 失败'}`);
      
      if (passed) {
        passCount++;
      } else {
        failCount++;
      }
    } else {
      console.log(`  ❌ 计算失败: ${result.error}`);
      console.log(`  步骤:`, result.steps);
      failCount++;
    }
    
    console.log('');
  });
  
  console.log('=== 测试总结 ===');
  console.log(`通过: ${passCount}/${testCases.length}`);
  console.log(`失败: ${failCount}/${testCases.length}`);
  console.log(`成功率: ${((passCount / testCases.length) * 100).toFixed(1)}%`);
}

// 运行测试
console.log('开始测试...\n');
testVariableReplacement();
testDefiniteIntegral();
console.log('\n测试完成！');

export { testVariableReplacement, testDefiniteIntegral };

