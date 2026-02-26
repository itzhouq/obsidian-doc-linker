#!/bin/bash
# Obsidian Doc Linker - Plugin 一键安装脚本
# 支持 macOS 和 Linux

set -e

echo "🚀 Obsidian Doc Linker - Plugin 安装"
echo ""

# 检测操作系统
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

if [ "${MACHINE}" = "UNKNOWN:${OS}" ]; then
    echo "❌ 不支持的操作系统: ${OS}"
    echo "   请使用 macOS、Linux 或 Windows (Git Bash/WSL)"
    exit 1
fi

echo "✅ 检测到系统: ${MACHINE}"
echo ""

# 配置路径
CLAUDE_DIR="$HOME/.claude"
PLUGIN_DIR="$CLAUDE_DIR/plugins/cache/local"
CONFIG_FILE="$CLAUDE_DIR/plugins/installed_plugins.json"

# 检查 Claude Code 目录
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "❌ 未找到 Claude Code 目录: $CLAUDE_DIR"
    echo "   请确保已安装 Claude Code"
    exit 1
fi

echo "📂 Claude Code 目录: $CLAUDE_DIR"
echo ""

# 创建插件目录
mkdir -p "$PLUGIN_DIR"
echo "📁 插件目录: $PLUGIN_DIR"
echo ""

# 检查是否已安装
if [ -d "$PLUGIN_DIR/plugin" ]; then
    echo "⚠️  检测到已安装的 plugin"
    echo "   是否覆盖？(y/n)"
    read -r OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo "❌ 安装已取消"
        exit 0
    fi
    rm -rf "$PLUGIN_DIR/plugin"
    echo "🗑️  已删除旧版本"
    echo ""
fi

# 克隆仓库
echo "📥 正在下载..."
cd "$PLUGIN_DIR"
git clone https://github.com/itzhouq/obsidian-doc-linker.git
mv obsidian-doc-linker plugin

echo "✅ 下载完成"
echo ""

# 获取用户名
USERNAME=$(whoami)
INSTALL_PATH="$HOME/.claude/plugins/cache/local/plugin"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "📝 创建配置文件: $CONFIG_FILE"
    cat > "$CONFIG_FILE" << EOF
{
  "version": 2,
  "plugins": {}
}
EOF
fi

# 添加插件配置
echo "🔧 配置插件..."

# 使用 Python 或手动修改 JSON
if command -v python3 &> /dev/null; then
    python3 << EOF
import json
from datetime import datetime

config_file = "$CONFIG_FILE"
install_path = "$INSTALL_PATH"
timestamp = "$TIMESTAMP"

with open(config_file, "r") as f:
    config = json.load(f)

config["plugins"]["obsidian-doc-linker@local"] = [{
    "scope": "user",
    "installPath": install_path,
    "version": "2.0.0",
    "installedAt": timestamp,
    "lastUpdated": timestamp
}]

with open(config_file, "w") as f:
    json.dump(config, f, indent=2)

print("✅ 配置已更新")
EOF
else
    # 备用方案：手动添加
    BACKUP_FILE="$CONFIG_FILE.bak"
    cp "$CONFIG_FILE" "$BACKUP_FILE"

    # 读取现有配置并添加新插件
    # 注意：这是简化的处理，可能需要手动调整
    echo "⚠️  Python 未安装，请手动配置:"
    echo "   编辑 $CONFIG_FILE"
    echo "   添加以下内容到 plugins 对象:"
    echo ""
    cat << EOM
  "obsidian-doc-linker@local": [
    {
      "scope": "user",
      "installPath": "$INSTALL_PATH",
      "version": "2.0.0",
      "installedAt": "$TIMESTAMP",
      "lastUpdated": "$TIMESTAMP"
    }
  ]
EOM
    echo ""
    echo "💾 已备份原配置到: $BACKUP_FILE"
fi

echo ""
echo "✅ 安装完成！"
echo ""
echo "📋 下一步:"
echo "   1. 重启 Claude Code"
echo "   2. 使用 /link-docs 命令"
echo ""
echo "💡 使用示例:"
echo "   /link-docs                    # 使用默认配置"
echo "   /link-docs --help             # 查看帮助"
echo ""
