#!/usr/bin/env zsh
# Test suite for UI functions

ZERT_DIR="${ZERT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ZERT_DIR/tests/runner.zsh"
source "$ZERT_DIR/functions/_zert_ui_emphasize"
source "$ZERT_DIR/functions/_zert_ui_error"
source "$ZERT_DIR/functions/_zert_ui_ok"
source "$ZERT_DIR/functions/_zert_ui_log"
source "$ZERT_DIR/functions/_zert_ui_progress"

test_zert_ui_emphasize_no_formatting() {
  local output
  output="$(NO_COLOR= _zert_ui_emphasize "plain text" 2>&1)"
  assert_eq "plain text" "$output"
}

test_zert_ui_emphasize_bold_formatting() {
  local output
  output="$(NO_COLOR= _zert_ui_emphasize "this is **bold** text" 2>&1)"
  assert_eq "this is $(printf '\033[33m\033[1mbold\033[0m') text" "$output"
}

test_zert_ui_emphasize_multiple_bold() {
  local output
  output="$(NO_COLOR= _zert_ui_emphasize "**first** and **second**" 2>&1)"
  assert_eq "$(printf '\033[33m\033[1mfirst\033[0m') and $(printf '\033[33m\033[1msecond\033[0m')" "$output"
}

test_zert_ui_emphasize_no_color() {
  local output
  output="$(NO_COLOR=1 _zert_ui_emphasize "**bold**" 2>&1)"
  assert_eq "bold" "$output"
}

test_zert_ui_error_output() {
  local output
  output="$(NO_COLOR= _zert_ui_error "test error" 2>&1)"
  assert_eq "$(printf '\033[31m✗\033[0m \033[31mtest error\033[0m')" "$output"
}

test_zert_ui_error_no_color() {
  local output
  output="$(NO_COLOR=1 _zert_ui_error "test error" 2>&1)"
  assert_eq "✗ test error" "$output"
}

test_zert_ui_ok_output() {
  local output
  output="$(NO_COLOR= _zert_ui_ok "test success" 2>&1)"
  assert_eq "$(printf '\033[32m✓\033[0m \033[32mtest success\033[0m')" "$output"
}

test_zert_ui_ok_no_color() {
  local output
  output="$(NO_COLOR=1 _zert_ui_ok "test success" 2>&1)"
  assert_eq "✓ test success" "$output"
}

test_zert_ui_log_output() {
  local output
  output="$(NO_COLOR= _zert_ui_log "test log" 2>&1)"
  assert_eq "$(printf '\033[34m•\033[0m test log')" "$output"
}

test_zert_ui_log_no_color() {
  local output
  output="$(NO_COLOR=1 _zert_ui_log "test log" 2>&1)"
  assert_eq "• test log" "$output"
}

test_zert_ui_progress_output() {
  local output
  output="$(NO_COLOR= COLUMNS=80 _zert_ui_progress "plugin" "loading" 2>&1)"
  assert_eq "$(printf "\r\033[36m...\033[0m %-80s" "plugin: loading")" "$output"
}

test_zert_ui_progress_no_color() {
  local output
  output="$(NO_COLOR=1 COLUMNS=80 _zert_ui_progress "plugin" "loading" 2>&1)"
  assert_eq "$(printf "\r... %-80s" "plugin: loading")" "$output"
}

run_tests \
  test_zert_ui_emphasize_no_formatting \
  test_zert_ui_emphasize_bold_formatting \
  test_zert_ui_emphasize_multiple_bold \
  test_zert_ui_emphasize_no_color \
  test_zert_ui_error_output \
  test_zert_ui_error_no_color \
  test_zert_ui_ok_output \
  test_zert_ui_ok_no_color \
  test_zert_ui_log_output \
  test_zert_ui_log_no_color \
  test_zert_ui_progress_output \
  test_zert_ui_progress_no_color
