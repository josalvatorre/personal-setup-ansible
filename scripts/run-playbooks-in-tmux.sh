#!/usr/bin/env zsh

# Start a detached tmux session for ubuntus-playbook
tmux new-session -d -s ubuntus_playbook "make ubuntus-playbook"
# Start a detached tmux session for mymac-playbook
tmux new-session -d -s mymac_playbook "make mymac-playbook"
