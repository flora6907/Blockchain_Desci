#!/bin/bash
echo "=== 修复后端依赖问题 ==="

cd backend

echo "1. 停止现有的后端进程..."
pkill -f "node.*index.js" 2>/dev/null || true

echo "2. 重新安装 better-sqlite3 模块..."
npm rebuild better-sqlite3

if [ $? -ne 0 ]; then
    echo "重建失败，尝试重新安装..."
    npm install better-sqlite3 --force
fi

echo "3. 启动后端服务器..."
node index.js 