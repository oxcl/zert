# Zert - Pure Zsh plugin manager
# Main entrypoint - source this file from your .zshrc

# Get the directory where this script is located
_ZERT_BASE_DIR="${${(%):-%x}:A:h}"

# Zert version
typeset -g ZERT_VERSION="0.1.0"

# Resolve ZERT_DIR with XDG defaults
export ZERT_DIR="${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}"

# Resolve ZERT_PLUGINS_DIR with XDG defaults
export ZERT_PLUGINS_DIR="${ZERT_PLUGINS_DIR:-$ZERT_DIR/plugins}"

# Resolve other config paths
export ZERT_LOCKFILE="${ZERT_LOCKFILE:-${ZDOTDIR:-$HOME}/zert.lock}"

# Initialize loaded plugins array
typeset -ga __ZERT_LOADED_PLUGINS

# Color definitions (respects NO_COLOR)
if [[ -z "$NO_COLOR" ]]; then
  typeset -g __ZERT_CLR_RESET=$'\033[0m'
  typeset -g __ZERT_CLR_BOLD=$'\033[1m'
  typeset -g __ZERT_CLR_ITALIC=$'\033[3m'
  typeset -g __ZERT_CLR_RED=$'\033[31m'
  typeset -g __ZERT_CLR_GREEN=$'\033[32m'
  typeset -g __ZERT_CLR_YELLOW=$'\033[33m'
  typeset -g __ZERT_CLR_BLUE=$'\033[34m'
  typeset -g __ZERT_CLR_CYAN=$'\033[36m'
  typeset -g __ZERT_CLR_GRAY=$'\033[90m'
else
  typeset -g __ZERT_CLR_RESET=''
  typeset -g __ZERT_CLR_BOLD=''
  typeset -g __ZERT_CLR_ITALIC=''
  typeset -g __ZERT_CLR_RED=''
  typeset -g __ZERT_CLR_GREEN=''
  typeset -g __ZERT_CLR_YELLOW=''
  typeset -g __ZERT_CLR_BLUE=''
  typeset -g __ZERT_CLR_CYAN=''
  typeset -g __ZERT_CLR_GRAY=''
fi

# Set up fpath for lazy loading
fpath=("$_ZERT_BASE_DIR/functions" "$_ZERT_BASE_DIR/commands" $fpath)

# Mark functions for autoload
autoload -Uz _zert_check_deps
autoload -Uz _zert_cmd_list _zert_cmd_update _zert_cmd_prune _zert_cmd_use _zert_cmd_ohmyzsh _zert_cmd_prezto _zert_cmd_help
autoload -Uz _zert_ui_ok _zert_ui_error _zert_ui_log _zert_ui_emphasize _zert_ui_truncate _zert_ui_pick_spinner _zert_ui_task_start _zert_ui_task_update _zert_ui_task_end _zert_ui_subtask_start _zert_ui_subtask_update _zert_ui_subtask_end _zert_ui_subtask_log _zert_ui_background_renderer
autoload -Uz _zert_parse_source _zert_plugin_add _zert_should_fast_track _zert_fast_track
autoload -Uz _zert_plugin_sanitize_id _zert_parse_flags _zert_lockfile_read_entry _zert_lockfile_write_entry _zert_lockfile_remove_entry
autoload -Uz _zert_plugin_ensure_exists _zert_plugin_clone _zert_plugin_ensure_sync _zert_plugin_register _zert_plugin_checkout _zert_plugin_pull _zert_plugin_update _zert_plugin_compile _zert_plugin_source _zert_source_file
autoload -Uz _zert_use_ohmyzsh _zert_use_prezto _zert_use_source_file
autoload -Uz zert

# Zsh completions
autoload -Uz _zert
(( $+functions[compdef] )) && compdef _zert zert

# Run dependency check
_zert_check_deps || return 1


