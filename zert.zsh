# Zert - Pure Zsh plugin manager
# Main entrypoint - source this file from your .zshrc

# Get the directory where this script is located
_ZERT_BASE_DIR="${${(%):-%x}:A:h}"

# Resolve ZERT_DIR with XDG defaults
export ZERT_DIR="${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}"

# Resolve ZERT_PLUGINS_DIR with XDG defaults
export ZERT_PLUGINS_DIR="${ZERT_PLUGINS_DIR:-$ZERT_DIR/plugins}"

# Resolve other config paths
export ZERT_LOCKFILE="${ZERT_LOCKFILE:-${ZDOTDIR:-$HOME}/zert.lock}"

# Initialize loaded plugins array
typeset -ga __ZERT_LOADED_PLUGINS

# Set up fpath for lazy loading
fpath=("$_ZERT_BASE_DIR/functions" "$_ZERT_BASE_DIR/commands" $fpath)

# Mark functions for autoload
autoload -Uz _zert_check_deps
autoload -Uz _zert_cmd_list _zert_cmd_update _zert_cmd_prune _zert_cmd_lock _zert_cmd_config _zert_cmd_use
autoload -Uz _zert_ui_ok _zert_ui_error _zert_ui_log _zert_ui_progress _zert_ui_emphasize
autoload -Uz _zert_parse_source _zert_plugin_add
autoload -Uz _zert_plugin_sanitize_id _zert_parse_flags _zert_lockfile_read_entry _zert_lockfile_write_entry
autoload -Uz _zert_plugin_ensure_exists _zert_plugin_clone _zert_plugin_ensure_sync _zert_plugin_sync _zert_plugin_compile _zert_plugin_source
autoload -Uz zert

# Run dependency check
_zert_check_deps || return 1
