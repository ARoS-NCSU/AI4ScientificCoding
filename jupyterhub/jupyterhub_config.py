import os

c.JupyterHub.authenticator_class = "oauthenticator.github.GitHubOAuthenticator"
c.GitHubOAuthenticator.oauth_callback_url = os.environ["OAUTH_CALLBACK_URL"]
c.GitHubOAuthenticator.client_id = os.environ["GITHUB_CLIENT_ID"]
c.GitHubOAuthenticator.client_secret = os.environ["GITHUB_CLIENT_SECRET"]
c.GitHubOAuthenticator.allowed_organizations = {"NCSU-NNDL-Spring26"}
c.GitHubOAuthenticator.scope = ["read:org"]
c.JupyterHub.hub_ip = "0.0.0.0"
c.JupyterHub.hub_connect_ip = "jupyterhub"
c.JupyterHub.spawner_class = "dockerspawner.DockerSpawner"
c.DockerSpawner.image = "pytorch-cline:latest"
c.DockerSpawner.network_name = "jupyterhub-network"
c.DockerSpawner.remove = False
c.DockerSpawner.http_timeout = 300
c.DockerSpawner.extra_host_config = {"runtime": "nvidia"}
