# Zert - Pure Zsh plugin manager
# Main entrypoint - source this file from your .zshrc

# Get the directory where this script is located
_ZERT_BASE_DIR="${${(%):-%x}:A:h}"

# Resolve ZERT_PLUGINS_DIR with XDG defaults
ZERT_PLUGINS_DIR="${ZERT_PLUGINS_DIR:-${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}/plugins}"

# Resolve other config paths
ZERT_LOCKFILE="${ZERT_LOCKFILE:-${ZDOTDIR:-$HOME}/zert.lock}"

# Set up fpath for lazy loading
fpath=("$_ZERT_BASE_DIR/functions" "$_ZERT_BASE_DIR/commands" $fpath)

# Mark functions for autoload
autoload -Uz _zert_check_deps
autoload -Uz _zert_cmd_list _zert_cmd_update _zert_cmd_prune _zert_cmd_lock _zert_cmd_config
autoload -Uz _zert_ui_ok _zert_ui_error _zert_ui_log _zert_ui_progress _zert_ui_emphasize
autoload -Uz zert

# Run dependency check
_zert_check_deps || return 1
