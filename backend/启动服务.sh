#!/bin/bash

echo "========================================"
echo "  启动 SmartCalc 后端服务"
echo "========================================"
echo ""

cd "$(dirname "$0")"

echo "正在检查 Python..."
python3 --version

echo ""
echo "正在启动服务..."
python3 main.py

