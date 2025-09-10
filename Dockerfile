ARG BASE_IMAGE=datascience-notebook
FROM $BASE_IMAGE

LABEL maintainer="Daniel Febrian Sengkey <danielsengkey@unsrat.ac.id>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

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
RUN echo "jovyan ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# SSH configuration
RUN mkdir -p /var/run/sshd && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

# Switch to jovyan for conda/mamba installs
USER ${NB_UID}
RUN mkdir -p /home/${NB_USER}/.ssh && \
    fix-permissions "/home/${NB_USER}/.ssh"

# Install Python and R packages
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

# Copy supervisor configuration
COPY services.conf /etc/supervisor/conf.d/services.conf

# Expose Jupyter and SSH ports
EXPOSE 8888 22

# Run Supervisor as PID 1 (root)
# The shell has line to su to normal user
# Create start-supervisor.sh inside the container
RUN echo '#!/bin/bash' > /usr/local/bin/start-supervisor.sh && \
    echo 'set -e' >> /usr/local/bin/start-supervisor.sh && \
    echo '' >> /usr/local/bin/start-supervisor.sh && \
    echo '# Fix authorized_keys permissions' >> /usr/local/bin/start-supervisor.sh && \
    echo '    chown ${NB_USER} /home/${NB_USER}' >> /usr/local/bin/start-supervisor.sh && \
    echo '    chmod go-w /home/${NB_USER}' >> /usr/local/bin/start-supervisor.sh && \
    echo 'if [ -d /home/${NB_USER}/.ssh ]; then' >> /usr/local/bin/start-supervisor.sh && \
    echo '    chown -R ${NB_USER} /home/${NB_USER}/.ssh' >> /usr/local/bin/start-supervisor.sh && \
    echo '    chmod 700 /home/${NB_USER}/.ssh' >> /usr/local/bin/start-supervisor.sh && \
    echo '    if [ -f /home/${NB_USER}/.ssh/authorized_keys ]; then' >> /usr/local/bin/start-supervisor.sh && \
    echo '        chmod 600 /home/${NB_USER}/.ssh/authorized_keys' >> /usr/local/bin/start-supervisor.sh && \
    echo '    fi' >> /usr/local/bin/start-supervisor.sh && \
    echo 'fi' >> /usr/local/bin/start-supervisor.sh && \
    echo '' >> /usr/local/bin/start-supervisor.sh && \
    echo '# Start Supervisor in foreground as PID 1' >> /usr/local/bin/start-supervisor.sh && \
    echo 'exec supervisord -n -c /etc/supervisor/conf.d/services.conf' >> /usr/local/bin/start-supervisor.sh && \
    chmod +x /usr/local/bin/start-supervisor.sh
RUN chmod +x /usr/local/bin/start-supervisor.sh

ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/usr/local/bin/start-supervisor.sh"]
