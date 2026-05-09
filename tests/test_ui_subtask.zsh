#!/usr/bin/env zsh
# Test suite for subtask-level UI

ZERT_DIR="${ZERT_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
source "$ZERT_DIR/tests/runner.zsh"
source "$ZERT_DIR/functions/_zert_ui_spinner"
source "$ZERT_DIR/functions/_zert_ui_task"
source "$ZERT_DIR/functions/_zert_ui_subtask"

test_zert_subtask_start_single() {
  _zert_ui_spinner_start
  _zert_ui_task start "Build" 2>/dev/null
  local out
  out="$(NO_COLOR=1 _zert_ui_subtask start "compile" 2>&1)"
  _zert_ui_spinner_stop
  assert_true "[[ '$out' =~ '⠿' ]]"
  assert_true "[[ '$out' =~ 'Build' ]]"
  assert_true "[[ '$out' =~ 'compile' ]]"
}

test_zert_subtask_start_blocks_after_fail() {
  _zert_ui_spinner_start
  _zert_ui_task start "Build" 2>/dev/null
  _zert_ui_task fail "broken" 2>/dev/null
  local out ret
  out="$(NO_COLOR=1 _zert_ui_subtask start "compile" 2>&1; ret=$?; echo "EXIT:$ret")"
  _zert_ui_spinner_stop
  assert_true "[[ '$out' =~ 'EXIT:1' ]]"
}

test_zert_subtask_log_truncates_long_lines() {
  _zert_ui_spinner_start
  _zert_ui_task start "Build" 2>/dev/null
  _zert_ui_subtask start "compile" 2>/dev/null
  echo "this is a very long line that exceeds sixty characters and should be truncated at sixty" | _zert_ui_subtask log 2>/dev/null
  local logs="${__ZERT_TASK_LOGS[Build]}"
  assert_true "[[ ${#logs} -le 60 ]]"
  _zert_ui_spinner_stop
}

test_zert_subtask_log_max_four_lines() {
  _zert_ui_spinner_start
  _zert_ui_task start "Build" 2>/dev/null
  _zert_ui_subtask start "compile" 2>/dev/null
  printf 'line1\nline2\nline3\nline4\nline5\n' | _zert_ui_subtask log 2>/dev/null
  local -a log_arr
  local logs="${__ZERT_TASK_LOGS[Build]}"
  log_arr=("${(@s/|/)logs}")
  log_arr=("${log_arr[@]:#}")
  assert_eq 4 ${#log_arr[@]}
  _zert_ui_spinner_stop
}

test_zert_subtask_end_success_replaces_spinner() {
  _zert_ui_spinner_start
  _zert_ui_task start "Build" 2>/dev/null
  _zert_ui_subtask start "compile" 2>/dev/null
  local out
  out="$(NO_COLOR=1 _zert_ui_subtask end 0 2>&1)"
  _zert_ui_spinner_stop
  assert_true "[[ '$out' =~ '✓ compile' ]]"
}

test_zert_subtask_end_fail_draws_fail_state() {
  _zert_ui_spinner_start
  _zert_ui_task start "Build" 2>/dev/null
  _zert_ui_subtask start "compile" 2>/dev/null
  local out
  out="$(NO_COLOR=1 _zert_ui_subtask end 1 2>&1)"
  _zert_ui_spinner_stop
  assert_true "[[ '$out' =~ '✗ compile' ]]"
}

test_zert_subtask_log_no_stdin_no_change() {
  _zert_ui_spinner_start
  _zert_ui_task start "Build" 2>/dev/null
  _zert_ui_subtask start "compile" 2>/dev/null
  _zert_ui_subtask log </dev/null 2>/dev/null
  local logs="${__ZERT_TASK_LOGS[Build]:-}"
  assert_eq "" "$logs"
  _zert_ui_spinner_stop
}

test_zert_subtask_end_fail_keeps_tree_visible() {
  _zert_ui_spinner_start
  _zert_ui_task start "Build" 2>/dev/null
  _zert_ui_subtask start "compile" 2>/dev/null
  local out
  out="$(NO_COLOR=1 _zert_ui_subtask end 1 2>&1)"
  _zert_ui_spinner_stop
  assert_true "[[ '$out' =~ 'Build' ]]"
  assert_true "[[ '$out' =~ '✗ compile' ]]"
}

test_zert_subtask_log_preserves_existing_logs() {
  _zert_ui_spinner_start
  _zert_ui_task start "Build" 2>/dev/null
  _zert_ui_subtask start "compile" 2>/dev/null
  echo "first line" | _zert_ui_subtask log 2>/dev/null
  echo "second line" | _zert_ui_subtask log 2>/dev/null
  local logs="${__ZERT_TASK_LOGS[Build]}"
  assert_true "[[ '$logs' =~ 'first line' ]]"
  assert_true "[[ '$logs' =~ 'second line' ]]"
  _zert_ui_spinner_stop
}

run_tests \
  test_zert_subtask_start_single \
  test_zert_subtask_start_blocks_after_fail \
  test_zert_subtask_log_truncates_long_lines \
  test_zert_subtask_log_max_four_lines \
  test_zert_subtask_end_success_replaces_spinner \
  test_zert_subtask_end_fail_draws_fail_state \
  test_zert_subtask_log_no_stdin_no_change \
  test_zert_subtask_end_fail_keeps_tree_visible \
  test_zert_subtask_log_preserves_existing_logs