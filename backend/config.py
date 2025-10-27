"""
配置文件
"""
import os
from typing import Optional

# API 配置
API_TITLE: str = "SmartCalc Backend API"
API_DESCRIPTION: str = "智能计算器后端服务 - 提供高等数学计算功能"
API_VERSION: str = "1.0.0"

# 服务器配置
HOST: str = os.getenv("HOST", "0.0.0.0")
PORT: int = int(os.getenv("PORT", "5000"))
DEBUG: bool = os.getenv("DEBUG", "false").lower() == "true"

# CORS 配置
CORS_ORIGINS: list = os.getenv(
    "CORS_ORIGINS",
    "http://localhost:8080,http://localhost:5173,*"
).split(",")

# 安全配置
API_KEY: Optional[str] = os.getenv("API_KEY", None)
ENABLE_AUTH: bool = os.getenv("ENABLE_AUTH", "false").lower() == "true"

# 性能配置
MAX_WORKERS: int = int(os.getenv("MAX_WORKERS", "4"))
TIMEOUT: int = int(os.getenv("TIMEOUT", "30"))

# 日志配置
LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")
LOG_FORMAT: str = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

