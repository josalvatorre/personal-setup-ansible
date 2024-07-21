#!/usr/bin/env zsh

# Fail if any command or pipeline fails.
set -e
set -o pipefail

$@ &> /dev/null
