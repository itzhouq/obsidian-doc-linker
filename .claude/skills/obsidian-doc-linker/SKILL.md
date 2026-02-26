---
name: obsidian-doc-linker
description: 将项目文档（CLAUDE.md、docs/）迁移到 Obsidian vault 并创建符号链接。跨平台支持，配置持久化，项目名智能推断。触发词：Obsidian、符号链接、文档迁移、link docs、symlink、vault。
---

# Obsidian Doc Linker

将项目文档迁移到 Obsidian vault 并创建符号链接，实现文档集中管理。

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

## 执行步骤

当用户请求将文档迁移到 Obsidian 时：

1. **确认或获取配置**
   - 检查 `~/.claude/obsidian-doc-linker/config.json`
   - 如不存在，提示用户输入 vault 路径和分类名称

2. **推断项目名称**
   - 从当前项目文件夹名提取
   - 去除版本号后缀（如 `-v2.0`、`_1.0`）

3. **执行迁移**
   ```bash
   .claude/skills/obsidian-doc-linker/scripts/link_docs.sh [选项]
   ```

4. **验证结果**
   - 检查符号链接是否正确创建
   - 确认 `.gitignore` 已更新

## 参数说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--vault <path>` | Obsidian vault 路径 | 从配置读取或提示输入 |
| `--name <name>` | 项目名称 | 从文件夹名智能推断 |
| `--category <name>` | 分类目录名 | "项目开发" |
| `--dry-run` | 预览操作，不实际执行 | - |

## 示例调用

```bash
# 默认配置
.claude/skills/obsidian-doc-linker/scripts/link_docs.sh

# 完整指定
.claude/skills/obsidian-doc-linker/scripts/link_docs.sh --vault ~/vault --name "我的项目" --category "工作项目"

# 预览模式
.claude/skills/obsidian-doc-linker/scripts/link_docs.sh --dry-run
```

## 项目名推断规则

| 项目文件夹 | 推断结果 |
|-----------|---------|
| `xinyunqian-v2.3` | `xinyunqian` |
| `myapp-1.0.0` | `myapp` |
| `project_v2` | `project` |
| `我的项目` | `我的项目` |

## 配置文件

配置保存位置：`~/.claude/obsidian-doc-linker/config.json`

```json
{
  "vault_path": "/path/to/vault",
  "category": "项目开发"
}
```

## 规则

- **必须**先确认用户已安装 Obsidian 并有可用 vault
- **不要**在用户拒绝的情况下修改 `.gitignore`
- **必须**在执行前用 `--dry-run` 模式预览（如果用户不确定）
- 警告用户符号链接在团队协作中的限制

## 注意事项

- 符号链接对 Claude 透明，不影响 AI 读写
- 团队成员无法访问个人的符号链接
- 移动项目后需重新运行脚本
