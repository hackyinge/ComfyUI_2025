# 更新日志

## [1.0.0] - 2025-12-19

### 🎉 初始版本

#### 新增功能
- ✅ 创建完整的 ComfyUI Docker 部署项目
- ✅ 基于 NVIDIA CUDA 12.4 的 Dockerfile
- ✅ Docker Compose 配置，支持 GPU 加速
- ✅ 自动克隆和安装 ComfyUI 主程序
- ✅ 自动安装 ComfyUI-Manager 扩展管理器
- ✅ 数据持久化配置（模型、输出、配置）
- ✅ 一键启动脚本 (start.sh)
- ✅ 容器启动脚本 (entrypoint.sh)

#### 文档
- 📚 README.md - 完整的项目说明文档
- 📚 USAGE.md - 详细的使用指南
- 📚 QUICKREF.md - 快速参考卡
- 📚 CHANGELOG.md - 更新日志（本文件）

#### 目录结构
- 📁 models/ - 模型文件目录（7个子目录）
  - checkpoints/ - Stable Diffusion 模型
  - vae/ - VAE 模型
  - loras/ - LoRA 模型
  - controlnet/ - ControlNet 模型
  - clip/ - CLIP 模型
  - unet/ - UNet 模型
  - embeddings/ - Embedding 模型
- 📁 output/ - 输出文件目录
- 📁 input/ - 输入文件目录
- 📁 custom_nodes/ - 自定义节点目录
- 📁 user/ - 用户配置目录

#### 技术栈
- 🐳 Docker & Docker Compose
- 🎮 NVIDIA CUDA 12.4
- 🐍 Python 3.10
- 🔥 PyTorch 2.3.1 (CUDA 12.1)
- 🎨 ComfyUI (latest from GitHub)
- 🔧 ComfyUI-Manager (latest from GitHub)

#### 优化
- ⚡ 使用阿里云镜像源加速下载
- ⚡ 优化 Docker 构建层缓存
- ⚡ 预创建所有必要目录
- ⚡ 设置合理的共享内存大小 (8GB)

#### 参考项目
- 参考 GLM-TTS 项目的 Docker 配置
- 参考 ComfyUI 官方安装文档
- 参考 ComfyUI-Manager 安装指南

---

## 未来计划

### 待添加功能
- [ ] 添加更多预装的自定义节点
- [ ] 提供常用模型的下载脚本
- [ ] 添加工作流示例
- [ ] 支持多 GPU 配置
- [ ] 添加性能监控面板
- [ ] 提供 Kubernetes 部署配置
- [ ] 添加自动备份脚本

### 优化计划
- [ ] 优化镜像大小
- [ ] 添加健康检查
- [ ] 改进日志输出
- [ ] 添加环境变量配置
- [ ] 支持自定义 Python 版本

---

## 贡献指南

欢迎提交 Issue 和 Pull Request！

### 如何贡献
1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

---

## 许可证

本项目遵循以下开源许可证：
- ComfyUI: GPL-3.0 License
- ComfyUI-Manager: GPL-3.0 License

---

**项目创建日期**: 2025-12-19  
**最后更新**: 2025-12-19  
**版本**: 1.0.0
