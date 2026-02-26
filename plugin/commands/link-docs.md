---
description: 将项目文档（CLAUDE.md、docs/）链接到 Obsidian 仓库
---

使用 obsidian-doc-linker skill 将项目文档迁移到 Obsidian 仓库并创建符号链接。

## 参数

所有参数都是可选的：

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--vault <path>` | Obsidian vault 路径 | 首次使用时提示输入，后续自动使用已保存的配置 |
| `--name <name>` | 项目名称 | 自动从项目文件夹名推断（去除版本号后缀） |
| `--category <name>` | 分类目录名称 | "项目开发" |
| `--dry-run` | 预览操作，不实际执行 | - |

## 示例

```bash
# 使用默认配置（首次使用会提示输入 vault 路径）
/link-docs

# 指定项目名称
/link-docs --name "我的项目"

# 指定 vault 路径和项目名称
/link-docs --vault ~/vault --name "项目A"

# 自定义分类目录
/link-docs --category "工作项目"

# 预览操作（不实际执行）
/link-docs --dry-run

# 完整示例
/link-docs --vault ~/Documents/vault --name "我的项目" --category "工作项目"
```

## 首次使用

首次运行时会提示输入 Obsidian vault 路径，配置会自动保存到 `~/.claude/obsidian-doc-linker/config.json`，后续使用无需重复输入。

## 项目名称推断

脚本会自动从项目文件夹名推断项目名称，并去除常见版本号后缀：

| 项目文件夹 | 推断的项目名 |
|-----------|-------------|
| `xinyunqian-v2.3` | `xinyunqian` |
| `myapp-1.0.0` | `myapp` |
| `project_v2` | `project` |
| `我的项目` | `我的项目` |
