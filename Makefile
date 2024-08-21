ORIGINAL_PYTHON_PATH ?= python3
VENV_ACTIVATE = venv/bin/activate
ANSIBLE_CMD = VENV_ACTIVATE=$(VENV_ACTIVATE) ./scripts/activate-venv-then.sh

.PHONY: ensure_scripts_are_executable
ensure_scripts_are_executable:
	chmod 754 ./scripts/*

.PHONY: ensure_venv_exists_and_activated
ensure_venv_exists_and_activated: ensure_scripts_are_executable
	./scripts/quiet-run.sh stat ./venv || ( \
		$(ORIGINAL_PYTHON_PATH) -m venv ./venv \
		&& $(ANSIBLE_CMD) pip install --upgrade pip \
	)
	$(ANSIBLE_CMD) python --version
	$(ANSIBLE_CMD) pip --version

.PHONY: ensure_ansible_is_installed
ensure_ansible_is_installed: ensure_venv_exists_and_activated
	$(ANSIBLE_CMD) pip install ansible

.PHONY: galaxy_collections_are_installed
galaxy_collections_are_installed: ensure_ansible_is_installed
	$(ANSIBLE_CMD) ansible-galaxy collection install community.general

.PHONY: pingable
pingable: ensure_ansible_is_installed
	$(ANSIBLE_CMD) ansible $(TARGET) --module-name ping -i inventory.yml

.PHONY: playbook
playbook: pingable galaxy_collections_are_installed
	$(ANSIBLE_CMD) ansible-playbook ./$(TARGET)-playbook.yml -i ./inventory.yml $(PLAYBOOK_ARGS)

.PHONY: ubuntus_are_pingable mymac_is_pingable
ubuntus_are_pingable: TARGET = ubuntus
ubuntus_are_pingable: pingable

mymac_is_pingable: TARGET = mymac
mymac_is_pingable: pingable

.PHONY: ubuntus-playbook ubuntus-playbook-debug mymac-playbook mymac-playbook-debug
ubuntus-playbook: TARGET = ubuntus
ubuntus-playbook: playbook

mymac-playbook: TARGET = mymac
mymac-playbook: playbook

%-debug: PLAYBOOK_ARGS = -vvv
%-debug: %

.PHONY: run-playbooks
run-playbooks: ensure_ansible_is_installed galaxy_collections_are_installed
	./scripts/run-playbooks-in-tmux.sh

.PHONY: clean
clean:
	rm -rf venv/
