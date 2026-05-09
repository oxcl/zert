#!/usr/bin/env zsh

source "./zert.zsh"

_zert_ui_task_start "Install Plugin **powerlevel10k**"

_zert_ui_subtask_start 0 "Cloning repository"
git clone https://github.com/neovim/neovim --filter=tree:0 --progress --verbose /tmp/neovim2 2>&1 | _zert_ui_subtask_log 4
_zert_ui_subtask_end 0 "ok"

_zert_ui_task_end "ok"


sleep 2