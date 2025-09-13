# ----------------------------
# Base image
# ----------------------------
ARG BASE_IMAGE=datascience-notebook
FROM $BASE_IMAGE

LABEL maintainer="Daniel Febrian Sengkey <danielsengkey@unsrat.ac.id>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ----------------------------
# Switch to root for package installation
# ----------------------------
USER root

# Install monitoring tools, SSH, sudo, and supervisor
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
        htop \
        btop \
        openssh-server \
        sudo \
        supervisor && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Allow jovyan passwordless sudo
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# SSH configuration
RUN mkdir -p /var/run/sshd && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

# ----------------------------
# Switch to jovyan for conda/mamba installs
# ----------------------------
USER ${NB_UID}

# Ensure .ssh directory exists with correct permissions
RUN mkdir -p /home/${NB_USER}/.ssh && \
    chown -R ${NB_USER} /home/${NB_USER}/.ssh && \
    chmod 700 /home/${NB_USER}/.ssh

# ----------------------------
# Install Python and R packages
# ----------------------------
RUN mamba install -c conda-forge --yes -vv \
        chembl_webresource_client \
        numpy \
        padelpy \
        papermill \
        rdkit \
        lightgbm \
        r-dplyr \
        r-forcats \
        r-ggplot2 \
        r-ggsci \
        r-rcdk \
        r-readr \
        r-reshape2 \
        r-rstatix \
        r-tidyr \
        r-irkernel && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

# Install R kernel system-wide
USER root
RUN Rscript -e "IRkernel::installspec(user = FALSE)"

# ----------------------------
# Supervisor configuration
# ----------------------------
COPY services.conf /etc/supervisor/conf.d/services.conf

# ----------------------------
# Copy merged entrypoint script
# ----------------------------
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ----------------------------
# Expose ports
# ----------------------------
EXPOSE 8888 22

# ----------------------------
# Use tini as init, entrypoint handles Jupyter + SSH
# ----------------------------
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/usr/local/bin/entrypoint.sh"]
