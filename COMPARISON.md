# Zsh Plugin Manager Comparison

This document compares Zert with the most widely used Zsh plugin managers. It is aimed at experienced Zsh users evaluating which plugin manager fits their workflow. Each entry describes how the manager works, how plugins are configured, and where its approach diverges from Zert's.

The comparison table covers key dimensions at a glance. The individual sections below provide deeper context for each manager.

---

## Comparison Table

| Feature | Zert | Antidote | Antibody | Antigen | Sheldon | Zap | Zgenom | Zim | Zinit | Zplug |
|---|---|---|---|---|---|---|---|---|---|---|
| **Written in** | Zsh | Zsh | Go | Zsh | Rust | Zsh | Zsh | Zsh | Zsh | Zsh |
| **Config style** | Inline | Separate file | Separate file | Inline | TOML file | Inline | Inline | `.zimrc` file | Inline | Inline |
| **Lockfile** | Yes | No | No | No | No | No | No | No | No | No |
| **Parallel install** | Yes | Yes | Yes | No | Yes | No | No | Yes | No | Yes |
| **Loading strategy** | Direct source | Static file | Static file | Static bundle | Static file | Direct source | Static file | Static file | Turbo mode (async) | Cache |
| **Bytecode compile** | Yes | No | No | Yes | N/A | No | Optional | Yes | Yes | No |
| **OMZ support** | Yes | Yes | Yes | Yes | Templates | Limited | Yes | Yes | Yes (snippet) | Yes |
| **Prezto support** | Yes | Yes | No | No | Templates | No | Yes | Yes | Yes (snippet) | Yes |
| **Self-managing** | Yes | No | No | No | No | No | No | No | No | No |
| **Config files** | None | `plugins.txt` | `plugins.txt` | None | `plugins.toml` | None | None | `.zimrc` | None | None |
| **External binary** | None | None | Go binary | None | Rust binary | None | None | None | None | None |
| **Status** | Active | Active | Archived | Unmaintained | Active | Active | Active | Active | Active | Abandoned |

---

## Antidote

**GitHub:** [mattmc3/antidote](https://github.com/mattmc3/antidote) · **Status:** Active

Antidote is a pure-Zsh plugin manager created as the successor to Antibody. It reads plugins from a `~/.zsh_plugins.txt` file (one plugin per line), generates a static load script containing `source` statements, and your `.zshrc` sources that generated file. On subsequent shell starts, only the static file is sourced — no re-parsing of plugin declarations occurs.

Install is parallel. Loading is effectively a single `source` call. Antidote supports Oh-My-Zsh and Prezto plugins natively using `owner/repo` shorthand notation.

**vs Zert:** Antidote uses a separate `plugins.txt` config file; Zert declares plugins inline in `.zshrc`. Antidote has no lockfile — plugins are not pinned to commit SHAs, so reproducibility across machines depends on whatever state each clone happens to be at. Zert writes a `zert.lock` that pins every plugin to an exact commit. Both are pure Zsh with parallel installs. Antidote's static-file approach means zero parsing overhead on load; Zert parses declarations each startup but optimizes with a fast path that skips UI/git ops when plugins are already synced.

---

## Antibody

**GitHub:** [getantibody/antibody](https://github.com/getantibody/antibody) · **Status:** Archived (deprecated January 2021)

Antibody was a Go binary that managed Zsh plugins. It supported a `plugins.txt` file (similar to Antidote) and could generate a static loading file. It was the predecessor to Antidote — its author deprecated it after native-Zsh managers caught up on performance.

Antibody's Go implementation handled parsing and file generation, but the actual plugin sourcing was done by Zsh's `source` command, meaning the Go binary only reduced config-parsing overhead, not plugin-loading overhead.

**vs Zert:** Antibody required a compiled Go binary; Zert is pure Zsh. Antibody had no lockfile or commit pinning. Antibody is archived and no longer maintained; Zert is actively developed. Both supported parallel installs and static loading. The key difference is the dependency model — Zert requires only `git` and `curl`, while Antibody required installing and updating a Go binary.

---

## Antigen

**GitHub:** [zsh-users/antigen](https://github.com/zsh-users/antigen) · **Status:** Unmaintained

Antigen was one of the earliest Zsh plugin managers, inspired by Vim's Vundle/Pathogen. It introduced the `antigen bundle` command for declaring plugins inline and was the first to bring Oh-My-Zsh plugin compatibility to standalone plugin management. Later versions added static bundle loading and bytecode compilation.

Antigen loads plugins by sourcing them sequentially. It has no parallel install capability. Clean startup time is around 60ms, which is slower than modern alternatives.

**vs Zert:** Both use inline declarations. Antigen has no lockfile, no parallel install, and no commit pinning. Antigen is unmaintained; Zert is active. Antigen's bytecode compilation predates Zert's, but Zert's parallel clone + treeless clone strategy makes installation significantly faster. Antigen only supports Oh-My-Zsh; Zert also supports Prezto.

---

## Sheldon

**GitHub:** [rossmacarthur/sheldon](https://github.com/rossmacarthur/sheldon) · **Status:** Active

Sheldon is a shell plugin manager written in Rust. It uses a TOML configuration file (`plugins.toml`) and generates a static loading script. Because parsing and file generation happen in Rust, the Zsh startup overhead is minimal — the shell only sources the pre-generated file.

Sheldon supports plugins from Git repositories (with branch/tag/commit pinning), GitHub Gists, remote scripts, local plugins, and inline plugins. It uses a template system for flexible install methods. It is shell-agnostic, working with both Bash and Zsh.

**vs Zert:** Sheldon requires a Rust binary; Zert is pure Zsh. Sheldon uses a TOML config file; Zert uses inline declarations. Sheldon has no lockfile; Zert's `zert.lock` pins every plugin to an exact commit. Sheldon is shell-agnostic; Zert is Zsh-specific. Sheldon's template system is more configurable but adds complexity; Zert's approach is simpler with sensible defaults. Both support parallel installs.

---

## Zap

**GitHub:** [zap-zsh/zap](https://github.com/zap-zsh/zap) · **Status:** Active

Zap is a minimal Zsh plugin manager. Plugins are declared inline using `plug` commands in `.zshrc`. It clones plugins on first load and sources them directly — no static file generation, no bytecode compilation, no caching. The entire codebase is small.

Zap provides `zap update`, `zap list`, and `zap clean` subcommands. It supports local plugins and custom URL prefixes for private repositories. It has no Oh-My-Zsh or Prezto integration.

**vs Zert:** Both use inline declarations and are pure Zsh. Zap is the closest in philosophy to Zert — minimal, inline, no config files. However, Zap has no lockfile, no parallel installs, no bytecode compilation, and limited framework compatibility. Zert adds reproducibility (lockfile), performance (parallel + compile), and OMZ/Prezto support on top of the same inline model. Zap is simpler; Zert is more capable.

---

## Zgenom

**GitHub:** [jandamm/zgenom](https://github.com/jandamm/zgenom) · **Status:** Active

Zgenom is the maintained fork of zgen. It takes a "generate once, source many" approach: plugins are declared with `zgenom load` commands inside an `if ! zgenom saved; then ... zgenom save; fi` block. On first run, it clones plugins and generates a static init script. On subsequent runs, it sources that script directly.

Zgenom supports Oh-My-Zsh and Prezto, auto-update on a configurable schedule, `--pin` for individual plugins, and `zgenom compile` for bytecode compilation. It also has a `zgenom autoupdate` feature that checks for updates in the background periodically without slowing startup.

**vs Zert:** Both are pure Zsh with inline declarations and OMZ/Prezto support. Zgenom requires a manual `zgenom reset` after changing plugin declarations to regenerate the init script; Zert detects changes automatically on each load. Zgenom's `--pin` exists for individual plugins but there is no global lockfile; Zert's `zert.lock` pins every plugin atomically. Zgenom's static file approach means zero parsing overhead on warm loads; Zert parses declarations each time but short-circuits when plugins are already synced. Zgenom has no parallel install; Zert clones in parallel.

---

## Zim (zimfw)

**GitHub:** [zimfw/zimfw](https://github.com/zimfw/zimfw) · **Status:** Active

Zim is a Zsh configuration framework that bundles a plugin manager with curated modules. It uses a separate `~/.zimrc` file with `zmodule` calls to define modules. It builds a static `init.zsh` script and aggressively compiles all Zsh files to bytecode. Warm load times are extremely fast — around 0.009s in benchmarks.

Zim ships its own modules (environment, git, input, completion, etc.) alongside external plugins. It supports a `degit` tool (curl/wget-based) as an alternative to git for faster, lighter installs on GitHub repos. Modules can define custom source files, autoload functions, and on-pull hooks.

**vs Zert:** Zim is a framework with a plugin manager; Zert is a standalone plugin manager. Zim uses a separate `.zimrc` config file; Zert uses inline declarations. Zim has no lockfile. Zim's aggressive bytecode compilation gives it the fastest warm load times in the ecosystem. Zert compiles too, but Zim's framework-level integration means it compiles its own infrastructure as well. Zim's `degit` option trades git history for faster downloads; Zert always uses git. Zim's curated module set is a pro (turnkey defaults) and a con (less flexible than cherry-picking from arbitrary repos).

---

## Zinit

**GitHub:** [zdharma-continuum/zinit](https://github.com/zdharma-continuum/zinit) · **Status:** Active (community-maintained after original author deleted the project in 2021)

Zinit is the most feature-rich Zsh plugin manager. Its defining feature is "turbo mode" — plugins load asynchronously after the prompt appears, hiding load latency. It also provides bytecode compilation, plugin reports (showing what aliases, functions, and completions a plugin sets up), an annex system for extensibility, and services for background processes.

Zinit uses `zinit light` for plugins and `zinit snippet` for loading individual files from Oh-My-Zsh or Prezto repos. It has a complex "ice modifier" system (`atload`, `wait`, `depth`, `lucid`, etc.) that controls how and when plugins load. Turbo mode can reduce perceived startup by 50-80%, though it has tradeoffs — some plugins expect synchronous loading and break when deferred.

**vs Zert:** Zinit is the most complex manager; Zert is deliberately simple. Zinit has turbo mode (async loading); Zert loads everything synchronously before the prompt. Zinit has no lockfile; Zert's `zert.lock` pins every commit. Zinit's ice modifier system is powerful but has a steep learning curve; Zert's `--pin`, `--branch`, `--no-alias` flags cover common cases without complexity. Zinit is community-maintained after a turbulent history; Zert is actively developed. Both support OMZ/Prezto and bytecode compilation. Zinit solves perceived latency; Zert solves reproducibility.

---

## Zplug

**GitHub:** [zplug/zplug](https://github.com/zplug/zplug) · **Status:** Abandoned

Zplug was a feature-rich plugin manager that supported parallel installation, lazy loading, dependency management between plugins, branch/tag/commit pinning, and post-update hooks. It managed plugins from GitHub, Bitbucket, Oh-My-Zsh, Prezto, and local directories.

Despite its feature set, Zplug had a poor implementation — clean startup time was around 160ms, significantly slower than alternatives. The project has been abandoned with no recent commits.

**vs Zert:** Both use inline declarations. Zplug had parallel install and caching but with poor performance; Zert achieves parallel installs with minimal overhead via treeless clones. Zplug has no lockfile; Zert's `zert.lock` provides reproducibility. Zplug is abandoned; Zert is active. Zplug's dependency management between plugins was a unique feature that Zert does not replicate. Zplug's lazy loading was conceptually similar to Zinit's turbo mode but less well-implemented.

---

## Zsh Unplugged / Zcomet

**GitHub:** [mattmc3/zsh_unplugged](https://github.com/mattmc3/zsh_unplugged) / [menacel-mgmt/zcomet](https://github.com/menacel-mgmt/zcomet) · **Status:** Active

Zsh Unplugged is not a plugin manager — it is a ~20-line `plugin-load` function that demonstrates how to manage Zsh plugins without any manager. It clones repos, finds the appropriate `.zsh` file, and sources it. The intent is to demystify what plugin managers do and show that for basic configs, a standalone tool is unnecessary.

Zcomet is a minimal plugin manager from the same author that formalizes the unplugged approach. It achieves excellent benchmark scores (10% first-prompt lag, 44% first-command lag) with a tiny codebase.

**vs Zert:** Zsh Unplugged is an educational exercise; Zert is a production tool. The unplugged approach has no lockfile, no parallel install, no compilation, no framework compatibility, and no UI. Zcomet adds structure but remains minimal — no lockfile, no parallel install. Both philosophies reject complexity, but Zert adds reproducibility and performance tooling while keeping the same inline declaration model. If you want the simplest possible setup and are willing to manage versions manually, the unplugged approach works. If you want reproducibility without thinking about it, Zert fills that gap.
