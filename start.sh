#!/bin/bash

# ComfyUI Docker 快速启动脚本

echo "=========================================="
echo "ComfyUI Docker 快速部署脚本"
echo "=========================================="

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: Docker 未安装"
    echo "请先安装 Docker: curl -fsSL https://get.docker.com | sh"
    exit 1
fi

# 检查 Docker Compose 是否安装
if ! command -v docker compose &> /dev/null; then
    echo "错误: Docker Compose 未安装"
    echo "请先安装 Docker Compose"
    exit 1
fi

# 检查 NVIDIA 驱动
if ! command -v nvidia-smi &> /dev/null; then
    echo "警告: nvidia-smi 未找到，GPU 可能不可用"
    read -p "是否继续? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "检测到 NVIDIA GPU:"
    nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader
    echo "=========================================="
fi

# 构建镜像
echo "开始构建 Docker 镜像..."
docker compose build

if [ $? -ne 0 ]; then
    echo "错误: 镜像构建失败"
    exit 1
fi

echo "=========================================="
echo "镜像构建成功！"
echo "=========================================="

# 启动服务
echo "启动 ComfyUI 服务..."
docker compose up -d

if [ $? -ne 0 ]; then
    echo "错误: 服务启动失败"
    exit 1
fi


echo "=========================================="
echo "正在检查并安装自定义节点依赖..."
echo "=========================================="
# 遍历 custom_nodes 目录安装依赖
docker compose exec -T comfyui bash -c '
if [ -d "custom_nodes" ]; then
    cd custom_nodes
    echo "Scanning custom_nodes for requirements.txt..."
    for dir in */; do
        if [ -f "${dir}requirements.txt" ]; then
            echo "Found requirements.txt in ${dir}, installing..."
            pip install -r "${dir}requirements.txt"
        fi
    done
fi
'
echo "=========================================="
echo "ComfyUI 服务已启动！"
echo "访问地址: http://223.72.19.107:8188/"
echo "=========================================="
echo ""
echo "常用命令:"
echo "  查看日志: docker compose logs -f"
echo "  停止服务: docker compose down"
echo "  重启服务: docker compose restart"
echo "  进入容器: docker compose exec comfyui bash"
echo "=========================================="
