# Obsidian Doc Linker

将项目文档（`CLAUDE.md`、`docs/`）迁移到 Obsidian 仓库并在项目中创建符号链接，实现文档集中管理。

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)](https://github.com/itzhouq/obsidian-doc-linker)

## 功能特性

- **一键迁移**：自动将项目文档移动到 Obsidian vault 并创建符号链接
- **配置持久化**：首次配置后，其他项目一键完成
- **智能命名**：自动从项目文件夹名推断项目名称，去除版本号后缀
- **跨平台支持**：支持 macOS、Linux 和 Windows (Git Bash/WSL)
- **自定义分类**：支持按分类目录组织项目（如：工作项目、个人项目）
- **Claude 无感**：符号链接对 Claude Code 透明，不影响 AI 读写文档
- **斜杠命令**：支持 `/link-docs` 快捷命令

## 安装

### 方法一：Plugin 安装（推荐，支持 `/link-docs` 命令）

#### macOS / Linux

```bash
# 1. 克隆到 plugin 目录
cd ~/.claude/plugins/cache/local/
git clone https://github.com/itzhouq/obsidian-doc-linker.git
mv obsidian-doc-linker plugin

# 2. 自动配置插件（一键安装）
curl -fsSL https://raw.githubusercontent.com/itzhouq/obsidian-doc-linker/master/install.sh | bash

# 3. 重启 Claude Code
```

#### Windows (Git Bash / WSL)

```bash
# 1. 克隆到 plugin 目录
cd ~/.claude/plugins/cache/local/
git clone https://github.com/itzhouq/obsidian-doc-linker.git
mv obsidian-doc-linker plugin

# 2. 手动配置
# 编辑 ~/.claude/plugins/installed_plugins.json，添加以下内容：
```

```json
{
  "version": 2,
  "plugins": {
    "obsidian-doc-linker@local": [
      {
        "scope": "user",
        "installPath": "C:\\\\Users\\\\YOUR_USERNAME\\\\.claude\\\\plugins\\\\cache\\\\local\\\\plugin",
        "version": "2.0.0",
        "installedAt": "2025-01-01T00:00:00.000Z",
        "lastUpdated": "2025-01-01T00:00:00.000Z"
      }
    ]
  }
}
```

**重启 Claude Code** 即可使用 `/link-docs` 命令。

### 方法二：仅 Skill 安装（仅自然语言调用）

```bash
cd ~/.claude/skills/
git clone https://github.com/itzhouq/obsidian-doc-linker.git
```

重启 Claude Code，通过自然语言调用。

### 方法三：手动下载

1. 下载 `obsidian-doc-linker.skill` 文件
2. 复制到 `~/.claude/skills/` 目录
3. 重启 Claude Code

## 使用方法

### 斜杠命令（需要 Plugin 安装）

```bash
# 使用默认配置（首次使用会提示输入 vault 路径）
/link-docs

# 指定项目名称
/link-docs --name "我的项目"

# 指定 vault 路径
/link-docs --vault ~/vault

# 自定义分类目录
/link-docs --category "工作项目"

# 预览操作（不实际执行）
/link-docs --dry-run

# 查看帮助
/link-docs --help

# 完整示例
/link-docs --vault ~/Documents/vault --name "我的项目" --category "工作项目"
```

### 自然语言调用（Skill 或 Plugin 都支持）

```
请帮我把项目链接到 Obsidian
把 CLAUDE.md 迁移到 Obsidian 仓库
将项目文档移动到 Obsidian
```

## 工作原理

```
Obsidian Vault/
└── 项目开发/              # 默认分类（可自定义）
    └── xinyunqian/       # 智能推断的项目名
        ├── CLAUDE.md       # 真实文件
        └── docs/           # 真实目录

项目目录/
├── CLAUDE.md  → 符号链接到 Obsidian
├── docs/      → 符号链接到 Obsidian
└── .gitignore # 忽略上述文件
```

## 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--vault <path>` | Obsidian vault 路径 | 首次提示，后续自动读取配置 |
| `--name <name>` | 项目名称 | 从文件夹名智能推断 |
| `--category <name>` | 分类目录名 | "项目开发" |
| `--dry-run` | 预览操作，不实际执行 | - |
| `--help` | 显示帮助信息 | - |

## 项目名推断

自动从项目文件夹名推断项目名称，去除版本号后缀：

| 项目文件夹 | 推断结果 |
|-----------|---------|
| `xinyunqian-v2.3` | `xinyunqian` |
| `myapp-1.0.0` | `myapp` |
| `project_v2` | `project` |
| `我的项目` | `我的项目` |

## 配置文件

配置自动保存到 `~/.claude/obsidian-doc-linker/config.json`：

```json
{
  "vault_path": "/Users/xxx/vault",
  "category": "项目开发"
}
```

## 安装方式对比

| 方式 | 斜杠命令 | 自然语言 | 难度 |
|------|---------|---------|------|
| Plugin 安装 | ✅ | ✅ | 中 |
| 仅 Skill 安装 | ❌ | ✅ | 低 |

## 跨平台支持

| 平台 | 状态 | 说明 |
|------|------|------|
| macOS | ✅ 完全支持 | 原生符号链接 |
| Linux | ✅ 完全支持 | 原生符号链接 |
| Windows | ✅ 支持 | Git Bash / WSL 环境 |

## 常见问题

### /link-docs 命令无法使用？

请确保使用 **Plugin 安装** 方式，而不是仅 Skill 安装。

### 符号链接创建失败？

**macOS**：确保有文件系统写入权限

**Windows**：
- 启用开发者模式
- 或使用 Git Bash / WSL 运行命令

### 如何修改已保存的配置？

编辑 `~/.claude/obsidian-doc-linker/config.json` 或使用 `--vault` 参数覆盖

### 团队协作怎么办？

此配置适用于个人开发。团队成员需要各自配置自己的 Obsidian 路径。

### 移动项目后怎么办？

重新运行 `/link-docs`，配置保持不变，会重新创建符号链接。

## 验证安装

```bash
# 检查命令是否可用
/link-docs --help

# 应该看到帮助信息
```

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 作者

itzhouq

## 致谢

- [Claude Code](https://claude.ai/code) - Anthropic 的 AI 编程助手

---

**觉得有用吗？请给个 ⭐️ Star！**
