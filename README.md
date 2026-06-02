<div align="center">

![Zert logo](./logo.png)

**[中文](./README_zh.md) | [Русский](./README_ru.md) | [Español](./README_es.md) | [Português](./README_pt.md)**

# ⚡ Zert

### The plugin manager your `.zshrc` has been waiting for.

**Declarative. Reproducible. Pure Zsh.**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Zsh 5.0+](https://img.shields.io/badge/Zsh-5.0%2B-green?logo=gnu-bash&logoColor=white)](https://www.zsh.org/)
[![Pure Zsh](https://img.shields.io/badge/dependencies-git%20%2B%20curl-orange)](https://github.com/oxcl/zert)

</div>

---

Zert is a **pure-Zsh plugin manager** built around a simple idea: your plugins should be declared directly in your `.zshrc`, pinned to exact commits, and reproducible on any machine just like npm does for Node projects.

No config files to maintain. No subcommands to memorize No external tools. Just Zsh, `git`, and `curl`.

---

## ✨ Features

- **Inline, declarative syntax** — declare plugins directly in `.zshrc`. No separate config file.
- **Lockfile-based reproducibility** — `zert.lock` pins every plugin to an exact git commit SHA. Commit it. Share it. Reproduce it anywhere.
- **Parallel installs** — clones multiple plugins simultaneously using git treeless clones for minimal bandwidth.
- **Zero external UI dependencies** — beautiful UI built entirely from ANSI escape codes.
- **Self-managing** — Opt in with `zert zert` in your `.zshrc`. Zert tracks and updates itself like any other plugin.
- **Oh-My-Zsh / Prezto compatibility** — load OMZ libs and Prezto modules without installing either framework.

---

## 🚀 Install

Paste this at the top of your `.zshrc`:

```zsh
export ZERT_PLUGINS_DIR="${ZERT_PLUGINS_DIR:-${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}/plugins}"; \
[[ -f "$ZERT_PLUGINS_DIR/zert/zert.zsh" ]] || \
(curl -fsSL https://raw.githubusercontent.com/oxcl/zert/main/bootstrap.sh | zsh); \
source "$ZERT_PLUGINS_DIR/zert/zert.zsh"

zert zert  # manage zert itself (optional, enables self-updates)
```

That's it. The first time your shell starts, Zert bootstraps itself. On every subsequent start, it loads instantly from the cached clone.

---

## 📦 Usage

### Declaring Plugins

Add `zert` lines to your `.zshrc` after the bootstrap line:

```zsh
# Self-management (opt-in)
zert zert                          # track zert itself in the lockfile
zert zert --branch dev             # track a specific branch of zert

# GitHub shorthand
zert zsh-users/zsh-autosuggestions
zert zsh-users/zsh-syntax-highlighting

# Full URL (GitHub or GitLab)
zert https://gitlab.com/someone/their-plugin.git

# Specific branch
zert zsh-users/zsh-completions --branch main

# Pin to an exact commit (takes precedence over lockfile)
zert zsh-users/zsh-autosuggestions --pin a1b2c3d4e5f6

# Local plugin 
zert $ZDOTDIR/local-plugins/my-work-plugin

# Oh-My-Zsh compatibility — load OMZ libs without the full framework
zert use ohmyzsh
zert ohmyzsh lib/clipboard
zert ohmyzsh plugins/git

# Prezto compatibility
zert use prezto
zert prezto modules/utility
```

### Flags

| Flag | What it does |
|------|-------------|
| `--no-alias` | Skip loading the plugin's alias definitions |
| `--no-completion` | Skip adding completion files to `fpath` |
| `--only-completion` | Only add to `fpath` — don't source the plugin |
| `--pin <sha>` | Pin to an exact commit SHA |
| `--branch <name>` | Clone a specific branch |

---

## 🔧 Subcommands

```zsh
zert list          # Show all declared plugins + their status
zert update        # Pull latest commits for all unpinned plugins
zert prune         # Delete plugins no longer declared in your config
```

---

## 🔒 The Lockfile

After every install or update, Zert writes `zert.lock` to your `$ZDOTDIR` (usually `$HOME`):

```
# AUTO-GENERATED FILE. DO NOT EDIT MANUALLY.
# Commit this file to version control for reproducible installs.
version::1
zsh-users/zsh-autosuggestions::git::https://github.com/zsh-users/zsh-autosuggestions::a1b2c3d4e5f6...::pin=false
zsh-users/zsh-syntax-highlighting::git::https://github.com/zsh-users/zsh-syntax-highlighting::f7g8h9i0j1k2...::
ohmyzsh::ohmyzsh::ohmyzsh::3l4m5n6o7p8q...::
```

**Commit `zert.lock` to your dotfiles.** On a new machine, Zert reads the lockfile and clones every plugin at the exact same commit — bit-for-bit identical to your other machines.

---

## ⚙️ Configuration

Zert is configured entirely through environment variables. Set them before the bootstrap line:

```zsh
export ZERT_DIR="$HOME/.zert"               # Change where Zert lives
export ZERT_PLUGINS_DIR="$ZERT_DIR/plugins" # Change where plugins are cloned
export ZERT_LOCKFILE="$HOME/.zert.lock"     # Change the lockfile path
```

## 🏗️ How It Works

```
.zshrc startup
│
├─ 1. Bootstrap line — source zert.zsh
│
├─ 2. Process zert declarations (in order)
│   ├─ Missing plugins → parallel git clone + zcompile
│   └─ Write/update zert.lock
│
└─ 3. Load plugins (sequential, strict order)
    ├─ Source each plugin's main file
    └─ Stop + report on first failure
```

**Install is parallel. Load is sequential.** This gives you the speed of parallel cloning without any of the ordering surprises.


## ⭐ Support

If Zert is useful to you, consider giving the repo a star on [GitHub](https://github.com/oxcl/zert) or making a [donation](https://oxcl.github.io/zert/#donate).


## 📄 License

GNU General Public License v3.0 — see [`LICENSE`](./LICENSE) for details.

---

<div align="center">

**Built with unreasonable attention to detail.**

[github.com/oxcl/zert](https://github.com/oxcl/zert)

</div>