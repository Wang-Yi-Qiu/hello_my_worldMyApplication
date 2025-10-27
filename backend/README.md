# SmartCalc 后端服务

FastAPI 实现的智能计算器后端，提供强大的数学计算功能。

## 🚀 快速开始

### 1. 安装依赖

```bash
cd backend
pip install -r requirements.txt
```

### 2. 运行开发服务器

```bash
# 方式 1: 直接运行
python main.py

# 方式 2: 使用 uvicorn
uvicorn main:app --reload --host 0.0.0.0 --port 5000

# 方式 3: 使用 uvicorn + SSL（HTTPS）
uvicorn main:app --reload --host 0.0.0.0 --port 5000 --ssl-keyfile key.pem --ssl-certfile cert.pem
```

### 3. 访问 API 文档

启动后访问：
- **Swagger UI**: http://localhost:5000/docs
- **ReDoc**: http://localhost:5000/redoc
- **OpenAPI**: http://localhost:5000/openapi.json

## 📦 项目结构

```
backend/
├── main.py              # FastAPI 主应用
├── requirements.txt     # Python 依赖
├── README.md           # 本文档
├── config.py           # 配置文件（可选）
└── tests/              # 测试文件（可选）
```

## 🔌 API 接口

### 基础接口

#### GET /health
健康检查

```bash
curl http://localhost:5000/health
```

响应：
```json
{
  "status": "ok",
  "service": "SmartCalc Backend",
  "version": "1.0.0"
}
```

### 计算接口

#### POST /execute
执行任意 SageMath/SymPy 代码

```bash
curl -X POST http://localhost:5000/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "sp.diff(x**2, x)"}'
```

请求：
```json
{
  "code": "sp.diff(x**2, x)",
  "timeout": 30
}
```

响应：
```json
{
  "success": true,
  "result": "2*x",
  "output": "2*x",
  "stdout": "2*x"
}
```

#### POST /differentiate
计算导数

```bash
curl -X POST http://localhost:5000/differentiate \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2", "variable": "x"}'
```

请求：
```json
{
  "expression": "x**2",
  "variable": "x"
}
```

响应：
```json
{
  "success": true,
  "result": "2*x",
  "latex": "2 x"
}
```

#### POST /integrate
计算定积分

```bash
curl -X POST http://localhost:5000/integrate \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2", "variable": "x", "lower": 0, "upper": 2}'
```

#### POST /integrate_indefinite
计算不定积分

```bash
curl -X POST http://localhost:5000/integrate_indefinite \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2", "variable": "x"}'
```

#### POST /solve
求解方程

```bash
curl -X POST http://localhost:5000/solve \
  -H "Content-Type: application/json" \
  -d '{"equation": "x**2 - 4", "variable": "x"}'
```

#### POST /simplify
简化表达式

```bash
curl -X POST http://localhost:5000/simplify \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2 + 2*x + 1"}'
```

#### POST /expand
展开表达式

```bash
curl -X POST http://localhost:5000/expand \
  -H "Content-Type: application/json" \
  -d '{"expression": "(x+1)*(x+2)"}'
```

#### POST /factor
因式分解

```bash
curl -X POST http://localhost:5000/factor \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2 - 4"}'
```

#### POST /limit
计算极限

```bash
curl -X POST "http://localhost:5000/limit?expression=sin(x)/x&variable=x&approach_value=0"
```

#### POST /taylor
泰勒级数展开

```bash
curl -X POST "http://localhost:5000/taylor?expression=sin(x)&variable=x&center=0&order=5"
```

## 🧪 测试

### 测试基本功能

```bash
# 测试健康检查
curl http://localhost:5000/health

# 测试导数计算
curl -X POST http://localhost:5000/differentiate \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2", "variable": "x"}'

# 测试积分计算
curl -X POST http://localhost:5000/integrate \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2", "variable": "x", "lower": 0, "upper": 2}'
```

## 🚀 部署

### 开发环境

```bash
uvicorn main:app --reload --host 0.0.0.0 --port 5000
```

### 生产环境

#### 方式 1: 使用 Gunicorn + Uvicorn

```bash
# 启动生产服务器
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:5000

# 后台运行
nohup gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:5000 &
```

#### 方式 2: 使用 Docker

**创建 Dockerfile:**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

EXPOSE 5000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]
```

**构建和运行:**
```bash
docker build -t smartcalc-backend .
docker run -p 5000:5000 smartcalc-backend
```

#### 方式 3: 使用 systemd

**创建服务文件 `/etc/systemd/system/smartcalc-backend.service`:**

```ini
[Unit]
Description=SmartCalc Backend API
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/path/to/backend
Environment="PATH=/usr/local/bin"
ExecStart=/usr/local/bin/uvicorn main:app --host 0.0.0.0 --port 5000

[Install]
WantedBy=multi-user.target
```

**启动服务:**
```bash
sudo systemctl start smartcalc-backend
sudo systemctl enable smartcalc-backend
```

### 使用 Nginx 反向代理

**创建 Nginx 配置 `/etc/nginx/sites-available/smartcalc-backend`:**

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**启用配置:**
```bash
sudo ln -s /etc/nginx/sites-available/smartcalc-backend /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### HTTPS 配置

使用 Let's Encrypt 获取 SSL 证书:

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

## 🌐 云端部署平台

### Railway
```bash
railway login
railway init
railway up
```

### Render
1. 连接 GitHub 仓库
2. 设置构建命令: `pip install -r backend/requirements.txt`
3. 设置启动命令: `cd backend && uvicorn main:app --host 0.0.0.0 --port $PORT`

### Fly.io
```bash
fly launch
fly deploy
```

## 🔒 安全建议

1. **添加认证**（可选）
   ```python
   from fastapi import Depends, HTTPException, status
   from fastapi.security import HTTPBearer
   
   security = HTTPBearer()
   
   async def verify_token(token: str = Depends(security)):
       # 验证 token
       pass
   
   @app.post("/execute")
   async def execute(request: ExecuteRequest, token: str = Depends(verify_token)):
       # ...
   ```

2. **限流保护**
   ```bash
   pip install slowapi
   ```

3. **CORS 配置**
   生产环境应该限制特定域名：
   ```python
   app.add_middleware(
       CORSMiddleware,
       allow_origins=["https://your-domain.com"],
       allow_credentials=True,
       allow_methods=["GET", "POST"],
       allow_headers=["*"],
   )
   ```

## 📊 性能优化

1. **使用异步**
   - 所有路由都是异步的
   - 使用 uvicorn 异步服务器

2. **启用压缩**
   ```python
   from fastapi.middleware.gzip import GZipMiddleware
   app.add_middleware(GZipMiddleware, minimum_size=1000)
   ```

3. **缓存结果**（可选）
   ```python
   from functools import lru_cache
   @lru_cache()
   def compute(expr):
       # ...
   ```

## 📞 故障排除

### 端口被占用
```bash
# 查找占用进程
lsof -i :5000
# 杀死进程
kill -9 <PID>
```

### 依赖安装失败
```bash
# 升级 pip
pip install --upgrade pip
# 使用虚拟环境
python -m venv venv
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate    # Windows
```

### 查看日志
```bash
# 使用 journalctl (systemd)
sudo journalctl -u smartcalc-backend -f

# 使用 pm2
pm2 logs smartcalc-backend
```

## 🎯 快速测试脚本

创建 `test_api.sh`:

```bash
#!/bin/bash

BASE_URL="http://localhost:5000"

echo "Testing SmartCalc Backend API..."
echo ""

# 健康检查
echo "1. Health Check:"
curl -s $BASE_URL/health | jq
echo ""

# 导数
echo "2. Derivative (d/dx(x^2)):"
curl -s -X POST $BASE_URL/differentiate \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2", "variable": "x"}' | jq
echo ""

# 积分
echo "3. Integral (∫ x^2 dx from 0 to 2):"
curl -s -X POST $BASE_URL/integrate \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2", "variable": "x", "lower": 0, "upper": 2}' | jq
echo ""

# 求解方程
echo "4. Solve (x^2 - 4 = 0):"
curl -s -X POST $BASE_URL/solve \
  -H "Content-Type: application/json" \
  -d '{"equation": "x**2 - 4", "variable": "x"}' | jq
echo ""

echo "Tests completed!"
```

运行测试:
```bash
chmod +x test_api.sh
./test_api.sh
```

## 📚 更多资源

- FastAPI 文档: https://fastapi.tiangolo.com/
- SymPy 文档: https://docs.sympy.org/
- SciPy 文档: https://docs.scipy.org/

