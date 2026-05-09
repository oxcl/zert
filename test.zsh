#!/usr/bin/env zsh
source "./zert.zsh"

# __ZERT_UI_BG_TASK_STATUS
# __ZERT_UI_BG_TASK_MESSAGE

function _zert_ui_pick_spinner(){
    local i="$1"
    idx=$(( i % 10 ))
    case $idx in
            0) ch='⠋' ;;
            1) ch='⠙' ;;
            2) ch='⠹' ;;
            3) ch='⠸' ;;
            4) ch='⠼' ;;
            5) ch='⠴' ;;
            6) ch='⠦' ;;
            7) ch='⠧' ;;
            8) ch='⠇' ;;
            9) ch='⠏' ;;
    esac
    printf "$ch"
}
function _zert_ui_background_renderer(){
    local parent_pid="$1"
    local comm_file="$2"
    local lines_count=0 i=0
    typeset -A ui_state

    exec 3<>"$comm_file"

    while true; do
        kill -0 $parent_pid 2>/dev/null || break

        # Read all available lines from the FIFO and update the UI state
        while read -t 0.05 -u 3 line; do
            local key="${line%%=*}"
            local value="${line#*=}"
            ui_state[$key]="$value"
        done

        # Move cursor up to overwrite previous output
        [[ $lines_count -gt 0 ]] && printf "\033[${lines_count}A"
        (( lines_count = 0 ))

        # print the icon for the task
        if [[ $ui_state[task_status] == "ongoing" ]]; then
            printf '\r\033[1;36m%s\e[0m' "$(_zert_ui_pick_spinner $i)"
        elif [[ $ui_state[task_status] == "ok" ]]; then
            printf '\r\033[1;32m✔\033[0m'
        elif [[ $ui_state[task_status] == "fail" ]]; then
            printf '\r\033[1;31m✗\033[0m'
        else
            printf '\r\033[1;90m?\033[0m'
        fi

        # print the task name
        printf ' %s\033[K\n' "$(_zert_ui_emphasize "$ui_state[task_name]")"
        (( lines_count++ ))

        # Count total subtasks first
        local subtask_index=0 total_subtasks=0
        while [[ -n "${ui_state[subtask_${subtask_index}_title]}" ]]; do
            (( total_subtasks++ ))
            (( subtask_index++ ))
        done

        # print subtasks in order (subtask_0, subtask_1, etc.) with tree structure
        subtask_index=0
        while [[ -n "${ui_state[subtask_${subtask_index}_title]}" ]]; do
            local subtask_title="${ui_state[subtask_${subtask_index}_title]}"
            local subtask_status="${ui_state[subtask_${subtask_index}_status]}"
            local is_last_subtask=$(( subtask_index == total_subtasks - 1 ))
            local tree_prefix="├── "
            [[ $is_last_subtask -eq 1 ]] && tree_prefix="└── "
            
            printf '%s' "$tree_prefix"
            if [[ "$subtask_status" == "ongoing" ]]; then
                printf '\033[1;36m%s\e[0m' "$(_zert_ui_pick_spinner $i)"
            elif [[ "$subtask_status" == "ok" ]]; then
                printf '\033[1;32m✔\033[0m'
            elif [[ "$subtask_status" == "fail" ]]; then
                printf '\033[1;31m✗\033[0m'
            else
                printf '\033[1;90m?\033[0m'
            fi
            printf ' %s\033[K\n' "$(_zert_ui_emphasize "$subtask_title")"
            (( lines_count++ ))
            (( subtask_index++ ))
        done

        # Exit cleanly after rendering the final state
        if [[ $ui_state[task_done] == "1" ]]; then
            if [[ "$ui_state[task_status]" == "ok" ]]; then
                printf '\r\033[1;32m✔ %s\033[0m\n' "$ui_state[message]"
            elif [[ "$ui_state[task_status]" == "fail" ]]; then
                printf '\r\033[1;31m✗ %s\033[0m\n' "$ui_state[message]"
            else
                printf '\r\033[1;90m? %s\033[0m\n' "$ui_state[message]"
            fi
            break
        fi

        sleep 0.1
        (( i++ ))
    done
    exec 3>&-
}

function _zert_ui_task_start(){
    local comm_file="/tmp/zert_ui_comm_$$"
    mkfifo "$comm_file" || { echo "Failed to create FIFO"; exit 1 }
    
    __ZERT_COMM_FILE="$comm_file"
    trap 'rm -f "$__ZERT_COMM_FILE" 2>/dev/null' EXIT INT TERM HUP

    # Start the renderer
    _zert_ui_background_renderer "$$" "$comm_file" &
    __ZERT_BG_PID="$!"

    # Open the FIFO for writing in the main shell (non-blocking writes)
    exec 4<>"$comm_file"   # FD 4 for writing from main process

    sleep 0.05

    echo "task_status=ongoing" >&4
    echo "task_name=$1" >&4
}

function _zert_ui_task_update(){
    echo "task_name=$1" >&4
}

function _zert_ui_task_end(){
    # These writes now go through the already-opened FD 4 → much more reliable
    echo "task_status=$1" >&4
    echo "message=$2" >&4
    echo "task_done=1" >&4

    # Give the renderer a moment to process
    sleep 0.2
    wait "$__ZERT_BG_PID" 2>/dev/null
    
    exec 4>&-          # close writer
    rm -f "$__ZERT_COMM_FILE" 2>/dev/null
}

function _zert_ui_subtask_start(){
    local subtask_index="$1" subtask_title="$2"
    echo "subtask_${subtask_index}_title=$subtask_title" >&4
    echo "subtask_${subtask_index}_status=ongoing" >&4
}

function _zert_ui_subtask_update(){
    local subtask_index="$1" subtask_title="$2"
    echo "subtask_${subtask_index}_title=$subtask_title" >&4
}

function _zert_ui_subtask_end(){
    local subtask_index="$1" subtask_status="$2"
    echo "subtask_${subtask_index}_status=$subtask_status" >&4
}

_zert_ui_task_start "Installing Plugin **thing**..."


_zert_ui_subtask_start 0 "Cloning repository"
sleep 1
_zert_ui_subtask_update 0 "Cloned repository"
_zert_ui_subtask_end 0 "ok"
_zert_ui_subtask_start 1 "Building plugin"
sleep 1
_zert_ui_subtask_update 1 "Built plugin"
_zert_ui_subtask_end 1 "ok"
_zert_ui_subtask_start 2 "Running tests"
sleep 1
_zert_ui_subtask_update 2 "Running tests"
_zert_ui_subtask_end 2 "fail"

sleep 3

_zert_ui_task_update "Installed **thing**"
_zert_ui_task_end "ok" "Installation complete"
