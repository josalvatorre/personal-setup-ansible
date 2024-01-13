#!/usr/bin/env bash

# Fail if any command or pipeline fails.
set -e
set -o pipefail

$@ &> /dev/null
