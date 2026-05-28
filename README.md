<div align="center">

# ⚡ Zert

### The plugin manager your `.zshrc` has been waiting for.

**Declarative. Reproducible. Pure Zsh.**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Zsh 5.0+](https://img.shields.io/badge/Zsh-5.0%2B-green?logo=gnu-bash&logoColor=white)](https://www.zsh.org/)
[![Pure Zsh](https://img.shields.io/badge/dependencies-git%20%2B%20curl-orange)](https://github.com/oxcl/zert)

</div>

---

Zert is a **pure-Zsh plugin manager** built around a simple idea: your plugins should be declared directly in your `.zshrc`, pinned to exact commits, and reproducible on any machine — just like npm does for Node projects.

No config files to maintain. No subcommands to memorize for adding plugins. No external tools. Just Zsh, `git`, and `curl`.

---

## ✨ Features

- **Inline, declarative syntax** — declare plugins directly in `.zshrc`. No separate config file, no `add` command.
- **Lockfile-based reproducibility** — `zert.lock` pins every plugin to an exact git commit SHA. Commit it. Share it. Reproduce it anywhere.
- **Parallel installs** — clones multiple plugins simultaneously using `git clone --filter=tree:0` for minimal bandwidth.
- **Sequential, ordered loading** — plugins are sourced in exactly the order you declare them. Always.
- **Zero external UI dependencies** — real-time progress bars and spinners built entirely from ANSI escape codes.
- **Self-managing** — Zert updates itself with `zert update zert`, managed as a first-class plugin.
- **Oh-My-Zsh / Prezto compatibility** — load OMZ libs and Prezto modules without installing either framework.

---

## 🚀 Install

Paste this single line at the top of your `.zshrc`:

```zsh
ZERT_PLUGINS_DIR="${ZERT_PLUGINS_DIR:-${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}/plugins}"; \
[[ -f "$ZERT_PLUGINS_DIR/zert/zert.zsh" ]] || \
(curl -fsSL https://raw.githubusercontent.com/oxcl/zert/main/bootstrap.sh | zsh); \
source "$ZERT_PLUGINS_DIR/zert/zert.zsh"
```

That's it. The first time your shell starts, Zert bootstraps itself. On every subsequent start, it loads instantly from the cached clone.

---

## 📦 Usage

### Declaring Plugins

Add `zert` lines to your `.zshrc` after the bootstrap line:

```zsh
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
zert lock          # Manually regenerate zert.lock
zert config        # Print all active ZERT_* environment variables
zert config <key> <value>  # Set a config value for the current session
```

---

## 🔒 The Lockfile

After every install or update, Zert writes `zert.lock` to your `$ZDOTDIR` (usually `$HOME`):

```
# AUTO-GENERATED FILE. DO NOT EDIT MANUALLY.
# Commit this file to version control for reproducible installs.
version::1
zsh-users/zsh-autosuggestions::github::https://github.com/zsh-users/zsh-autosuggestions::a1b2c3d4e5f6...::pin=false
zsh-users/zsh-syntax-highlighting::github::https://github.com/zsh-users/zsh-syntax-highlighting::f7g8h9i0j1k2...::
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

Or use Zsh-native `zstyle` for non-path settings:

```zsh
zstyle ':zert:*' filter-tree true
```

**Priority:** env vars → zstyle → built-in defaults.

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

## 🤝 Contributing

Zert is built in pure Zsh with no external dependencies. Before contributing, read:

- [`AGENTS.md`](./AGENTS.md) — coding rules and invariants (also useful for AI agents)
- [`IMPLEMENTATIONS.md`](./IMPLEMENTATIONS.md) — architecture standards

Run tests with:

```zsh
zsh tests/runner.zsh
```

---

## 📄 License

GNU General Public License v3.0 — see [`LICENSE`](./LICENSE) for details.

---

<div align="center">

**Built with no dependencies and unreasonable attention to detail.**

[github.com/oxcl/zert](https://github.com/oxcl/zert)

</div>