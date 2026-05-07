#!/usr/bin/env zsh
# Zert test runner

__ZERT_TESTS_PASSED=0
__ZERT_TESTS_FAILED=0

assert_eq() {
  local expected="$1" actual="$2"
  if [[ "$expected" != "$actual" ]]; then
    print -u2 "[ASSERT FAILED] Expected: '$expected' | Actual: '$actual'"
    ((__ZERT_TESTS_FAILED++))
    return 1
  fi
  ((__ZERT_TESTS_PASSED++))
  return 0
}

assert_true() {
  local value="$1"
  if [[ "$value" != "true" && "$value" != "1" && "$value" != "yes" ]]; then
    print -u2 "[ASSERT FAILED] Expected true, got: '$value'"
    ((__ZERT_TESTS_FAILED++))
    return 1
  fi
  ((__ZERT_TESTS_PASSED++))
  return 0
}

assert_false() {
  local value="$1"
  if [[ "$value" == "true" || "$value" == "1" || "$value" == "yes" ]]; then
    print -u2 "[ASSERT FAILED] Expected false, got: '$value'"
    ((__ZERT_TESTS_FAILED++))
    return 1
  fi
  ((__ZERT_TESTS_PASSED++))
  return 0
}

assert_file_exists() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    print -u2 "[ASSERT FAILED] File does not exist: '$file'"
    ((__ZERT_TESTS_FAILED++))
    return 1
  fi
  ((__ZERT_TESTS_PASSED++))
  return 0
}

assert_output() {
  local expected="$1" actual="$2"
  if [[ "$expected" != "$actual" ]]; then
    print -u2 "[ASSERT FAILED] Output expected: '$expected' | Got: '$actual'"
    ((__ZERT_TESTS_FAILED++))
    return 1
  fi
  ((__ZERT_TESTS_PASSED++))
  return 0
}

run_tests() {
  print "Running tests..."
  local tests=("$@")
  for test_func in "${tests[@]}"; do
    if functions "$test_func" >/dev/null 2>&1; then
      "$test_func"
    fi
  done
  print "\nTest results: ${__ZERT_TESTS_PASSED} passed, ${__ZERT_TESTS_FAILED} failed"
  return $((__ZERT_TESTS_FAILED > 0))
}
