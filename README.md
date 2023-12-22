# Jose's automated personal setup

I use this repository to automate my personal development machine.
Most of the automation is performed using [Ansible][1], an ssh-based
configuration management software.

[1]: https://docs.ansible.com/ansible/latest/

## Setup

### Set up Ansible Navigator

We're going to use an [Ansible Execution Environment][2] (basically a container-based environment)
to run Ansible so that we have a more predictable environment.

As mentioned in the [Ansible Execution Environment setup instructions][3],
we need to install Docker, Python (only needed for Ansible Navigator), and Ansible Navigator
(which basically just manages the execution environments).

1. Install Docker on your machine. ([Installation instructions for Docker Engine][3])
2. Install Python3
    * We're only going to use this for the Ansible Navigator, which seems to basically
    manage the different execution environments.
    * Ansible itself will run in the container, so it won't be impacted by this
    version of python.
    * I suggest installing the latest version of python you can.
    * You can see the version of python required on [the PyPI page][4].
    * Google how to install that version of python (or higher) on your machine.

I suggest creating a python virtual environment for this repository so that 
the list of python packages we use are isolated from the rest of your machine.
If you're on Mac or Linux, you'll want to do something like the following.

```sh
# I recommend running these commands one at a time in your terminal.
cd /path/to/this/repo/personal-setup-ansible
# Use python3.x where x is whatever version of python you installed.
# We'll use python 3.10 as an example.
python3.10 -m venv ./venv
# Run this to "activate" the virtual environment.
source ./venv/bin/activate
# Now that you're in a virtual environment, you can freely call
# "pip" or "python" without worrying about which version of python
# you're using or where the packages get installed.
pip install install ansible-navigator
# Verify that the following commands print the version ok
ansible-navigator --version
ansible-builder --version
```

### Build our execution environment

```sh
# I recommend running these commands one at a time in your terminal.
cd /path/to/this/repo/personal-setup-ansible
source ./venv/bin/activate
# This will create a Docker image tagged with "ansible-execution-environment".
sudo ./venv/bin/ansible-builder build --tag ansible-execution-environment --container-runtime docker
# Validate by listing out the docker images.
sudo docker image ls
```

### Useful Docker commands

```sh
# Delete all containers.
sudo docker rm $(sudo docker container ls --quiet --all)
# Delete all images.
sudo docker image rmi $(sudo docker images --quiet)
```

[1]: https://ansible.readthedocs.io/en/latest/getting_started_ee/setup_environment.html
[2]: https://ansible.readthedocs.io/en/latest/getting_started_ee/index.html
[3]: https://docs.docker.com/engine/install/
[4]: https://pypi.org/project/ansible-navigator/
