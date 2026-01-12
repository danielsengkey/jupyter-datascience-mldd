ARG BASE_IMAGE=pytorch-notebook
FROM $BASE_IMAGE

LABEL maintainer="Daniel Febrian Sengkey <danielsengkey@unsrat.ac.id>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install CUDA libraries for GNINA, nvtop, htop and btop for resource monitoring
RUN wget -qO /tmp/cuda-keyring_1.1-1_all.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb && \
    dpkg -i /tmp/cuda-keyring_1.1-1_all.deb && \
    apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    htop \
    btop \
    git-lfs \
    cuda-cudart-12-6 \
    libcublas-12-6 \
    libcusparse-12-6 \
    libcufft-12-6 \
    libcusolver-12-6 \
    libcudnn9-cuda-12 \
    libcudnn9-dev-cuda-12 \
    libnvjitlink-12-6 \
    libnvrtc12 \
    nvtop && \
    rm /tmp/cuda-keyring_1.1-1_all.deb && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Ensure the dynamic linker can find the new libraries
## CUDA 12.6 libraries
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/cuda-12.6/lib64:/usr/lib/x86_64-linux-gnu/"
RUN ldconfig

# Get GNINA
RUN wget https://github.com/gnina/gnina/releases/download/v1.3.2/gnina.1.3.2.cuda12.8 -O /usr/local/bin/gnina \
    && chmod +x /usr/local/bin/gnina

USER ${NB_UID}
ENV CONDA_OVERRIDE_CUDA="12.8"

# Install additional Python 3 and R packages
RUN mamba install -c conda-forge -c rapidsai --yes -vv \
    'biopython' \
    'bokeh' \
    'chembl_webresource_client' \
    'cudf-polars' \
    'cuml' \
    'dimorphite-dl' \
    'gromacs=*=nompi_cuda*' \
    'nglview' \
    'mdanalysis' \
    'mdtraj' \
    'numpy' \
    'openbabel' \
    'openmm' \
    'polars' \
    'padelpy' \
    'papermill' \
    'pdbfixer' \
    'py3dmol' \
    'pytest' \
    'python-Levenshtein' \
    'rdkit' \
    'selfies' \
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

## OpenBabel libraries
ENV BABEL_DATADIR=/opt/conda/pkgs/openbabel-3.1.1-py312hbfe4552_9/share/openbabel/3.1.0/