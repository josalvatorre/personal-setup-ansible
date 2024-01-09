#!/usr/bin/env bash

# shellcheck source=../venv/bin/activate
source "$VENV_ACTIVATE" || exit 1

ansible devapps --module-name ping -i inventory.yml
