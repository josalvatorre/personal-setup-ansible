# Jose's personal machine setup automation using Ansible

I use this repository to automate the setting-up of my personal machines, which are normally Mac or Ubuntu machines.
I have a separate version for my work machine.

Most of the automation is performed using [Ansible][1], an ssh-based
configuration management software originally designed for deploying software to many production machines.
Nowadays, it's much better to use an immutable-server approach: create a container/vm image and deploy that to
an orchestration service like Kubernetes. However, Ansible is better for personal machines because:

* Ansible doesn't require controlling the machine's base image.
  * Your company wants all developers to use the same base image so that it's easier to provide support and
  enforce security measures.
  * That means that the immutable-server approach is a non-starter.
* Ansible makes changes through SSH, which every company I've worked for seems to embrace.
  * By using Ansible, I'm learning a technology that I can use for both my company and personal machine.
* We value flexibility over stability compared to a prod server.
  * We want to be able to make on-the-fly changes to our setup.
  * Customizing the virtual machine image would mean starting over every time we want to swap the OS.
* Agent-ful configuration management software like Chef and Puppet might conflict with something my company installed.
  * If your company uses Puppet or Chef, then using one of those softwares would mean trying to run 2 agents on the
  same machine, which might either be impossible or risky.

## How to run

We'll run Ansible on the same machine that it manipulates.

I'm assuming that you'll run this in your Ubuntu machine. However, you should be able to customize the inventory or
playbook to adapt to your use case.

### Quickstart

The Makefile should take care of installing dependencies. You can read it for details.
The key detail is that we'll use the python interpreter you provide (default: `python3`) to create a virtual
environment in this directory and install Ansible there. The latest versions of Ubuntu and Mac come with
some version of Python 3. However, if you run into problems and need a newer version of Python, then you can
install it using `apt` or `apt-get` for Ubuntu or [Homebrew][4] for Mac. You can google how to do that.
[This website][3] has good instructions for Ubuntu, but use the latest version of python you can.

#### Mac

```sh
# I recommend explicitly pointing Ansible to the python interpreter you want to use.
ORIGINAL_PYTHON_PATH=/path/to/python make mymac-playbook
# If you don't provide ORIGINAL_PYTHON_PATH, then we default to whatever python3 points to.
make mymac-playbook
```

#### Ubuntu

TODO Rename "devapp" to "ubuntu". Sorry for the confusion.
The legacy reason is that I started with Ubuntu and thought I would only have 1 playbook for all machines.

```sh
# I recommend explicitly pointing Ansible to the python interpreter you want to use.
ORIGINAL_PYTHON_PATH=/path/to/python make devapps-playbook-executed
# If you don't provide ORIGINAL_PYTHON_PATH, then we default to whatever python3 points to.
make devapps-playbook-executed
```

### Activate the virtual environment before running arbitrary Ansible commands

We install Ansible in a virtual environment, so I recommend **_always_** activating the virtual environment
in your terminal session before running arbitrary Ansible commands. Note that the Makefile tries to always use the
virtual environment.

```sh
source ./venv/bin/activate
```

If you want to automate this, then it might be a good idea to use
[autoenv](https://github.com/hyperupcall/autoenv), which will look at the
`.env` and `.env.leave` files in this repo.

### Cleaning

Simply run `make clean` to destroy the virtual environment.

```sh
make clean
```

## Why not use an [Ansible Execution Environment][2] (ie container)?

I tried to get this working inside a container, but he gave up for a few reasons:

* The container-free approach is simpler in this case.
  * Ansible relies on Python (already installed on Mac) and a few packages. It was easy to make the Makefile that
  creates the virtual environment.
  * The execution environment has more dependencies.
    * User has to install Docker/Podman, Python, and a few pip packages.
  * The ansible navigator is bizarre and not easy to work with.
* Pinterest engineers are already exposed to python regularly. That's not true with respect to containers.
* SSH auth relies on gironde, which is specific to Pinterest. You'd either need to figure out how to install gironde
into the container image or poke a hole in the container so that it can access the host's gironde.
  * It's not clear whether either method is possible.
  * If there's any issue, it's going to be incredibly difficult to debug unless you're a container expert.

[1]: https://docs.ansible.com/ansible/latest/
[2]: https://ansible.readthedocs.io/en/latest/getting_started_ee/index.html
[3]: https://docs.python-guide.org/starting/install3/linux/
[4]: https://brew.sh/
