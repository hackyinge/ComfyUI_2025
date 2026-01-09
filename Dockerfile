# 使用 NVIDIA CUDA 12.4 基础镜像，兼容 RTX 4090
FROM nvidia/cuda:12.4.0-devel-ubuntu22.04

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PIP_DEFAULT_TIMEOUT=600

# 换源加快下载速度
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list && \
    sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3-pip \
    python3.10-dev \
    git \
    wget \
    curl \
    ca-certificates \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 创建符号链接
RUN ln -sf /usr/bin/python3.10 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

# 升级 pip
RUN pip install --no-cache-dir --upgrade pip

# 克隆 ComfyUI 仓库
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /app/ComfyUI

# 设置工作目录为 ComfyUI
WORKDIR /app/ComfyUI

# 安装 PyTorch 和相关依赖（CUDA 12.1 版本，兼容 RTX 4090）
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# 安装 ComfyUI 依赖
RUN pip install --no-cache-dir -r requirements.txt

# 克隆 ComfyUI-Manager 到 custom_nodes 目录
RUN mkdir -p /app/ComfyUI/custom_nodes && \
    cd /app/ComfyUI/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git

# 安装 ComfyUI-Manager 依赖
RUN if [ -f /app/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt ]; then \
        pip install --no-cache-dir -r /app/ComfyUI/custom_nodes/ComfyUI-Manager/requirements.txt; \
    fi

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
