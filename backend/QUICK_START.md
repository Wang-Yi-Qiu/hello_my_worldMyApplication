# ⚡ 快速开始

## 🚀 3 分钟启动后端

```bash
# 1. 进入后端目录
cd backend

# 2. 运行启动脚本
./start.sh
```

**完成了！** 服务已启动在 http://localhost:5000

访问 http://localhost:5000/docs 查看 API 文档

## 📝 快速测试

```bash
# 健康检查
curl http://localhost:5000/health

# 计算导数
curl -X POST http://localhost:5000/differentiate \
  -H "Content-Type: application/json" \
  -d '{"expression": "x**2", "variable": "x"}'
```

## 📱 在 HarmonyOS 应用中连接

```typescript
import { sageMathService } from './services/SageMathService';

// 设置后端地址
sageMathService.setCustomServer('http://YOUR_IP:5000');

// 使用
const result = await sageMathService.computeDefiniteIntegral('x**2', 'x', '0', '2');
```

## 🐳 Docker 部署

```bash
# 构建
docker build -t smartcalc-backend .

# 运行
docker run -p 5000:5000 smartcalc-backend
```

## 📚 完整文档

- 详细文档: `README.md`
- 集成指南: `INTEGRATION.md`
- 主设置: `../BACKEND_SETUP.md`

## ⚙️ 环境要求

- Python 3.11+
- pip
- 500MB 磁盘空间

## 🔥 常用命令

```bash
# 启动服务
./start.sh

# 查看日志
tail -f logs/*.log

# 停止服务
pkill -f uvicorn

# Docker Compose
docker-compose up -d
docker-compose down
```

## 📞 需要帮助？

查看 `README.md` 了解详细配置和部署选项。

