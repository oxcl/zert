<div align="center">

![Zert logo](./logo.png)

# ⚡ Zert

### 你的 `.zshrc` 一直在等待的插件管理器

**声明式. 可复现. 纯 Zsh.**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Zsh 5.0+](https://img.shields.io/badge/Zsh-5.0%2B-green?logo=gnu-bash&logoColor=white)](https://www.zsh.org/)
[![Pure Zsh](https://img.shields.io/badge/dependencies-git%20%2B%20curl-orange)](https://github.com/oxcl/zert)

</div>

---

Zert 是一个**纯 Zsh 插件管理器**，围绕一个简单的理念构建：你的插件应该直接在 `.zshrc` 中声明，锁定到精确的提交，并且可以像 npm 为 Node 项目所做的那样在任何机器上复现。

无需维护配置文件。无需记忆子命令。无需外部工具。只需要 Zsh、`git` 和 `curl`。

---

## ✨ 特性

- **内联声明式语法** — 直接在 `.zshrc` 中声明插件，无需单独的配置文件。
- **基于锁文件的可复现性** — `zert.lock` 将每个插件锁定到精确的 git 提交 SHA。提交它、分享它，在任何地方复现。
- **并行安装** — 使用 git 树克隆同时克隆多个插件，最小化带宽消耗。
- **零外部 UI 依赖** — 精美的 UI 完全由 ANSI 转义码构建。
- **自我管理** — 在 `.zshrc` 中使用 `zert zert` 启用。Zert 像其他插件一样跟踪和更新自身。
- **Oh-My-Zsh / Prezto 兼容** — 无需安装框架即可加载 OMZ 库和 Prezto 模块。

---

## 🚀 安装

将以下内容粘贴到 `.zshrc` 的顶部：

```zsh
export ZERT_PLUGINS_DIR="${ZERT_PLUGINS_DIR:-${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}/plugins}"; \
[[ -f "$ZERT_PLUGINS_DIR/zert/zert.zsh" ]] || \
(curl -fsSL https://raw.githubusercontent.com/oxcl/zert/main/bootstrap.sh | zsh); \
source "$ZERT_PLUGINS_DIR/zert/zert.zsh"

zert zert  # 管理 zert 自身（可选，启用自动更新）
```

就这样。第一次启动 shell 时，Zert 会自动引导自身。之后每次启动都从缓存的克隆中即时加载。

---

## 📦 用法

### 声明插件

在引导行之后将 `zert` 行添加到 `.zshrc`：

```zsh
# 自我管理（可选启用）
zert zert                          # 在锁文件中跟踪 zert 自身
zert zert --branch dev             # 跟踪 zert 的特定分支

# GitHub 简写
zert zsh-users/zsh-autosuggestions
zert zsh-users/zsh-syntax-highlighting

# 完整 URL（GitHub 或 GitLab）
zert https://gitlab.com/someone/their-plugin.git

# 特定分支
zert zsh-users/zsh-completions --branch main

# 锁定到精确提交（优先于锁文件）
zert zsh-users/zsh-autosuggestions --pin a1b2c3d4e5f6

# 本地插件
zert $ZDOTDIR/local-plugins/my-work-plugin

# Oh-My-Zsh 兼容 — 无需完整框架即可加载 OMZ 库
zert use ohmyzsh
zert ohmyzsh lib/clipboard
zert ohmyzsh plugins/git

# Prezto 兼容
zert use prezto
zert prezto modules/utility
```

### 标志

| 标志 | 功能 |
|------|------|
| `--no-alias` | 跳过加载插件的别名定义 |
| `--no-completion` | 跳过将补全文件添加到 `fpath` |
| `--only-completion` | 仅添加到 `fpath` — 不加载插件 |
| `--pin <sha>` | 锁定到精确的提交 SHA |
| `--branch <name>` | 克隆特定分支 |

---

## 🔧 子命令

```zsh
zert list          # 显示所有已声明的插件及其状态
zert update        # 拉取所有未锁定插件的最新提交
zert prune         # 删除配置中不再声明的插件
```

---

## 🔒 锁文件

每次安装或更新后，Zert 会将 `zert.lock` 写入 `$ZDOTDIR`（通常是 `$HOME`）：

```
# 自动生成的文件。请勿手动编辑。
# 将此文件提交到版本控制以实现可复现的安装。
version::1
zsh-users/zsh-autosuggestions::git::https://github.com/zsh-users/zsh-autosuggestions::a1b2c3d4e5f6...::pin=false
zsh-users/zsh-syntax-highlighting::git::https://github.com/zsh-users/zsh-syntax-highlighting::f7g8h9i0j1k2...::
ohmyzsh::ohmyzsh::ohmyzsh::3l4m5n6o7p8q...::
```

**将 `zert.lock` 提交到你的 dotfiles 仓库。** 在新机器上，Zert 读取锁文件并以完全相同的提交克隆每个插件 — 与其他机器完全一致。

---

## ⚙️ 配置

Zert 完全通过环境变量配置。在引导行之前设置它们：

```zsh
export ZERT_DIR="$HOME/.zert"               # 更改 Zert 的安装位置
export ZERT_PLUGINS_DIR="$ZERT_DIR/plugins" # 更改插件的克隆位置
export ZERT_LOCKFILE="$HOME/.zert.lock"     # 更改锁文件路径
```

## 🏗️ 工作原理

```
.zshrc 启动
│
├─ 1. 引导行 — source zert.zsh
│
├─ 2. 处理 zert 声明（按顺序）
│   ├─ 缺失的插件 → 并行 git clone + zcompile
│   └─ 写入/更新 zert.lock
│
└─ 3. 加载插件（按顺序，严格排序）
    ├─ 加载每个插件的主文件
    └─ 遇到第一个失败时停止并报告
```

**安装是并行的，加载是按顺序的。** 这为你提供了并行克隆的速度，同时不会出现任何排序问题。

## 📄 许可证

GNU 通用公共许可证 v3.0 — 详见 [`LICENSE`](./LICENSE)。

---

<div align="center">

**以极致的细节追求打造。**

[github.com/oxcl/zert](https://github.com/oxcl/zert)

</div>
