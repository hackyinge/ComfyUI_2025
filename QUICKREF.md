# ComfyUI Docker 快速参考卡

## 🚀 一键启动

```bash
cd /mnt/sda/ComfyUI_2025
./start.sh
```

访问地址: **http://localhost:8188**

---

## 📋 常用命令

| 操作 | 命令 |
|------|------|
| 启动服务 | `docker compose up -d` |
| 停止服务 | `docker compose down` |
| 重启服务 | `docker compose restart` |
| 查看日志 | `docker compose logs -f` |
| 进入容器 | `docker compose exec comfyui bash` |
| 查看 GPU | `docker compose exec comfyui nvidia-smi` |
| 重新构建 | `docker compose build --no-cache` |

---

## 📁 模型目录

| 模型类型 | 目录路径 |
|---------|---------|
| Checkpoint | `models/checkpoints/` |
| VAE | `models/vae/` |
| LoRA | `models/loras/` |
| ControlNet | `models/controlnet/` |
| CLIP | `models/clip/` |
| Embedding | `models/embeddings/` |

---

## 🔧 配置文件

| 文件 | 说明 |
|------|------|
| `docker-compose.yml` | Docker Compose 配置 |
| `Dockerfile` | Docker 镜像构建文件 |
| `entrypoint.sh` | 容器启动脚本 |

---

## 🆘 故障排除

### GPU 不可用
```bash
nvidia-smi  # 检查驱动
sudo systemctl restart docker  # 重启 Docker
```

### 端口被占用
```bash
sudo netstat -tulpn | grep 8188  # 检查端口
# 修改 docker-compose.yml 中的端口号
```

### 容器启动失败
```bash
docker compose logs  # 查看日志
docker compose build --no-cache  # 重新构建
```

---

## 📚 文档

- **README.md** - 完整项目说明
- **USAGE.md** - 详细使用指南
- **QUICKREF.md** - 本快速参考（你正在看的）

---

## 💡 提示

1. 首次构建需要 10-20 分钟
2. 模型文件放入 `models/` 对应目录
3. 生成的图片在 `output/` 目录
4. 使用 ComfyUI-Manager 管理扩展
5. RTX 4090 建议使用 `--highvram` 参数

---

**项目位置**: `/mnt/sda/ComfyUI_2025`
