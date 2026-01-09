# ComfyUI Docker 使用指南

## 📋 项目概述

这是一个完整的 ComfyUI Docker 部署方案，包含：
- ✅ ComfyUI 主程序（自动从 GitHub 克隆）
- ✅ ComfyUI-Manager 扩展管理器（自动安装）
- ✅ NVIDIA GPU 支持（RTX 4090 等）
- ✅ 数据持久化（模型、输出、配置）

## 🚀 快速开始

### 方法一：使用启动脚本（推荐）

```bash
cd /mnt/sda/ComfyUI_2025
./start.sh
```

启动脚本会自动：
1. 检查 Docker 和 GPU 环境
2. 构建 Docker 镜像
3. 启动 ComfyUI 服务
4. 显示访问地址

### 方法二：手动启动

```bash
cd /mnt/sda/ComfyUI_2025

# 1. 构建镜像
docker compose build

# 2. 启动服务
docker compose up -d

# 3. 查看日志
docker compose logs -f
```

## 🌐 访问 ComfyUI

服务启动后，在浏览器中访问：

```
http://localhost:8188
```

## 📁 目录说明

```
ComfyUI_2025/
├── Dockerfile              # Docker 镜像配置
├── docker-compose.yml      # Docker Compose 配置
├── entrypoint.sh          # 容器启动脚本
├── start.sh               # 快速启动脚本
├── README.md              # 详细说明文档
├── USAGE.md               # 本使用指南
│
├── models/                # 模型文件目录
│   ├── checkpoints/       # Stable Diffusion 模型
│   ├── vae/              # VAE 模型
│   ├── loras/            # LoRA 模型
│   ├── controlnet/       # ControlNet 模型
│   ├── clip/             # CLIP 模型
│   ├── unet/             # UNet 模型
│   └── embeddings/       # Embedding 模型
│
├── output/               # 生成的图片输出目录
├── input/                # 输入文件目录
├── custom_nodes/         # 自定义节点目录
└── user/                 # 用户配置目录
```

## 📥 添加模型

### 1. 下载模型

从以下网站下载模型：
- [Civitai](https://civitai.com/)
- [HuggingFace](https://huggingface.co/)
- [ModelScope](https://modelscope.cn/)

### 2. 放置模型

将下载的模型文件放入对应目录：

```bash
# Stable Diffusion 模型
cp your_model.safetensors /mnt/sda/ComfyUI_2025/models/checkpoints/

# LoRA 模型
cp your_lora.safetensors /mnt/sda/ComfyUI_2025/models/loras/

# VAE 模型
cp your_vae.safetensors /mnt/sda/ComfyUI_2025/models/vae/
```

### 3. 刷新模型列表

在 ComfyUI 界面中点击 "Refresh" 按钮，或重启服务：

```bash
docker compose restart
```

## 🔧 使用 ComfyUI-Manager

ComfyUI-Manager 是一个强大的扩展管理器，已预装在容器中。

### 安装自定义节点

1. 在 ComfyUI 界面中，点击右侧的 **"Manager"** 按钮
2. 选择 **"Install Custom Nodes"**
3. 搜索并安装你需要的节点
4. 安装完成后点击 **"Restart"** 重启服务

### 常用功能

- **Install Custom Nodes**: 安装自定义节点
- **Install Models**: 下载模型
- **Update All**: 更新所有扩展
- **Manager Settings**: 管理器设置

## 💻 常用命令

### 服务管理

```bash
# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 查看服务状态
docker compose ps
```

### 日志查看

```bash
# 查看实时日志
docker compose logs -f

# 查看最近 100 行日志
docker compose logs --tail=100

# 查看特定服务日志
docker compose logs -f comfyui
```

### 容器操作

```bash
# 进入容器
docker compose exec comfyui bash

# 查看 GPU 使用情况
docker compose exec comfyui nvidia-smi

# 查看 Python 版本
docker compose exec comfyui python --version

# 查看 PyTorch 版本
docker compose exec comfyui python -c "import torch; print(torch.__version__)"
```

### 数据管理

```bash
# 备份输出文件
cp -r output/ output_backup_$(date +%Y%m%d)/

# 清理输出文件
rm -rf output/*

# 查看模型大小
du -sh models/
```

## 🎨 工作流示例

### 基础文生图工作流

1. 加载 Checkpoint 模型
2. 添加 Prompt（正向提示词）
3. 添加 Negative Prompt（负向提示词）
4. 设置采样器和步数
5. 点击 "Queue Prompt" 生成图片

### 使用 LoRA

1. 加载基础模型
2. 添加 LoRA Loader 节点
3. 选择 LoRA 文件和权重
4. 连接到 Prompt 节点
5. 生成图片

## 🔍 故障排除

### 问题 1: 容器无法启动

**解决方法:**
```bash
# 查看详细日志
docker compose logs

# 检查端口占用
sudo netstat -tulpn | grep 8188

# 重新构建镜像
docker compose build --no-cache
```

### 问题 2: GPU 不可用

**解决方法:**
```bash
# 检查 NVIDIA 驱动
nvidia-smi

# 检查 Docker GPU 支持
docker run --rm --gpus all nvidia/cuda:12.4.0-base-ubuntu22.04 nvidia-smi

# 重启 Docker 服务
sudo systemctl restart docker
```

### 问题 3: 模型加载失败

**解决方法:**
```bash
# 检查模型文件权限
ls -lh models/checkpoints/

# 修改权限
chmod -R 755 models/

# 重启服务
docker compose restart
```

### 问题 4: 内存不足

**解决方法:**

编辑 `docker-compose.yml`，增加共享内存：

```yaml
shm_size: 16g  # 从 8g 增加到 16g
```

## ⚙️ 高级配置

### 修改端口

编辑 `docker-compose.yml`:

```yaml
ports:
  - "8080:8188"  # 将 8188 改为 8080
```

### 限制 GPU 使用

编辑 `docker-compose.yml`:

```yaml
environment:
  - NVIDIA_VISIBLE_DEVICES=0  # 只使用第一块 GPU
```

### 添加启动参数

编辑 `docker-compose.yml`:

```yaml
environment:
  - CLI_ARGS=--listen 0.0.0.0 --port 8188 --preview-method auto --highvram
```

常用参数：
- `--highvram`: 高显存模式（24GB+）
- `--normalvram`: 普通显存模式（8-16GB）
- `--lowvram`: 低显存模式（4-8GB）
- `--novram`: CPU 模式
- `--preview-method auto`: 自动预览方法

## 📊 性能优化

### RTX 4090 优化建议

1. 使用 `--highvram` 参数
2. 启用 xformers 加速
3. 使用 FP16 精度
4. 合理设置 batch size

### 监控 GPU 使用

```bash
# 实时监控
watch -n 1 nvidia-smi

# 在容器中监控
docker compose exec comfyui watch -n 1 nvidia-smi
```

## 🔄 更新

### 更新 ComfyUI

```bash
# 进入容器
docker compose exec comfyui bash

# 更新代码
cd /app/ComfyUI
git pull

# 退出容器
exit

# 重启服务
docker compose restart
```

### 更新 Docker 镜像

```bash
# 重新构建镜像
docker compose build --no-cache

# 重启服务
docker compose up -d
```

## 📚 参考资源

- [ComfyUI 官方文档](https://github.com/comfyanonymous/ComfyUI)
- [ComfyUI-Manager 文档](https://github.com/Comfy-Org/ComfyUI-Manager)
- [ComfyUI 工作流示例](https://comfyanonymous.github.io/ComfyUI_examples/)
- [Docker 官方文档](https://docs.docker.com/)

## 💡 提示

1. **首次启动**: 首次构建镜像需要下载大量依赖，请耐心等待
2. **模型管理**: 建议使用 ComfyUI-Manager 下载模型，自动放置到正确目录
3. **数据备份**: 定期备份 `models/`、`output/` 和 `custom_nodes/` 目录
4. **性能监控**: 使用 `nvidia-smi` 监控 GPU 使用情况
5. **工作流保存**: ComfyUI 支持保存和加载工作流，方便复用

## 🆘 获取帮助

如果遇到问题，可以：
1. 查看 `README.md` 详细文档
2. 检查 Docker 日志：`docker compose logs -f`
3. 访问 ComfyUI 官方 GitHub Issues
4. 加入 ComfyUI 社区讨论

---

**祝你使用愉快！🎉**
