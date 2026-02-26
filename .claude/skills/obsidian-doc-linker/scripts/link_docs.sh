#!/bin/bash
# Obsidian Doc Linker - 将项目文档链接到 Obsidian 仓库
# 跨平台支持：macOS / Linux / Windows (Git Bash / WSL)

set -e

# ==================== 默认配置 ====================
DEFAULT_CATEGORY="项目开发"
CONFIG_DIR="$HOME/.claude/obsidian-doc-linker"
CONFIG_FILE="$CONFIG_DIR/config.json"

# ==================== 工具函数 ====================

# 检测操作系统
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux";;
        Darwin*)    echo "macos";;
        MINGW*|MSYS*|CYGWIN*) echo "windows";;
        *)          echo "unknown";;
    esac
}

# 获取项目文件夹名并去除版本号后缀
clean_project_name() {
    local name="$1"
    # 去除常见版本号后缀：-v1.0, -v2.3, _1.0, @2.0 等
    echo "$name" | sed -E 's/[-_@][vV]?[0-9]+\.[0-9]+.*$//;s/[-_]([0-9]+\.)?[0-9]+$//'
}

# 检查路径是否存在
path_exists() {
    local path="$1"
    if [[ "$OS" == "windows" ]]; then
        # Windows 路径检查
        if [[ -d "$path" || -d "$path.exe" ]]; then
            return 0
        fi
    else
        if [[ -d "$path" ]]; then
            return 0
        fi
    fi
    return 1
}

# 创建目录（跨平台）
create_dir() {
    local path="$1"
    if [[ ! -d "$path" ]]; then
        mkdir -p "$path"
    fi
}

# ==================== 配置管理 ====================

# 加载配置
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # 使用 jq 或简单 grep 解析 JSON
        if command -v jq &> /dev/null; then
            VAULT_PATH=$(jq -r '.vault_path // empty' "$CONFIG_FILE" 2>/dev/null)
            CATEGORY=$(jq -r '.category // "'"$DEFAULT_CATEGORY"'"' "$CONFIG_FILE" 2>/dev/null)
        else
            # 简单解析（备用方案）
            VAULT_PATH=$(grep '"vault_path"' "$CONFIG_FILE" 2>/dev/null | sed 's/.*"vault_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
            CATEGORY=$(grep '"category"' "$CONFIG_FILE" 2>/dev/null | sed 's/.*"category"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        fi
    else
        CATEGORY="$DEFAULT_CATEGORY"
    fi
}

# 保存配置
save_config() {
    local vault_path="$1"
    local category="$2"

    create_dir "$CONFIG_DIR"

    if command -v jq &> /dev/null; then
        echo "{\"vault_path\": \"$vault_path\", \"category\": \"$category\"}" > "$CONFIG_FILE"
    else
        # 手动构建 JSON（处理路径中的特殊字符）
        vault_escaped=$(echo "$vault_path" | sed 's/\\/\\\\/g; s/"/\\"/g')
        cat_escaped=$(echo "$category" | sed 's/\\/\\\\/g; s/"/\\"/g')
        echo "{\"vault_path\": \"$vault_escaped\", \"category\": \"$cat_escaped\"}" > "$CONFIG_FILE"
    fi
}

# ==================== 参数解析 ====================

OS=$(detect_os)
PROJECT_PATH=""
VAULT_OVERRIDE=""
PROJECT_NAME_OVERRIDE=""
CATEGORY_OVERRIDE=""
DRY_RUN=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --vault)
            VAULT_OVERRIDE="$2"
            shift 2
            ;;
        --name)
            PROJECT_NAME_OVERRIDE="$2"
            shift 2
            ;;
        --category)
            CATEGORY_OVERRIDE="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --vault <path>     指定 Obsidian vault 路径（覆盖配置）"
            echo "  --name <name>      指定项目名称（覆盖自动推断）"
            echo "  --category <name>  指定分类目录，默认：$DEFAULT_CATEGORY"
            echo "  --dry-run          预览操作，不实际执行"
            echo "  -h, --help         显示帮助信息"
            echo ""
            echo "示例:"
            echo "  $0                                    # 使用配置和默认值"
            echo "  $0 --name \"我的项目\"                # 指定项目名"
            echo "  $0 --vault ~/itzhouq_vault --name \"项目A\"    # 完整指定"
            echo "  $0 --category \"工作项目\"              # 自定义分类"
            exit 0
            ;;
        *)
            # 位置参数：项目路径
            if [[ -z "$PROJECT_PATH" ]]; then
                PROJECT_PATH="$1"
            fi
            shift
            ;;
    esac
done

# ==================== 项目路径处理 ====================

# 获取当前工作目录（如果未指定项目路径）
if [[ -z "$PROJECT_PATH" ]]; then
    PROJECT_PATH="$(pwd)"
fi

# 规范化路径
if [[ "$OS" == "windows" ]]; then
    # Windows: 转换为绝对路径
    PROJECT_PATH=$(cd "$PROJECT_PATH" 2>/dev/null && pwd) || PROJECT_PATH="$PROJECT_PATH"
else
    PROJECT_PATH=$(eval echo "$PROJECT_PATH")
fi

# 检查项目路径是否存在
if [[ ! -d "$PROJECT_PATH" ]]; then
    echo "❌ 错误: 项目目录不存在: $PROJECT_PATH"
    exit 1
fi

# ==================== 项目名称处理 ====================

# 获取项目文件夹名
PROJECT_DIRNAME=$(basename "$PROJECT_PATH")

# 去除版本号后缀
PROJECT_NAME_CLEAN=$(clean_project_name "$PROJECT_DIRNAME")

# 应用参数覆盖
if [[ -n "$PROJECT_NAME_OVERRIDE" ]]; then
    PROJECT_NAME="$PROJECT_NAME_OVERRIDE"
else
    PROJECT_NAME="$PROJECT_NAME_CLEAN"
fi

# ==================== 加载配置 ====================

load_config

# 应用参数覆盖
if [[ -n "$VAULT_OVERRIDE" ]]; then
    VAULT_PATH="$VAULT_OVERRIDE"
fi

if [[ -n "$CATEGORY_OVERRIDE" ]]; then
    CATEGORY="$CATEGORY_OVERRIDE"
fi

# ==================== 配置检查 ====================

if [[ -z "$VAULT_PATH" ]]; then
    echo "⚙️  未配置 Obsidian vault 路径"
    echo ""
    echo "请输入你的 Obsidian vault 路径（示例：~/Documents/vault 或 ~/itzhouq_vault/项目开发）:"
    read -r USER_VAULT

    # 规范化用户输入
    USER_VAULT=$(eval echo "$USER_VAULT")

    if [[ ! -d "$USER_VAULT" ]]; then
        echo "⚠️  警告: 路径不存在: $USER_VAULT"
        echo "是否创建此目录？(y/n)"
        read -r CREATE_DIR
        if [[ "$CREATE_DIR" =~ ^[Yy]$ ]]; then
            mkdir -p "$USER_VAULT"
            echo "✅ 目录已创建"
        else
            echo "❌ 操作已取消"
            exit 1
        fi
    fi

    VAULT_PATH="$USER_VAULT"
    save_config "$VAULT_PATH" "$CATEGORY"
    echo "✅ 配置已保存到: $CONFIG_FILE"
fi

# 构建完整的 Obsidian 项目路径
OBSIDIAN_PROJECT_PATH="$VAULT_PATH/$CATEGORY/$PROJECT_NAME"

# ==================== 执行操作 ====================

echo ""
echo "📂 项目路径: $PROJECT_PATH"
echo "📝 项目名称: $PROJECT_NAME"
echo "📂 Obsidian 路径: $OBSIDIAN_PROJECT_PATH"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo "🔍 [DRY RUN] 预览操作（不会实际执行）:"
    echo "  1. 创建目录: $OBSIDIAN_PROJECT_PATH"
    if [[ -f "$PROJECT_PATH/CLAUDE.md" && ! -L "$PROJECT_PATH/CLAUDE.md" ]]; then
        echo "  2. 移动: $PROJECT_PATH/CLAUDE.md → $OBSIDIAN_PROJECT_PATH/CLAUDE.md"
    fi
    if [[ -d "$PROJECT_PATH/docs" && ! -L "$PROJECT_PATH/docs" ]]; then
        echo "  3. 移动: $PROJECT_PATH/docs → $OBSIDIAN_PROJECT_PATH/docs"
    fi
    echo "  4. 创建符号链接..."
    echo "  5. 更新 .gitignore..."
    exit 0
fi

# 1. 创建 Obsidian 目录
echo "📁 创建 Obsidian 目录..."
mkdir -p "$OBSIDIAN_PROJECT_PATH"

# 2. 处理 CLAUDE.md
if [[ -f "$PROJECT_PATH/CLAUDE.md" && ! -L "$PROJECT_PATH/CLAUDE.md" ]]; then
    echo "📄 移动 CLAUDE.md 到 Obsidian..."
    mv "$PROJECT_PATH/CLAUDE.md" "$OBSIDIAN_PROJECT_PATH/CLAUDE.md"
    CLAUDE_MOVED=true
elif [[ -L "$PROJECT_PATH/CLAUDE.md" ]]; then
    echo "ℹ️  CLAUDE.md 已是符号链接，跳过"
    CLAUDE_MOVED=false
else
    echo "ℹ️  CLAUDE.md 不存在，跳过"
    CLAUDE_MOVED=false
fi

# 3. 处理 docs 目录
if [[ -d "$PROJECT_PATH/docs" && ! -L "$PROJECT_PATH/docs" ]]; then
    echo "📂 移动 docs/ 到 Obsidian..."
    mv "$PROJECT_PATH/docs" "$OBSIDIAN_PROJECT_PATH/docs"
    DOCS_MOVED=true
elif [[ -L "$PROJECT_PATH/docs" ]]; then
    echo "ℹ️  docs/ 已是符号链接，跳过"
    DOCS_MOVED=false
else
    echo "ℹ️  docs/ 不存在，跳过"
    DOCS_MOVED=false
fi

echo ""

# 4. 创建符号链接
if [[ "$CLAUDE_MOVED" == true ]]; then
    echo "🔗 创建 CLAUDE.md 符号链接..."
    ln -s "$OBSIDIAN_PROJECT_PATH/CLAUDE.md" "$PROJECT_PATH/CLAUDE.md"
fi

if [[ "$DOCS_MOVED" == true ]]; then
    echo "🔗 创建 docs/ 符号链接..."
    ln -s "$OBSIDIAN_PROJECT_PATH/docs" "$PROJECT_PATH/docs"
fi

echo ""

# 5. 更新 .gitignore
if [[ -f "$PROJECT_PATH/.gitignore" ]]; then
    echo "📝 更新 .gitignore..."
    if ! grep -q "^CLAUDE.md$" "$PROJECT_PATH/.gitignore" 2>/dev/null; then
        echo "CLAUDE.md" >> "$PROJECT_PATH/.gitignore"
    fi
    if ! grep -q "^docs/$" "$PROJECT_PATH/.gitignore" 2>/dev/null; then
        echo "docs/" >> "$PROJECT_PATH/.gitignore"
    fi
else
    echo "ℹ️  .gitignore 不存在（可能不是 Git 仓库），跳过"
fi

echo ""
echo "✅ 完成！"
echo ""
echo "验证结果:"
ls -la "$PROJECT_PATH" | grep -E "CLAUDE.md|docs" || true
echo ""
echo "Obsidian 仓库: $OBSIDIAN_PROJECT_PATH"
