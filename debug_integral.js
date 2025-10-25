/**
 * 调试定积分计算 - JavaScript 版本
 */

function replaceMathFunctions(expr) {
  let result = expr;
  result = result.replace(/\bsin\s*\(/g, 'Math.sin(');
  result = result.replace(/\bcos\s*\(/g, 'Math.cos(');
  result = result.replace(/\btan\s*\(/g, 'Math.tan(');
  result = result.replace(/\bexp\s*\(/g, 'Math.exp(');
  result = result.replace(/\bsqrt\s*\(/g, 'Math.sqrt(');
  result = result.replace(/\babs\s*\(/g, 'Math.abs(');
  result = result.replace(/\bln\s*\(/g, 'Math.log(');
  result = result.replace(/\blog\s*\(/g, 'Math.log10(');
  return result;
}

function evaluateExpression(expression, variable, value) {
  console.log('\n=== 开始计算 ===');
  console.log(`输入: expression="${expression}", variable="${variable}", value=${value}`);
  
  let expr = expression.trim();
  console.log(`步骤1 - 去除空格: "${expr}"`);
  
  // 创建占位符
  const placeholder = '__VAR_' + Math.random().toString(36).substr(2, 9) + '__';
  console.log(`步骤2 - 创建占位符: "${placeholder}"`);
  
  // 替换变量为占位符
  const regex = new RegExp(`([^a-zA-Z]|^)${variable}([^a-zA-Z]|$)`, 'g');
  console.log(`步骤3 - 变量匹配正则: ${regex}`);
  
  expr = expr.replace(regex, `$1${placeholder}$2`);
  console.log(`步骤4 - 替换为占位符后: "${expr}"`);
  
  // 替换占位符为值
  expr = expr.replace(new RegExp(placeholder, 'g'), `(${value})`);
  console.log(`步骤5 - 替换占位符为值后: "${expr}"`);
  
  // 处理表达式就是变量本身的情况
  if (expr === variable) {
    expr = `(${value})`;
    console.log(`步骤6 - 表达式就是变量本身，替换为: "${expr}"`);
  }
  
  // 替换数学函数
  expr = replaceMathFunctions(expr);
  console.log(`步骤7 - 替换数学函数后: "${expr}"`);
  
  // 替换幂运算符
  expr = expr.replace(/\^/g, '**');
  console.log(`步骤8 - 替换幂运算符后: "${expr}"`);
  
  // 安全性检查
  const safePattern = /^[\d\s+\-*\/.()Matha-z,]+$/i;
  console.log(`步骤9 - 安全性检查: ${safePattern.test(expr)}`);
  
  if (!safePattern.test(expr)) {
    console.error(`❌ 表达式不安全: "${expr}"`);
    throw new Error(`表达式包含不安全的字符: ${expr}`);
  }
  
  try {
    console.log(`步骤10 - 准备执行: return ${expr}`);
    const func = new Function('return ' + expr);
    const result = func();
    console.log(`步骤11 - 执行结果: ${result}`);
    
    if (typeof result !== 'number' || isNaN(result)) {
      console.error(`❌ 结果不是有效数字: ${result}`);
      throw new Error('表达式求值结果不是有效数字');
    }
    
    console.log('=== 计算成功 ===\n');
    return result;
  } catch (error) {
    console.error(`❌ 计算失败:`, error.message);
    console.log('=== 计算失败 ===\n');
    throw error;
  }
}

// 测试用例
console.log('========================================');
console.log('定积分计算调试');
console.log('========================================');

// 测试1
console.log('\n【测试1】sin(x) 在 x = π/2');
try {
  const result1 = evaluateExpression('sin(x)', 'x', Math.PI / 2);
  console.log(`✅ 成功: sin(π/2) = ${result1}`);
  console.log(`   期望值: 1.0`);
  console.log(`   误差: ${Math.abs(result1 - 1.0)}`);
} catch (error) {
  console.log(`❌ 失败:`, error.message);
}

// 测试2
console.log('\n【测试2】sin(x) 在 x = 0');
try {
  const result2 = evaluateExpression('sin(x)', 'x', 0);
  console.log(`✅ 成功: sin(0) = ${result2}`);
  console.log(`   期望值: 0.0`);
  console.log(`   误差: ${Math.abs(result2 - 0.0)}`);
} catch (error) {
  console.log(`❌ 失败:`, error.message);
}

// 测试3
console.log('\n【测试3】sin(x) 在 x = π');
try {
  const result3 = evaluateExpression('sin(x)', 'x', Math.PI);
  console.log(`✅ 成功: sin(π) = ${result3}`);
  console.log(`   期望值: 0.0`);
  console.log(`   误差: ${Math.abs(result3 - 0.0)}`);
} catch (error) {
  console.log(`❌ 失败:`, error.message);
}

// 测试4
console.log('\n【测试4】x^2 在 x = 2');
try {
  const result4 = evaluateExpression('x^2', 'x', 2);
  console.log(`✅ 成功: 2^2 = ${result4}`);
  console.log(`   期望值: 4.0`);
  console.log(`   误差: ${Math.abs(result4 - 4.0)}`);
} catch (error) {
  console.log(`❌ 失败:`, error.message);
}

// 测试5
console.log('\n【测试5】cos(x) 在 x = 0');
try {
  const result5 = evaluateExpression('cos(x)', 'x', 0);
  console.log(`✅ 成功: cos(0) = ${result5}`);
  console.log(`   期望值: 1.0`);
  console.log(`   误差: ${Math.abs(result5 - 1.0)}`);
} catch (error) {
  console.log(`❌ 失败:`, error.message);
}

// 测试6 - 模拟定积分中的一个采样点
console.log('\n【测试6】sin(x) 在 x = 1.5707963267948966 (π/2)');
try {
  const result6 = evaluateExpression('sin(x)', 'x', 1.5707963267948966);
  console.log(`✅ 成功: sin(1.5707963267948966) = ${result6}`);
  console.log(`   期望值: 1.0`);
  console.log(`   误差: ${Math.abs(result6 - 1.0)}`);
} catch (error) {
  console.log(`❌ 失败:`, error.message);
}

console.log('\n========================================');
console.log('调试完成');
console.log('========================================');

