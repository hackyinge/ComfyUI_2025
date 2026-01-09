#!/bin/bash

# ComfyUI 模型复制脚本
# 从现有 ComfyUI 目录复制模型到新项目，重名文件自动跳过

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 源目录和目标目录
SOURCE_DIR="/home/money/AI/privatecloud/data/autodl-container-69d64390ed-0e232830-storage/ComfyUI/models"
TARGET_DIR="/mnt/sda/ComfyUI_2025/models"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          ComfyUI 模型复制脚本                                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 检查源目录是否存在
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}错误: 源目录不存在: $SOURCE_DIR${NC}"
    exit 1
fi

# 检查目标目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}错误: 目标目录不存在: $TARGET_DIR${NC}"
    exit 1
fi

echo -e "${GREEN}源目录: $SOURCE_DIR${NC}"
echo -e "${GREEN}目标目录: $TARGET_DIR${NC}"
echo ""

# 统计变量
total_files=0
copied_files=0
skipped_files=0
failed_files=0
total_size=0

# 复制函数
copy_directory() {
    local src_subdir="$1"
    local dst_subdir="$2"
    
    # 如果源目录不存在，跳过
    if [ ! -d "$src_subdir" ]; then
        return
    fi
    
    # 创建目标子目录（如果不存在）
    mkdir -p "$dst_subdir"
    
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}处理目录: $(basename "$src_subdir")${NC}"
    echo ""
    
    # 遍历源目录中的所有文件（包括子目录）
    find "$src_subdir" -type f | while read -r src_file; do
        # 计算相对路径
        rel_path="${src_file#$src_subdir/}"
        dst_file="$dst_subdir/$rel_path"
        
        # 创建目标文件的父目录
        mkdir -p "$(dirname "$dst_file")"
        
        total_files=$((total_files + 1))
        
        # 检查目标文件是否已存在
        if [ -f "$dst_file" ]; then
            echo -e "${YELLOW}⊘ 跳过 (已存在): $rel_path${NC}"
            skipped_files=$((skipped_files + 1))
        else
            # 获取文件大小
            file_size=$(stat -f%z "$src_file" 2>/dev/null || stat -c%s "$src_file" 2>/dev/null || echo 0)
            file_size_mb=$(echo "scale=2; $file_size / 1048576" | bc 2>/dev/null || echo "0")
            
            echo -e "${GREEN}→ 复制: $rel_path (${file_size_mb} MB)${NC}"
            
            # 复制文件
            if cp "$src_file" "$dst_file" 2>/dev/null; then
                copied_files=$((copied_files + 1))
                total_size=$((total_size + file_size))
            else
                echo -e "${RED}✗ 失败: $rel_path${NC}"
                failed_files=$((failed_files + 1))
            fi
        fi
    done
}

# 定义需要复制的目录映射
# 格式: "源子目录名:目标子目录名"
declare -a dir_mappings=(
    "checkpoints:checkpoints"
    "vae:vae"
    "loras:loras"
    "controlnet:controlnet"
    "clip:clip"
    "unet:unet"
    "embeddings:embeddings"
    "upscale_models:upscale_models"
    "ipadapter:ipadapter"
    "instantid:instantid"
    "style_models:style_models"
    "clip_vision:clip_vision"
    "diffusion_models:diffusion_models"
    "text_encoders:text_encoders"
    "LLM:LLM"
    "sam2:sam2"
    "sams:sams"
    "BiRefNet:BiRefNet"
    "Joy_caption:Joy_caption"
    "latent_upscale_models:latent_upscale_models"
    "animatediff_models:animatediff_models"
    "animatediff_motion_lora:animatediff_motion_lora"
    "audio_encoders:audio_encoders"
    "configs:configs"
    "deepbump:deepbump"
    "diffusers:diffusers"
    "facedetection:facedetection"
    "facerestore_models:facerestore_models"
    "FILM:FILM"
    "florence2:florence2"
    "gligen:gligen"
    "hypernetworks:hypernetworks"
    "insightface:insightface"
    "mmdets:mmdets"
    "model_patches:model_patches"
    "nsfw_detector:nsfw_detector"
    "onnx:onnx"
    "photomaker:photomaker"
    "reactor:reactor"
    "rembg:rembg"
    "ultralytics:ultralytics"
    "vae_approx:vae_approx"
)

echo -e "${BLUE}开始复制模型文件...${NC}"
echo ""

# 遍历所有目录映射
for mapping in "${dir_mappings[@]}"; do
    IFS=':' read -r src_name dst_name <<< "$mapping"
    src_path="$SOURCE_DIR/$src_name"
    dst_path="$TARGET_DIR/$dst_name"
    
    if [ -d "$src_path" ]; then
        # 检查目录是否为符号链接
        if [ -L "$src_path" ]; then
            echo -e "${YELLOW}⊘ 跳过符号链接: $src_name${NC}"
            continue
        fi
        
        # 检查目录是否为空
        if [ -z "$(ls -A "$src_path" 2>/dev/null)" ]; then
            echo -e "${YELLOW}⊘ 跳过空目录: $src_name${NC}"
            continue
        fi
        
        copy_directory "$src_path" "$dst_path"
    fi
done

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    复制完成统计                                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 计算总大小（转换为 GB）
total_size_gb=$(echo "scale=2; $total_size / 1073741824" | bc 2>/dev/null || echo "0")

echo -e "${GREEN}✓ 成功复制: $copied_files 个文件${NC}"
echo -e "${YELLOW}⊘ 跳过文件: $skipped_files 个文件 (已存在)${NC}"
if [ $failed_files -gt 0 ]; then
    echo -e "${RED}✗ 失败文件: $failed_files 个文件${NC}"
fi
echo -e "${BLUE}📊 总计处理: $((copied_files + skipped_files)) 个文件${NC}"
echo -e "${BLUE}💾 复制大小: ${total_size_gb} GB${NC}"
echo ""

if [ $copied_files -gt 0 ]; then
    echo -e "${GREEN}✅ 模型复制完成！${NC}"
else
    echo -e "${YELLOW}ℹ️  没有新文件需要复制${NC}"
fi

echo ""
echo -e "${BLUE}提示: 可以运行以下命令查看模型目录:${NC}"
echo -e "${BLUE}  du -sh models/*${NC}"
echo ""
