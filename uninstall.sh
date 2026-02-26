#!/bin/bash
# Obsidian Doc Linker - 卸载脚本
# 仅删除本 skill，不影响其他 skill

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         Obsidian Doc Linker - 卸载脚本                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Claude Code 目录
CLAUDE_DIR="$HOME/.claude"
SKILL_NAME="obsidian-doc-linker"
SKILL_DEST="$CLAUDE_DIR/skills/$SKILL_NAME"
CONFIG_DIR="$CLAUDE_DIR/$SKILL_NAME"

# 检查 skill 是否已安装
if [[ ! -e "$SKILL_DEST" ]]; then
    warning "Skill 未安装: $SKILL_DEST"
    info "无需卸载"
    exit 0
fi

info "准备卸载 Skill: $SKILL_NAME"
echo ""
echo "将删除以下内容："
echo "  - Skill: $SKILL_DEST"
if [[ -d "$CONFIG_DIR" ]]; then
    echo "  - 配置: $CONFIG_DIR"
fi
echo ""

# 确认卸载
read -p "确认卸载？(y/n): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    info "卸载已取消"
    exit 0
fi

# 删除 skill
if [[ -L "$SKILL_DEST" ]]; then
    rm "$SKILL_DEST"
    info "已删除符号链接"
elif [[ -d "$SKILL_DEST" ]]; then
    rm -rf "$SKILL_DEST"
    info "已删除目录"
fi

# 询问是否删除配置
if [[ -d "$CONFIG_DIR" ]]; then
    echo ""
    read -p "是否同时删除配置文件？(y/n): " DELETE_CONFIG
    if [[ "$DELETE_CONFIG" =~ ^[Yy]$ ]]; then
        rm -rf "$CONFIG_DIR"
        success "配置已删除"
    else
        info "配置已保留: $CONFIG_DIR"
    fi
fi

echo ""
success "卸载完成！"
echo ""
info "提示: 如需重新安装，请运行安装脚本"
echo ""
