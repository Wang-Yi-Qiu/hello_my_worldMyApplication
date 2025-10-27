@echo off
echo ========================================
echo  启动 SmartCalc 后端服务
echo ========================================
echo.

cd /d %~dp0

echo 正在检查 Python...
python --version

echo.
echo 正在启动服务...
python main.py

pause

