ARG BASE_IMAGE=datascience-notebook
FROM $BASE_IMAGE

LABEL maintainer="Daniel Febrian Sengkey <danielsengkey@unsrat.ac.id>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install htop and btop for resource monitoring
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    htop \
    btop \
    openssh-server \
    sudo && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Password-less sudo in case things need to be installed from the terminal
RUN echo "jovyan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up SSH
RUN mkdir -p /var/run/sshd && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

EXPOSE 22
CMD service ssh start

USER ${NB_UID}
# Ensure directory for ssh configs exist
RUN mkdir -p /home/${NB_USER}/.ssh && \
    fix-permissions "/home/${NB_USER}/.ssh"

# Install additional Python 3 and R packages
RUN mamba install -c conda-forge --yes -vv \
    'chembl_webresource_client' \
    'numpy' \
    'padelpy' \
    'papermill' \
    'rdkit' \
    'lightgbm' \
    'r-dplyr' \
    'r-forcats' \
    'r-ggplot2' \
    'r-ggsci' \
    'r-rcdk' \
    'r-readr' \
    'r-reshape2' \
    'r-rstatix' \
    'r-tidyr' \
    'r-irkernel' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install R Kernel (irkernel) for Jupyter
USER root
RUN Rscript -e "IRkernel::installspec(user = FALSE)"