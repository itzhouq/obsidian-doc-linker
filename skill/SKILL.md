---
name: obsidian-doc-linker
description: 将项目文档（CLAUDE.md、docs/）迁移到 Obsidian 仓库并在项目中创建符号链接，实现文档集中管理。跨平台支持（macOS/Linux/Windows），配置自动持久化，项目名智能推断。适用于需要将项目文档与代码分离、使用 Obsidian 管理所有项目笔记的场景。触发词：Obsidian、符号链接、文档迁移、link docs、symlink、文档管理。
---

# Obsidian Doc Linker

将项目文档迁移到 Obsidian 仓库并创建符号链接，实现文档集中管理。

## 工作原理

```
Obsidian Vault/
└── <分类>/          # 默认：项目开发（可自定义）
    └── <项目名>/     # 智能推断或手动指定
        ├── CLAUDE.md  # 真实文件
        └── docs/      # 真实目录

项目目录/
├── CLAUDE.md  # → 符号链接到 Obsidian
├── docs/      # → 符号链接到 Obsidian
└── .gitignore # 忽略上述文件
```

## 使用方式

### 方式 1：斜杠命令（推荐）

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

# 完整示例
/link-docs --vault ~/Documents/vault --name "我的项目" --category "工作项目"
```

### 方式 2：自然语言

```
请帮我把项目链接到 Obsidian
把 CLAUDE.md 迁移到 Obsidian 仓库
将项目文档移动到 Obsidian
```

## 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--vault <path>` | Obsidian vault 路径 | 首次提示，后续自动读取配置 |
| `--name <name>` | 项目名称 | 从文件夹名智能推断 |
| `--category <name>` | 分类目录名 | "项目开发" |
| `--dry-run` | 预览操作 | - |

## 功能特性

### 智能项目名推断

自动从项目文件夹名推断项目名称，去除版本号后缀：

| 项目文件夹 | 推断结果 |
|-----------|---------|
| `xinyunqian-v2.3` | `xinyunqian` |
| `myapp-1.0.0` | `myapp` |
| `project_v2` | `project` |
| `我的项目` | `我的项目` |

### 配置持久化

首次使用时输入 vault 路径，配置自动保存到 `~/.claude/obsidian-doc-linker/config.json`，后续无需重复输入。

### 跨平台支持

- macOS：原生支持
- Linux：原生支持
- Windows：Git Bash / WSL 支持

## 验证结果

```bash
# 检查符号链接是否创建成功
ls -la <项目路径> | grep -E "CLAUDE.md|docs"

# 应显示类似：
# lrwxr-xr-x  ...  CLAUDE.md -> /path/to/vault/项目开发/...
# lrwxr-xr-x  ...  docs -> /path/to/vault/项目开发/...
```

## 优势

| 优势 | 说明 |
|------|------|
| 文档集中管理 | 所有项目文档在一个 Obsidian vault，统一 Git 管理 |
| Claude 无感访问 | 符号链接对 Claude 透明，读取和编辑不受影响 |
| 代码仓库干净 | 项目 Git 只管理代码，文档独立维护 |
| 跨项目搜索 | Obsidian 可跨所有项目搜索文档 |
| 一次配置 | 首次配置后，其他项目一键完成 |

## 注意事项

- **符号链接**：需要操作系统支持符号链接（macOS/Linux 原生，Windows 需要开发者模式或 Git Bash）
- **团队协作**：此配置适用于个人开发，团队成员无法访问你的符号链接
- **IDE 兼容**：IntelliJ IDEA、VS Code 等现代 IDE 原生支持符号链接
- **路径变更**：移动项目目录后需重新运行命令，配置保持不变
