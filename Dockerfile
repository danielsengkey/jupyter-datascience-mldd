ARG BASE_IMAGE=datascience-notebook
FROM $BASE_IMAGE

LABEL maintainer="Daniel Febrian Sengkey <danielsengkey@unsrat.ac.id>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install htop and btop for resource monitoring
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    htop \
    btop && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# Install additional Python 3 packages
RUN mamba install --yes \
    'chembl_webresource_client' \
    'numpy' \
    'padelpy' \
    'papermill' \
    'rdkit' \
    'r-dplyr' \
    'r-forcats' \
    'r-ggplot2' \
    'r-ggsci' \
    'r-rcdk' \
    'r-readr' \
    'r-reshape2' \
    'r-rstatix' \
    'r-tidyr' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"