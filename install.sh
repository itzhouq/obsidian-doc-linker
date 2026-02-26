#!/bin/bash
# Obsidian Doc Linker - 一键安装脚本
# 支持 macOS、Linux 和 Windows (Git Bash/WSL)

set -e

# 检测是否在交互式终端中运行
if [[ ! -t 0 ]]; then
    cat >&2 << 'EOF'
╔════════════════════════════════════════════════════════════╗
║                    安装方式错误                            ║
╚════════════════════════════════════════════════════════════╝

⚠️  检测到脚本正在通过管道运行（如 curl | bash）
    这种方式无法进行交互式配置。

✅ 请使用以下正确的安装方式：

   # 方法 1: 下载后执行（推荐）
   curl -fsSL -o install.sh https://raw.githubusercontent.com/itzhouq/obsidian-doc-linker/master/install.sh
   bash install.sh

   # 方法 2: 直接克隆仓库
   git clone https://github.com/itzhouq/obsidian-doc-linker.git
   cd obsidian-doc-linker
   ./install.sh

════════════════════════════════════════════════════════════
EOF
    exit 1
fi

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

# 检测操作系统
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        MINGW*|MSYS*|CYGWIN*) echo "windows";;
        *)          echo "unknown";;
    esac
}

OS=$(detect_os)

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         Obsidian Doc Linker - 一键安装脚本                ║"
echo "║     将项目文档迁移到 Obsidian 并创建符号链接               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# 检查 Claude Code 目录
CLAUDE_DIR="$HOME/.claude"
if [[ ! -d "$CLAUDE_DIR" ]]; then
    error "未找到 Claude Code 目录: $CLAUDE_DIR"
    info "请确保已安装 Claude Code"
    exit 1
fi

success "检测到 Claude Code 目录"

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 全局安装
SKILL_DEST="$CLAUDE_DIR/skills/obsidian-doc-linker"
info "全局安装到: $SKILL_DEST"

# 检查是否已安装
if [[ -e "$SKILL_DEST" ]]; then
    warning "检测到已安装的 Skill"
    read -p "是否覆盖？(y/n): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        info "安装已取消"
        exit 0
    fi
    rm -rf "$SKILL_DEST"
    info "已删除旧版本"
fi

# 创建符号链接
ln -sf "$SCRIPT_DIR/.claude/skills/obsidian-doc-linker" "$SKILL_DEST"
success "Skill 已安装到: $SKILL_DEST"

echo ""
success "安装完成！"
echo ""

# 配置向导
CONFIG_DIR="$HOME/.claude/obsidian-doc-linker"
CONFIG_FILE="$CONFIG_DIR/config.json"

if [[ -f "$CONFIG_FILE" ]]; then
    info "已有配置文件:"
    cat "$CONFIG_FILE"
    echo ""
    read -p "是否重新配置？(y/n): " RECONFIGURE
    if [[ ! "$RECONFIGURE" =~ ^[Yy]$ ]]; then
        CONFIG_DONE=true
    fi
fi

if [[ "$CONFIG_DONE" != true ]]; then
    echo ""
    echo "配置向导"
    echo "─────────────────────────────────────────────────────────"
    echo ""

    # 输入 vault 路径
    echo "请输入你的 Obsidian vault 路径"
    echo "示例: ~/Documents/vault 或 ~/itzhouq_vault"
    read -p "> " USER_VAULT
    USER_VAULT=$(eval echo "$USER_VAULT")

    if [[ ! -d "$USER_VAULT" ]]; then
        warning "路径不存在: $USER_VAULT"
        read -p "是否创建此目录？(y/n): " CREATE_DIR
        if [[ "$CREATE_DIR" =~ ^[Yy]$ ]]; then
            mkdir -p "$USER_VAULT"
            success "目录已创建"
        else
            error "操作已取消"
            exit 1
        fi
    fi

    # 输入分类名称
    echo ""
    read -p "请输入分类目录名 (默认: 项目开发): " USER_CATEGORY
    USER_CATEGORY=${USER_CATEGORY:-"项目开发"}

    # 保存配置
    mkdir -p "$CONFIG_DIR"

    if command -v jq &> /dev/null; then
        echo "{\"vault_path\": \"$USER_VAULT\", \"category\": \"$USER_CATEGORY\"}" > "$CONFIG_FILE"
    else
        vault_escaped=$(echo "$USER_VAULT" | sed 's/\\/\\\\/g; s/"/\\"/g')
        cat_escaped=$(echo "$USER_CATEGORY" | sed 's/\\/\\\\/g; s/"/\\"/g')
        echo "{\"vault_path\": \"$vault_escaped\", \"category\": \"$cat_escaped\"}" > "$CONFIG_FILE"
    fi

    success "配置已保存到: $CONFIG_FILE"
fi

echo ""
echo "📋 下一步:"
echo "─────────────────────────────────────────────────────────"
echo ""
echo "重启 Claude Code 后，你可以："
echo ""
echo "  1. 使用自然语言调用："
echo "     \"请帮我把项目链接到 Obsidian\""
echo "     \"把 CLAUDE.md 迁移到 Obsidian 仓库\""
echo ""
echo "  2. 或直接运行脚本："
echo "     ~/.claude/skills/obsidian-doc-linker/scripts/link_docs.sh"
echo ""
echo "  3. 查看帮助："
echo "     ~/.claude/skills/obsidian-doc-linker/scripts/link_docs.sh --help"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""
