#!/usr/bin/env zsh

# shellcheck source=../venv/bin/activate
source "$VENV_ACTIVATE" || exit 1

$@
