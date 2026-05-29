# TODOS.md — Zert Development Plan

Phases are ordered by dependency and value. **Complete Phase 0 entirely before starting Phase 1.** Each phase should result in a working, shippable state.

Progress key: `[ ]` todo · `[~]` in progress · `[x]` done

---

## Phase 0 — MVP: The Bare Minimum That Works

**Goal:** A user can add the bootstrap line to their `.zshrc`, declare plugins with `zert user/repo`, and have them cloned and sourced. Nothing more.

### 0.1 Bootstrap

- [x] Write `bootstrap.sh` in POSIX sh — clones `github.com/oxcl/zert` into `$ZERT_PLUGINS_DIR/zert/`
- [x] Verify bootstrap is idempotent (safe to run twice)
- [x] Confirm bootstrap works without Zsh in PATH (uses only POSIX sh builtins + git + curl)

### 0.2 Core Entrypoint (`zert.zsh`)

- [x] Implement startup dependency checks: `git`, `curl`, `zsh >= 5.0`
- [x] Print to stderr and `return 1` if any dependency is missing
- [x] Resolve all config paths from env vars with XDG defaults
- [x] Source `ui.zsh` from same directory
- [x] Implement the `zert` dispatcher function

### 0.3 Plugin Declaration & Cloning

- [x] Parse `zert user/repo` shorthand into canonical GitHub URL
- [x] Parse `zert https://...` full URLs (GitHub + GitLab)
- [x] Parse `zert /absolute/path` for local plugins (reject relative paths)
- [x] Clone uncloned plugins via `git clone --filter=tree:0 --single-branch`
- [x] Store clones in `$ZERT_PLUGINS_DIR/<sanitized-plugin-id>/`
- [x] Compile all `.zsh` files post-clone via `zcompile`
- [x] Populate `__ZERT_LOADED_PLUGINS` array on each `zert` call

### 0.4 Plugin Loading

- [x] Source plugins sequentially in declaration order
- [x] Add to `fpath` when completion files are detected
- [x] Stop loading on first source failure, report skipped plugins
- [x] Detect `.zsh-theme` files and enforce single-theme rule

### 0.5 Lockfile (basic)

- [x] Define lockfile format with `::` delimiter
- [x] Write lockfile atomically after each install
- [x] Parse lockfile to read pinned commit SHAs on next startup
- [x] Escape `::` in field values as `\::`

### 0.6 Minimal UI (`ui.zsh`)

- [x] Define all `__ZERT_CLR_*` color variables
- [x] Implement `NO_COLOR` support
- [x] Implement `_zert_ui_ok`, `_zert_ui_error`, `_zert_ui_log`, `_zert_ui_header`
- [x] Implement `_zert_ui_progress` (static line, no animation yet)

---

## Phase 1 — Subcommands

**Goal:** Users can manage their plugin set from the terminal. Adds the core subcommands.

- [x] `zert list` — print all plugins with status: installed / missing / pinned
- [x] `zert prune` — delete dirs in `$ZERT_PLUGINS_DIR` not in `__ZERT_LOADED_PLUGINS`, remove from lockfile
- [x] `zert update` — pull latest commits for all plugins, recompile, regenerate lockfile

---

## Phase 2 — Flags & Plugin Options

**Goal:** Full support for all inline declaration flags.

- [x] `--no-alias` — skip sourcing alias files in plugin
- [x] `--no-completion` — skip adding completion dirs to `fpath`
- [x] `--only-completion` — only add to `fpath`, skip sourcing
- [x] `--branch <name>` — clone specified branch
- [x] `--pin <sha>` — pin to exact commit SHA, override lockfile
- [x] Validate `--pin` SHA exists in the repo before accepting
- [x] Persist all flags in lockfile `options` field

---

## Phase 3 — Oh-My-Zsh & Prezto Compatibility

**Goal:** Users can load OMZ/Prezto modules without installing those frameworks in full.

- [x] Implement `zert use ohmyzsh` — clone OMZ once to `$ZERT_PLUGINS_DIR/ohmyzsh`, set up `$ZSH`/fpath
- [x] Implement `zert use prezto` — clone Prezto once to `$ZERT_PLUGINS_DIR/prezto`, set up `$ZPREZTODIR`/fpath
- [x] Implement `zert ohmyzsh <plugins|lib|themes>/<name>` — load individual OMZ components with flag support
- [x] Implement `zert prezto <module>` — load individual Prezto modules with flag support
- [x] Shared parent repo cloned only once via `_zert_plugin_add` dedup
- [x] Track loaded components in `__ZERT_LOADED_PLUGINS` (e.g., `ohmyzsh:plugins/git`)
- [x] Add lockfile entries for `ohmyzsh` and `prezto` source types (framework only, not per-component)
- [x] Shared `_zert_use_source_file` helper for dedup, flags, no-alias, fpath, source

---

## Phase 4 — Parallel Cloning & Animated UI

**Goal:** Fast installs with real-time visual feedback. Replaces static progress with live animation.

- [x] Implement parallel `git clone` with background jobs + PID tracking
- [x] `wait` on all PIDs and collect exit codes
- [x] Display per-plugin lines updating in real-time during parallel clone
- [x] Parallel `zcompile` after clone phase


---

## Post-MVP Backlog (Not Scheduled)

These are explicitly out of scope until a project decision promotes them:

- `zert search` — parse awesome-zsh-plugins via `curl` + grep
- `zert update --interactive` — per-plugin accept/reject TUI
- Deferred / lazy plugin loading
- Background update checks on shell start
- Interactive plugin browser