/**
 * 调试定积分计算
 * 模拟实际的计算过程并输出详细日志
 */

// 模拟 Logger
const Logger = {
  info: (msg: string, ...args: any[]) => console.log(`[INFO] ${msg}`, ...args),
  error: (msg: string, ...args: any[]) => console.error(`[ERROR] ${msg}`, ...args),
  debug: (msg: string, ...args: any[]) => console.log(`[DEBUG] ${msg}`, ...args)
};

/**
 * 模拟 evaluateExpression 函数
 */
function evaluateExpression(expression: string, variable: string, value: number): number {
  console.log('\n--- evaluateExpression 开始 ---');
  console.log(`输入: expression="${expression}", variable="${variable}", value=${value}`);
  
  // 预处理表达式
  let expr = expression.trim();
  console.log(`步骤1 - 去除空格: "${expr}"`);
  
  // 替换变量为实际值
  // 创建一个临时占位符，避免重复替换
  const placeholder = `__VAR_${Math.random().toString(36).substr(2, 9)}__`;
  console.log(`步骤2 - 创建占位符: "${placeholder}"`);
  
  // 1. 先将所有独立的变量替换为占位符
  const regex1 = new RegExp(`([^a-zA-Z]|^)${variable}([^a-zA-Z]|$)`, 'g');
  console.log(`步骤3 - 变量匹配正则: ${regex1}`);
  
  expr = expr.replace(regex1, `$1${placeholder}$2`);
  console.log(`步骤4 - 替换为占位符后: "${expr}"`);
  
  // 2. 将占位符替换为实际值（带括号）
  expr = expr.replace(new RegExp(placeholder, 'g'), `(${value})`);
  console.log(`步骤5 - 替换占位符为值后: "${expr}"`);
  
  // 3. 处理表达式就是变量本身的情况
  if (expr === variable) {
    expr = `(${value})`;
    console.log(`步骤6 - 表达式就是变量本身，替换为: "${expr}"`);
  }
  
  // 替换数学常数
  expr = expr.replace(/\bπ\b/g, Math.PI.toString());
  expr = expr.replace(/\bpi\b/gi, Math.PI.toString());
  expr = expr.replace(/\be\b/g, Math.E.toString());
  console.log(`步骤7 - 替换数学常数后: "${expr}"`);
  
  // 替换数学函数为 Math 对象方法
  expr = replaceMathFunctions(expr);
  console.log(`步骤8 - 替换数学函数后: "${expr}"`);
  
  // 替换幂运算符
  expr = expr.replace(/\^/g, '**');
  console.log(`步骤9 - 替换幂运算符后: "${expr}"`);
  
  // 添加调试日志
  Logger.info(`Evaluating expression: ${expr} (original: ${expression}, ${variable}=${value})`);
  
  // 验证表达式安全性
  const safePattern = /^[\d\s+\-*\/.()Matha-z,]+$/i;
  console.log(`步骤10 - 安全性检查正则: ${safePattern}`);
  console.log(`步骤11 - 安全性检查结果: ${safePattern.test(expr)}`);
  
  if (!safePattern.test(expr)) {
    Logger.error(`Unsafe expression: ${expr}`);
    throw new Error(`表达式包含不安全的字符: ${expr}`);
  }
  
  try {
    // 使用 Function 构造函数安全地求值
    console.log(`步骤12 - 准备执行: return ${expr}`);
    const func = new Function('return ' + expr);
    const result = func();
    console.log(`步骤13 - 执行结果: ${result}`);
    
    if (typeof result !== 'number' || isNaN(result)) {
      Logger.error(`Invalid result: ${result} from expression: ${expr}`);
      throw new Error('表达式求值结果不是有效数字');
    }
    
    Logger.info(`Expression result: ${result}`);
    console.log('--- evaluateExpression 成功 ---\n');
    return result;
  } catch (error) {
    Logger.error(`Expression evaluation failed: ${expr}`, error);
    console.log('--- evaluateExpression 失败 ---\n');
    throw new Error(`无法计算表达式: ${expression} (${error instanceof Error ? error.message : '未知错误'})`);
  }
}

/**
 * 替换数学函数为 Math 对象方法
 */
function replaceMathFunctions(expr: string): string {
  let result = expr;
  
  console.log('  [replaceMathFunctions] 开始替换数学函数');
  
  // 三角函数
  result = result.replace(/\bsin\s*\(/g, 'Math.sin(');
  result = result.replace(/\bcos\s*\(/g, 'Math.cos(');
  result = result.replace(/\btan\s*\(/g, 'Math.tan(');
  result = result.replace(/\basin\s*\(/g, 'Math.asin(');
  result = result.replace(/\bacos\s*\(/g, 'Math.acos(');
  result = result.replace(/\batan\s*\(/g, 'Math.atan(');
  
  // 双曲函数
  result = result.replace(/\bsinh\s*\(/g, 'Math.sinh(');
  result = result.replace(/\bcosh\s*\(/g, 'Math.cosh(');
  result = result.replace(/\btanh\s*\(/g, 'Math.tanh(');
  
  // 对数和指数
  result = result.replace(/\bln\s*\(/g, 'Math.log(');
  result = result.replace(/\blog\s*\(/g, 'Math.log10(');
  result = result.replace(/\bexp\s*\(/g, 'Math.exp(');
  
  // 其他函数
  result = result.replace(/\bsqrt\s*\(/g, 'Math.sqrt(');
  result = result.replace(/\babs\s*\(/g, 'Math.abs(');
  result = result.replace(/\bfloor\s*\(/g, 'Math.floor(');
  result = result.replace(/\bceil\s*\(/g, 'Math.ceil(');
  
  console.log(`  [replaceMathFunctions] 替换后: "${result}"`);
  
  return result;
}

/**
 * 测试用例
 */
console.log('========================================');
console.log('定积分计算调试');
console.log('========================================');

// 测试用例1: sin(x) 在 x = π/2
console.log('\n【测试1】sin(x) 在 x = π/2');
try {
  const result1 = evaluateExpression('sin(x)', 'x', Math.PI / 2);
  console.log(`✅ 成功: sin(π/2) = ${result1}`);
  console.log(`   期望值: 1.0`);
  console.log(`   误差: ${Math.abs(result1 - 1.0)}`);
} catch (error) {
  console.log(`❌ 失败:`, error);
}

// 测试用例2: sin(x) 在 x = 0
console.log('\n【测试2】sin(x) 在 x = 0');
try {
  const result2 = evaluateExpression('sin(x)', 'x', 0);
  console.log(`✅ 成功: sin(0) = ${result2}`);
  console.log(`   期望值: 0.0`);
  console.log(`   误差: ${Math.abs(result2 - 0.0)}`);
} catch (error) {
  console.log(`❌ 失败:`, error);
}

// 测试用例3: sin(x) 在 x = π
console.log('\n【测试3】sin(x) 在 x = π');
try {
  const result3 = evaluateExpression('sin(x)', 'x', Math.PI);
  console.log(`✅ 成功: sin(π) = ${result3}`);
  console.log(`   期望值: 0.0`);
  console.log(`   误差: ${Math.abs(result3 - 0.0)}`);
} catch (error) {
  console.log(`❌ 失败:`, error);
}

// 测试用例4: x^2 在 x = 2
console.log('\n【测试4】x^2 在 x = 2');
try {
  const result4 = evaluateExpression('x^2', 'x', 2);
  console.log(`✅ 成功: 2^2 = ${result4}`);
  console.log(`   期望值: 4.0`);
  console.log(`   误差: ${Math.abs(result4 - 4.0)}`);
} catch (error) {
  console.log(`❌ 失败:`, error);
}

// 测试用例5: cos(x) 在 x = 0
console.log('\n【测试5】cos(x) 在 x = 0');
try {
  const result5 = evaluateExpression('cos(x)', 'x', 0);
  console.log(`✅ 成功: cos(0) = ${result5}`);
  console.log(`   期望值: 1.0`);
  console.log(`   误差: ${Math.abs(result5 - 1.0)}`);
} catch (error) {
  console.log(`❌ 失败:`, error);
}

console.log('\n========================================');
console.log('调试完成');
console.log('========================================');

