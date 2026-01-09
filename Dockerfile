# 使用 NVIDIA CUDA 12.4 基础镜像，兼容 RTX 4090
FROM nvidia/cuda:12.4.0-devel-ubuntu22.04

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PIP_DEFAULT_TIMEOUT=600 \
    PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# 换源加快下载速度
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# --- 缓存破坏者：确保 Docker 重新执行后续步骤 ---
ARG CACHE_BUST=1

# 安装系统依赖（增强版，包含 Python 3.11 和常用库）
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
    git \
    wget \
    curl \
    ca-certificates \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    ffmpeg \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 彻底替换系统 Python
RUN rm -f /usr/bin/python3 && \
    ln -sf /usr/bin/python3.11 /usr/bin/python && \
    ln -sf /usr/bin/python3.11 /usr/bin/python3

# 使用 Python 3.11 官方安装最新的 pip，并确保全局唯一
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11 && \
    python3.11 -m pip install --no-cache-dir --upgrade pip && \
    python3.11 -m pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 克隆 ComfyUI 仓库
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app/ComfyUI

# 设置工作目录为 ComfyUI
WORKDIR /app/ComfyUI

# --- 修复依赖冲突：移除 requirements.txt 中可能导致构建失败的非核心包 ---
# 有时特定的镜像源或 Python 环境下 comfy-kitchen 无法找到匹配版本
RUN sed -i '/comfy-kitchen/d' requirements.txt

# 安装 PyTorch 和相关依赖（显式使用 python3 即 3.11）
RUN python3 -m pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# 安装 ComfyUI 基础依赖 (尝试使用官方源排除镜像同步问题)
RUN python3 -m pip install --no-cache-dir -r requirements.txt -i https://pypi.org/simple

# --- 处理自定义节点依赖 ---
# 1. 克隆 ComfyUI-Manager (必备)
RUN mkdir -p /app/ComfyUI/custom_nodes && \
    cd /app/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# 2. 自动化安装已存在的自定义节点依赖 (通用扫描逻辑)
RUN for req in /app/ComfyUI/custom_nodes/*/requirements.txt; do \
    if [ -f "$req" ]; then \
    echo "Installing dependencies for: $(dirname $req)..."; \
    python3 -m pip install --no-cache-dir -r "$req"; \
    fi; \
    done

# 创建必要的目录
RUN mkdir -p /app/ComfyUI/models/checkpoints \
    /app/ComfyUI/models/vae \
    /app/ComfyUI/models/loras \
    /app/ComfyUI/models/controlnet \
    /app/ComfyUI/models/clip \
    /app/ComfyUI/models/unet \
    /app/ComfyUI/models/embeddings \
    /app/ComfyUI/input \
    /app/ComfyUI/output

# 暴露端口 (ComfyUI 默认端口 8188)
EXPOSE 8188

# 复制启动脚本
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# 设置启动命令
CMD ["/app/entrypoint.sh"]
