# TODOS.md — Zert Pre-Launch Testing Plan

Comprehensive test coverage for all Zert functionality before public launch.

Progress key: `[ ]` todo · `[~]` in progress · `[x]` done

---

## Category 1 — Bootstrap (`bootstrap.sh`)

- [x] 1.1 Fresh install — run bootstrap on clean system with no `$ZERT_PLUGINS_DIR`, verify `zert/zert.zsh` and `zert/zert.plugin.zsh` created
- [x] 1.2 Idempotency — run bootstrap twice, second run should `exit 0` immediately
- [x] 1.3 Custom `ZERT_PLUGINS_DIR` — set to custom path, verify clone lands there
- [x] 1.4 Custom `ZERT_DIR` — set `ZERT_DIR` (no `ZERT_PLUGINS_DIR`), verify resolves to `$ZERT_DIR/plugins`
- [x] 1.5 XDG fallback — unset both `ZERT_DIR` and `ZERT_PLUGINS_DIR`, verify falls back to `$XDG_DATA_HOME/zert/plugins` or `~/.local/share/zert/plugins`
- [x] 1.6 Atomic clone — verify temp directory used during clone and removed after `mv`
- [x] 1.7 Cleanup on failure — interrupt bootstrap mid-clone, verify temp directory cleaned via trap
- [x] 1.8 No Zsh required — verify bootstrap runs under plain `sh` without Zsh in PATH
- [x] 1.9 Network failure — test with unreachable remote, verify error message and non-zero exit
- [x] 1.10 Existing partial install — create `zert.zsh` but not `zert.plugin.zsh`, verify clone runs

---

## Category 2 — Dependency Checks (`_zert_check_deps`)

- [ ] 2.1 All deps present — verify returns 0 when `git`, `curl`, `stdbuf`, `find`, Zsh >= 5.0 exist
- [ ] 2.2 Missing `git` — hide from PATH, verify error and return 1
- [ ] 2.3 Missing `curl` — hide from PATH, verify error and return 1
- [ ] 2.4 Old Zsh version — mock `ZSH_VERSION=4.9`, verify error about Zsh >= 5.0
- [ ] 2.5 Multiple missing deps — hide both `git` and `curl`, verify both reported
- [ ] 2.6 Output goes to stderr — verify errors print to fd 2, not stdout

---

## Category 3 — Source Parsing (`_zert_parse_source`)

- [x] 3.1 GitHub shorthand — `zsh-users/zsh-autosuggestions` → type=`git`, value=`https://github.com/zsh-users/zsh-autosuggestions.git`
- [x] 3.2 Full HTTPS URL — `https://github.com/user/repo.git` → type=`git`, value=URL
- [x] 3.3 GitLab URL — `https://gitlab.com/user/repo` → type=`git`, value=URL
- [x] 3.4 SSH URL — `git@github.com:user/repo.git` → type=`git`, value=URL
- [x] 3.5 Absolute local path — `/home/user/plugin` → type=`local`, value=path (if exists)
- [x] 3.6 Relative path rejected — `./my-plugin` → error + return 1
- [x] 3.7 Nonexistent local path — `/nonexistent/path` → error + return 1
- [x] 3.8 Empty input — `""` → error + return 1
- [x] 3.9 `ohmyzsh` source — `ohmyzsh` → type=`ohmyzsh`, value=`ohmyzsh`
- [x] 3.10 `prezto` source — `prezto` → type=`prezto`, value=`prezto`
- [x] 3.11 GitHub URL without `.git` — `https://github.com/user/repo` → type=`git`
- [x] 3.12 Trailing slash handling — `https://github.com/user/repo/` → handled correctly

---

## Category 4 — Flag Parsing (`_zert_parse_flags`)

- [x] 4.1 Boolean flag — `--no-alias` → `"true"`
- [x] 4.2 Value flag — `--branch main` → `"main"`
- [x] 4.3 Missing flag — query for `--branch` when not present → `""`
- [x] 4.4 Pin flag — `--pin abc123` → `"abc123"`
- [x] 4.5 Multiple flags — `--no-alias --branch dev --pin xyz` → each parses correctly
- [x] 4.6 Underscore normalization — query `no_alias` → matches `--no-alias`
- [x] 4.7 Flag at end of args — `--no-alias` as last arg (no value after) → `"true"`

---

## Category 5 — Plugin ID Sanitization (`_zert_plugin_sanitize_id`)

- [x] 5.1 GitHub shorthand — `git` + `https://github.com/zsh-users/zsh-autosuggestions.git` → `github.com--zsh-users--zsh-autosuggestions`
- [x] 5.2 GitLab URL — `git` + `https://gitlab.com/user/repo` → `gitlab.com--user--repo`
- [x] 5.3 SSH format — `git` + `git@github.com:user/repo.git` → correct sanitized ID
- [x] 5.4 Local path — `local` + `/home/user/plugin` → `local--home--user--plugin`
- [x] 5.5 `.git` suffix stripped — URL ending in `.git` → suffix removed
- [x] 5.6 Trailing slashes — URL with trailing `/` → handled correctly
- [x] 5.7 Special chars in path — paths with dots, hyphens, underscores → sanitized correctly

---

## Category 6 — Plugin Cloning (`_zert_plugin_clone`)

- [ ] 6.1 Fresh clone — clone a known public repo, verify directory exists with `.git`
- [ ] 6.2 Treeless clone — verify `--filter=tree:0` is used
- [ ] 6.3 Atomic clone (temp dir) — verify clone uses temp dir + `mv` pattern
- [ ] 6.4 Cleanup on failure — simulate clone failure, verify temp dir removed
- [ ] 6.5 Branch flag — `--branch develop` → verify correct branch cloned
- [ ] 6.6 Oh-My-Zsh URL mapping — `ohmyzsh` source type → maps to correct GitHub URL
- [ ] 6.7 Prezto URL mapping — `prezto` source type → maps to correct GitHub URL
- [ ] 6.8 Zert self-clone — `zert` source type → maps to `https://github.com/oxcl/zert.git`
- [ ] 6.9 Custom GitLab URL — clone from GitLab URL, verify works
- [ ] 6.10 Already cloned — clone when directory exists → skip or handle gracefully

---

## Category 7 — Plugin Compilation (`_zert_plugin_compile`)

- [ ] 7.1 Compile `.zsh` files — create plugin with `.zsh` files, verify `.zwc` created
- [ ] 7.2 No `.zsh` files — plugin with no `.zsh` files → silent skip, return 0
- [ ] 7.3 Nested `.zsh` files — plugin with subdirs containing `.zsh` → all compiled via `**/*.zsh(N)`
- [ ] 7.4 Nonexistent directory — pass invalid path → return 1
- [ ] 7.5 Recompilation — compile already-compiled files → `.zwc` updated without error

---

## Category 8 — Plugin Sourcing (`_zert_plugin_source`)

- [ ] 8.1 `.plugin.zsh` detection — plugin with `name.plugin.zsh` → sourced correctly
- [ ] 8.2 `init.zsh` detection — plugin with `init.zsh` → sourced correctly
- [ ] 8.3 `.zsh` fallback — plugin with only `name.zsh` → sourced
- [ ] 8.4 `.sh` fallback — plugin with only `name.sh` → sourced
- [ ] 8.5 Single `.zsh` file — directory with one `.zsh` file → sourced directly
- [ ] 8.6 No sourceable file — empty plugin directory → return 1
- [ ] 8.7 `completions/` fpath — plugin with `completions/` dir → added to `fpath`
- [ ] 8.8 `functions/` fpath — plugin with `functions/` dir → added to `fpath`
- [ ] 8.9 `--no-completion` — verify `completions/` NOT added to `fpath`
- [ ] 8.10 `--only-completion` — verify nothing sourced, only `fpath` updated
- [ ] 8.11 `--no-alias` — plugin defines aliases → verify NOT loaded
- [ ] 8.12 Theme detection — `.zsh-theme` file → sourced, single-theme rule enforced
- [ ] 8.13 `ohmyzsh`/`prezto` type — returns 0 immediately (handled by respective commands)

---

## Category 9 — Lockfile Operations

- [ ] 9.1 Write entry — write new entry, verify file created with correct format
- [ ] 9.2 Read entry — write then read, verify all fields match
- [ ] 9.3 Replace entry — write same `plugin_id` twice, verify replaced not duplicated
- [ ] 9.4 Remove entry — write then remove, verify entry gone, others preserved
- [ ] 9.5 Atomic write — verify temp file + `mv` pattern (no partial writes)
- [ ] 9.6 Header preservation — after write, verify comments and `version::1` present
- [ ] 9.7 Options serialization — write with `--branch main --no-alias`, verify options field format
- [ ] 9.8 `::` escaping — plugin ID or URL containing `::` → escaped as `\::`
- [ ] 9.9 Read nonexistent — read for plugin not in lockfile → return 1
- [ ] 9.10 Read missing lockfile — read when `$ZERT_LOCKFILE` doesn't exist → return 1
- [ ] 9.11 Remove from missing lockfile — remove when file doesn't exist → return 1
- [ ] 9.12 Multiple entries — write 5+ entries, verify all readable and removable independently
- [ ] 9.13 Comments/blank lines — lockfile with comments and blanks → parser skips correctly
- [ ] 9.14 Pin option persistence — `--pin abc123` → lockfile shows `pin=abc123` in options
- [ ] 9.15 Local plugin entry — `source=local`, empty url and commit_sha fields

---

## Category 10 — Plugin Lifecycle (`_zert_plugin_ensure_sync`)

- [ ] 10.1 Fresh plugin (no lockfile) — returns `"register"`
- [ ] 10.2 Already synced — plugin exists, lockfile matches → `"synced"`
- [ ] 10.3 Branch mismatch — `--branch dev` but lockfile says `main` → `"checkout"` or `"pull"`
- [ ] 10.4 Pin mismatch — `--pin abc` but lockfile says `def` → `"checkout"` or `"pull"`
- [ ] 10.5 SHA mismatch (remote updated) — lockfile SHA doesn't match local HEAD → `"pull"` if SHA not local
- [ ] 10.6 SHA exists locally — lockfile SHA exists in local git history → `"checkout"`
- [ ] 10.7 Local plugin — always returns `"synced"`

---

## Category 11 — Subcommand `list` (`_zert_cmd_list`)

- [ ] 11.1 Empty list — no plugins loaded → "No plugins loaded" message
- [ ] 11.2 Single plugin — one plugin → correct columns (PLUGIN, TYPE, SHA, FLAGS)
- [ ] 11.3 Multiple plugins — 5+ plugins → table formatted correctly
- [ ] 11.4 Plugin with lockfile entry — shows truncated 7-char SHA
- [ ] 11.5 Plugin without lockfile — shows em-dash for missing fields
- [ ] 11.6 Local plugin display — shows path with `--` converted to `/`
- [ ] 11.7 Plugin with flags — shows flags like `pin=abc`, `branch=dev`
- [ ] 11.8 Terminal width adaptation — narrow terminal (< 80 cols) → columns truncated
- [ ] 11.9 Very long plugin names — names truncated with `...`
- [ ] 11.10 Color output — verify ANSI colors applied when `$NO_COLOR` unset

---

## Category 12 — Subcommand `update` (`_zert_cmd_update`)

- [ ] 12.1 Update all plugins — multiple unlocked plugins → all updated, lockfile regenerated
- [ ] 12.2 Skip local plugins — local source type → skipped, not updated
- [ ] 12.3 Skip pinned plugins — plugin with `pin=*` option → skipped
- [ ] 12.4 Missing lockfile — no lockfile → error message
- [ ] 12.5 Missing plugin directory — lockfile entry but no cloned dir → skip with log
- [ ] 12.6 Pull failure — simulate git pull failure → error logged, failed counter incremented
- [ ] 12.7 Compile after update — verify `.zwc` files regenerated after pull
- [ ] 12.8 Lockfile updated — after update, lockfile has new commit SHAs
- [ ] 12.9 Interrupt handling — Ctrl-C during update → `__ZERT_INTERRUPTED=1`, partial results preserved
- [ ] 12.10 Update count output — verify updated/skipped/failed counts reported
- [ ] 12.11 `--ff-only` fallback — if `git pull --ff-only` fails, falls back to `git fetch origin`

---

## Category 13 — Subcommand `prune` (`_zert_cmd_prune`)

- [ ] 13.1 Nothing to prune — all dirs in loaded plugins → "Nothing to prune"
- [ ] 13.2 Prune stale dirs — extra dirs not in `__ZERT_LOADED_PLUGINS` → deleted
- [ ] 13.3 Skip `zert` directory — `zert` dir never pruned (self-management)
- [ ] 13.4 Lockfile cleanup — pruned plugin's lockfile entry removed
- [ ] 13.5 Missing plugins dir — `$ZERT_PLUGINS_DIR` doesn't exist → graceful message
- [ ] 13.6 Partial failure — `rm -rf` fails on one dir → error logged, others still pruned
- [ ] 13.7 Count output — verify "Pruned N plugin(s)" message

---

## Category 14 — Subcommand `use` / Framework Compatibility

- [ ] 14.1 `zert use ohmyzsh` — initializes OMZ: clones repo, sets `$ZSH`, `$ZSH_CUSTOM`, `$ZSH_CACHE_DIR`
- [ ] 14.2 `zert use prezto` — initializes Prezto: clones repo, sets `$ZPREZTODIR`, sources helper init
- [ ] 14.3 Idempotent `use` — call `zert use ohmyzsh` twice, second call is no-op
- [ ] 14.4 `zert ohmyzsh plugins/git` — loads OMZ git plugin from cloned repo
- [ ] 14.5 `zert ohmyzsh lib/clipboard` — loads OMZ clipboard lib
- [ ] 14.6 `zert ohmyzsh themes/robbyrussell` — loads OMZ theme
- [ ] 14.7 `zert prezto modules/utility` — loads Prezto utility module, autoloads functions
- [ ] 14.8 OMZ not initialized — `zert ohmyzsh X` without `zert use ohmyzsh` → error
- [ ] 14.9 Prezto not initialized — `zert prezto X` without `zert use prezto` → error
- [ ] 14.10 Invalid OMZ component — `zert ohmyzsh invalid/name` → error with valid options
- [ ] 14.11 Nonexistent OMZ plugin — `zert ohmyzsh plugins/nonexistent` → error
- [ ] 14.12 Nonexistent Prezto module — `zert prezto nonexistent` → error
- [ ] 14.13 OMZ lockfile entry — after `use ohmyzsh`, lockfile has `ohmyzsh::ohmyzsh::...` entry
- [ ] 14.14 Prezto lockfile entry — after `use prezto`, lockfile has `prezto::prezto::...` entry
- [ ] 14.15 OMZ flags passthrough — `zert ohmyzsh plugins/git --no-alias` → alias suppression works

---

## Category 15 — Fast-Track Parallel Install

- [ ] 15.1 Trigger fast-track — lockfile with non-local entries, no cloned dirs → fast-track runs
- [ ] 15.2 Skip fast-track — no lockfile → falls back to sequential
- [ ] 15.3 Skip if already cloned — all lockfile plugins already cloned → skip
- [ ] 15.4 Skip if only local — lockfile has only `local` entries → skip
- [ ] 15.5 Parallel clone — 3+ plugins → verify parallel execution (background PIDs)
- [ ] 15.6 Failure collection — one clone fails → others still complete, failure counted
- [ ] 15.7 Options from lockfile — lockfile has `--branch`, `--pin`, `--no-alias` → applied during fast-track
- [ ] 15.8 Compile after clone — all cloned plugins compiled after parallel phase
- [ ] 15.9 Stale tmpdir cleanup — pre-existing `.zert-clone-*` dirs → cleaned before starting
- [ ] 15.10 Interrupt handling — Ctrl-C during fast-track → all background jobs killed

---

## Category 16 — UI Functions

- [ ] 16.1 Color variables defined — all `__ZERT_CLR_*` variables set when `$NO_COLOR` unset
- [ ] 16.2 `NO_COLOR` support — set `$NO_COLOR` → all color variables empty
- [ ] 16.3 `_zert_ui_ok` — output contains green text, goes to stderr
- [ ] 16.4 `_zert_ui_error` — output contains red text, goes to stderr
- [ ] 16.5 `_zert_ui_log` — output contains blue text, goes to stderr
- [ ] 16.6 `_zert_ui_truncate` — text shorter than max → unchanged, text longer → truncated with `...`
- [ ] 16.7 `_zert_ui_truncate` edge cases — `max_width=0` → empty, `max_width=3` → truncated without `...`
- [ ] 16.8 `_zert_ui_emphasize` — `**text**` → yellow+italic ANSI, no markers → unchanged
- [ ] 16.9 `_zert_ui_pick_spinner` — frame 0-9 → correct braille characters, cycles at 10
- [ ] 16.10 Task start/end — `_zert_ui_task_start` creates FIFO, spawns renderer, `_zert_ui_task_end` cleans up
- [ ] 16.11 Subtask lifecycle — start → update → end sequence works correctly
- [ ] 16.12 Background renderer — FIFO communication, spinner animation, log ring buffer
- [ ] 16.13 Ctrl-C handling — `TRAPINT` kills background PIDs, ends task with fail
- [ ] 16.14 FIFO cleanup — after task end, `/tmp/zert_ui_comm_$$` removed
- [ ] 16.15 80-column constraint — all output fits within 80 columns

---

## Category 17 — Dispatcher (`zert` command)

- [ ] 17.1 No arguments — shows usage error, returns 1
- [ ] 17.2 Known subcommand — `zert list` → dispatches to `_zert_cmd_list`
- [ ] 17.3 Unknown subcommand — `zert foobar` → tries to parse as source, fails with error
- [ ] 17.4 Plugin shorthand — `zert user/repo` → parsed as plugin, added
- [ ] 17.5 Plugin with flags — `zert user/repo --branch dev` → flags passed through
- [ ] 17.6 `zert use X` — dispatches to `_zert_cmd_use`
- [ ] 17.7 `zert ohmyzsh X` — dispatches to `_zert_cmd_ohmyzsh`

---

## Category 18 — Configuration Priority

- [ ] 18.1 Env var `ZERT_DIR` — set → overrides default
- [ ] 18.2 Env var `ZERT_PLUGINS_DIR` — set → overrides `ZERT_DIR/plugins`
- [ ] 18.3 Env var `ZERT_LOCKFILE` — set → overrides `$ZDOTDIR/zert.lock`
- [ ] 18.4 XDG fallback — unset all → uses `$XDG_DATA_HOME/zert` or `~/.local/share/zert`
- [ ] 18.5 `$ZDOTDIR` fallback — `ZERT_LOCKFILE` unset → uses `$ZDOTDIR/zert.lock` or `$HOME/zert.lock`
- [ ] 18.6 Env vars export — all `ZERT_*` variables are exported to child processes

---

## Category 19 — Error Handling & Edge Cases

- [ ] 19.1 No `exit` in sourced files — grep all `.zsh` files for `exit`, verify none outside `bootstrap.sh`
- [ ] 19.2 All functions use `local` — verify no unscoped variable assignments in functions
- [ ] 19.3 Return codes — functions return 1 on user error, 2 on internal error
- [ ] 19.4 stderr for errors — all error output goes to fd 2
- [ ] 19.5 Sourcing failure — plugin main file has syntax error → error reported, loading stops
- [ ] 19.6 Network timeout — clone with slow/unreachable network → appropriate error
- [ ] 19.7 Disk full — simulate disk full during clone/lockfile write → graceful error
- [ ] 19.8 Concurrent sourcing — source `zert.zsh` from two shells simultaneously → no corruption
- [ ] 19.9 Signal handling — SIGINT during clone → cleanup temp dirs
- [ ] 19.10 Empty plugin declaration — `zert` with empty string → error

---

## Category 20 — Integration / End-to-End Scenarios

- [ ] 20.1 Fresh `.zshrc` to running shell — full bootstrap → declare 3 plugins → shell starts with all loaded
- [ ] 20.2 Lockfile reproducibility — clone on machine A → copy lockfile to machine B → identical plugin versions
- [ ] 20.3 Update workflow — `zert update` → lockfile SHA changes → next startup uses new SHA
- [ ] 20.4 Prune workflow — remove plugin from `.zshrc` → `zert prune` → dir deleted, lockfile cleaned
- [ ] 20.5 Mixed source types — `git` + `local` + `ohmyzsh` + `prezto` plugins all in one `.zshrc`
- [ ] 20.6 Pin workflow — `zert user/repo --pin abc123` → lockfile has pin → update skips it
- [ ] 20.7 Branch workflow — `zert user/repo --branch dev` → cloned from dev → lockfile records branch
- [ ] 20.8 Re-bootstrap after delete — delete `$ZERT_PLUGINS_DIR/zert` → re-run bootstrap → works
- [ ] 20.9 Large plugin count — 10+ plugins → parallel install performance acceptable
- [ ] 20.10 Self-update — `zert update` when zert itself is listed → updates self

---

## Category 21 — Security & Safety

- [ ] 21.1 No user file modification — verify Zert never writes to `.zshrc`, `.zprofile`, etc.
- [ ] 21.2 Lockfile atomicity — kill process during lockfile write → no corruption
- [ ] 21.3 No eval usage — grep for `eval` in all source files, verify none or justified with comment
- [ ] 21.4 Relative path rejection — `zert ../etc/passwd` → rejected
- [ ] 21.5 Path traversal in plugin ID — sanitized IDs prevent `../` in filesystem paths
- [ ] 21.6 Temp file permissions — temp dirs/files don't expose sensitive data

---

**Total: 180 test cases across 21 categories.**
