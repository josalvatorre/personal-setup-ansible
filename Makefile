ANSIBLE = ./venv/bin/ansible
ANSIBLE_GALAXY = ./venv/bin/ansible-galaxy
PIP = ./venv/bin/pip
PYTHON = ./venv/bin/python
VENV_ACTIVATE = ./venv/bin/activate
# We'll use this python interpreter only to create the virtual environment.
ORIGINAL_PYTHON_PATH ?= python3

.PHONY: ensure_venv_exists_and_activated
ensure_venv_exists_and_activated:
	stat ./venv || ($(ORIGINAL_PYTHON_PATH) -m venv ./venv && $(PIP) install --upgrade pip)
	$(PYTHON) --version
	$(PIP) --version

.PHONY: ensure_ansible_is_installed
ensure_ansible_is_installed: ensure_venv_exists_and_activated
	$(PIP) install ansible

.PHONY: hosts_are_pingable
hosts_are_pingable: ensure_ansible_is_installed
	$(ANSIBLE) devapps --module-name ping -i inventory.yml

.PHONY: galaxy_collections_are_installed
galaxy_collections_are_installed: ensure_ansible_is_installed
	ansible-galaxy collection install community.general

.PHONY: devapps-playbook-executed
devapps-playbook-executed: hosts_are_pingable galaxy_collections_are_installed
	VENV_ACTIVATE=$(VENV_ACTIVATE) PLAYBOOK_PATH="./devapps-playbook.yml" INVENTORY_PATH="./inventory.yml" \
		scripts/execute-devapps-playbook.sh

.PHONY: clean
clean:
	rm -rf venv/
