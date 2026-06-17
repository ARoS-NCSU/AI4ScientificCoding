FROM quay.io/jupyterhub/jupyterhub:latest

# Add tools needed by the Hub image itself.
# npm is required to install configurable-http-proxy, which JupyterHub uses
# to route browser traffic to the Hub and to each user notebook server.
# git is useful for Hub-side maintenance and extension/package workflows.
RUN apt-get update && apt-get install -y \
    npm \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install the JupyterHub Node.js proxy globally so the jupyterhub command can
# start and manage it when the Hub container launches.
RUN npm install -g configurable-http-proxy

# Install Hub-side Python integrations from the shared requirements file.
COPY jupyterhub/requirements.txt /tmp/jupyterhub-requirements.txt
RUN pip install --no-cache-dir -r /tmp/jupyterhub-requirements.txt

# Create the directory where jupyterhub_config.py will be mounted at runtime.
# The README run command mounts ~/jupyterhub-config here.
RUN mkdir -p /etc/jupyterhub

# Publish the default JupyterHub HTTP port from the container.
EXPOSE 8000
