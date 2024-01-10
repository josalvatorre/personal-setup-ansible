# We'll use this python interpreter only to create the virtual environment.
ORIGINAL_PYTHON_PATH ?= python3

.PHONY: ensure_scripts_are_executable
ensure_scripts_are_executable:
	chmod 554 ./scripts/*

.PHONY: ensure_venv_exists_and_activated
ensure_venv_exists_and_activated:
	stat ./venv || \
		($(ORIGINAL_PYTHON_PATH) -m venv ./venv && ./scripts/activate-venv-then.sh pip install --upgrade pip)
	./scripts/activate-venv-then.sh python --version
	./scripts/activate-venv-then.sh pip --version

.PHONY: ensure_ansible_is_installed
ensure_ansible_is_installed: ensure_venv_exists_and_activated
	./scripts/activate-venv-then.sh pip install ansible

.PHONY: hosts_are_pingable
hosts_are_pingable: ensure_ansible_is_installed ensure_scripts_are_executable
	./scripts/activate-venv-then.sh ansible devapps --module-name ping -i inventory.yml

.PHONY: galaxy_collections_are_installed
galaxy_collections_are_installed: ensure_ansible_is_installed
	./scripts/activate-venv-then.sh ansible-galaxy collection install community.general

.PHONY: devapps-playbook-executed
devapps-playbook-executed: hosts_are_pingable galaxy_collections_are_installed ensure_scripts_are_executable
	./scripts/activate-venv-then.sh ansible-playbook ./devapps-playbook.yml -i ./inventory.yml

.PHONY: clean
clean:
	rm -rf venv/
