ARG BASE_IMAGE=scipy-notebook
FROM $BASE_IMAGE

LABEL maintainer="Daniel Febrian Sengkey <danielsengkey@unsrat.ac.id>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install htop and btop for resource monitoring
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    htop \
    btop \
    git-lfs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${NB_UID}

# Install additional Python 3 and R packages
RUN mamba install -c conda-forge --yes -vv \
    'chembl_webresource_client' \
    'numpy' \
    'padelpy' \
    'papermill' \
    'pytest' \
    'rdkit' \
    'scikit-learn=1.5.1' \
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
RUN Rscript -e "IRkernel::installspec(user = TRUE)"
