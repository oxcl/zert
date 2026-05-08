#!/usr/bin/env zsh
# Test suite for plugin add functions

ZERT_DIR="${ZERT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ZERT_DIR/tests/runner.zsh"
source "$ZERT_DIR/functions/_zert_plugin_sanitize_id"
source "$ZERT_DIR/functions/_zert_parse_flags"
source "$ZERT_DIR/functions/_zert_lockfile_read_entry"
source "$ZERT_DIR/functions/_zert_lockfile_write_entry"
source "$ZERT_DIR/functions/_zert_parse_source"

test_zert_plugin_sanitize_id_git_url() {
  local output
  output="$(_zert_plugin_sanitize_id "git" "https://github.com/user/repo")"
  assert_eq "github.com/user/repo" "$output"
}

test_zert_plugin_sanitize_id_ssh() {
  local output
  output="$(_zert_plugin_sanitize_id "git" "git@github.com:user/repo")"
  assert_eq "github.com/user/repo" "$output"
}

test_zert_plugin_sanitize_id_local() {
  local output
  output="$(_zert_plugin_sanitize_id "local" "/absolute/path/to/plugin")"
  assert_eq "local--absolute--path--to--plugin" "$output"
}

test_zert_plugin_sanitize_id_ohmyzsh() {
  local output
  output="$(_zert_plugin_sanitize_id "ohmyzsh" "ohmyzsh/lib/clipboard")"
  assert_eq "ohmyzsh/lib/clipboard" "$output"
}

test_zert_plugin_sanitize_id_prezto() {
  local output
  output="$(_zert_plugin_sanitize_id "prezto" "prezto/modules/utility")"
  assert_eq "prezto/modules/utility" "$output"
}

test_zert_parse_flags_branch() {
  local output
  output="$(_zert_parse_flags --branch main)"
  assert_eq "branch=main" "$output"
}

test_zert_parse_flags_pin() {
  local output
  output="$(_zert_parse_flags --pin abc123)"
  assert_eq "pin=abc123" "$output"
}

test_zert_parse_flags_no_alias() {
  local output
  output="$(_zert_parse_flags --no-alias)"
  assert_eq "no-alias=true" "$output"
}

test_zert_parse_flags_combined() {
  local output
  output="$(_zert_parse_flags --branch main --no-completion)"
  assert_eq "branch=main,no-completion=true" "$output"
}

test_zert_lockfile_write_and_read() {
  local tmpfile="/tmp/zert_test_lock.$$"
  ZERT_LOCKFILE="$tmpfile"

  # Write entry
  _zert_lockfile_write_entry "test/plugin" "git" "https://github.com/test/plugin" "abc123" "branch=main"

  # Read entry
  local entry
  entry="$(_zert_lockfile_read_entry "test/plugin")"

  # Cleanup
  rm -f "$tmpfile"

  assert_eq "test/plugin::git::https://github.com/test/plugin::abc123::branch=main" "$entry"
}

test_zert_lockfile_update_entry() {
  local tmpfile="/tmp/zert_test_lock.$$"
  ZERT_LOCKFILE="$tmpfile"

  # Write initial entry
  _zert_lockfile_write_entry "test/plugin" "git" "https://github.com/test/plugin" "abc123" "branch=main"
  # Update entry
  _zert_lockfile_write_entry "test/plugin" "git" "https://github.com/test/plugin" "def456" "branch=main,pin=def456"

  # Read updated entry
  local entry
  entry="$(_zert_lockfile_read_entry "test/plugin")"

  # Cleanup
  rm -f "$tmpfile"

  assert_eq "test/plugin::git::https://github.com/test/plugin::def456::branch=main,pin=def456" "$entry"
}

test_zert_parse_source_github_shorthand() {
  local output
  _zert_parse_source "user/repo" >/dev/null 2>&1
  assert_eq "git" "$__ZERT_SOURCE_TYPE"
  assert_eq "https://github.com/user/repo" "$__ZERT_SOURCE_VALUE"
}

test_zert_parse_source_ssh() {
  local output
  _zert_parse_source "git@github.com:user/repo" >/dev/null 2>&1
  assert_eq "git" "$__ZERT_SOURCE_TYPE"
  assert_eq "git://github.com/user/repo" "$__ZERT_SOURCE_VALUE"
}

test_zert_parse_source_full_url() {
  local output
  _zert_parse_source "https://gitlab.com/user/repo" >/dev/null 2>&1
  assert_eq "git" "$__ZERT_SOURCE_TYPE"
  assert_eq "https://gitlab.com/user/repo" "$__ZERT_SOURCE_VALUE"
}

test_zert_parse_source_invalid() {
  _zert_parse_source "not_valid" >/dev/null 2>&1
  assert_eq "" "$__ZERT_SOURCE_TYPE"
}

run_tests \
  test_zert_plugin_sanitize_id_git_url \
  test_zert_plugin_sanitize_id_ssh \
  test_zert_plugin_sanitize_id_local \
  test_zert_plugin_sanitize_id_ohmyzsh \
  test_zert_plugin_sanitize_id_prezto \
  test_zert_parse_flags_branch \
  test_zert_parse_flags_pin \
  test_zert_parse_flags_no_alias \
  test_zert_parse_flags_combined \
  test_zert_lockfile_write_and_read \
  test_zert_lockfile_update_entry \
  test_zert_parse_source_github_shorthand \
  test_zert_parse_source_ssh \
  test_zert_parse_source_full_url \
  test_zert_parse_source_invalid
