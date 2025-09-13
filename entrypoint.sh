#!/bin/bash
set -e

# ----------------------------
# Fix .ssh permissions for the user
# ----------------------------
if [ -d "/home/${NB_USER}/.ssh" ]; then
    chown -R ${NB_USER} "/home/${NB_USER}/.ssh"
    chmod 700 "/home/${NB_USER}/.ssh"
    if [ -f "/home/${NB_USER}/.ssh/authorized_keys" ]; then
        chmod 600 "/home/${NB_USER}/.ssh/authorized_keys"
    fi
fi

chown -R ${NB_USER} "/home/${NB_USER}/"
chmod 750 "/home/${NB_USER}/"

# ----------------------------
# Pass Jupyter password to environment variable for supervisor
# ----------------------------
if [ -n "${JUPYTER_PASSWORD}" ]; then
    export JUPYTER_PASSWORD_HASHED="${JUPYTER_PASSWORD}"
fi

# ----------------------------
# Start supervisor (manages Jupyter + SSH)
# ----------------------------
exec supervisord -n -c /etc/supervisor/conf.d/services.conf
