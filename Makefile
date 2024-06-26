# We'll use this python interpreter only to create the virtual environment.
ORIGINAL_PYTHON_PATH ?= python3
VENV_ACTIVATE = venv/bin/activate

.PHONY: ensure_scripts_are_executable
ensure_scripts_are_executable:
	chmod 754 ./scripts/*

.PHONY: ensure_venv_exists_and_activated
ensure_venv_exists_and_activated: ensure_scripts_are_executable
	./scripts/quiet-run.sh stat ./venv || ( \
		$(ORIGINAL_PYTHON_PATH) -m venv ./venv \
		&& VENV_ACTIVATE=$(VENV_ACTIVATE) ./scripts/activate-venv-then.sh pip install --upgrade pip \
	)
	VENV_ACTIVATE=$(VENV_ACTIVATE) ./scripts/activate-venv-then.sh python --version
	VENV_ACTIVATE=$(VENV_ACTIVATE) ./scripts/activate-venv-then.sh pip --version

.PHONY: ensure_ansible_is_installed
ensure_ansible_is_installed: ensure_venv_exists_and_activated ensure_scripts_are_executable
	VENV_ACTIVATE=$(VENV_ACTIVATE) ./scripts/activate-venv-then.sh pip install ansible

.PHONY: devapps_are_pingable
devapps_are_pingable: ensure_ansible_is_installed ensure_scripts_are_executable
	VENV_ACTIVATE=$(VENV_ACTIVATE) ./scripts/activate-venv-then.sh \
		ansible devapps --module-name ping -i inventory.yml

.PHONY: mymac_is_pingable
mymac_is_pingable: ensure_ansible_is_installed ensure_scripts_are_executable
	VENV_ACTIVATE=$(VENV_ACTIVATE) ./scripts/activate-venv-then.sh \
		ansible mymac --module-name ping -i inventory.yml

.PHONY: galaxy_collections_are_installed
galaxy_collections_are_installed: ensure_ansible_is_installed ensure_scripts_are_executable
	VENV_ACTIVATE=$(VENV_ACTIVATE) ./scripts/activate-venv-then.sh \
		ansible-galaxy collection install community.general

.PHONY: devapps-playbook-executed
devapps-playbook-executed: devapps_are_pingable galaxy_collections_are_installed ensure_scripts_are_executable
	VENV_ACTIVATE=$(VENV_ACTIVATE) ./scripts/activate-venv-then.sh \
		ansible-playbook ./devapps-playbook.yml -i ./inventory.yml --ask-become-pass

.PHONY: mymac-playbook
mymac-playbook: mymac_is_pingable galaxy_collections_are_installed ensure_scripts_are_executable
	VENV_ACTIVATE=$(VENV_ACTIVATE) ./scripts/activate-venv-then.sh \
		ansible-playbook ./mymac-playbook.yml -i ./inventory.yml

.PHONY: mymac-playbook-debug
mymac-playbook-debug: mymac_is_pingable galaxy_collections_are_installed ensure_scripts_are_executable
	VENV_ACTIVATE=$(VENV_ACTIVATE) ./scripts/activate-venv-then.sh \
		ansible-playbook ./mymac-playbook.yml -i ./inventory.yml -vvv

.PHONY: clean
clean:
	rm -rf venv/
