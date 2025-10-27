# HarmonyOS 应用集成 FastAPI 后端指南

## 📱 在 HarmonyOS 应用中使用 FastAPI 后端

### 步骤 1: 配置后端地址

在应用的入口文件中（如 `EntryAbility.ets`）：

```typescript
import { sageMathService } from './services/SageMathService';

// 开发环境
sageMathService.setCustomServer('http://localhost:5000');

// 或者生产环境
// sageMathService.setCustomServer('https://your-domain.com');
```

### 步骤 2: 调用后端 API

由于 FastAPI 自动生成 OpenAPI 文档，你的 HarmonyOS 应用可以使用标准的 HTTP 请求。

```typescript
import { http } from '@kit.NetworkKit';
import { Logger } from '../utils/Logger';

export class FastAPIBackend {
  private baseUrl: string;
  
  constructor(baseUrl: string = 'http://localhost:5000') {
    this.baseUrl = baseUrl;
  }
  
  /**
   * 调用后端 API
   */
  private async request<T>(
    endpoint: string,
    method: string = 'GET',
    data?: any
  ): Promise<T> {
    try {
      const httpRequest = http.createHttp();
      
      const options: http.HttpRequestOptions = {
        method: method as http.RequestMethod,
        header: {
          'Content-Type': 'application/json'
        },
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 30000,
        readTimeout: 30000
      };
      
      if (data) {
        options.extraData = JSON.stringify(data);
      }
      
      const response = await httpRequest.request(`${this.baseUrl}${endpoint}`, options);
      httpRequest.destroy();
      
      if (response.responseCode === 200) {
        return JSON.parse(response.result as string);
      } else {
        throw new Error(`HTTP ${response.responseCode}`);
      }
    } catch (error) {
      Logger.error(`API request failed: ${endpoint}`, error);
      throw error;
    }
  }
  
  /**
   * 计算导数
   */
  async differentiate(expression: string, variable: string = 'x') {
    return await this.request('/differentiate', 'POST', {
      expression,
      variable
    });
  }
  
  /**
   * 计算定积分
   */
  async integrate(expression: string, variable: string, lower: number, upper: number) {
    return await this.request('/integrate', 'POST', {
      expression,
      variable,
      lower,
      upper
    });
  }
  
  /**
   * 求解方程
   */
  async solve(equation: string, variable: string = 'x') {
    return await this.request('/solve', 'POST', {
      equation,
      variable
    });
  }
  
  /**
   * 简化表达式
   */
  async simplify(expression: string) {
    return await this.request('/simplify', 'POST', {
      expression
    });
  }
  
  /**
   * 展开表达式
   */
  async expand(expression: string) {
    return await this.request('/expand', 'POST', {
      expression
    });
  }
  
  /**
   * 因式分解
   */
  async factor(expression: string) {
    return await this.request('/factor', 'POST', {
      expression
    });
  }
  
  /**
   * 执行任意代码
   */
  async execute(code: string, timeout: number = 30) {
    return await this.request('/execute', 'POST', {
      code,
      timeout
    });
  }
  
  /**
   * 健康检查
   */
  async health() {
    return await this.request('/health', 'GET');
  }
}

// 创建全局实例
export const fastAPIBackend = new FastAPIBackend();
```

### 步骤 3: 在页面中使用

```typescript
import { fastAPIBackend } from '../utils/FastAPIBackend';

@Entry
@Component
struct CalculatorPage {
  async computeExample() {
    try {
      // 计算导数
      const diffResult = await fastAPIBackend.differentiate('x**2', 'x');
      console.log('导数:', diffResult.result); // 输出: 2*x
      
      // 计算积分
      const intResult = await fastAPIBackend.integrate('x**2', 'x', 0, 2);
      console.log('积分:', intResult.result); // 输出: 2.6666666666666665
      
      // 求解方程
      const solveResult = await fastAPIBackend.solve('x**2 - 4', 'x');
      console.log('方程解:', solveResult.solutions); // 输出: ['-2', '2']
      
    } catch (error) {
      console.error('计算失败:', error);
    }
  }
}
```

### 步骤 4: 错误处理和重试

```typescript
export class SmartCalculator {
  private maxRetries = 3;
  
  async computeWithRetry<T>(
    fn: () => Promise<T>,
    retries: number = this.maxRetries
  ): Promise<T> {
    try {
      return await fn();
    } catch (error) {
      if (retries > 0) {
        Logger.warn(`重试中... 剩余 ${retries} 次`);
        await new Promise(resolve => setTimeout(resolve, 1000));
        return this.computeWithRetry(fn, retries - 1);
      }
      throw error;
    }
  }
  
  async smartCompute(
    expression: string,
    operation: 'differentiate' | 'integrate' | 'solve' = 'solve'
  ) {
    try {
      // 尝试调用 FastAPI 后端
      switch (operation) {
        case 'differentiate':
          return await this.computeWithRetry(
            () => fastAPIBackend.differentiate(expression, 'x')
          );
        case 'integrate':
          return await this.computeWithRetry(
            () => fastAPIBackend.integrate(expression, 'x', 0, 2)
          );
        case 'solve':
          return await this.computeWithRetry(
            () => fastAPIBackend.solve(expression, 'x')
          );
      }
    } catch (error) {
      // 降级到本地计算引擎
      Logger.warn('后端不可用，使用本地计算');
      return await localEngine.compute(expression);
    }
  }
}
```

### 步骤 5: 配置网络权限

在 `module.json5` 中添加网络权限：

```json
{
  "module": {
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
      }
    ]
  }
}
```

## 🔧 开发环境配置

### 本地开发测试

1. **启动后端服务**
   ```bash
   cd backend
   chmod +x start.sh
   ./start.sh
   ```

2. **查找你的 IP 地址**
   ```bash
   # macOS/Linux
   ifconfig | grep "inet "
   
   # Windows
   ipconfig
   ```

3. **在应用中配置 IP**
   ```typescript
   // 例如你的电脑 IP 是 192.168.1.100
   fastAPIBackend.baseUrl = 'http://192.168.1.100:5000';
   ```

4. **测试连接**
   ```bash
   # 在手机上访问或在电脑浏览器
   curl http://192.168.1.100:5000/health
   ```

## 🌐 生产环境部署

### 部署到云服务器

1. **上传代码到服务器**
   ```bash
   scp -r backend user@your-server.com:/path/to/app
   ```

2. **在服务器上运行**
   ```bash
   ssh user@your-server.com
   cd /path/to/app/backend
   pip install -r requirements.txt
   gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:5000
   ```

3. **配置 Nginx 反向代理**（可选）
   ```nginx
   server {
       listen 80;
       server_name api.your-domain.com;
       
       location / {
           proxy_pass http://127.0.0.1:5000;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

4. **在应用中更新地址**
   ```typescript
   fastAPIBackend.baseUrl = 'https://api.your-domain.com';
   ```

## 📊 性能优化

### 1. 启用压缩

在 `main.py` 中添加：

```python
from fastapi.middleware.gzip import GZipMiddleware

app.add_middleware(GZipMiddleware, minimum_size=1000)
```

### 2. 添加缓存（可选）

```python
from functools import lru_cache
import hashlib

@lru_cache(maxsize=1000)
def cached_compute(expression_hash, code):
    # 计算逻辑
    pass
```

### 3. 异步计算（处理长时间计算）

在 `main.py` 中：

```python
import asyncio
from concurrent.futures import ThreadPoolExecutor

executor = ThreadPoolExecutor(max_workers=4)

async def async_compute(code: str):
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(executor, execute_math, code)
```

## 🔒 安全配置

### 1. 添加 API 密钥认证

在 `main.py` 中：

```python
from fastapi import Security, HTTPException
from fastapi.security import APIKeyHeader

API_KEY = "your-secret-api-key"
api_key_header = APIKeyHeader(name="X-API-Key")

async def verify_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API Key")
    return api_key

@app.post("/execute")
async def execute_code(request: ExecuteRequest, api_key: str = Security(verify_api_key)):
    # ...
```

### 2. 限流保护

```bash
pip install slowapi
```

```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter

@app.post("/execute")
@limiter.limit("10/minute")
async def execute_code(request: ExecuteRequest):
    # ...
```

## 📱 测试清单

- [ ] 后端服务能够启动
- [ ] /health 接口返回正确
- [ ] 能够计算导数
- [ ] 能够计算积分
- [ ] 能够求解方程
- [ ] HarmonyOS 应用能够连接后端
- [ ] 网络断开时能降级到本地计算
- [ ] 错误处理正常

## 🎯 下一步

1. 阅读 `backend/README.md` 了解所有 API
2. 查看 `http://localhost:5000/docs` 自动生成的 API 文档
3. 测试每个接口
4. 配置生产环境
5. 部署到云服务器

