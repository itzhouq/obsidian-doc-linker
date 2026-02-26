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

✅ 请使用以下正确的一键安装方式：

   curl -fsSL \
     -H "Cache-Control: no-cache" \
     -H "Pragma: no-cache" \
     -o install.sh \
     https://raw.githubusercontent.com/itzhouq/obsidian-doc-linker/master/install.sh && \
   bash install.sh && \
   rm install.sh

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

# 检查并显示已有配置
CONFIG_DIR="$HOME/.claude/obsidian-doc-linker"
CONFIG_FILE="$CONFIG_DIR/config.json"

if [[ -f "$CONFIG_FILE" ]]; then
    echo ""
    echo "📋 已有配置:"
    echo "─────────────────────────────────────────────────────────"
    if command -v jq &> /dev/null; then
        vault_path=$(jq -r '.vault_path' "$CONFIG_FILE" 2>/dev/null)
        category=$(jq -r '.category' "$CONFIG_FILE" 2>/dev/null)
        echo "  Obsidian Vault: $vault_path"
        echo "  项目分类目录: $category"
    else
        # 使用 grep 和 sed 提取配置
        vault_path=$(grep '"vault_path"' "$CONFIG_FILE" | sed 's/.*"vault_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        category=$(grep '"category"' "$CONFIG_FILE" | sed 's/.*"category"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        echo "  Obsidian Vault: $vault_path"
        echo "  项目分类目录: $category"
    fi
    echo "─────────────────────────────────────────────────────────"
    echo ""
fi

# 查找 skill 源目录（支持从项目目录或 skills 目录运行）
find_skill_source() {
    # 尝试从脚本所在目录查找
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # 可能的源路径
    local possible_paths=(
        "$script_dir/.claude/skills/obsidian-doc-linker"    # 从项目根目录运行
        "$script_dir/../.claude/skills/obsidian-doc-linker"  # 从 skills 目录运行
        "$script_dir/obsidian-doc-linker"                    # 从 .claude 目录运行
    )

    for path in "${possible_paths[@]}"; do
        if [[ -d "$path" && -f "$path/SKILL.md" ]]; then
            echo "$path"
            return 0
        fi
    done

    return 1
}

SKILL_SOURCE="$(find_skill_source)"

# 如果本地找不到源，从 GitHub 获取
if [[ -z "$SKILL_SOURCE" ]]; then
    info "本地未找到源目录，从 GitHub 获取..."

    # 创建临时目录
    TMP_DIR=$(mktemp -d 2>/dev/null || mktemp -d -t 'obsidian-doc-linker')
    trap "rm -rf '$TMP_DIR'" EXIT

    # 下载并解压
    REPO_URL="https://github.com/itzhouq/obsidian-doc-linker"
    if command -v git &> /dev/null; then
        echo "正在从 GitHub 克隆..."
        git clone --depth 1 "$REPO_URL" "$TMP_DIR" || {
            error "git clone 失败"
            echo ""
            info "可能的原因："
            echo "  1. 网络连接问题"
            echo "  2. GitHub 访问受限"
            echo ""
            info "建议："
            echo "  1. 检查网络连接"
            echo "  2. 手动克隆仓库：git clone $REPO_URL"
            echo "  3. 或使用克隆安装方式"
            exit 1
        }
    elif command -v curl &> /dev/null; then
        echo "正在下载压缩包..."
        curl -fSL "$REPO_URL/archive/refs/heads/master.tar.gz" -o "$TMP_DIR/master.tar.gz" || {
            error "下载失败"
            echo ""
            info "可能的原因："
            echo "  1. 网络连接问题"
            echo "  2. GitHub 访问受限"
            echo ""
            info "建议："
            echo "  1. 检查网络连接"
            echo "  2. 或使用 git clone 方式安装"
            exit 1
        }
        tar -xzf "$TMP_DIR/master.tar.gz" -C "$TMP_DIR" --strip-components=1 || {
            error "解压失败"
            exit 1
        }
        rm -f "$TMP_DIR/master.tar.gz"
    else
        error "需要 git 或 curl 来安装"
        exit 1
    fi

    SKILL_SOURCE="$TMP_DIR/.claude/skills/obsidian-doc-linker"

    if [[ ! -d "$SKILL_SOURCE" ]]; then
        error "下载的文件不完整"
        exit 1
    fi

    info "源已下载到临时目录"

    # 标记需要复制而不是符号链接
    NEED_COPY=true
fi

# 获取规范路径（解析 .. 和符号链接）
if command -v realpath &> /dev/null; then
    SKILL_SOURCE="$(realpath "$SKILL_SOURCE")"
elif [[ "$OS" == "macos" ]]; then
    SKILL_SOURCE="$(perl -MCwd -e 'print Cwd::realpath($ARGV[0])' "$SKILL_SOURCE")"
fi

# 全局安装
SKILL_DEST="$CLAUDE_DIR/skills/obsidian-doc-linker"
info "全局安装到: $SKILL_DEST"
info "源目录: $SKILL_SOURCE"

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

# 创建符号链接或复制
if [[ "$NEED_COPY" == true ]]; then
    # 从临时目录复制
    cp -R "$SKILL_SOURCE" "$SKILL_DEST"
    success "Skill 已复制到: $SKILL_DEST"
    info "（已从 GitHub 下载）"
else
    # 创建符号链接
    ln -sf "$SKILL_SOURCE" "$SKILL_DEST"
    success "Skill 已安装到: $SKILL_DEST"
fi

echo ""
success "安装完成！"
echo ""

# 配置向导
if [[ -f "$CONFIG_FILE" ]]; then
    echo ""
    info "检测到已有配置，如需修改请手动编辑: $CONFIG_FILE"
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
echo "重启 Claude Code 后，使用自然语言即可调用："
echo ""
echo "  \"请帮我把项目链接到 Obsidian\""
echo "  \"把 CLAUDE.md 迁移到 Obsidian 仓库\""
echo "  \"将项目文档移动到 Obsidian\""
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""
