Cline + VS Code Integration into JupyterHub
This integration adds an AI-powered coding assistant (Cline) and VS Code (via code-server) into every student's JupyterHub container. Students get a fully pre-configured environment — no manual setup required.

📌 Quick Access
ItemValueJupyterHub URLhttps://srp-jupyterhub.nairr240257.projects.jetstream-cloud.orgLoginGitHub OAuth (NCSU-NNDL-Spring26 org)LLM APIhttps://llm.jetstream-cloud.org/v1Default ModelKimi-K2.6Fallback ModelLlama-4-ScoutAPI Keyjetstream

🏗️ Architecture
When a student logs into JupyterHub, a personal Docker container is spawned from the pytorch-cline:latest image. Inside that container, three tools are available:

JupyterLab on port 8888 — for notebooks and data science work
code-server on port 8080 — VS Code in the browser with Cline pre-installed
Cline CLI — AI assistant accessible directly from the JupyterLab terminal

All three connect to the Jetstream LLM API running Kimi-K2.6 at no cost to students.

📁 Repository Files
Dockerfile — Builds the student container image. Installs code-server, the Cline VS Code extension, the Cline CLI, and pre-configures all settings so students land directly in a working environment.
start-code-server.sh — Runs automatically every time a container starts. It writes fresh Cline configuration files (API key, model, base URL), authenticates the Cline CLI, and starts code-server in the background alongside JupyterLab.
jupyterhub_config.py — Configures JupyterHub with GitHub OAuth authentication, DockerSpawner settings, GPU access, and the allowed user list.

🖥️ How Students Use Cline
Option 1 — VS Code + Cline (recommended)

Log into JupyterHub at the URL above
Click the VS Code + Cline button in the JupyterLab launcher
The Cline sidebar opens on the left with Kimi-K2.6 already configured
Type your coding task and press Enter

Option 2 — Cline CLI in terminal

Open a terminal in JupyterLab
Type your task directly, for example: cline "write a PyTorch training loop"


🤖 Available LLM Models
Both models are free via the Jetstream LLM API:
ModelModel IDNotesKimi K2.6Kimi-K2.6Default — best for coding tasksLlama 4 ScoutLlama-4-ScoutFallback if Kimi is unavailable
Switching Models in VS Code
Click the model name at the bottom of the Cline sidebar, scroll down to Model ID, type the new model ID, and click Done.
Switching Models in CLI
Run cline auth -p openai-compatible -k jetstream -m Llama-4-Scout -b https://llm.jetstream-cloud.org/v1 in the terminal.
Verifying API Status
Run curl https://llm.jetstream-cloud.org/v1/models -H "Authorization: Bearer jetstream" to see all available models.

⚙️ Initial Deployment
Prerequisites

Docker installed on the host VM
NVIDIA GPU with CUDA drivers
GitHub OAuth App credentials (stored in jupyterhub_config.py)
jupyterhub-network Docker network created

Steps

Clone this repository onto the JupyterHub VM
Build the Docker image: docker build -t pytorch-cline:latest .
Update jupyterhub_config.py with your OAuth Client ID and Secret
Restart JupyterHub: docker restart jupyterhub
All users log in fresh to get new containers


👥 Managing Users
Open jupyterhub_config.py and add or remove GitHub usernames from the allowed_users list, then restart JupyterHub. Only listed GitHub accounts can log in.
To force a user to get a fresh container from the latest image, stop and remove their container. It will be automatically recreated on next login.

⚠️ Known Issues
IssueCauseSolutionKimi-K2.6 connection errorJetstream API temporarily downSwitch to Llama-4-Scout400 OAuth state missing from cookiesBrowser cookie conflictUse a private/incognito windowDisk full during image buildDocker build cache accumulationRun docker system prune -f before rebuildingVS Code + Cline button not showingContainer was built from old imageRemove old container and log in againCannot use checkpoints in home directoryVS Code internal warningHarmless — safely ignored

🔐 Security Notes
Never commit your GitHub OAuth client_secret to the repository
The jupyterhub_config.py in this repo uses placeholder values — real credentials are stored only on the VM
Each student's container is fully isolated from others
HTTPS is enforced via Caddy with Let's Encrypt certificates
