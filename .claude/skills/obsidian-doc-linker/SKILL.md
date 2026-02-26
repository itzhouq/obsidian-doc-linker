---
name: obsidian-doc-linker
description: 当用户请求将项目文档链接到 Obsidian、移动文档到 Obsidian vault、创建符号链接、或管理 CLAUDE.md/docs 目录时使用。支持跨平台、配置持久化、智能项目名推断。触发短语："链接到 Obsidian"、"迁移到 Obsidian"、"创建符号链接"、"link to obsidian"、"move docs to vault"、"symlink docs"。
---

# Obsidian Doc Linker

将项目文档迁移到 Obsidian vault 并创建符号链接。

## 何时使用

用户说以下任何内容时，使用此 skill：
- "链接到 Obsidian" / "link to Obsidian"
- "迁移到 Obsidian vault"
- "创建符号链接" / "create symlink"
- "把文档移到 Obsidian"
- "link docs"
- "管理 CLAUDE.md"

## 执行步骤

1. **检查配置**
   ```bash
   cat ~/.claude/obsidian-doc-linker/config.json
   ```

2. **如无配置，获取信息**
   - Obsidian vault 路径
   - 分类目录名（默认：项目开发）

3. **执行迁移脚本**
   ```bash
   ~/.claude/skills/obsidian-doc-linker/scripts/link_docs.sh
   ```

4. **验证结果**
   ```bash
   ls -la CLAUDE.md docs/
   ```

## 参数

| 参数 | 说明 |
|------|------|
| `--vault <path>` | Vault 路径 |
| `--name <name>` | 项目名称 |
| `--category <name>` | 分类目录 |
| `--dry-run` | 预览模式 |

## 规则

- 执行前确认用户有 Obsidian vault
- 首次运行需配置 vault 路径
- 符号链接对团队协作有限制
