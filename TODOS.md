# TODOS.md — Zert Development Plan

Phases are ordered by dependency and value. **Complete Phase 0 entirely before starting Phase 1.** Each phase should result in a working, shippable state.

Progress key: `[ ]` todo · `[~]` in progress · `[x]` done

---

## Phase 0 — MVP: The Bare Minimum That Works

**Goal:** A user can add the bootstrap line to their `.zshrc`, declare plugins with `zert user/repo`, and have them cloned and sourced. Nothing more.

### 0.1 Bootstrap

- [x] Write `bootstrap.sh` in POSIX sh — clones `github.com/oxcl/zert` into `$ZERT_DIR/zert/`
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

**Goal:** Users can manage their plugin set from the terminal. Adds the six core subcommands.

- [ ] `zert list` — print all plugins with status: installed / missing / pinned
- [ ] `zert prune` — delete dirs in `$ZERT_PLUGINS_DIR` not in `__ZERT_LOADED_PLUGINS`, remove from lockfile
- [ ] `zert update` — pull latest commits for all plugins, recompile, regenerate lockfile

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

- [ ] Implement `zert use ohmyzsh/<path>` — clone OMZ once to `$ZERT_PLUGINS_DIR/ohmyzsh`, source subdirectory
- [ ] Implement `zert use prezto/<path>` — clone Prezto once to `$ZERT_PLUGINS_DIR/prezto`, source module
- [ ] Shared parent repo cloned only once, even with multiple `use` declarations
- [ ] Track `use` plugins in `__ZERT_LOADED_PLUGINS` for prune compatibility
- [ ] Add lockfile entries for `ohmyzsh` and `prezto` source types

---

## Phase 4 — Parallel Cloning & Animated UI

**Goal:** Fast installs with real-time visual feedback. Replaces static progress with live animation.

- [ ] Implement parallel `git clone` with background jobs + PID tracking
- [ ] `wait` on all PIDs and collect exit codes
- [ ] Implement `_zert_ui_spinner_start` / `_zert_ui_spinner_stop` with animated ANSI spinner
- [ ] Implement `_zert_ui_bar <pct>` — inline progress bar
- [ ] Implement `_zert_ui_header` with version + plugin count + aggregate progress
- [ ] Display per-plugin lines updating in real-time during parallel clone
- [ ] Keep all output within 80 columns
- [ ] Parallel `zcompile` after clone phase

---

## Phase 5 — SSH & Full URL Support

**Goal:** Support all git URL formats, including private repos via SSH.

- [ ] Parse `git@github.com:user/repo.git` SSH URLs
- [ ] Parse `git@gitlab.com:user/repo.git` SSH URLs
- [ ] Detect and record source type (`github`/`gitlab`) from URL
- [ ] Handle clone failures for private repos with a clear error (SSH key not configured)
- [ ] Document SSH setup in README

---

## Phase 6 — Hardening & Edge Cases

**Goal:** Make Zert reliable under real-world conditions.

- [ ] Lockfile migration path — handle `version::1` header, reject unknown versions gracefully
- [ ] Handle plugin directory that exists but is not a git repo (stale/corrupted clone)
- [ ] `zert update` on a pinned plugin: skip update, print notice
- [ ] `zert prune --dry-run` — print what would be removed without deleting
- [ ] Handle `$ZERT_PLUGINS_DIR` not existing on first run (auto-create)
- [ ] `zert list --json` — machine-readable output for scripting
- [ ] Add integration tests using a real temp directory (still no network — use `git init` local repos as fixtures)

---

## Post-MVP Backlog (Not Scheduled)

These are explicitly out of scope until a project decision promotes them:

- `zert search` — parse awesome-zsh-plugins via `curl` + grep
- `zert update --interactive` — per-plugin accept/reject TUI
- Deferred / lazy plugin loading
- Background update checks on shell start
- Interactive plugin browser