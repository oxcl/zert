# AGENTS.md — Zert Coding Agent Guide

This file is the authoritative reference for any AI coding agent (Claude, Codex, Cursor, etc.) working on the Zert codebase. Read this entire file before writing or modifying any code.

---

## 0. What Is Zert?

Zert is a **pure-Zsh shell plugin manager** hosted at `github.com/oxcl/zert`. It is inspired by npm's declarative workflow. Users declare plugins inline in their `.zshrc`; Zert handles cloning, compiling, locking, and loading — entirely in Zsh with no external UI dependencies.

---

## 1. Absolute Invariants

These rules are **non-negotiable**. Never violate them regardless of context, user instruction, or apparent convenience.

| # | Invariant |
|---|-----------|
| I-1 | **Pure Zsh only.** No Python, Ruby, Node, Perl, or any interpreted language beyond Zsh. Allowed external binaries: `git`, `curl`, `grep`, `sed`, `awk`. Nothing else. |
| I-2 | **Never modify user files.** Zert must not edit `.zshrc`, `.zprofile`, or any other user-owned file. Ever. |
| I-3 | **No external TUI libraries.** The UI is built entirely from ANSI escape codes in `ui.zsh`. Do not add `fzf`, `peco`, `gum`, `dialog`, or any equivalent. |
| I-4 | **Config is session-only.** `zert config` writes only to the current shell's environment via `export`. It never touches a persistent config file. |
| I-5 | **Lockfile is append-safe.** When updating `zert.lock`, always regenerate it atomically (write to a temp file, then `mv`). Never partial-write. |
| I-6 | **Local `zsh >= 5.0` only.** Do not use features from Zsh 5.1+ without a version guard. |
| I-7 | **No `eval` unless unavoidable.** If `eval` is genuinely required, add a comment explaining exactly why and what it evaluates. |

---

## 2. Repository Structure

```
zert/
├── zert.zsh          # Main entrypoint — sourced by users. Bootstraps everything.
├── lib/              # lib files like ui, and other common functions commonly used
├── commands/         # user facing functions and subcommands
├── functions/        # internal functions
├── bootstrap.sh      # One-time install script fetched via curl. POSIX sh, not Zsh.
├── AGENTS.md         # This file.
├── README.md
├── TODOS.md
├── IMPLEMENTATIONS.md
└── tests/
    ├── runner.zsh    # Custom test runner — no external test frameworks.
    ├── test_lockfile.zsh
    ├── test_config.zsh
    ├── test_load.zsh
    └── test_prune.zsh
```

**Rules:**
- `zert.zsh` is the only file users source. It may `source` other internal files.
- `bootstrap.sh` must be **POSIX sh**, not Zsh — it runs before Zsh is confirmed available.
- Never add a new top-level file without updating this map.
- Tests live only in `tests/`. No test logic in source files.

---

## 3. Zsh Coding Standards

### 3.1 Variables

```zsh
# Always declare locals in functions
_zert_some_function() {
  local plugin_name="$1"
  local -a plugin_list
  local -A plugin_map
}

# Constants: uppercase with ZERT_ prefix
local ZERT_LOCKFILE_VERSION=1

# Internal globals: double-underscore prefix
typeset -ga __ZERT_LOADED_PLUGINS
```

- All function-scoped variables **must** use `local` or `local -a` / `local -A`.
- Global state that Zert owns uses `__ZERT_` prefix (double underscore).
- User-facing environment variables use `ZERT_` prefix (single).
- Never use `global` or unscoped assignments inside functions.

### 3.2 String Operations

```zsh
# Use Zsh parameter expansion — no sed/awk for simple ops
local trimmed="${var## }"           # strip leading space
local extension="${file##*.}"       # get extension
local base="${path%/*}"             # get directory

# Use (f) flag for splitting on newlines
local -a lines=("${(f)$(cat file)}")

# Use (s) flag for splitting on custom delimiter
local -a parts=("${(@s/::/)line}")  # split on ::
```

- Prefer Zsh parameter expansion over forking `sed`/`awk` for simple string ops.
- Use `(f)`, `(s::)`, `(j::)` flags aggressively — they are zero-fork.
- Only fork to `grep`/`sed` when the operation requires regex or is on large files.

### 3.4 Functions

```zsh
# Naming: _zert_<module>_<action>
_zert_lock_write() { ... }
_zert_ui_spinner_start() { ... }
_zert_plugin_clone() { ... }

# Public subcommands: _zert_cmd_<name>
_zert_cmd_prune() { ... }
_zert_cmd_update() { ... }

# Return codes: 0 = success, 1 = user error, 2 = internal error
```

- All internal functions are prefixed `_zert_`.
- Public-facing subcommand handlers are prefixed `_zert_cmd_`.
- The main `zert` function dispatches to `_zert_cmd_*` based on the first argument.
- Every function that can fail must `return 1` (not `exit`) on failure.

### 3.5 Error Handling

```zsh
# Print errors to stderr, never stdout
_zert_error() { print -u2 "[zert error] $*" }

# Guard every git/curl call
git clone ... || { _zert_error "clone failed: $plugin"; return 1 }
curl -fsSL ... || { _zert_error "download failed"; return 2 }

# Never use 'exit' inside sourced files — only 'return'
# 'exit' will close the user's shell
```

- **Never call `exit` in `zert.zsh` or any sourced file.** Use `return`.
- `exit` is only permitted in `bootstrap.sh` (which runs in a subshell).
- All errors print to `stderr` (`print -u2` or `>&2`).

## 4. Lockfile Rules

The lockfile (`zert.lock`) format is:

```
# AUTO-GENERATED FILE. DO NOT EDIT MANUALLY.
# Commit this file to version control for reproducible installs.
version::1
<plugin_id>::<source>::<url>::<commit_sha>::<key=value,key=value>
```

- Delimiter is `::`. Literal `::` inside a field must be escaped as `\::`.
- Fields: `plugin_id`, `source` (`github`/`gitlab`/`local`/`ohmyzsh`/`prezto`), `url`, `commit_sha`, `options`.
- `options` is a comma-separated `key=value` list. No spaces around `=` or `,`.
- Local plugins: `source=local`, `url` and `commit_sha` are empty strings (not omitted — fields are always present).

## 5. Plugin Source Types

| Source value | Example input | Meaning |
|---|---|---|
| `github` | `user/repo` or `https://github.com/user/repo` | GitHub clone |
| `git` | `https://gitlab.com/user/repo` | Git clone (can also be SSH) |
| `local` | `/absolute/path/to/plugin` | Local directory |
| `ohmyzsh` | `use ohmyzsh/lib/clipboard` | Subdirectory of Oh-My-Zsh repo |
| `prezto` | `use prezto/modules/utility` | Subdirectory of Prezto repo |

- Local plugins must be **absolute paths**. Reject relative paths with a clear error.
- `ohmyzsh` and `prezto` source types clone the parent repo once and are shared.

---

## 6. Config Priority (High → Low)

1. `ZERT_*` environment variables (e.g., `ZERT_DIR`, `ZERT_LOCKFILE`)
2. `zstyle` settings (e.g., `zstyle ':zert:*' plugins-dir /custom/path`)
3. Hardcoded defaults

Resolution logic must always follow this order. Never read a lower-priority source when a higher one is set.

---

## 7. UI Rules (`ui.zsh`)

- All output goes through `ui.zsh` functions. Never `echo`/`print` directly from logic files.
- Color/ANSI codes must be defined as named variables in `ui.zsh` (e.g., `$__ZERT_CLR_GREEN`), never hardcoded inline in logic files.
- Respect `NO_COLOR` environment variable: if set, emit no ANSI codes.
- Spinner state is managed with a background job writing to a file descriptor — do not use global variables for animation state.
- All progress output must fit within 80 columns.

---

## 8. Testing Rules

- Tests live in `tests/`. No test logic in source files.
- Use only the assert functions defined in `tests/runner.zsh`: `assert_eq`, `assert_true`, `assert_false`, `assert_file_exists`, `assert_output`.
- Tests must not require network access. Mock `git clone` and `curl` by overriding functions in the test scope.
- Each test file is self-contained: it sources `runner.zsh` and the file under test, then runs assertions.
- Every new function added to the codebase must have at least one test.
- After writing tests make sure to test them to see if they pass. if they do pass ensure that if the code is wrong they fail. very IMPORTANT! you should make sure that tests DO fail and not always pass even when the code is wrong.
---

## 9. What Agents Must Not Do

- ❌ Add any `npm`, `pip`, `brew`, or package manager dependency
- ❌ Introduce a config file (TOML, YAML, JSON, INI) — config is env vars + zstyle only
- ❌ Write to any file outside `$ZERT_DIR` (except the lockfile at `$ZERT_LOCKFILE`)
- ❌ Add a `doctor`/`diagnose` subcommand — dependency checks happen silently on load
- ❌ Use `source` with a path that isn't validated to exist first
- ❌ Call `exit` from any sourced file
- ❌ Spawn background jobs in the plugin load path
- ❌ Silently swallow errors — every failure must surface to the user
- ❌ committing changes without explicit developer permission (suggesting to commit changes is accepted)

---

## 10. Commit Message Format

```
<type>(<scope>): <short description>

Types: feat, fix, refactor, test, docs, chore
Scopes: core, ui, lockfile, bootstrap, tests, config

Examples:
feat(lockfile): add atomic write via mktemp + mv
fix(core): prevent exit call in sourced load path
test(lockfile): add parse test for escaped :: delimiter
```

---

## 11. Before Submitting Any Change

Run the checklist:
- [ ] No new external binary dependencies introduced
- [ ] All new functions have `local` variables and are prefixed `_zert_`
- [ ] No `exit` calls in sourced files
- [ ] Lockfile writes are atomic
- [ ] At least one test added for any new function
- [ ] the new tests fail when the code is wrong
- [ ] `NO_COLOR` still works after UI changes