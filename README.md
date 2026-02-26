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

## 安装

### 方法一：直接下载（推荐）

1. 下载最新的 `obsidian-doc-linker.skill` 文件
2. 将文件复制到 `~/.claude/skills/` 目录
3. 重启 Claude Code

### 方法二：Git Clone

```bash
cd ~/.claude/skills/
git clone https://github.com/itzhouq/obsidian-doc-linker.git
```

### 方法三：通过 Plugin Marketplace（待发布）

```bash
/plugin marketplace add itzhouq/skills-marketplace
/plugin install obsidian-doc-linker@skills-marketplace
```

## 使用方法

### 斜杠命令（推荐）

```bash
# 使用默认配置（首次使用会提示输入 vault 路径）
/link-docs

# 指定项目名称
/link-docs --name "我的项目"

# 指定 vault 路径
/link-docs --vault ~/itzhouq_vault

# 自定义分类目录
/link-docs --category "工作项目"

# 预览操作（不实际执行）
/link-docs --dry-run

# 完整示例
/link-docs --vault ~/Documents/vault --name "我的项目" --category "工作项目"
```

### 自然语言调用

```
请帮我把项目链接到 Obsidian
把 CLAUDE.md 迁移到 Obsidian 仓库
将项目文档移动到 Obsidian
```

## 工作原理

```
Obsidian Vault/
└── 项目开发/              # 默认分类（可自定义）
    └── my-mall/         # 智能推断的项目名
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
| `--vault <path>` | Obsidian vault 路径 | 首次提示，后续自动读取 |
| `--name <name>` | 项目名称 | 从文件夹名智能推断 |
| `--category <name>` | 分类目录名 | "项目开发" |
| `--dry-run` | 预览操作 | - |

## 项目名推断

自动从项目文件夹名推断项目名称，去除版本号后缀：

| 项目文件夹 | 推断结果 |
|-----------|---------|
| `my-mall-v2.3` | `my-mall` |
| `myapp-1.0.0` | `myapp` |
| `project_v2` | `project` |
| `我的项目` | `我的项目` |

## 配置文件

配置自动保存到 `~/.claude/obsidian-doc-linker/config.json`：

```json
{
  "vault_path": "/Users/itzhouq/itzhouq_vault",
  "category": "项目开发"
}
```

## 跨平台支持

| 平台 | 状态 | 说明 |
|------|------|------|
| macOS | ✅ 完全支持 | 原生符号链接 |
| Linux | ✅ 完全支持 | 原生符号链接 |
| Windows | ✅ 支持 | Git Bash / WSL 环境 |

## 常见问题

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

# 检查 skill 是否加载
# 应该在系统提示中看到 obsidian-doc-linker
```

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 作者

itzhouq

## 致谢

- [Claude Code](https://claude.ai/code) - Anthropic 的 AI 编程助手

---

**觉得有用吗？请给个 ⭐️ Star！**
