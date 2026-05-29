#!/usr/bin/env zsh
# sandbox.zsh — Isolated environment for manual testing
#
# Usage:
#   source ./sandbox.zsh           # Basic setup
#   source ./sandbox.zsh stale     # With stale dirs for prune testing
#   source ./sandbox.zsh pinned    # With pinned plugin for update testing
#   source ./sandbox.zsh empty     # No plugins loaded
#   source ./sandbox.zsh debug     # Basic setup with set -x tracing
#
# Cleanup:
#   zert_sandbox_cleanup

# Guard against double-sourcing
if [[ -n "$ZERT_SANDBOX_DIR" ]]; then
  print "Sandbox already active. Run 'zert_sandbox_cleanup' first."
  return 1
fi

# Create isolated temp directory
ZERT_SANDBOX_DIR=$(mktemp -d -t zert_sandbox_XXXXXX)

# Override Zert config paths BEFORE sourcing zert.zsh
export ZERT_DIR="$ZERT_SANDBOX_DIR"
export ZERT_PLUGINS_DIR="$ZERT_DIR/plugins"
export ZERT_LOCKFILE="$ZERT_SANDBOX_DIR/zert.lock"

# Create directory structure
mkdir -p "$ZERT_PLUGINS_DIR"

# Get scenario from argument
local scenario="${1:-basic}"
local debug_mode=false
[[ "$scenario" == "debug" ]] && { scenario="basic"; debug_mode=true; }

# --- Mock Plugin Creation ---

_zert_sandbox_create_plugin() {
  local dir="$1" main_file="$2" content="$3"
  mkdir -p "$dir"
  print "$content" > "$dir/$main_file"
}

# Plugin 1: zsh-autosuggestions
_zert_sandbox_create_plugin \
  "$ZERT_PLUGINS_DIR/github.com--zsh-users--zsh-autosuggestions" \
  "zsh-autosuggestions.plugin.zsh" \
  'echo "[sandbox] zsh-autosuggestions loaded"'

# Plugin 2: zsh-syntax-highlighting
_zert_sandbox_create_plugin \
  "$ZERT_PLUGINS_DIR/github.com--zsh-users--zsh-syntax-highlighting" \
  "zsh-syntax-highlighting.zsh" \
  'echo "[sandbox] zsh-syntax-highlighting loaded"'

# Plugin 3: my-custom-plugin (completions + aliases)
local custom_dir="$ZERT_PLUGINS_DIR/github.com--myuser--my-custom-plugin"
mkdir -p "$custom_dir/completions"
_zert_sandbox_create_plugin \
  "$custom_dir" \
  "my-custom-plugin.plugin.zsh" \
  'echo "[sandbox] my-custom-plugin loaded"
alias testalias="echo testalias works"'
print '#compdef testcmd' > "$custom_dir/completions/_testcmd"

# Plugin 4: ohmyzsh framework
local omz_dir="$ZERT_PLUGINS_DIR/ohmyzsh"
mkdir -p "$omz_dir/plugins/git" "$omz_dir/lib"
print '# git plugin' > "$omz_dir/plugins/git/git.plugin.zsh"
print '# clipboard lib' > "$omz_dir/lib/clipboard.zsh"

# Plugin 5: local plugin
local local_dir="$ZERT_SANDBOX_DIR/local-plugins/my-work-plugin"
mkdir -p "$local_dir"
_zert_sandbox_create_plugin \
  "$local_dir" \
  "my-work-plugin.plugin.zsh" \
  'echo "[sandbox] my-work-plugin (local) loaded"'

# --- Scenario-specific setup ---

case "$scenario" in
  stale)
    # Create extra dirs not in loaded plugins (for prune testing)
    mkdir -p "$ZERT_PLUGINS_DIR/github.com--stale--old-plugin"
    print 'echo "stale"' > "$ZERT_PLUGINS_DIR/github.com--stale--old-plugin/old.zsh"
    mkdir -p "$ZERT_PLUGINS_DIR/github.com--stale--another-old"
    print 'echo "stale2"' > "$ZERT_PLUGINS_DIR/github.com--stale--another-old/another.zsh"
    ;;
  pinned)
    # Will add pin flag to lockfile entry below
    ;;
  empty)
    # No plugins loaded, no lockfile
    ;;
esac

# --- Create Lockfile ---

if [[ "$scenario" != "empty" ]]; then
  local pin_options=""
  [[ "$scenario" == "pinned" ]] && pin_options="pin=abc123def456"

  cat > "$ZERT_LOCKFILE" << EOF
# AUTO-GENERATED FILE. DO NOT EDIT MANUALLY.
# Commit this file to version control for reproducible installs.
version::1
github.com--zsh-users--zsh-autosuggestions::git::https://github.com/zsh-users/zsh-autosuggestions::a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0::
github.com--zsh-users--zsh-syntax-highlighting::git::https://github.com/zsh-users/zsh-syntax-highlighting::b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1::
github.com--myuser--my-custom-plugin::git::https://github.com/myuser/my-custom-plugin::c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2::${pin_options}
ohmyzsh::ohmyzsh::ohmyzsh::d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3::
EOF
fi

# --- Source Zert ---

source "${0:A:h}/zert.zsh"

# Enable tracing if debug mode
if $debug_mode; then
  set -x
  print "[sandbox] Debug mode enabled (set -x active)"
fi

# --- Populate Loaded Plugins ---

if [[ "$scenario" != "empty" ]]; then
  __ZERT_LOADED_PLUGINS=(
    "github.com--zsh-users--zsh-autosuggestions"
    "github.com--zsh-users--zsh-syntax-highlighting"
    "github.com--myuser--my-custom-plugin"
    "ohmyzsh"
    "ohmyzsh:plugins/git"
    "local--home--user--sandbox-plugins--my-work-plugin"
  )
fi

# Fix the local plugin ID to match the actual temp path
# (The ID above is a placeholder; we need the real path-based ID)
if [[ "$scenario" != "empty" ]]; then
  local real_local_id="local${local_dir//\//--}"
  __ZERT_LOADED_PLUGINS[-1]="$real_local_id"
fi

# --- Cleanup Function ---

zert_sandbox_cleanup() {
  if [[ -n "$ZERT_SANDBOX_DIR" && -d "$ZERT_SANDBOX_DIR" ]]; then
    rm -rf "$ZERT_SANDBOX_DIR"
    unset ZERT_SANDBOX_DIR
    unset ZERT_DIR
    unset ZERT_PLUGINS_DIR
    unset ZERT_LOCKFILE
    __ZERT_LOADED_PLUGINS=()
    print "Sandbox cleaned up."
  else
    print "No active sandbox to clean up."
  fi
}

zert_sandbox_debug_on() {
  set -x
  print "[sandbox] Debug tracing ON"
}

zert_sandbox_debug_off() {
  set +x
  print "[sandbox] Debug tracing OFF"
}

# --- Print Status ---

print ""
print "=== Zert Sandbox Active ==="
print "Scenario: $scenario"
print "Debug:    $debug_mode"
print "ZERT_DIR: $ZERT_DIR"
print "ZERT_PLUGINS_DIR: $ZERT_PLUGINS_DIR"
print "ZERT_LOCKFILE: $ZERT_LOCKFILE"
print "Loaded plugins: ${#__ZERT_LOADED_PLUGINS}"
print ""
print "Available commands:"
print "  zert list              Show loaded plugins"
print "  zert prune             Delete unused plugin dirs"
print "  zert update            Update all lockfile entries"
print "  cat \$ZERT_LOCKFILE    View lockfile"
print "  ls \$ZERT_PLUGINS_DIR  View plugin dirs"
print ""
print "Debug commands:"
print "  zert_sandbox_debug_on  Enable set -x tracing"
print "  zert_sandbox_debug_off Disable set -x tracing"
print ""
print "Cleanup: zert_sandbox_cleanup"
print "============================="
print ""
