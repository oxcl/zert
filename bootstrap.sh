#!/bin/sh
# Bootstrap script for Zert - clones the zert repository
# This script is POSIX sh compatible (no zsh dependencies)
#
# Add this to your .zshrc:
# ZERT_PLUGINS_DIR="${ZERT_PLUGINS_DIR:-${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}/plugins}"; \
# [[ -f "$ZERT_PLUGINS_DIR/zert/zert.zsh" ]] || \
# (curl -fsSL https://raw.githubusercontent.com/oxcl/zert/main/bootstrap.sh | zsh); \
# source "$ZERT_PLUGINS_DIR/zert/zert.zsh"

set -e

# Determine ZERT_PLUGINS_DIR with XDG defaults
ZERT_PLUGINS_DIR="${ZERT_PLUGINS_DIR:-${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}/plugins}"

# If already cloned (marker files exist), we're done (idempotent)
if [ -f "$ZERT_PLUGINS_DIR/zert/zert.zsh" ] && [ -f "$ZERT_PLUGINS_DIR/zert/zert.plugin.zsh" ]; then
    exit 0
fi

# Create directory if needed
mkdir -p "$ZERT_PLUGINS_DIR"

# Clone to temp directory first, then move (atomic-ish)
TMPDIR_ZERT=$(mktemp -d "$ZERT_PLUGINS_DIR/.zert-bootstrap-XXXXXX")

cleanup() {
    rm -rf "$TMPDIR_ZERT"
}
trap cleanup EXIT

# Log message in cyan to stderr before cloning
printf '\033[36m[zert] Downloading zert to %s/zert...\033[0m\n' "$ZERT_PLUGINS_DIR" >&2

# Clone zert repository (shallow, single-branch for minimal bandwidth)
git clone --filter=tree:0 --single-branch --branch main --depth 1 https://github.com/oxcl/zert.git "$TMPDIR_ZERT/zert"

# Move to final location
mv "$TMPDIR_ZERT/zert" "$ZERT_PLUGINS_DIR/zert"