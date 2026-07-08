#!/bin/bash
set -e

WORKDIR=/media/volume/workshop-volume/workshop-hub
cd $WORKDIR

# ── 1. Fixed Dockerfile ─────────────────────────────────────────
cat > Dockerfile << 'EOF'
FROM jupyter/scipy-notebook:latest
USER root
RUN pip install marimo jupyter-server-proxy jupyter-ai langchain-openai
RUN mkdir -p /home/jovyan/.config/marimo
COPY marimo.toml /home/jovyan/.config/marimo/marimo.toml
RUN chown -R $NB_UID:$NB_GID /home/jovyan/.config/marimo
USER $NB_UID
EOF

# ── 2. Marimo config ────────────────────────────────────────────
cat > marimo.toml << 'EOF'
[ai]
open_ai_api_key = "jetstream"
open_ai_base_url = "https://llm.jetstream-cloud.org/v1"
open_ai_model = "gpt-oss-120b"
EOF

# ── 3. JupyterHub config ────────────────────────────────────────
cat > jupyterhub_config.py << 'EOF'
import os
from oauthenticator.github import GitHubOAuthenticator

c.JupyterHub.authenticator_class = GitHubOAuthenticator
c.GitHubOAuthenticator.client_id = os.environ["GITHUB_CLIENT_ID"]
c.GitHubOAuthenticator.client_secret = os.environ["GITHUB_CLIENT_SECRET"]
c.GitHubOAuthenticator.oauth_callback_url = "https://ncstate-ai-workshop.nairr240257.projects.jetstream-cloud.org/hub/oauth_callback"
c.GitHubOAuthenticator.allowed_organizations = {"NCState-AI-Workshop"}
c.GitHubOAuthenticator.scope = ["read:org"]

c.JupyterHub.ip = "0.0.0.0"
c.JupyterHub.port = 8000

from dockerspawner import DockerSpawner
c.JupyterHub.spawner_class = DockerSpawner
c.DockerSpawner.image = "workshop-notebook:latest"
c.DockerSpawner.network_name = "jupyterhub-network"
c.DockerSpawner.remove = True
c.DockerSpawner.debug = True
c.DockerSpawner.volumes = {
    "jupyterhub-user-{username}": "/home/jovyan/work"
}

c.JupyterHub.hub_ip = "jupyterhub"
c.JupyterHub.cookie_secret = bytes.fromhex(os.environ["JUPYTERHUB_CRYPT_KEY"])
EOF

# ── 4. docker-compose.yml ───────────────────────────────────────
cat > docker-compose.yml << 'EOF'
version: "3"
services:
  jupyterhub:
    image: jupyterhub/jupyterhub:latest
    container_name: jupyterhub
    volumes:
      - ./jupyterhub_config.py:/srv/jupyterhub/jupyterhub_config.py
      - /var/run/docker.sock:/var/run/docker.sock
      - jupyterhub-data:/data
    env_file: .env
    networks:
      - jupyterhub-network
    ports:
      - "8000:8000"
    command: >
      bash -c "pip install dockerspawner oauthenticator &&
               jupyterhub -f /srv/jupyterhub/jupyterhub_config.py"
    restart: unless-stopped

  caddy:
    image: caddy:latest
    container_name: caddy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy-data:/data
      - caddy-config:/config
    networks:
      - jupyterhub-network
    restart: unless-stopped

networks:
  jupyterhub-network:
    external: true

volumes:
  jupyterhub-data:
  caddy-data:
  caddy-config:
EOF

# ── 5. Caddyfile ────────────────────────────────────────────────
cat > Caddyfile << 'EOF'
ncstate-ai-workshop.nairr240257.projects.jetstream-cloud.org {
    reverse_proxy jupyterhub:8000
}
EOF

# ── 6. Docker network ───────────────────────────────────────────
docker network create jupyterhub-network 2>/dev/null || echo "Network already exists"

# ── 7. Rebuild image with fixed Marimo config ───────────────────
echo "Rebuilding workshop-notebook image..."
docker build -t workshop-notebook:latest .

echo ""
echo "✅ All done! Run: docker-compose --env-file .env up -d"
