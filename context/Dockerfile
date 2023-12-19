ARG EE_BASE_IMAGE="ubuntu:latest"
ARG PYCMD="/usr/bin/python3.10"
ARG PYPKG="python3.10"
ARG PKGMGR_PRESERVE_CACHE=""
ARG ANSIBLE_GALAXY_CLI_COLLECTION_OPTS=""
ARG ANSIBLE_GALAXY_CLI_ROLE_OPTS=""
ARG ANSIBLE_INSTALL_REFS="ansible-core ansible-runner"
ARG PKGMGR="/usr/bin/apt-get"

# Base build stage
FROM $EE_BASE_IMAGE as base
USER root
ARG EE_BASE_IMAGE
ARG PYCMD
ARG PYPKG
ARG PKGMGR_PRESERVE_CACHE
ARG ANSIBLE_GALAXY_CLI_COLLECTION_OPTS
ARG ANSIBLE_GALAXY_CLI_ROLE_OPTS
ARG ANSIBLE_INSTALL_REFS
ARG PKGMGR

# Yes, this is ridiculous, but the auto-generated Dockerfile insists on using ensurepip
# even though it doesn't exist on Ubuntu. There's no way to install it separately.
# Even installing a venv and pip do not sidestep this.
RUN echo "print('THIS IS A FAKE ensurepip MODULE!!!')" > ensurepip.py
# We do this instead of "wget ... | $PYCMD" so that errors don't get swallowed by the pipe.
RUN $PKGMGR update -y \
  && $PKGMGR install -y $PYPKG wget \
  && wget https://bootstrap.pypa.io/get-pip.py \
  && $PYCMD get-pip.py \
  && rm -rf get-pip.py \
  && $PKGMGR remove -y wget
RUN $PKGMGR install $PYPKG -y ; if [ -z $PKGMGR_PRESERVE_CACHE ]; then $PKGMGR clean all; fi
RUN $PYCMD -m ensurepip
RUN $PYCMD -m pip install --no-cache-dir $ANSIBLE_INSTALL_REFS
COPY _build/scripts/ /output/scripts/
COPY _build/scripts/entrypoint /opt/builder/bin/entrypoint

# Builder build stage
FROM base as builder
WORKDIR /build
ARG EE_BASE_IMAGE
ARG PYCMD
ARG PYPKG
ARG PKGMGR_PRESERVE_CACHE
ARG ANSIBLE_GALAXY_CLI_COLLECTION_OPTS
ARG ANSIBLE_GALAXY_CLI_ROLE_OPTS
ARG ANSIBLE_INSTALL_REFS
ARG PKGMGR

RUN $PYCMD -m pip install --no-cache-dir bindep pyyaml requirements-parser
COPY _build/bindep.txt bindep.txt
RUN $PYCMD /output/scripts/introspect.py introspect --sanitize --user-bindep=bindep.txt --write-bindep=/tmp/src/bindep.txt --write-pip=/tmp/src/requirements.txt
RUN /output/scripts/assemble

# Final build stage
FROM base as final
ARG EE_BASE_IMAGE
ARG PYCMD
ARG PYPKG
ARG PKGMGR_PRESERVE_CACHE
ARG ANSIBLE_GALAXY_CLI_COLLECTION_OPTS
ARG ANSIBLE_GALAXY_CLI_ROLE_OPTS
ARG ANSIBLE_INSTALL_REFS
ARG PKGMGR

RUN /output/scripts/check_ansible $PYCMD
COPY --from=builder /output/ /output/
RUN /output/scripts/install-from-bindep && rm -rf /output/wheels
RUN chmod ug+rw /etc/passwd
RUN mkdir -p /runner && chgrp 0 /runner && chmod -R ug+rwx /runner
WORKDIR /runner
RUN $PYCMD -m pip install --no-cache-dir 'dumb-init==1.2.5'
RUN rm -rf /output
LABEL ansible-execution-environment=true
USER 1000
ENTRYPOINT ["/opt/builder/bin/entrypoint", "dumb-init"]
CMD ["bash"]
