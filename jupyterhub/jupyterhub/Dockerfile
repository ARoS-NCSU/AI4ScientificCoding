FROM quay.io/jupyterhub/jupyterhub:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    npm \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install configurable-http-proxy
RUN npm install -g configurable-http-proxy

# Install Python packages
RUN pip install --no-cache-dir \
    oauthenticator \
    dockerspawner

# Create config directory
RUN mkdir -p /etc/jupyterhub

EXPOSE 8000
