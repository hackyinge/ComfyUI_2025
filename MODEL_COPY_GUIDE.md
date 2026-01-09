# 模型复制指南

## 📥 从现有 ComfyUI 复制模型

本项目提供了一个智能模型复制脚本 `copy_models.sh`，可以从现有的 ComfyUI 安装目录复制所有模型到新项目。

### 🚀 使用方法

#### 方法一：直接运行（推荐）

```bash
cd /mnt/sda/ComfyUI_2025
./copy_models.sh
```

#### 方法二：后台运行并记录日志

```bash
cd /mnt/sda/ComfyUI_2025
nohup ./copy_models.sh > copy_models.log 2>&1 &

# 查看进度
tail -f copy_models.log
```

### 📋 脚本功能

✅ **智能跳过**：如果目标文件已存在，自动跳过，不会覆盖  
✅ **完整复制**：复制所有类型的模型文件  
✅ **保持结构**：保持原有的目录结构  
✅ **详细日志**：显示每个文件的复制状态和大小  
✅ **统计信息**：完成后显示复制统计  

### 📁 支持的模型类型

脚本会复制以下类型的模型：

| 模型类型 | 目录名 | 说明 |
|---------|--------|------|
| Checkpoint | checkpoints | Stable Diffusion 主模型 |
| VAE | vae | VAE 模型 |
| LoRA | loras | LoRA 微调模型 |
| ControlNet | controlnet | ControlNet 模型 |
| CLIP | clip | CLIP 文本编码器 |
| UNet | unet | UNet 扩散模型 |
| Embedding | embeddings | 文本嵌入模型 |
| Upscale | upscale_models | 放大模型 |
| IP-Adapter | ipadapter | IP-Adapter 模型 |
| InstantID | instantid | InstantID 模型 |
| Style Models | style_models | 风格模型 |
| CLIP Vision | clip_vision | CLIP 视觉编码器 |
| Diffusion Models | diffusion_models | 扩散模型 |
| Text Encoders | text_encoders | 文本编码器 |
| LLM | LLM | 大语言模型 |
| SAM2 | sam2 | Segment Anything Model 2 |
| BiRefNet | BiRefNet | BiRefNet 模型 |
| Joy Caption | Joy_caption | Joy Caption 模型 |
| AnimateDiff | animatediff_models | AnimateDiff 模型 |
| Face Restore | facerestore_models | 面部修复模型 |
| Florence2 | florence2 | Florence2 模型 |
| InsightFace | insightface | InsightFace 模型 |
| 其他 | ... | 更多扩展模型 |

### 📊 复制过程示例

```
╔════════════════════════════════════════════════════════════════╗
║          ComfyUI 模型复制脚本                                  ║
╚════════════════════════════════════════════════════════════════╝

源目录: /home/money/AI/privatecloud/data/autodl-container-69d64390ed-0e232830-storage/ComfyUI/models
目标目录: /mnt/sda/ComfyUI_2025/models

开始复制模型文件...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
处理目录: checkpoints

→ 复制: dreamshaperXL_lightningDPMSDE.safetensors (6617.75 MB)
→ 复制: flux1-dev-fp8.safetensors (16447.56 MB)
⊘ 跳过 (已存在): model_v1.safetensors

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
处理目录: loras

→ 复制: style_lora_v1.safetensors (143.91 MB)
→ 复制: character_lora.safetensors (143.91 MB)

...

╔════════════════════════════════════════════════════════════════╗
║                    复制完成统计                                ║
╚════════════════════════════════════════════════════════════════╝

✓ 成功复制: 156 个文件
⊘ 跳过文件: 23 个文件 (已存在)
📊 总计处理: 179 个文件
💾 复制大小: 125.34 GB

✅ 模型复制完成！
```

### ⏱️ 预计时间

复制时间取决于：
- 模型文件总大小
- 磁盘读写速度
- 系统负载

**参考时间**：
- 小型模型（< 1GB）：几秒钟
- 中型模型（1-5GB）：1-3 分钟
- 大型模型（> 10GB）：5-15 分钟
- 全部模型（100GB+）：30-60 分钟

### 🔍 查看复制进度

#### 方法一：实时查看日志

```bash
tail -f copy_models.log
```

#### 方法二：查看目标目录大小

```bash
# 查看总大小
du -sh models/

# 查看各子目录大小
du -sh models/*

# 实时监控
watch -n 5 'du -sh models/*'
```

#### 方法三：统计文件数量

```bash
# 统计各目录文件数
find models/ -type f | wc -l

# 按目录统计
for dir in models/*/; do
    echo "$(basename "$dir"): $(find "$dir" -type f | wc -l) 个文件"
done
```

### ⚠️ 注意事项

1. **磁盘空间**：确保目标磁盘有足够空间（建议预留 150GB+）
2. **权限问题**：如果遇到权限错误，使用 `sudo ./copy_models.sh`
3. **中断恢复**：如果复制中断，再次运行脚本会自动跳过已复制的文件
4. **符号链接**：脚本会自动跳过符号链接，只复制实际文件
5. **空目录**：空目录会被自动跳过

### 🛠️ 故障排除

#### 问题 1: 权限被拒绝

```bash
# 解决方案：使用 sudo
sudo ./copy_models.sh

# 或修改目标目录权限
sudo chown -R $USER:$USER models/
```

#### 问题 2: 磁盘空间不足

```bash
# 检查磁盘空间
df -h /mnt/sda

# 清理不需要的文件
docker system prune -a
```

#### 问题 3: 复制速度慢

```bash
# 使用 rsync 替代（更快，支持断点续传）
rsync -avh --progress \
  /home/money/AI/privatecloud/data/autodl-container-69d64390ed-0e232830-storage/ComfyUI/models/ \
  /mnt/sda/ComfyUI_2025/models/
```

### 📝 手动复制特定模型

如果只想复制特定类型的模型：

```bash
# 只复制 checkpoints
cp -n /home/money/AI/privatecloud/data/autodl-container-69d64390ed-0e232830-storage/ComfyUI/models/checkpoints/* \
   models/checkpoints/

# 只复制 loras
cp -n /home/money/AI/privatecloud/data/autodl-container-69d64390ed-0e232830-storage/ComfyUI/models/loras/* \
   models/loras/

# 只复制 vae
cp -n /home/money/AI/privatecloud/data/autodl-container-69d64390ed-0e232830-storage/ComfyUI/models/vae/* \
   models/vae/
```

**注意**：`-n` 参数表示不覆盖已存在的文件

### 🔄 更新模型

如果源目录有新模型，再次运行脚本即可：

```bash
./copy_models.sh
```

脚本会自动：
- 复制新增的模型
- 跳过已存在的模型
- 显示更新统计

### 📊 验证复制结果

```bash
# 比较文件数量
echo "源目录文件数:"
find /home/money/AI/privatecloud/data/autodl-container-69d64390ed-0e232830-storage/ComfyUI/models -type f | wc -l

echo "目标目录文件数:"
find models/ -type f | wc -l

# 比较总大小
echo "源目录大小:"
du -sh /home/money/AI/privatecloud/data/autodl-container-69d64390ed-0e232830-storage/ComfyUI/models

echo "目标目录大小:"
du -sh models/
```

### 🎯 完成后的步骤

1. **验证模型**：检查重要模型是否已复制
2. **启动服务**：运行 `./start.sh` 启动 ComfyUI
3. **测试模型**：在 ComfyUI 界面中测试模型加载
4. **清理日志**：可选，删除 `copy_models.log`

---

**源目录**: `/home/money/AI/privatecloud/data/autodl-container-69d64390ed-0e232830-storage/ComfyUI/models`  
**目标目录**: `/mnt/sda/ComfyUI_2025/models`  
**脚本位置**: `/mnt/sda/ComfyUI_2025/copy_models.sh`
