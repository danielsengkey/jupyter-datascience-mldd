ARG BASE_IMAGE=pytorch-notebook
FROM $BASE_IMAGE

LABEL maintainer="Daniel Febrian Sengkey <danielsengkey@unsrat.ac.id>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# 1. Install CUDA libraries, nvtop, htop, and btop
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

# Ensure dynamic linker finds CUDA libraries
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/cuda-12.6/lib64:/usr/lib/x86_64-linux-gnu/"
RUN ldconfig

# 2. Download GNINA and fix root-owned file permission issue before switching user
RUN wget https://github.com/gnina/gnina/releases/download/v1.3.2/gnina.1.3.2.cuda12.8 -O /usr/local/bin/gnina && \
    chmod +x /usr/local/bin/gnina && \
    rm -f /home/${NB_USER}/.wget-hsts && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Switch to non-root notebook user
USER ${NB_UID}
ENV CONDA_OVERRIDE_CUDA="12.8"

# 3. Create isolated 'mldd' environment (Python, CUDA, RAPIDS & Cheminformatics)
RUN mamba create -n mldd -c rapidsai -c pytorch -c conda-forge -c nvidia -c bioconda --yes \
    python=3.12 \
    ipykernel \
    accelerate \
    biopython \
    bokeh \
    chembl_webresource_client \
    cudf-polars \
    cuml \
    datasets \
    dimorphite-dl \
    cuda-version=12.6 \
    'gromacs=*=nompi_cuda*' \
    nglview \
    mdanalysis \
    mdtraj \
    numpy \
    openbabel \
    openmm \
    polars \
    padelpy \
    papermill \
    pdbfixer \
    py3dmol \
    pytest \
    python-Levenshtein \
    pytorch \
    rdkit \
    safetensors \
    selfies \
    transformers \
    lightgbm && \
    mamba clean --all -f -y

# 4. Install R & CRAN packages into 'mldd'
RUN mamba install -n mldd -c conda-forge --yes \
    r-dplyr \
    r-forcats \
    r-ggplot2 \
    r-ggsci \
    r-rcdk \
    r-readr \
    r-reshape2 \
    r-rstatix \
    r-tidyr \
    r-irkernel \
    r-biocmanager && \
    mamba clean --all -f -y

# 5. Install Bioconductor packages via Bioconda channel
# (Add or remove specific 'bioconductor-*' packages as needed)
RUN mamba install -n mldd -c bioconda -c conda-forge --yes \
    bioconductor-biostrings \
    bioconductor-genomicranges \
    bioconductor-deseq2 \
    bioconductor-complexheatmap \
    bioconductor-rcpi \
    r-protr && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}"

# 6. Register Python and R kernels for JupyterLab
RUN /opt/conda/envs/mldd/bin/python -m ipykernel install --user --name mldd --display-name "Python 3 (MLDD)"
RUN /opt/conda/envs/mldd/bin/Rscript -e "IRkernel::installspec(user = TRUE)"

# Set OpenBabel environment path targeting the mldd environment
ENV BABEL_DATADIR=/opt/conda/envs/mldd/share/openbabel/3.1.0/