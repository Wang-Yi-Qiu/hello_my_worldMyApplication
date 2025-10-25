# SageMath 集成增强方案

## 📋 概述

本文档详细说明如何将 SageMath 强大的数学计算能力集成到科学计算器中，实现符号计算、方程求解、微积分等高级功能。

## 🎯 集成目标

### 1. 符号计算
- 表达式简化
- 因式分解
- 展开表达式
- 符号积分
- 符号微分

### 2. 方程求解
- 一元方程
- 多元方程组
- 微分方程
- 不等式求解

### 3. 微积分
- 极限计算
- 导数计算
- 不定积分
- 定积分
- 泰勒展开

### 4. 矩阵运算
- 矩阵加减乘
- 行列式
- 特征值/特征向量
- 矩阵分解

## 🏗️ 架构设计

### 1. 三层架构

```
┌─────────────────────────────────────┐
│        UI Layer (ArkTS)             │
│  CalculatorPage / AdvancedMathPage  │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│     Service Layer (TypeScript)      │
│      SageMathService.ts             │
│      - 请求封装                      │
│      - 结果解析                      │
│      - 错误处理                      │
│      - 缓存管理                      │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│    Backend Layer (Python/SageMath)  │
│      SageMath Server                │
│      - 接收请求                      │
│      - 执行计算                      │
│      - 返回结果                      │
└─────────────────────────────────────┘
```

### 2. 通信协议

#### 请求格式
```json
{
  "type": "compute",
  "operation": "integrate",
  "params": {
    "expression": "x^2",
    "variable": "x",
    "from": 0,
    "to": 1
  },
  "options": {
    "timeout": 30000,
    "precision": 10
  }
}
```

#### 响应格式
```json
{
  "success": true,
  "result": "1/3",
  "numerical_value": 0.3333333333,
  "steps": [
    "∫ x² dx",
    "= x³/3",
    "= [x³/3]₀¹",
    "= 1/3 - 0",
    "= 1/3"
  ],
  "latex": "\\frac{1}{3}",
  "computation_time": 0.05
}
```

## 💻 实现方案

### 方案 A：SageMathCell 公共服务（推荐用于开发）

#### 优点
- ✅ 无需搭建服务器
- ✅ 开箱即用
- ✅ 免费使用
- ✅ 快速原型开发

#### 缺点
- ❌ 依赖网络连接
- ❌ 有请求频率限制
- ❌ 不适合生产环境
- ❌ 数据隐私问题

#### 实现代码
```typescript
// 已实现在 SageMathService.ts
async executeOnSageMathCell(request: SageMathRequest): Promise<SageMathResponse> {
  const httpRequest = http.createHttp();
  
  const response = await httpRequest.request(
    'https://sagecell.sagemath.org/service',
    {
      method: http.RequestMethod.POST,
      header: { 'Content-Type': 'application/x-www-form-urlencoded' },
      extraData: `code=${encodeURIComponent(request.code)}`,
      expectDataType: http.HttpDataType.STRING,
      connectTimeout: 30000,
      readTimeout: 30000
    }
  );
  
  // 解析响应...
}
```

### 方案 B：自建 SageMath 服务器（推荐用于生产）

#### 优点
- ✅ 完全控制
- ✅ 无请求限制
- ✅ 更快的响应速度
- ✅ 数据隐私保护
- ✅ 可自定义功能

#### 缺点
- ❌ 需要服务器资源
- ❌ 需要维护
- ❌ 初期成本较高

#### 服务器实现

##### 1. 创建 Flask API 服务器

```python
# sagemath_server.py
from flask import Flask, request, jsonify
from sage.all import *
import sys
from io import StringIO
import traceback
import time

app = Flask(__name__)

@app.route('/compute', methods=['POST'])
def compute():
    """通用计算接口"""
    try:
        data = request.json
        operation = data.get('operation')
        params = data.get('params', {})
        options = data.get('options', {})
        
        start_time = time.time()
        
        # 根据操作类型调用相应函数
        if operation == 'integrate':
            result = compute_integral(params)
        elif operation == 'differentiate':
            result = compute_derivative(params)
        elif operation == 'solve':
            result = solve_equation(params)
        elif operation == 'limit':
            result = compute_limit(params)
        elif operation == 'simplify':
            result = simplify_expression(params)
        elif operation == 'factor':
            result = factor_expression(params)
        elif operation == 'expand':
            result = expand_expression(params)
        elif operation == 'taylor':
            result = taylor_expansion(params)
        else:
            return jsonify({
                'success': False,
                'error': f'Unknown operation: {operation}'
            }), 400
        
        computation_time = time.time() - start_time
        
        return jsonify({
            'success': True,
            'result': str(result['result']),
            'numerical_value': result.get('numerical_value'),
            'steps': result.get('steps', []),
            'latex': result.get('latex'),
            'computation_time': computation_time
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e),
            'traceback': traceback.format_exc()
        }), 500

def compute_integral(params):
    """计算积分"""
    expression = params['expression']
    variable = params['variable']
    
    # 创建符号变量
    var(variable)
    
    # 解析表达式
    expr = sage_eval(expression, locals={variable: var(variable)})
    
    if 'from' in params and 'to' in params:
        # 定积分
        from_val = params['from']
        to_val = params['to']
        
        result = integrate(expr, (var(variable), from_val, to_val))
        numerical = N(result)
        
        return {
            'result': result,
            'numerical_value': float(numerical),
            'steps': [
                f"∫[{from_val}, {to_val}] {expression} d{variable}",
                f"= {result}",
                f"≈ {numerical}"
            ],
            'latex': latex(result)
        }
    else:
        # 不定积分
        result = integrate(expr, var(variable))
        
        return {
            'result': result,
            'steps': [
                f"∫ {expression} d{variable}",
                f"= {result} + C"
            ],
            'latex': latex(result)
        }

def compute_derivative(params):
    """计算导数"""
    expression = params['expression']
    variable = params['variable']
    order = params.get('order', 1)
    
    var(variable)
    expr = sage_eval(expression, locals={variable: var(variable)})
    
    result = diff(expr, var(variable), order)
    
    return {
        'result': result,
        'steps': [
            f"d^{order}/d{variable}^{order} ({expression})",
            f"= {result}"
        ],
        'latex': latex(result)
    }

def solve_equation(params):
    """求解方程"""
    equation = params['equation']
    variable = params['variable']
    
    var(variable)
    
    # 解析方程（支持 = 或 ==）
    if '==' in equation:
        lhs, rhs = equation.split('==')
    elif '=' in equation:
        lhs, rhs = equation.split('=')
    else:
        lhs = equation
        rhs = '0'
    
    lhs_expr = sage_eval(lhs.strip(), locals={variable: var(variable)})
    rhs_expr = sage_eval(rhs.strip(), locals={variable: var(variable)})
    
    # 求解
    solutions = solve(lhs_expr == rhs_expr, var(variable))
    
    return {
        'result': solutions,
        'steps': [
            f"求解方程: {lhs} = {rhs}",
            f"解: {', '.join(str(sol) for sol in solutions)}"
        ],
        'latex': latex(solutions)
    }

def compute_limit(params):
    """计算极限"""
    expression = params['expression']
    variable = params['variable']
    approach = params['approach']
    direction = params.get('direction')  # 'plus', 'minus', or None
    
    var(variable)
    expr = sage_eval(expression, locals={variable: var(variable)})
    
    # 处理无穷大
    if approach == 'infinity':
        approach_val = oo
    elif approach == '-infinity':
        approach_val = -oo
    else:
        approach_val = sage_eval(approach)
    
    # 计算极限
    if direction == 'plus':
        result = limit(expr, var(variable)==approach_val, dir='+')
    elif direction == 'minus':
        result = limit(expr, var(variable)==approach_val, dir='-')
    else:
        result = limit(expr, var(variable)==approach_val)
    
    return {
        'result': result,
        'steps': [
            f"lim({variable}→{approach}) {expression}",
            f"= {result}"
        ],
        'latex': latex(result)
    }

def simplify_expression(params):
    """简化表达式"""
    expression = params['expression']
    
    # 解析表达式
    expr = sage_eval(expression)
    result = simplify(expr)
    
    return {
        'result': result,
        'steps': [
            f"原式: {expression}",
            f"简化: {result}"
        ],
        'latex': latex(result)
    }

def factor_expression(params):
    """因式分解"""
    expression = params['expression']
    
    expr = sage_eval(expression)
    result = factor(expr)
    
    return {
        'result': result,
        'steps': [
            f"原式: {expression}",
            f"因式分解: {result}"
        ],
        'latex': latex(result)
    }

def expand_expression(params):
    """展开表达式"""
    expression = params['expression']
    
    expr = sage_eval(expression)
    result = expand(expr)
    
    return {
        'result': result,
        'steps': [
            f"原式: {expression}",
            f"展开: {result}"
        ],
        'latex': latex(result)
    }

def taylor_expansion(params):
    """泰勒展开"""
    expression = params['expression']
    variable = params['variable']
    center = params.get('center', 0)
    order = params.get('order', 5)
    
    var(variable)
    expr = sage_eval(expression, locals={variable: var(variable)})
    
    result = taylor(expr, var(variable), center, order)
    
    return {
        'result': result,
        'steps': [
            f"{expression} 在 {variable}={center} 处的 {order} 阶泰勒展开",
            f"= {result}"
        ],
        'latex': latex(result)
    }

@app.route('/health', methods=['GET'])
def health_check():
    """健康检查"""
    return jsonify({'status': 'ok', 'sage_version': version()})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
```

##### 2. Docker 部署

```dockerfile
# Dockerfile
FROM sagemath/sagemath:latest

USER root

# 安装 Flask
RUN sage -pip install flask flask-cors

# 复制服务器代码
COPY sagemath_server.py /home/sage/

# 暴露端口
EXPOSE 5000

# 设置工作目录
WORKDIR /home/sage

# 运行服务器
CMD ["sage", "-python", "sagemath_server.py"]
```

```bash
# 构建镜像
docker build -t sagemath-api .

# 运行容器
docker run -d -p 5000:5000 --name sagemath-server sagemath-api

# 查看日志
docker logs -f sagemath-server
```

##### 3. Docker Compose 部署

```yaml
# docker-compose.yml
version: '3.8'

services:
  sagemath:
    build: .
    container_name: sagemath-server
    ports:
      - "5000:5000"
    environment:
      - FLASK_ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    volumes:
      - ./logs:/home/sage/logs
```

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 查看日志
docker-compose logs -f
```

## 📱 客户端集成

### 1. 增强 SageMathService

```typescript
// entry/src/main/ets/services/SageMathService.ts

/**
 * 通用计算接口
 */
async compute(operation: string, params: Record<string, any>, options?: Record<string, any>): Promise<SageMathResponse> {
  try {
    const httpRequest = http.createHttp();
    
    const requestBody = {
      operation,
      params,
      options: options || {}
    };
    
    const response = await httpRequest.request(
      `${this.customServerUrl || this.SAGEMATH_CELL_URL}/compute`,
      {
        method: http.RequestMethod.POST,
        header: { 'Content-Type': 'application/json' },
        extraData: JSON.stringify(requestBody),
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 30000,
        readTimeout: 30000
      }
    );
    
    httpRequest.destroy();
    
    if (response.responseCode === 200) {
      const data = JSON.parse(response.result as string);
      return {
        success: data.success,
        result: data.result,
        numericalValue: data.numerical_value,
        steps: data.steps,
        latex: data.latex,
        computationTime: data.computation_time
      };
    } else {
      return {
        success: false,
        error: `HTTP ${response.responseCode}`
      };
    }
  } catch (error) {
    Logger.error('SageMath compute error', error);
    return {
      success: false,
      error: '计算失败'
    };
  }
}

/**
 * 简化表达式
 */
async simplifyExpression(expression: string): Promise<SageMathResponse> {
  return await this.compute('simplify', { expression });
}

/**
 * 因式分解
 */
async factorExpression(expression: string): Promise<SageMathResponse> {
  return await this.compute('factor', { expression });
}

/**
 * 展开表达式
 */
async expandExpression(expression: string): Promise<SageMathResponse> {
  return await this.compute('expand', { expression });
}
```

### 2. 在 CalculatorPage 中集成

```typescript
// 添加 SageMath 按钮
@Builder buildSageMathButtons() {
  Row() {
    Button('简化')
      .onClick(async () => {
        if (!this.expression) return;
        
        const result = await sageMathService.simplifyExpression(this.expression);
        if (result.success) {
          this.result = result.result || '';
          promptAction.showToast({ message: '已简化' });
        }
      })
    
    Button('因式分解')
      .onClick(async () => {
        if (!this.expression) return;
        
        const result = await sageMathService.factorExpression(this.expression);
        if (result.success) {
          this.result = result.result || '';
          promptAction.showToast({ message: '已分解' });
        }
      })
    
    Button('展开')
      .onClick(async () => {
        if (!this.expression) return;
        
        const result = await sageMathService.expandExpression(this.expression);
        if (result.success) {
          this.result = result.result || '';
          promptAction.showToast({ message: '已展开' });
        }
      })
  }
}
```

## 🔧 优化建议

### 1. 结果缓存
```typescript
class SageMathCache {
  private cache: Map<string, SageMathResponse> = new Map();
  private maxSize: number = 100;
  
  get(key: string): SageMathResponse | null {
    return this.cache.get(key) || null;
  }
  
  set(key: string, value: SageMathResponse): void {
    if (this.cache.size >= this.maxSize) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
    this.cache.set(key, value);
  }
  
  generateKey(operation: string, params: Record<string, any>): string {
    return `${operation}:${JSON.stringify(params)}`;
  }
}
```

### 2. 请求队列
```typescript
class RequestQueue {
  private queue: Array<() => Promise<any>> = [];
  private processing: boolean = false;
  private maxConcurrent: number = 3;
  private currentCount: number = 0;
  
  async add<T>(request: () => Promise<T>): Promise<T> {
    return new Promise((resolve, reject) => {
      this.queue.push(async () => {
        try {
          const result = await request();
          resolve(result);
        } catch (error) {
          reject(error);
        }
      });
      
      this.process();
    });
  }
  
  private async process(): Promise<void> {
    if (this.processing || this.currentCount >= this.maxConcurrent) {
      return;
    }
    
    this.processing = true;
    
    while (this.queue.length > 0 && this.currentCount < this.maxConcurrent) {
      const request = this.queue.shift();
      if (request) {
        this.currentCount++;
        request().finally(() => {
          this.currentCount--;
          this.process();
        });
      }
    }
    
    this.processing = false;
  }
}
```

### 3. 离线降级
```typescript
async computeWithFallback(operation: string, params: Record<string, any>): Promise<SageMathResponse> {
  // 尝试使用 SageMath
  try {
    const result = await this.compute(operation, params);
    if (result.success) {
      return result;
    }
  } catch (error) {
    Logger.warn('SageMath unavailable, using local fallback');
  }
  
  // 降级到本地计算
  return await this.localCompute(operation, params);
}

private async localCompute(operation: string, params: Record<string, any>): Promise<SageMathResponse> {
  // 使用本地的 CalculusEngine 或 ExpressionEngine
  switch (operation) {
    case 'integrate':
      return await this.localIntegrate(params);
    case 'differentiate':
      return await this.localDifferentiate(params);
    default:
      return {
        success: false,
        error: '离线模式下不支持此操作'
      };
  }
}
```

## 📊 性能指标

### 目标性能
- 简单计算：< 100ms
- 中等复杂度：< 500ms
- 复杂计算：< 2s
- 超时时间：30s

### 监控指标
- 请求成功率
- 平均响应时间
- 缓存命中率
- 错误率

## 🔒 安全考虑

### 1. 输入验证
- 限制表达式长度
- 过滤危险字符
- 验证参数类型

### 2. 访问控制
- API 密钥认证
- 请求频率限制
- IP 白名单

### 3. 资源限制
- 计算超时
- 内存限制
- CPU 限制

## 📝 测试计划

### 1. 单元测试
```typescript
describe('SageMathService', () => {
  it('should compute integral', async () => {
    const result = await sageMathService.computeDefiniteIntegral('x^2', 'x', '0', '1');
    expect(result.success).toBe(true);
    expect(result.result).toBe('1/3');
  });
  
  it('should simplify expression', async () => {
    const result = await sageMathService.simplifyExpression('(x+1)^2 - (x^2+2*x+1)');
    expect(result.success).toBe(true);
    expect(result.result).toBe('0');
  });
});
```

### 2. 集成测试
- 测试完整的计算流程
- 测试错误处理
- 测试缓存机制

### 3. 性能测试
- 压力测试
- 并发测试
- 长时间运行测试

## 📚 文档

### 用户文档
- 功能说明
- 使用示例
- 常见问题

### 开发文档
- API 文档
- 部署指南
- 故障排查

---

**下一步行动：**
1. ✅ 完成 SageMath 服务器代码
2. ⏳ 部署测试环境
3. ⏳ 集成到客户端
4. ⏳ 进行全面测试
5. ⏳ 编写用户文档

**预计完成时间：** 2-3 周

