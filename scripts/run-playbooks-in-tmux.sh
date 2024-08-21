#!/usr/bin/env zsh

# Function to create a tmux session that doesn't exit on command completion
create_persistent_session() {
  local session_name="$1"
  local command="$2"
  tmux new-session -d -s "$session_name" "($command); bash"
}

# Create persistent sessions for each playbook
create_persistent_session ubuntus_playbook "make ubuntus-playbook"
create_persistent_session mymac_playbook "make mymac-playbook"
