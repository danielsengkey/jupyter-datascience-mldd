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

# Install additional Python 3 and CUDA packages, and libraries needed to compile LightGBM
RUN mamba install -c conda-forge -c rapidsai -c nvidia --yes -vv \
    'chembl_webresource_client' \
    'numpy' \
    'padelpy' \
    'papermill' \
    'rdkit' \
    'r-dplyr' \
    'r-forcats' \
    'r-ggplot2' \
    'r-ggsci' \
    'r-irkernel' \
    'r-rcdk' \
    'r-readr' \
    'r-reshape2' \
    'r-rstatix' \
    'r-tidyr' \
    'setuptools' \
    'pocl-cuda' \
    'clinfo' \
    'cmake' \
    'git' \
    'libboost=1.84.0' \
    'libboost-devel' \
    'libboost-headers' \
    'libboost-python' \
    'libboost-python-devel' \
    'ocl-icd-system' \
    'opencl-headers' \
    'cuda-toolkit=12.*' \
    'cuda-opencl' \
    'cudf=25.06' \
    'cuml=25.06' \
    'cuda-version>12.0,<=12.8' && \
    mamba clean --all -f -y  && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

## LightGBM ##
RUN git clone --recursive https://github.com/microsoft/LightGBM && \
    cd LightGBM && \
    cmake -B build -S . -DUSE_GPU=1 && \
    cmake --build build -j$(nproc) && \
    # Installing Python API
    sh ./build-python.sh install --precompile

# Install R Kernel (irkernel) for Jupyter
USER root
RUN cd LightGBM && \
    sh ./build-python.sh install --precompile --gpu

RUN Rscript -e "IRkernel::installspec(user = FALSE)" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"