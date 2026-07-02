import os
from oauthenticator.github import GitHubOAuthenticator

# ── Authentication ───────────────────────────────────────────────────────────
c.JupyterHub.authenticator_class = GitHubOAuthenticator
c.GitHubOAuthenticator.client_id = os.environ["GITHUB_CLIENT_ID"]
c.GitHubOAuthenticator.client_secret = os.environ["GITHUB_CLIENT_SECRET"]
c.GitHubOAuthenticator.oauth_callback_url = "https://ncstate-ai-workshop.nairr240257.projects.jetstream-cloud.org/hub/oauth_callback"

# Anyone in the NCState-AI-Workshop GitHub org can log in automatically
c.GitHubOAuthenticator.allowed_organizations = {"NCState-AI-Workshop"}
c.GitHubOAuthenticator.scope = ["read:org"]

# ── Hub network ──────────────────────────────────────────────────────────────
c.JupyterHub.ip = "0.0.0.0"
c.JupyterHub.port = 8000
c.JupyterHub.hub_ip = "jupyterhub"
c.JupyterHub.cookie_secret = bytes.fromhex(os.environ["JUPYTERHUB_CRYPT_KEY"])

# ── DockerSpawner ────────────────────────────────────────────────────────────
from dockerspawner import DockerSpawner
c.JupyterHub.spawner_class = DockerSpawner
c.DockerSpawner.image = "workshop-notebook:latest"
c.DockerSpawner.network_name = "jupyterhub-network"
c.DockerSpawner.remove = True
c.DockerSpawner.debug = True
c.DockerSpawner.volumes = {
    "jupyterhub-user-{username}": "/home/jovyan/work"
}

# ── GPU support ──────────────────────────────────────────────────────────────
c.DockerSpawner.extra_host_config = {"runtime": "nvidia"}
