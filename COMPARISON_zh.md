# Zsh 插件管理器对比

本文档将 Zert 与最广泛使用的 Zsh 插件管理器进行对比。面向正在评估哪个插件管理器适合自己工作流程的有经验的 Zsh 用户。每个条目描述了管理器的工作方式、插件配置方法，以及其方式与 Zert 的差异。

对比表一目了然地展示关键维度。下方的各个部分提供了每个管理器的更深入信息。

---

## 对比表

| 特性 | Zert | Antidote | Antibody | Antigen | Sheldon | Zap | Zgenom | Zim | Zinit | Zplug |
|---|---|---|---|---|---|---|---|---|---|---|
| **编写语言** | Zsh | Zsh | Go | Zsh | Rust | Zsh | Zsh | Zsh | Zsh | Zsh |
| **配置方式** | 内联 | 单独文件 | 单独文件 | 内联 | TOML 文件 | 内联 | 内联 | `.zimrc` 文件 | 内联 | 内联 |
| **锁文件** | 是 | 否 | 否 | 否 | 否 | 否 | 否 | 否 | 否 | 否 |
| **并行安装** | 是 | 是 | 是 | 否 | 是 | 否 | 否 | 是 | 否 | 是 |
| **加载策略** | 直接 source | 静态文件 | 静态文件 | 静态包 | 静态文件 | 直接 source | 静态文件 | 静态文件 | Turbo 模式（异步） | 缓存 |
| **字节码编译** | 是 | 否 | 否 | 是 | N/A | 否 | 可选 | 是 | 是 | 否 |
| **OMZ 支持** | 是 | 是 | 是 | 是 | 模板 | 有限 | 是 | 是 | 是（snippet） | 是 |
| **Prezto 支持** | 是 | 是 | 否 | 否 | 模板 | 否 | 是 | 是 | 是（snippet） | 是 |
| **自我管理** | 是 | 否 | 否 | 否 | 否 | 否 | 否 | 否 | 否 | 否 |
| **配置文件** | 无 | `plugins.txt` | `plugins.txt` | 无 | `plugins.toml` | 无 | 无 | `.zimrc` | 无 | 无 |
| **外部二进制** | 无 | 无 | Go 二进制 | 无 | Rust 二进制 | 无 | 无 | 无 | 无 | 无 |
| **状态** | 活跃 | 活跃 | 已归档 | 未维护 | 活跃 | 活跃 | 活跃 | 活跃 | 活跃 | 已弃用 |

---

## Antidote

**GitHub：** [mattmc3/antidote](https://github.com/mattmc3/antidote) · **状态：** 活跃

Antidote 是一个纯 Zsh 插件管理器，作为 Antibody 的继任者创建。它从 `~/.zsh_plugins.txt` 文件（每行一个插件）读取插件，生成包含 `source` 语句的静态加载脚本，你的 `.zshrc` 源引该生成的文件。在后续的 shell 启动中，仅源引静态文件——不会重新解析插件声明。

安装是并行的。加载实际上是一次 `source` 调用。Antidote 使用 `owner/repo` 简写格式原生支持 Oh-My-Zsh 和 Prezto 插件。

**与 Zert 的对比：** Antidote 使用单独的 `plugins.txt` 配置文件；Zert 在 `.zshrc` 中内联声明插件。Antidote 没有锁文件——插件不会固定到提交 SHA，因此跨机器的可复现性取决于每个克隆的状态。Zert 写入 `zert.lock` 将每个插件固定到精确的提交。两者都是纯 Zsh 且支持并行安装。Antidote 的静态文件方式意味着加载时零解析开销；Zert 每次启动时解析声明，但当插件已同步时会优化跳过 UI/git 操作。

---

## Antibody

**GitHub：** [getantibody/antibody](https://github.com/getantibody/antibody) · **状态：** 已归档（2021 年 1 月弃用）

Antibody 是一个用 Go 编写的管理 Zsh 插件的二进制程序。它支持 `plugins.txt` 文件（类似于 Antidote）并可以生成静态加载文件。它是 Antidote 的前身——其作者在原生 Zsh 管理器在性能上赶超后将其弃用。

Antibody 的 Go 实现处理解析和文件生成，但实际的插件加载由 Zsh 的 `source` 命令完成，这意味着 Go 二进制仅减少了配置解析开销，而非插件加载开销。

**与 Zert 的对比：** Antibody 需要编译的 Go 二进制；Zert 是纯 Zsh。Antibody 没有锁文件或提交固定。Antibody 已归档且不再维护；Zert 正在积极开发。两者都支持并行安装和静态加载。关键区别在于依赖模型——Zert 仅需要 `git` 和 `curl`，而 Antibody 需要安装和更新 Go 二进制。

---

## Antigen

**GitHub：** [zsh-users/antigen](https://github.com/zsh-users/antigen) · **状态：** 未维护

Antigen 是最早的 Zsh 插件管理器之一，受 Vim 的 Vundle/Pathogen 启发。它引入了 `antigen bundle` 命令用于内联声明插件，并且是第一个将 Oh-My-Zsh 插件兼容性带入独立插件管理的工具。后续版本添加了静态包加载和字节码编译。

Antigen 通过按顺序源引插件来加载。它没有并行安装能力。干净启动时间约为 60ms，比现代替代方案慢。

**与 Zert 的对比：** 两者都使用内联声明。Antigen 没有锁文件、没有并行安装、没有提交固定。Antigen 未维护；Zert 活跃。Antigen 的字节码编译早于 Zert，但 Zert 的并行克隆 + 树克隆策略使安装明显更快。Antigen 仅支持 Oh-My-Zsh；Zert 还支持 Prezto。

---

## Sheldon

**GitHub：** [rossmacarthur/sheldon](https://github.com/rossmacarthur/sheldon) · **状态：** 活跃

Sheldon 是一个用 Rust 编写的 shell 插件管理器。它使用 TOML 配置文件（`plugins.toml`）并生成静态加载脚本。因为解析和文件生成在 Rust 中发生，Zsh 启动开销最小——shell 仅源引预生成的文件。

Sheldon 支持来自 Git 仓库的插件（支持分支/标签/提交固定）、GitHub Gist、远程脚本、本地插件和内联插件。它使用模板系统来实现灵活的安装方法。它与 shell 无关，可与 Bash 和 Zsh 一起使用。

**与 Zert 的对比：** Sheldon 需要 Rust 二进制；Zert 是纯 Zsh。Sheldon 使用 TOML 配置文件；Zert 使用内联声明。Sheldon 没有锁文件；Zert 的 `zert.lock` 将每个插件固定到精确的提交。Sheldon 与 shell 无关；Zert 是 Zsh 特定的。Sheldon 的模板系统更可配置但增加了复杂性；Zert 的方式更简单，使用合理的默认值。两者都支持并行安装。

---

## Zap

**GitHub：** [zap-zsh/zap](https://github.com/zap-zsh/zap) · **状态：** 活跃

Zap 是一个极简的 Zsh 插件管理器。插件使用 `.zshrc` 中的 `plug` 命令内联声明。它在首次加载时克隆插件并直接源引——没有静态文件生成、没有字节码编译、没有缓存。整个代码库很小。

Zap 提供 `zap update`、`zap list` 和 `zap clean` 子命令。它支持本地插件和用于私有仓库的自定义 URL 前缀。它没有 Oh-My-Zsh 或 Prezto 集成。

**与 Zert 的对比：** 两者都使用内联声明且是纯 Zsh。Zap 在理念上最接近 Zert——极简、内联、无配置文件。然而，Zap 没有锁文件、没有并行安装、没有字节码编译，框架兼容性有限。Zert 在相同的内联模型上增加了可复现性（锁文件）、性能（并行 + 编译）和 OMZ/Prezto 支持。Zap 更简单；Zert 更强大。

---

## Zgenom

**GitHub：** [jandamm/zgenom](https://github.com/jandamm/zgenom) · **状态：** 活跃

Zgenom 是 zgen 的维护分支。它采用"生成一次，源引多次"的方式：插件在 `if ! zgenom saved; then ... zgenom save; fi` 块中使用 `zgenom load` 命令声明。首次运行时，它克隆插件并生成静态初始化脚本。后续运行时，它直接源引该脚本。

Zgenom 支持 Oh-My-Zsh 和 Prezto、可配置时间表的自动更新、单个插件的 `--pin`，以及 `zgenom compile` 字节码编译。它还有 `zgenom autoupdate` 功能，定期在后台检查更新而不会减慢启动速度。

**与 Zert 的对比：** 两者都是纯 Zsh，具有内联声明和 OMZ/Prezto 支持。Zgenom 在更改插件声明后需要手动 `zgenom reset` 来重新生成初始化脚本；Zert 在每次加载时自动检测更改。Zgenom 的 `--pin` 可用于单个插件但没有全局锁文件；Zert 的 `zert.lock` 原子性地固定每个插件。Zgenom 的静态文件方式意味着热加载时零解析开销；Zert 每次解析声明但在插件已同步时会短路。Zgenom 没有并行安装；Zert 并行克隆。

---

## Zim (zimfw)

**GitHub：** [zimfw/zimfw](https://github.com/zimfw/zimfw) · **状态：** 活跃

Zim 是一个 Zsh 配置框架，将插件管理器与精选模块捆绑在一起。它使用单独的 `~/.zimrc` 文件和 `zmodule` 调用来定义模块。它构建静态 `init.zsh` 脚本并积极地将所有 Zsh 文件编译为字节码。热加载时间极快——在基准测试中约为 0.009s。

Zim 提供自己的模块（环境、git、输入、补全等）以及外部插件。它支持 `degit` 工具（基于 curl/wget）作为 git 的替代方案，用于在 GitHub 仓库上更快、更轻量的安装。模块可以定义自定义源文件、自动加载函数和拉取后钩子。

**与 Zert 的对比：** Zim 是带有插件管理器的框架；Zert 是独立的插件管理器。Zim 使用单独的 `.zimrc` 配置文件；Zert 使用内联声明。Zim 没有锁文件。Zim 的积极字节码编译使其在生态系统中拥有最快的热加载时间。Zert 也编译，但 Zim 的框架级集成意味着它也编译自己的基础设施。Zim 的 `degit` 选项用 git 历史换取更快的下载；Zert 始终使用 git。Zim 的精选模块集既是优点（开箱即用的默认设置）也是缺点（不如从任意仓库灵活挑选）。

---

## Zinit

**GitHub：** [zdharma-continuum/zinit](https://github.com/zdharma-continuum/zinit) · **状态：** 活跃（原作者于 2021 年删除项目后由社区维护）

Zinit 是功能最丰富的 Zsh 插件管理器。它的定义性特征是"turbo 模式"——插件在提示符出现后异步加载，隐藏加载延迟。它还提供字节码编译、插件报告（显示插件设置了哪些别名、函数和补全）、用于可扩展性的 annex 系统，以及用于后台进程的服务。

Zinit 使用 `zinit light` 加载插件，使用 `zinit snippet` 从 Oh-My-Zsh 或 Prezto 仓库加载单个文件。它有一个复杂的"ice 修饰符"系统（`atload`、`wait`、`depth`、`lucid` 等），控制插件的加载方式和时间。Turbo 模式可以将感知启动时间减少 50-80%，尽管有取舍——一些插件期望同步加载，在延迟时会出问题。

**与 Zert 的对比：** Zinit 是最复杂的管理器；Zert 刻意简单。Zinit 有 turbo 模式（异步加载）；Zert 在提示符之前同步加载所有内容。Zinit 没有锁文件；Zert 的 `zert.lock` 固定每个提交。Zinit 的 ice 修饰符系统强大但学习曲线陡峭；Zert 的 `--pin`、`--branch`、`--no-alias` 标志覆盖了常见情况而无复杂性。Zinit 在动荡的历史后由社区维护；Zert 正在积极开发。两者都支持 OMZ/Prezto 和字节码编译。Zinit 解决感知延迟；Zert 解决可复现性。

---

## Zplug

**GitHub：** [zplug/zplug](https://github.com/zplug/zplug) · **状态：** 已弃用

Zplug 是一个功能丰富的插件管理器，支持并行安装、延迟加载、插件间依赖管理、分支/标签/提交固定和更新后钩子。它管理来自 GitHub、Bitbucket、Oh-My-Zsh、Prezto 和本地目录的插件。

尽管功能丰富，Zplug 的实现较差——干净启动时间约为 160ms，明显慢于替代方案。该项目已被弃用，没有最近的提交。

**与 Zert 的对比：** 两者都使用内联声明。Zplug 有并行安装和缓存但性能较差；Zert 通过树克隆以最小开销实现并行安装。Zplug 没有锁文件；Zert 的 `zert.lock` 提供可复现性。Zplug 已弃用；Zert 活跃。Zplug 的插件间依赖管理是 Zert 未复制的独特功能。Zplug 的延迟加载在概念上类似于 Zinit 的 turbo 模式但实现较差。

---

## Zsh Unplugged / Zcomet

**GitHub：** [mattmc3/zsh_unplugged](https://github.com/mattmc3/zsh_unplugged) / [menacel-mgmt/zcomet](https://github.com/menacel-mgmt/zcomet) · **状态：** 活跃

Zsh Unplugged 不是插件管理器——它是一个约 20 行的 `plugin-load` 函数，演示如何在没有任何管理器的情况下管理 Zsh 插件。它克隆仓库，找到适当的 `.zsh` 文件并源引它。目的是揭开插件管理器的神秘面纱，并展示对于基本配置，独立工具是不必要的。

Zcomet 是来自同一作者的极简插件管理器，形式化了 unplugged 方式。它以极小的代码库实现了出色的基准分数（10% 首次提示延迟，44% 首次命令延迟）。

**与 Zert 的对比：** Zsh Unplugged 是一个教育练习；Zert 是生产工具。unplugged 方式没有锁文件、没有并行安装、没有编译、没有框架兼容性、没有 UI。Zcomet 增加了结构但仍然极简——没有锁文件、没有并行安装。两种理念都拒绝复杂性，但 Zert 在保持相同内联声明模型的同时增加了可复现性和性能工具。如果你想要最简单的设置并愿意手动管理版本，unplugged 方式可行。如果你想要无需思考的可复现性，Zert 填补了这一空白。
