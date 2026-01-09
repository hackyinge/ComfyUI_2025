# ComfyUI Docker 部署项目

这是一个使用 Docker 部署 ComfyUI 的项目，支持 NVIDIA GPU 加速。

## 项目结构

```
ComfyUI_2025/
├── Dockerfile              # Docker 镜像构建文件
├── docker-compose.yml      # Docker Compose 配置文件
├── entrypoint.sh          # 容器启动脚本
├── models/                # 模型文件目录（挂载）
├── output/                # 输出文件目录（挂载）
├── input/                 # 输入文件目录（挂载）
├── custom_nodes/          # 自定义节点目录（挂载）
└── user/                  # 用户配置目录（挂载）
```

## 功能特性

- ✅ 基于 NVIDIA CUDA 12.4，完美支持 RTX 4090 等高端显卡
- ✅ 自动安装 ComfyUI 主程序
- ✅ 自动安装 ComfyUI-Manager 扩展管理器
- ✅ 使用阿里云镜像源加速下载
- ✅ 数据持久化，模型和配置不会丢失
- ✅ 支持 GPU 加速推理

## 前置要求

1. **Docker 和 Docker Compose**
   ```bash
   # 安装 Docker
   curl -fsSL https://get.docker.com | sh
   
   # 安装 Docker Compose
   sudo apt-get install docker-compose-plugin
   ```

2. **NVIDIA Docker Runtime**
   ```bash
   # 安装 NVIDIA Container Toolkit
   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
   curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
   
   sudo apt-get update
   sudo apt-get install -y nvidia-container-toolkit
   sudo systemctl restart docker
   ```

3. **NVIDIA 驱动**
   - 确保已安装 NVIDIA 显卡驱动
   - 运行 `nvidia-smi` 验证驱动是否正常

## 快速开始

### 1. 构建 Docker 镜像

```bash
cd /mnt/sda/ComfyUI_2025
docker compose build
```

### 2. 启动服务

```bash
docker compose up -d
```

### 3. 查看日志

```bash
docker compose logs -f
```

### 4. 访问 ComfyUI

在浏览器中打开：`http://localhost:8188`

## 使用说明

### 添加模型

将你的模型文件放入对应的目录：

- **Checkpoint 模型**: `models/checkpoints/`
- **VAE 模型**: `models/vae/`
- **LoRA 模型**: `models/loras/`
- **ControlNet 模型**: `models/controlnet/`
- **CLIP 模型**: `models/clip/`
- **Embedding 模型**: `models/embeddings/`

### 使用 ComfyUI-Manager

ComfyUI-Manager 已经预装在容器中，可以通过以下方式使用：

1. 在 ComfyUI 界面中，点击右侧的 "Manager" 按钮
2. 可以安装、更新、禁用自定义节点
3. 可以下载和管理模型

### 自定义节点

安装的自定义节点会保存在 `custom_nodes/` 目录中，重启容器后不会丢失。

## 常用命令

```bash
# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 查看日志
docker compose logs -f

# 进入容器
docker compose exec comfyui bash

# 重新构建镜像
docker compose build --no-cache

# 查看 GPU 使用情况
docker compose exec comfyui nvidia-smi
```

## 配置说明

### 修改端口

如果需要修改端口，编辑 `docker-compose.yml` 文件：

```yaml
ports:
  - "8188:8188"  # 修改左边的端口号，如 "8080:8188"
```

### 限制 GPU 使用

如果需要限制使用的 GPU，修改 `docker-compose.yml` 中的环境变量：

```yaml
environment:
  - NVIDIA_VISIBLE_DEVICES=0  # 只使用第一块 GPU
```

### 添加启动参数

修改 `docker-compose.yml` 中的 `CLI_ARGS` 环境变量：

```yaml
environment:
  - CLI_ARGS=--listen 0.0.0.0 --port 8188 --preview-method auto
```

## 故障排除

### GPU 不可用

1. 检查 NVIDIA 驱动：`nvidia-smi`
2. 检查 Docker GPU 支持：`docker run --rm --gpus all nvidia/cuda:12.4.0-base-ubuntu22.04 nvidia-smi`
3. 重启 Docker 服务：`sudo systemctl restart docker`

### 容器启动失败

1. 查看日志：`docker compose logs`
2. 检查端口是否被占用：`sudo netstat -tulpn | grep 8188`
3. 重新构建镜像：`docker compose build --no-cache`

### 模型下载慢

ComfyUI-Manager 支持多种下载源，可以在设置中切换到国内镜像源。

## 参考资料

- [ComfyUI 官方仓库](https://github.com/comfyanonymous/ComfyUI)
- [ComfyUI-Manager 官方仓库](https://github.com/Comfy-Org/ComfyUI-Manager)
- [NVIDIA Container Toolkit 文档](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)

## 许可证

本项目遵循 ComfyUI 和 ComfyUI-Manager 的原始许可证。
