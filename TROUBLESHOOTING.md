# 故障排除指南

## 🔍 常见问题解决方案

### 1. Docker 相关问题

#### 问题：Docker 未安装或无法运行

**症状：**
```bash
bash: docker: command not found
```

**解决方案：**
```bash
# 安装 Docker
curl -fsSL https://get.docker.com | sh

# 启动 Docker 服务
sudo systemctl start docker
sudo systemctl enable docker

# 将当前用户添加到 docker 组（避免每次使用 sudo）
sudo usermod -aG docker $USER
# 注销并重新登录以使更改生效
```

#### 问题：Docker Compose 未安装

**症状：**
```bash
docker: 'compose' is not a docker command.
```

**解决方案：**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker-compose-plugin

# 或使用 pip 安装
pip install docker-compose
```

---

### 2. GPU 相关问题

#### 问题：GPU 不可用或未检测到

**症状：**
```bash
RuntimeError: No CUDA GPUs are available
```

**诊断步骤：**

1. **检查 NVIDIA 驱动：**
```bash
nvidia-smi
```
如果命令不存在或报错，需要安装 NVIDIA 驱动。

2. **检查 NVIDIA Container Toolkit：**
```bash
docker run --rm --gpus all nvidia/cuda:12.4.0-base-ubuntu22.04 nvidia-smi
```

**解决方案：**

**安装 NVIDIA 驱动：**
```bash
# Ubuntu
sudo apt-get update
sudo apt-get install nvidia-driver-535  # 或更新版本
sudo reboot
```

**安装 NVIDIA Container Toolkit：**
```bash
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
    sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker
```

#### 问题：GPU 内存不足

**症状：**
```bash
RuntimeError: CUDA out of memory
```

**解决方案：**

1. **使用低显存模式：**

编辑 `docker-compose.yml`：
```yaml
environment:
  - CLI_ARGS=--listen 0.0.0.0 --port 8188 --lowvram
```

2. **限制使用的 GPU：**
```yaml
environment:
  - NVIDIA_VISIBLE_DEVICES=0  # 只使用第一块 GPU
```

3. **减小 batch size 或图片分辨率**

---

### 3. 容器启动问题

#### 问题：容器启动失败

**症状：**
```bash
Error response from daemon: ...
```

**诊断步骤：**

1. **查看详细日志：**
```bash
docker compose logs
```

2. **检查端口占用：**
```bash
sudo netstat -tulpn | grep 8188
# 或
sudo lsof -i :8188
```

**解决方案：**

**端口被占用：**

编辑 `docker-compose.yml`，修改端口：
```yaml
ports:
  - "8080:8188"  # 将 8188 改为其他端口
```

**权限问题：**
```bash
sudo chown -R $USER:$USER /mnt/sda/ComfyUI_2025
```

**重新构建镜像：**
```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```

---

### 4. 镜像构建问题

#### 问题：构建超时或下载失败

**症状：**
```bash
ERROR: failed to solve: ...
```

**解决方案：**

1. **增加 Docker 构建超时时间：**
```bash
export DOCKER_BUILDKIT=1
export COMPOSE_HTTP_TIMEOUT=600
docker compose build
```

2. **使用国内镜像源：**

Dockerfile 中已配置阿里云镜像，如果仍然慢，可以配置 Docker 镜像加速：

编辑 `/etc/docker/daemon.json`：
```json
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com",
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
```

然后重启 Docker：
```bash
sudo systemctl restart docker
```

3. **分步构建：**
```bash
# 先拉取基础镜像
docker pull nvidia/cuda:12.4.0-devel-ubuntu22.04

# 再构建
docker compose build
```

---

### 5. 网络问题

#### 问题：无法访问 ComfyUI 界面

**症状：**
浏览器无法打开 `http://localhost:8188`

**诊断步骤：**

1. **检查容器是否运行：**
```bash
docker compose ps
```

2. **检查端口映射：**
```bash
docker compose port comfyui 8188
```

3. **检查防火墙：**
```bash
sudo ufw status
```

**解决方案：**

**容器未运行：**
```bash
docker compose up -d
docker compose logs -f
```

**防火墙阻止：**
```bash
sudo ufw allow 8188
```

**使用服务器 IP 访问：**
```bash
# 获取服务器 IP
ip addr show

# 在浏览器中访问
http://<服务器IP>:8188
```

---

### 6. 模型加载问题

#### 问题：模型无法加载或找不到

**症状：**
ComfyUI 界面中看不到模型

**解决方案：**

1. **检查模型文件位置：**
```bash
ls -lh models/checkpoints/
```

2. **检查文件权限：**
```bash
chmod -R 755 models/
```

3. **检查文件格式：**
确保模型文件是 `.safetensors` 或 `.ckpt` 格式

4. **刷新模型列表：**
在 ComfyUI 界面点击 "Refresh" 按钮

5. **重启容器：**
```bash
docker compose restart
```

---

### 7. ComfyUI-Manager 问题

#### 问题：Manager 无法安装节点

**症状：**
安装自定义节点失败

**解决方案：**

1. **进入容器手动安装：**
```bash
docker compose exec comfyui bash
cd /app/ComfyUI/custom_nodes
git clone <节点仓库地址>
pip install -r <节点目录>/requirements.txt
exit
docker compose restart
```

2. **检查网络连接：**
```bash
docker compose exec comfyui ping -c 3 github.com
```

3. **更新 Manager：**
```bash
docker compose exec comfyui bash
cd /app/ComfyUI/custom_nodes/ComfyUI-Manager
git pull
exit
docker compose restart
```

---

### 8. 性能问题

#### 问题：生成速度慢

**解决方案：**

1. **检查 GPU 使用：**
```bash
docker compose exec comfyui nvidia-smi
```

2. **使用高显存模式（RTX 4090）：**

编辑 `docker-compose.yml`：
```yaml
environment:
  - CLI_ARGS=--listen 0.0.0.0 --port 8188 --highvram
```

3. **启用 xformers：**
```bash
docker compose exec comfyui bash
pip install xformers
exit
docker compose restart
```

4. **使用更快的采样器：**
在 ComfyUI 中选择 DPM++ 2M Karras 等快速采样器

---

### 9. 数据持久化问题

#### 问题：重启后数据丢失

**解决方案：**

1. **检查数据卷挂载：**
```bash
docker compose config | grep volumes -A 5
```

2. **确保文件在正确位置：**
- 模型：`/mnt/sda/ComfyUI_2025/models/`
- 输出：`/mnt/sda/ComfyUI_2025/output/`
- 配置：`/mnt/sda/ComfyUI_2025/user/`

3. **检查目录权限：**
```bash
ls -ld models/ output/ custom_nodes/ user/
```

---

### 10. 日志和调试

#### 查看实时日志

```bash
# 查看所有日志
docker compose logs -f

# 查看最近 100 行
docker compose logs --tail=100

# 查看特定时间段
docker compose logs --since 30m
```

#### 进入容器调试

```bash
# 进入容器
docker compose exec comfyui bash

# 查看 Python 环境
python --version
pip list

# 查看 PyTorch 版本和 CUDA 支持
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.cuda.is_available()}')"

# 查看 GPU 信息
nvidia-smi

# 退出容器
exit
```

---

## 🆘 仍然无法解决？

### 收集诊断信息

运行以下命令收集系统信息：

```bash
cat << 'EOF' > diagnostic.sh
#!/bin/bash
echo "=== 系统信息 ==="
uname -a
echo ""

echo "=== Docker 版本 ==="
docker --version
docker compose version
echo ""

echo "=== NVIDIA 驱动 ==="
nvidia-smi
echo ""

echo "=== 容器状态 ==="
docker compose ps
echo ""

echo "=== 容器日志（最近 50 行）==="
docker compose logs --tail=50
echo ""

echo "=== 磁盘空间 ==="
df -h
echo ""

echo "=== 目录权限 ==="
ls -la /mnt/sda/ComfyUI_2025/
EOF

chmod +x diagnostic.sh
./diagnostic.sh > diagnostic_output.txt
```

### 寻求帮助

1. **查看官方文档：**
   - [ComfyUI GitHub](https://github.com/comfyanonymous/ComfyUI)
   - [ComfyUI-Manager GitHub](https://github.com/Comfy-Org/ComfyUI-Manager)

2. **社区支持：**
   - ComfyUI Discord 社区
   - GitHub Issues

3. **提供信息：**
   - 系统信息（`diagnostic_output.txt`）
   - 错误日志
   - 复现步骤

---

## 📝 预防性维护

### 定期更新

```bash
# 更新 ComfyUI
docker compose exec comfyui bash -c "cd /app/ComfyUI && git pull"

# 更新 Manager
docker compose exec comfyui bash -c "cd /app/ComfyUI/custom_nodes/ComfyUI-Manager && git pull"

# 重启服务
docker compose restart
```

### 清理空间

```bash
# 清理 Docker 缓存
docker system prune -a

# 清理旧的输出文件
find output/ -mtime +30 -delete  # 删除 30 天前的文件
```

### 备份重要数据

```bash
# 备份模型
tar -czf models_backup_$(date +%Y%m%d).tar.gz models/

# 备份配置
tar -czf user_backup_$(date +%Y%m%d).tar.gz user/

# 备份自定义节点
tar -czf custom_nodes_backup_$(date +%Y%m%d).tar.gz custom_nodes/
```

---

**最后更新**: 2025-12-19
