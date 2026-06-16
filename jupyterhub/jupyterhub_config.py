# =============================================================
# JupyterHub Configuration - SHI-NAIRR SRP 2026
# NC State University, ECE Department
# ⚠️ WARNING: Do not commit real credentials to GitHub!
# =============================================================

# --- Authentication ---
c.JupyterHub.authenticator_class = "oauthenticator.github.GitHubOAuthenticator"
c.GitHubOAuthenticator.oauth_callback_url = "http://149.165.172.98:8000/hub/oauth_callback"
c.GitHubOAuthenticator.client_id = "YOUR_CLIENT_ID_HERE"
c.GitHubOAuthenticator.client_secret = "YOUR_CLIENT_SECRET_HERE"

# --- Allowed Users (GitHub usernames) ---
# Add new users here, then restart JupyterHub
c.Authenticator.allowed_users = [
    "lobaton",        # Prof. Edgar Lobaton
    "darrendbutler",  # Ren Butler
    "qsamson",        # Samson Quaye
    # "new-username", # Add new users below this line
]

# --- Hub Network Configuration ---
# Critical for DockerSpawner to communicate with Hub
c.JupyterHub.hub_ip = "0.0.0.0"
c.JupyterHub.hub_connect_ip = "jupyterhub"

# --- DockerSpawner Configuration ---
c.JupyterHub.spawner_class = "dockerspawner.DockerSpawner"
c.DockerSpawner.image = "ai4scientificcoding-notebook:latest"
c.DockerSpawner.network_name = "jupyterhub-network"
c.DockerSpawner.remove = True
c.DockerSpawner.http_timeout = 300
c.DockerSpawner.extra_host_config = {"runtime": "nvidia"}
