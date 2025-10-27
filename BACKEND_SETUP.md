# 🚀 FastAPI 后端服务 - 完整设置指南

## 📁 项目结构

```
项目根目录/
├── backend/                          # 后端服务目录
│   ├── main.py                       # FastAPI 主应用
│   ├── config.py                     # 配置文件
│   ├── requirements.txt              # Python 依赖
│   ├── start.sh                      # 启动脚本
│   ├── Dockerfile                    # Docker 配置
│   ├── docker-compose.yml            # Docker Compose 配置
│   ├── README.md                     # 后端使用说明
│   ├── INTEGRATION.md                # HarmonyOS 集成指南
│   └── .gitignore                    # Git 忽略文件
│
├── entry/                            # HarmonyOS 应用
│   └── src/
│       ├── services/
│       │   └── SageMathService.ts    # 已有的服务（可直接使用）
│       └── ...
│
└── BACKEND_SETUP.md                  # 本文档
```

## 🎯 快速开始

### 步骤 1: 进入后端目录

```bash
cd backend
```

### 步骤 2: 安装依赖

```bash
# 创建虚拟环境（推荐）
python3 -m venv venv

# 激活虚拟环境
# macOS/Linux:
source venv/bin/activate
# Windows:
# venv\Scripts\activate

# 安装依赖
pip install -r requirements.txt
```

### 步骤 3: 启动服务

```bash
# 方式 1: 使用启动脚本（推荐）
./start.sh

# 方式 2: 直接运行
python main.py

# 方式 3: 使用 uvicorn
uvicorn main:app --reload --host 0.0.0.0 --port 5000

# 方式 4: 生产环境
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:5000
```

### 步骤 4: 验证服务

打开浏览器访问：
- **Swagger UI**: http://localhost:5000/docs
- **ReDoc**: http://localhost:5000/redoc
- **健康检查**: http://localhost:5000/health

### 步骤 5: 测试 API

```bash
# 测试健康检查
curl http://localhost:5000/health

# 测试导数计算
curl -X POST http://localhost:5000/differentiate \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2", "variable": "x"}'

# 测试积分
curl -X POST http://localhost:5000/integrate \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2", "variable": "x", "lower": 0, "upper": 2}'
```

## 📱 在 HarmonyOS 应用中集成

### 方法 1: 使用已有的 SageMathService（最简单）

你的项目中已经有 `SageMathService.ts`，只需配置后端地址：

```typescript
import { sageMathService } from './services/SageMathService';

// 设置后端地址
// 开发环境（本地）:
sageMathService.setCustomServer('http://192.168.1.xxx:5000');

// 生产环境:
// sageMathService.setCustomServer('https://your-api-domain.com');

// 使用
const result = await sageMathService.computeDefiniteIntegral(
  'x**2', 'x', '0', '2'
);
```

### 方法 2: 创建新的 FastAPIBackend 客户端

参考 `backend/INTEGRATION.md` 创建专用的 FastAPI 客户端。

## 🌐 部署到生产环境

### 选项 1: Docker 部署（推荐）

```bash
# 在 backend 目录下
docker build -t smartcalc-backend .
docker run -p 5000:5000 smartcalc-backend
```

### 选项 2: Docker Compose 部署

```bash
cd backend
docker-compose up -d
```

### 选项 3: 云服务器部署

1. **上传代码到服务器**
   ```bash
   scp -r backend user@server.com:/path/to/app
   ```

2. **SSH 连接到服务器**
   ```bash
   ssh user@server.com
   cd /path/to/app/backend
   pip install -r requirements.txt
   ```

3. **使用 systemd 管理服务**
   ```bash
   # 创建服务文件
   sudo nano /etc/systemd/system/smartcalc-backend.service
   ```
   
   添加以下内容：
   ```ini
   [Unit]
   Description=SmartCalc Backend API
   After=network.target
   
   [Service]
   User=www-data
   Group=www-data
   WorkingDirectory=/path/to/app/backend
   Environment="PATH=/usr/local/bin"
   ExecStart=/usr/local/bin/uvicorn main:app --host 0.0.0.0 --port 5000
   
   [Install]
   WantedBy=multi-user.target
   ```
   
   ```bash
   # 启动服务
   sudo systemctl start smartcalc-backend
   sudo systemctl enable smartcalc-backend
   
   # 查看状态
   sudo systemctl status smartcalc-backend
   
   # 查看日志
   sudo journalctl -u smartcalc-backend -f
   ```

### 选项 4: 使用云平台

#### Railway
```bash
railway login
railway init
railway up
```

#### Render
- 连接 GitHub 仓库
- 自动部署
- 设置环境变量

#### Fly.io
```bash
fly launch
fly deploy
```

## 🔧 配置说明

### 环境变量

创建 `.env` 文件（可选）：

```bash
# 服务器配置
HOST=0.0.0.0
PORT=5000
DEBUG=false

# CORS 配置
CORS_ORIGINS=http://localhost:8080,http://localhost:5173,https://your-domain.com

# 安全配置
API_KEY=your-secret-key
ENABLE_AUTH=false

# 性能配置
MAX_WORKERS=4
TIMEOUT=30

# 日志配置
LOG_LEVEL=INFO
```

### 配置文件

修改 `config.py` 自定义配置：

```python
# API 配置
API_TITLE = "SmartCalc Backend API"
API_DESCRIPTION = "智能计算器后端服务"
API_VERSION = "1.0.0"

# 服务器配置
HOST = "0.0.0.0"
PORT = 5000
DEBUG = False

# CORS 配置
CORS_ORIGINS = ["http://localhost:8080", "https://your-domain.com"]
```

## 📊 可用 API 列表

### 基础接口

| 方法 | 端点 | 功能 |
|------|------|------|
| GET | `/health` | 健康检查 |
| GET | `/` | API 信息 |
| GET | `/docs` | Swagger UI |
| GET | `/redoc` | ReDoc 文档 |
| GET | `/openapi.json` | OpenAPI 规范 |

### 计算接口

| 方法 | 端点 | 功能 |
|------|------|------|
| POST | `/execute` | 执行任意代码 |
| POST | `/differentiate` | 计算导数 |
| POST | `/integrate` | 定积分 |
| POST | `/integrate_indefinite` | 不定积分 |
| POST | `/solve` | 求解方程 |
| POST | `/simplify` | 简化表达式 |
| POST | `/expand` | 展开表达式 |
| POST | `/factor` | 因式分解 |
| POST | `/limit` | 计算极限 |
| POST | `/taylor` | 泰勒展开 |

详细文档请访问：http://localhost:5000/docs

## 🧪 测试

### 手动测试

```bash
# 1. 健康检查
curl http://localhost:5000/health

# 2. 计算导数
curl -X POST http://localhost:5000/differentiate \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2", "variable": "x"}'

# 3. 计算积分
curl -X POST http://localhost:5000/integrate \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2", "variable": "x", "lower": 0, "upper": 2}'

# 4. 求解方程
curl -X POST http://localhost:5000/solve \
  -H "Content-Type: application/json" \
  -d '{"equation": "x**2 - 4", "variable": "x"}'
```

### 自动化测试

创建 `test_api.sh`：

```bash
#!/bin/bash

BASE_URL="http://localhost:5000"

echo "Testing SmartCalc Backend API..."

# 健康检查
curl -s $BASE_URL/health | jq

# 导数
curl -s -X POST $BASE_URL/differentiate \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2", "variable": "x"}' | jq

# 积分
curl -s -X POST $BASE_URL/integrate \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2", "variable": "x", "lower": 0, "upper": 2}' | jq

echo "Tests completed!"
```

运行：
```bash
chmod +x test_api.sh
./test_api.sh
```

## 🔒 安全建议

### 1. 添加 API 密钥认证

在 `main.py` 中添加：

```python
from fastapi import Security, HTTPException
from fastapi.security import APIKeyHeader

API_KEY = "your-secret-key"
api_key_header = APIKeyHeader(name="X-API-Key")

async def verify_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY:
        raise HTTPException(status_code=403, detail="Invalid API Key")
    return api_key
```

### 2. 启用 HTTPS

使用 Nginx + Let's Encrypt：

```bash
sudo apt-get install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

### 3. 限制 CORS

在 `main.py` 中：

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://your-domain.com"],  # 只允许特定域名
    allow_credentials=True,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)
```

### 4. 添加限流

```bash
pip install slowapi
```

## 📈 性能优化

### 1. 使用生产服务器

```bash
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:5000
```

### 2. 启用压缩

在 `main.py` 中：

```python
from fastapi.middleware.gzip import GZipMiddleware
app.add_middleware(GZipMiddleware, minimum_size=1000)
```

### 3. 使用缓存

```python
from functools import lru_cache

@lru_cache(maxsize=1000)
def cached_compute(expr_hash):
    # 计算逻辑
    pass
```

## ❓ 常见问题

### Q: 端口被占用怎么办？

```bash
# 查找占用进程
lsof -i :5000

# 杀死进程
kill -9 <PID>
```

### Q: 如何在手机上测试？

1. 确保手机和电脑在同一 WiFi
2. 找到电脑的 IP 地址：`ifconfig | grep "inet "`
3. 在应用中设置：`http://192.168.1.xxx:5000`

### Q: 如何查看日志？

```bash
# systemd
sudo journalctl -u smartcalc-backend -f

# Docker
docker logs -f <container_id>
```

### Q: 如何调试？

启用调试模式：

```bash
# 设置环境变量
export DEBUG=true

# 或修改 config.py
DEBUG = True
```

## 📚 相关文档

- **后端 API 文档**: `backend/README.md`
- **集成指南**: `backend/INTEGRATION.md`
- **HarmonyOS 应用配置**: 参考项目中的 `SageMathService.ts`
- **FastAPI 官方文档**: https://fastapi.tiangolo.com/
- **SymPy 文档**: https://docs.sympy.org/

## 🎉 总结

现在你已经拥有：
- ✅ 完整的 FastAPI 后端服务
- ✅ 自动生成的 API 文档
- ✅ Docker 部署支持
- ✅ 完整的集成指南
- ✅ 可以直接在 HarmonyOS 应用中使用的服务

**下一步：**
1. 启动后端服务
2. 在应用中配置后端地址
3. 测试计算功能
4. 部署到生产环境

**祝你开发顺利！** 🚀

