#!/bin/bash

# 启动脚本
echo "=========================================="
echo "Starting ComfyUI with GPU support..."
echo "=========================================="

# 检查 GPU 是否可用
if command -v nvidia-smi &> /dev/null; then
    echo "GPU Information:"
    nvidia-smi
    echo "=========================================="
else
    echo "Warning: nvidia-smi not found. GPU may not be available."
fi

# 进入 ComfyUI 目录
cd /app/ComfyUI

# 启动 ComfyUI
echo "Starting ComfyUI server..."
echo "Access ComfyUI at: http://localhost:8188"
echo "=========================================="

# 使用环境变量中的参数启动，如果没有设置则使用默认值
python main.py ${CLI_ARGS:---listen 0.0.0.0 --port 8188}
