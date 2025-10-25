/**
 * 模拟实际场景的测试
 * 测试用户输入 sin(x) 在 [0, π] 的定积分计算
 */

console.log('========================================');
console.log('模拟实际场景测试');
console.log('========================================\n');

// 模拟 Logger
const Logger = {
  info: (msg, ...args) => console.log(`[INFO] ${msg}`, ...args),
  error: (msg, ...args) => console.error(`[ERROR] ${msg}`, ...args)
};

// 替换数学函数
function replaceMathFunctions(expr) {
  let result = expr;
  result = result.replace(/\bsin\s*\(/g, 'Math.sin(');
  result = result.replace(/\bcos\s*\(/g, 'Math.cos(');
  result = result.replace(/\btan\s*\(/g, 'Math.tan(');
  result = result.replace(/\basin\s*\(/g, 'Math.asin(');
  result = result.replace(/\bacos\s*\(/g, 'Math.acos(');
  result = result.replace(/\batan\s*\(/g, 'Math.atan(');
  result = result.replace(/\bsinh\s*\(/g, 'Math.sinh(');
  result = result.replace(/\bcosh\s*\(/g, 'Math.cosh(');
  result = result.replace(/\btanh\s*\(/g, 'Math.tanh(');
  result = result.replace(/\bln\s*\(/g, 'Math.log(');
  result = result.replace(/\blog\s*\(/g, 'Math.log10(');
  result = result.replace(/\bexp\s*\(/g, 'Math.exp(');
  result = result.replace(/\bsqrt\s*\(/g, 'Math.sqrt(');
  result = result.replace(/\babs\s*\(/g, 'Math.abs(');
  result = result.replace(/\bfloor\s*\(/g, 'Math.floor(');
  result = result.replace(/\bceil\s*\(/g, 'Math.ceil(');
  return result;
}

// evaluateExpression 函数
function evaluateExpression(expression, variable, value) {
  // 预处理表达式
  let expr = expression.trim();
  
  // 替换变量为实际值
  const placeholder = `__VAR_${Math.random().toString(36).substr(2, 9)}__`;
  
  // 1. 先将所有独立的变量替换为占位符
  expr = expr.replace(
    new RegExp(`([^a-zA-Z]|^)${variable}([^a-zA-Z]|$)`, 'g'),
    `$1${placeholder}$2`
  );
  
  // 2. 将占位符替换为实际值（带括号）
  expr = expr.replace(new RegExp(placeholder, 'g'), `(${value})`);
  
  // 3. 处理表达式就是变量本身的情况
  if (expr === variable) {
    expr = `(${value})`;
  }
  
  // 替换数学常数
  expr = expr.replace(/\bπ\b/g, Math.PI.toString());
  expr = expr.replace(/\bpi\b/gi, Math.PI.toString());
  expr = expr.replace(/\be\b/g, Math.E.toString());
  
  // 替换数学函数为 Math 对象方法
  expr = replaceMathFunctions(expr);
  
  // 替换幂运算符
  expr = expr.replace(/\^/g, '**');
  
  // 添加调试日志
  Logger.info(`Evaluating expression: ${expr} (original: ${expression}, ${variable}=${value})`);
  
  // 验证表达式安全性（只包含数字、运算符、Math 对象和其方法）
  const safePattern = /^[\d\s+\-*\/.()Matha-z,]+$/i;
  if (!safePattern.test(expr)) {
    Logger.error(`Unsafe expression: ${expr}`);
    throw new Error(`表达式包含不安全的字符: ${expr}`);
  }
  
  try {
    // 使用 Function 构造函数安全地求值
    const func = new Function('return ' + expr);
    const result = func();
    
    if (typeof result !== 'number' || isNaN(result)) {
      Logger.error(`Invalid result: ${result} from expression: ${expr}`);
      throw new Error('表达式求值结果不是有效数字');
    }
    
    Logger.info(`Expression result: ${result}`);
    return result;
  } catch (error) {
    Logger.error(`Expression evaluation failed: ${expr}`, error);
    throw new Error(`无法计算表达式: ${expression} (${error instanceof Error ? error.message : '未知错误'})`);
  }
}

// 辛普森法则数值积分
function numericalIntegral(f, a, b, n = 1000) {
  const h = (b - a) / n;
  let sum = f(a) + f(b);
  
  for (let i = 1; i < n; i++) {
    const x = a + i * h;
    const weight = (i % 2 === 0) ? 2 : 4;
    sum += weight * f(x);
  }
  
  return (h / 3) * sum;
}

// definiteIntegral 函数
function definiteIntegral(expression, variable, from, to) {
  try {
    Logger.info(`Computing integral of ${expression} from ${from} to ${to}`);
    
    const steps = [];
    const fromStr = from === 0 ? '0' : (from === Math.PI ? 'π' : from.toString());
    const toStr = to === Math.PI ? 'π' : to.toString();
    steps.push(`计算定积分: ∫[${fromStr}, ${toStr}] ${expression} d${variable}`);
    steps.push(`被积函数: f(${variable}) = ${expression}`);
    steps.push(`积分区间: [${fromStr}, ${toStr}]`);
    
    // 创建函数 - 使用安全的表达式求值
    const f = (x) => {
      try {
        return evaluateExpression(expression, variable, x);
      } catch (error) {
        Logger.error(`Failed to evaluate expression at x=${x}`, error);
        throw new Error('表达式求值失败');
      }
    };
    
    // 验证函数在区间端点是否有效
    console.log('\n--- 验证区间端点 ---');
    try {
      console.log(`测试 from=${from}:`);
      const testFrom = f(from);
      console.log(`  f(${from}) = ${testFrom}`);
      
      console.log(`测试 to=${to}:`);
      const testTo = f(to);
      console.log(`  f(${to}) = ${testTo}`);
      
      if (!isFinite(testFrom) || !isFinite(testTo)) {
        steps.push(`警告: 函数在区间端点存在奇点`);
        console.log('  警告: 存在奇点');
      } else {
        console.log('  ✅ 端点验证通过');
      }
    } catch (error) {
      console.log(`  ❌ 端点验证失败: ${error.message}`);
      return {
        success: false,
        error: '函数在积分区间内无法求值，请检查表达式',
        steps
      };
    }
    
    // 使用辛普森法则进行数值积分
    console.log('\n--- 开始数值积分 ---');
    const value = numericalIntegral(f, from, to);
    console.log(`积分结果: ${value}`);
    
    steps.push(`使用辛普森法则进行数值积分（1000个分段）`);
    steps.push(`积分结果: ≈ ${value.toFixed(6)}`);
    
    return {
      success: true,
      value,
      steps
    };
  } catch (error) {
    Logger.error('Integral calculation error', error);
    return {
      success: false,
      error: '积分计算失败: ' + (error instanceof Error ? error.message : '未知错误')
    };
  }
}

// 测试：模拟用户输入 sin(x) 在 [0, π]
console.log('【测试】计算 ∫[0, π] sin(x) dx\n');
const result = definiteIntegral('sin(x)', 'x', 0, Math.PI);

console.log('\n--- 最终结果 ---');
if (result.success) {
  console.log('✅ 计算成功!');
  console.log(`结果: ${result.value}`);
  console.log(`期望值: 2.0`);
  console.log(`误差: ${Math.abs(result.value - 2.0)}`);
  console.log('\n步骤:');
  result.steps.forEach((step, i) => console.log(`  ${i + 1}. ${step}`));
} else {
  console.log('❌ 计算失败!');
  console.log(`错误: ${result.error}`);
  if (result.steps) {
    console.log('\n步骤:');
    result.steps.forEach((step, i) => console.log(`  ${i + 1}. ${step}`));
  }
}

console.log('\n========================================');
console.log('测试完成');
console.log('========================================');

