#!/usr/bin/env bash

# shellcheck source=../venv/bin/activate
source "$VENV_ACTIVATE" || exit 1

ansible-playbook "$PLAYBOOK_PATH" -i "$INVENTORY_PATH"
