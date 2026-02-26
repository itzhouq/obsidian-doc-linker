# Obsidian Doc Linker

将项目文档（`CLAUDE.md`、`docs/`）迁移到 Obsidian vault 并创建符号链接，实现文档集中管理。

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows-lightgrey.svg)](https://github.com/itzhouq/obsidian-doc-linker)

## 功能特性

- **一键迁移**：自动将项目文档移动到 Obsidian vault 并创建符号链接
- **配置持久化**：首次配置后，所有项目自动使用相同配置
- **智能命名**：自动从项目文件夹名推断项目名称，去除版本号后缀
- **跨平台支持**：支持 macOS、Linux 和 Windows (Git Bash/WSL)
- **自定义分类**：支持按分类目录组织项目（如：工作项目、个人项目）
- **Claude 无感**：符号链接对 Claude Code 透明，不影响 AI 读写文档

## 快速开始

### 方法一：一键安装（推荐）

```bash
# 克隆仓库
git clone https://github.com/itzhouq/obsidian-doc-linker.git
cd obsidian-doc-linker

# 运行安装脚本
./install.sh
```

安装脚本会引导你：
1. 选择安装方式（全局/项目）
2. 配置 Obsidian vault 路径
3. 设置默认分类目录

### 方法二：一键安装（远程执行）

```bash
curl -fsSL https://raw.githubusercontent.com/itzhouq/obsidian-doc-linker/master/install.sh | bash
```

## 安装方式

### 全局安装

安装到 `~/.claude/skills/`，所有项目都可用：

```bash
./install.sh
# 选择选项 1
```

### 项目本地安装

安装到当前项目的 `.claude/skills/`，随项目版本控制：

```bash
./install.sh
# 选择选项 2
```

或作为 Git 子模块：

```bash
git submodule add https://github.com/itzhouq/obsidian-doc-linker.git .claude/skills/obsidian-doc-linker
```

## 使用方法

### 自然语言调用（推荐）

重启 Claude Code 后，直接使用自然语言：

```
请帮我把项目链接到 Obsidian
把 CLAUDE.md 迁移到 Obsidian 仓库
将项目文档移动到 Obsidian
```

### 直接运行脚本

```bash
# 全局安装
~/.claude/skills/obsidian-doc-linker/scripts/link_docs.sh

# 项目本地安装
.claude/skills/obsidian-doc-linker/scripts/link_docs.sh
```

### 命令参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--vault <path>` | Obsidian vault 路径 | 从配置读取 |
| `--name <name>` | 项目名称 | 智能推断 |
| `--category <name>` | 分类目录名 | "项目开发" |
| `--dry-run` | 预览操作，不实际执行 | - |
| `--help` | 显示帮助信息 | - |

### 使用示例

```bash
# 默认配置
link_docs.sh

# 完整指定
link_docs.sh --vault ~/vault --name "我的项目" --category "工作项目"

# 预览模式
link_docs.sh --dry-run
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

如需修改配置，可编辑此文件或重新运行 `./install.sh`。

## 项目结构

```
obsidian-doc-linker/
├── .claude/
│   └── skills/
│       └── obsidian-doc-linker/    # Skill 根目录
│           ├── SKILL.md            # Skill 定义
│           └── scripts/            # 可选脚本目录
│               └── link_docs.sh    # 执行脚本
├── install.sh                      # 一键安装脚本
├── README.md
├── LICENSE
└── .gitignore
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

### 团队协作怎么办？

此配置适用于个人开发。符号链接指向你的本地 Obsidian vault，团队成员无法访问。建议将 `CLAUDE.md` 和 `docs/` 添加到 `.gitignore`。

### 移动项目后怎么办？

重新运行脚本，配置保持不变，会重新创建符号链接。

### Skill 没有被识别？

确保：
1. Skill 目录结构正确：`.claude/skills/obsidian-doc-linker/SKILL.md`
2. `SKILL.md` 在技能根目录下，不在子目录中
3. 已重启 Claude Code

## 优势

| 优势 | 说明 |
|------|------|
| 文档集中管理 | 所有项目文档在一个 Obsidian vault，统一 Git 管理 |
| Claude 无感访问 | 符号链接对 Claude 透明，读取和编辑不受影响 |
| 代码仓库干净 | 项目 Git 只管理代码，文档独立维护 |
| 跨项目搜索 | Obsidian 可跨所有项目搜索文档 |
| 一次配置 | 首次配置后，所有项目自动使用 |

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 作者

itzhouq

## 致谢

- [Claude Code](https://claude.ai/code) - Anthropic 的 AI 编程助手

---

**觉得有用吗？请给个 ⭐️ Star！**
