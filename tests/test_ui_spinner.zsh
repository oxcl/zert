#!/usr/bin/env zsh
# Test suite for spinner subsystem

ZERT_DIR="${ZERT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ZERT_DIR/tests/runner.zsh"
source "$ZERT_DIR/functions/_zert_ui_spinner"

test_spinner_ascii_mode() {
  NO_COLOR=1
  _zert_ui_spinner_start
  sleep 0.5
  local out="$(_zert_ui_spinner_char)"
  local -a chars=('|' '/' '-')
  local valid=0
  for c in $chars; do [[ "$out" = "$c" ]] && valid=1 && break; done
  (( valid == 1 )) && assert_true "true" || assert_true "false"
  _zert_ui_spinner_stop
}

test_spinner_unicode_mode() {
  unset NO_COLOR
  _zert_ui_spinner_start
  sleep 0.5
  local out="$(_zert_ui_spinner_char)"
  local -a chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local valid=0
  for c in $chars; do [[ "$out" = "$c" ]] && valid=1 && break; done
  (( valid == 1 )) && assert_true "true" || assert_true "false"
  _zert_ui_spinner_stop
}

test_spinner_changes() {
  _zert_ui_spinner_start
  sleep 0.5
  local out1="$(_zert_ui_spinner_char)"
  sleep 0.5
  local out2="$(_zert_ui_spinner_char)"
  assert_false "[[ \"$out1\" == \"$out2\" ]]"
  _zert_ui_spinner_stop
}

test_spinner_stop_cleanup() {
  _zert_ui_spinner_start
  sleep 0.5
  _zert_ui_spinner_char >/dev/null
  _zert_ui_spinner_stop
  local out="$(_zert_ui_spinner_char)"
  assert_eq "" "$out"
}

test_spinner_restart() {
  _zert_ui_spinner_start
  sleep 0.5
  local out1="$(_zert_ui_spinner_char)"
  _zert_ui_spinner_stop
  _zert_ui_spinner_start
  sleep 0.5
  local out2="$(_zert_ui_spinner_char)"
  _zert_ui_spinner_stop
  assert_false "[[ -z \"$out1\" ]]"
  assert_false "[[ -z \"$out2\" ]]"
}

run_tests \
  test_spinner_ascii_mode \
  test_spinner_unicode_mode \
  test_spinner_changes \
  test_spinner_stop_cleanup \
  test_spinner_restart