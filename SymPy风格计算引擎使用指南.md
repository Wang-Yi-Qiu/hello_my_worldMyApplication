# SymPy 风格计算引擎使用指南

## 概述

本项目已集成基于 **math.js** 的 SymPy 风格计算引擎，提供强大的符号计算和数值计算能力。

## 主要改进

### 1. 新增 SymPyLikeEngine
- 位置：`entry/src/main/ets/core/SymPyLikeEngine.ts`
- 功能：
  - 表达式求值
  - 符号求导
  - 符号积分和数值积分
  - 方程求解
  - 表达式化简
  - 展开和因式分解

### 2. 升级 UnifiedComputeEngine
- 集成 SymPyLikeEngine
- 所有核心计算功能均使用 math.js
- 保持原有 API 接口不变

### 3. 改进 ExpressionEngine
- 优先使用 math.js 进行计算
- 提供安全的降级方案
- 保持向后兼容

## 安装依赖

```bash
ohpm install
```

这会自动安装 `mathjs` 库。

## 使用示例

### 基础计算

```typescript
import { getMathAPI } from './core/UnifiedMathAPI';

const api = getMathAPI();

// 简单计算
const result1 = await api.compute('2 + 3 * 4');
console.log(result1.numeric); // 14

// 三角函数
const result2 = await api.compute('sin(pi/2)');
console.log(result2.numeric); // 1

// 指数函数
const result3 = await api.compute('exp(1)');
console.log(result3.numeric); // 2.718...
```

### 求导

```typescript
// 求 x^2 的导数
const diffResult = await api.differentiate('x^2', 'x');
console.log(diffResult.latex); // "2*x"

// 求 sin(x) 的导数
const sinDiff = await api.differentiate('sin(x)', 'x');
console.log(sinDiff.latex); // "cos(x)"
```

### 积分

```typescript
// 不定积分
const integral = await api.integrate('x^2', 'x');
console.log(integral.latex); // "x^3/3"

// 定积分（数值方法）
const definiteIntegral = await api.integrate('sin(x)', 'x', 0, Math.PI);
console.log(definiteIntegral.numeric); // 2
```

### 简化表达式

```typescript
// 化简
const simplified = await api.simplify('x + x');
console.log(simplified.latex); // "2*x"
```

### 展开表达式

```typescript
// 展开
const expanded = await api.expand('(x+1)(x+2)');
console.log(expanded.latex); // "x^2 + 3*x + 2"
```

### 求解方程

```typescript
// 求解方程
const solutions = await api.solve('x^2 - 4 = 0', 'x');
console.log(solutions.latex); // 显示解的集合
```

## API 变化

### 重要的变化：async/await

由于集成了异步计算的 math.js，以下方法现在是异步的：

```typescript
// ❌ 旧的方式（不再支持）
const result = api.compute('2+3'); 

// ✅ 新的方式
const result = await api.compute('2+3');
```

受影响的 API：
- `api.compute()`
- `api.differentiate()` 和 `api.diff()`
- `api.integrate()` 和 `api.int()`

未受影响的 API（仍为同步）：
- `api.simplify()`
- `api.expand()`
- `api.factor()`
- `api.solve()`
- 所有变量管理方法

## 优势

### 1. 更高的计算精度
- math.js 提供高精度计算
- 支持任意精度算术
- 支持复数计算

### 2. 更强的符号计算能力
- 符号求导
- 符号积分
- 表达式化简
- 因式分解

### 3. 更好的错误处理
- 详细的错误信息
- 安全的表达式求值
- 优雅的降级机制

### 4. 更丰富的数学函数
- 支持所有标准数学函数
- 支持自定义函数
- 支持矩阵和向量运算

## 降级方案

如果 math.js 不可用（例如在网络受限的环境），系统会自动使用 fallback 实现：

1. 自定义表达式解析器
2. 基本的数学函数实现
3. 安全的 JavaScript Function 求值

## 性能考虑

- math.js 会按需加载，不会影响应用启动速度
- 首次计算可能需要加载库（约 1-2 秒）
- 后续计算非常快速

## 故障排除

### 问题：计算结果不正确

1. 检查是否正确使用 `await`
2. 检查表达式语法是否正确
3. 查看日志中的错误信息

### 问题：math.js 加载失败

1. 确保已运行 `ohpm install`
2. 检查网络连接（如果需要下载）
3. 系统会自动降级到 fallback 实现

### 问题：异步调用错误

确保在异步函数中使用：

```typescript
// 正确
async function calculate() {
  const result = await api.compute('2+3');
}

// 错误
function calculate() {
  const result = api.compute('2+3'); // 返回 Promise 对象，不是结果
}
```

## 技术实现

### 架构

```
UnifiedMathAPI (门面)
    ├── UnifiedComputeEngine (统一计算引擎)
    │       └── SymPyLikeEngine (SymPy 风格引擎)
    │               └── math.js (底层计算库)
    ├── SymbolicEngine (符号计算)
    └── AlgebraEngine (代数引擎)
```

### 关键文件

- `entry/src/main/ets/core/SymPyLikeEngine.ts` - 新的 SymPy 风格引擎
- `entry/src/main/ets/core/UnifiedComputeEngine.ts` - 统一计算引擎（已更新）
- `entry/src/main/ets/core/UnifiedMathAPI.ts` - API 入口（已更新）
- `entry/src/main/ets/modules/ExpressionEngine.ts` - 表达式引擎（已更新）
- `oh-package.json5` - 依赖配置（已添加 mathjs）

## 迁移指南

如果你有现有代码使用旧 API：

### 1. 识别受影响的代码

查找以下方法调用：
- `api.compute()`
- `api.differentiate()` 或 `api.diff()`
- `api.integrate()` 或 `api.int()`

### 2. 添加 async/await

```typescript
// 旧代码
function handleCalculate() {
  const result = api.compute('2+3');
  console.log(result.numeric);
}

// 新代码
async function handleCalculate() {
  const result = await api.compute('2+3');
  console.log(result.numeric);
}
```

### 3. 更新事件处理

在 HarmonyOS 的 ArkUI 组件中：

```typescript
// 旧代码
onClick() {
  const result = api.compute(this.expression);
  this.result = result.numeric;
}

// 新代码
async onClick() {
  const result = await api.compute(this.expression);
  this.result = result.numeric;
}
```

## 下一步

1. 运行 `ohpm install` 安装依赖
2. 运行项目并测试计算功能
3. 根据需要调整 UI 以支持异步操作
4. 继续使用和完善

## 参考

- [math.js 文档](https://mathjs.org/docs/)
- [SymPy 文档](https://www.sympy.org/)
- [HarmonyOS 开发指南](https://developer.harmonyos.com/)

