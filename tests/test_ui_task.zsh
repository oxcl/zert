#!/usr/bin/env zsh
# Test suite for task-level UI

ZERT_DIR="${ZERT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ZERT_DIR/tests/runner.zsh"
source "$ZERT_DIR/functions/_zert_ui_spinner"
source "$ZERT_DIR/functions/_zert_ui_task"

test_zert_task_start_output() {
  NO_COLOR=1 _zert_ui_spinner_start
  local out
  out="$(_zert_ui_task start "Cloning" 2>&1)"
  _zert_ui_spinner_stop
  assert_true '[[ "$out" == *[C]l*oning* ]]'
}

test_zert_task_end_collapse() {
  _zert_ui_spinner_start
  _zert_ui_task start "Cloning" 2>/dev/null
  local out
  out="$(_zert_ui_task end 2>&1)"
  _zert_ui_spinner_stop
  assert_true '[[ "$out" == *"✓"*Cloning*" ]]'
}

test_zert_task_fail_output() {
  _zert_ui_spinner_start
  _zert_ui_task start "Cloning" 2>/dev/null
  local out
  out="$(_zert_ui_task fail "permission denied" 2>&1)"
  _zert_ui_spinner_stop
  assert_true '[[ "$out" == *"✗"*permission*denied* ]]'
}

test_zert_task_fail_state() {
  _zert_ui_spinner_start
  _zert_ui_task start "Cloning" 2>/dev/null
  _zert_ui_task fail "denied" 2>/dev/null
  local state="${__ZERT_TASK_STATE[Cloning]}"
  assert_eq "failed" "$state"
  _zert_ui_spinner_stop
}

test_zert_task_end_after_fail_returns_nonzero() {
  _zert_ui_spinner_start
  _zert_ui_task start "Clone" 2>/dev/null
  _zert_ui_task fail "denied" 2>/dev/null
  _zert_ui_task end >/dev/null 2>&1
  local ret=$?
  _zert_ui_spinner_stop
  assert_false "$ret"
}

run_tests \
  test_zert_task_start_output \
  test_zert_task_end_collapse \
  test_zert_task_fail_output \
  test_zert_task_fail_state \
  test_zert_task_end_after_fail_returns_nonzero