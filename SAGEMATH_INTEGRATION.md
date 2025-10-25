# SageMath 集成指南

## 概述

本项目集成了 [SageMath](https://github.com/sagemath/sage)，一个强大的开源数学软件系统，用于处理高等数学计算。

## 集成方案

由于 HarmonyOS 应用无法直接运行 Python/SageMath，我们提供两种集成方案：

### 方案一：使用 SageMathCell 公共服务（推荐用于开发测试）

**优点：**
- 无需搭建服务器
- 开箱即用
- 免费使用

**缺点：**
- 依赖网络连接
- 有请求频率限制
- 不适合生产环境

**使用方法：**

```typescript
import { sageMathService } from '../services/SageMathService';

// 计算定积分：∫[0, π] sin(x) dx
const result = await sageMathService.computeDefiniteIntegral(
  'sin(x)',
  'x',
  '0',
  'pi'
);

console.log(result.result); // 输出: 2
```

### 方案二：自建 SageMath 服务器（推荐用于生产环境）

**优点：**
- 完全控制
- 无请求限制
- 更快的响应速度
- 数据隐私保护

**缺点：**
- 需要服务器资源
- 需要维护

**搭建步骤：**

#### 1. 安装 SageMath

```bash
# Ubuntu/Debian
sudo apt-get install sagemath

# macOS
brew install --cask sage

# 或使用 Docker
docker pull sagemath/sagemath
```

#### 2. 创建 SageMath API 服务器

创建 `sagemath_server.py`：

```python
from flask import Flask, request, jsonify
from sage.all import *
import sys
from io import StringIO

app = Flask(__name__)

@app.route('/execute', methods=['POST'])
def execute_sage_code():
    try:
        data = request.json
        code = data.get('code', '')
        timeout = data.get('timeout', 30)
        
        # 捕获输出
        old_stdout = sys.stdout
        sys.stdout = StringIO()
        
        # 执行代码
        exec(code, globals())
        
        # 获取输出
        output = sys.stdout.getvalue()
        sys.stdout = old_stdout
        
        return jsonify({
            'success': True,
            'result': output.strip(),
            'output': output
        })
        
    except Exception as e:
        sys.stdout = old_stdout
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'ok'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

#### 3. 安装依赖并运行

```bash
pip install flask
python sagemath_server.py
```

#### 4. 在应用中配置自定义服务器

```typescript
import { sageMathService } from '../services/SageMathService';

// 设置自定义服务器地址
sageMathService.setCustomServer('http://your-server:5000');

// 现在所有计算都会使用自定义服务器
const result = await sageMathService.computeDefiniteIntegral(
  'sin(x)',
  'x',
  '0',
  'pi'
);
```

## API 使用示例

### 1. 定积分

```typescript
// ∫[0, π] sin(x) dx = 2
const result = await sageMathService.computeDefiniteIntegral(
  'sin(x)',
  'x',
  '0',
  'pi'
);
```

### 2. 不定积分

```typescript
// ∫ x^2 dx = x^3/3 + C
const result = await sageMathService.computeIndefiniteIntegral(
  'x^2',
  'x'
);
```

### 3. 导数

```typescript
// d/dx(sin(x)) = cos(x)
const result = await sageMathService.computeDerivative(
  'sin(x)',
  'x',
  1  // 一阶导数
);
```

### 4. 极限

```typescript
// lim(x→0) sin(x)/x = 1
const result = await sageMathService.computeLimit(
  'sin(x)/x',
  'x',
  '0'
);
```

### 5. 求解方程

```typescript
// 解方程 x^2 - 4 = 0
const result = await sageMathService.solveEquation(
  'x^2 - 4 == 0',
  'x'
);
```

### 6. 泰勒展开

```typescript
// sin(x) 在 x=0 处的 5 阶泰勒展开
const result = await sageMathService.taylorExpansion(
  'sin(x)',
  'x',
  0,
  5
);
```

## 在 AdvancedMathPage 中集成

修改 `AdvancedMathPage.ets`，添加 SageMath 支持：

```typescript
import { sageMathService } from '../services/SageMathService';

// 在计算积分时使用 SageMath
private async calculateIntegralWithSageMath() {
  const expression = this.latexInput.trim();
  const variable = this.structuredData?.variable || 'x';
  
  if (this.structuredData?.lowerLimit) {
    // 定积分
    const result = await sageMathService.computeDefiniteIntegral(
      expression,
      variable,
      this.structuredData.lowerLimit,
      this.structuredData.upperLimit || '0'
    );
    
    if (result.success) {
      this.result = result.result || '';
      this.showSteps = true;
    } else {
      this.errorMessage = result.error || '计算失败';
    }
  } else {
    // 不定积分
    const result = await sageMathService.computeIndefiniteIntegral(
      expression,
      variable
    );
    
    if (result.success) {
      this.result = result.result || '';
      this.showSteps = true;
    } else {
      this.errorMessage = result.error || '计算失败';
    }
  }
}
```

## Docker 部署（推荐）

创建 `Dockerfile`：

```dockerfile
FROM sagemath/sagemath:latest

USER root

# 安装 Flask
RUN sage -pip install flask

# 复制服务器代码
COPY sagemath_server.py /home/sage/

# 暴露端口
EXPOSE 5000

# 运行服务器
CMD ["sage", "-python", "/home/sage/sagemath_server.py"]
```

构建并运行：

```bash
docker build -t sagemath-api .
docker run -d -p 5000:5000 sagemath-api
```

## 性能优化建议

1. **缓存结果**：对于相同的计算请求，缓存结果以提高响应速度
2. **异步处理**：使用异步调用避免阻塞 UI 线程
3. **超时设置**：设置合理的超时时间，避免长时间等待
4. **错误处理**：优雅处理网络错误和计算错误

## 安全注意事项

1. **输入验证**：始终验证用户输入，防止代码注入
2. **访问控制**：如果使用自建服务器，添加身份验证
3. **HTTPS**：生产环境使用 HTTPS 加密通信
4. **资源限制**：限制计算时间和内存使用

## 故障排查

### 问题：连接超时

**解决方案：**
- 检查网络连接
- 增加超时时间
- 检查服务器是否运行

### 问题：计算错误

**解决方案：**
- 检查表达式语法
- 查看 SageMath 文档
- 使用 try-catch 捕获异常

### 问题：性能慢

**解决方案：**
- 使用自建服务器
- 优化计算表达式
- 添加结果缓存

## 参考资源

- [SageMath 官方网站](https://www.sagemath.org/)
- [SageMath GitHub](https://github.com/sagemath/sage)
- [SageMath 文档](https://doc.sagemath.org/)
- [SageMathCell](https://sagecell.sagemath.org/)

## 许可证

SageMath 使用 GPL 许可证。请确保您的使用符合其许可证要求。

