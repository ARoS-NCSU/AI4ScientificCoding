**Cline + VS Code Integration into JupyterHub**
This integration adds an AI-powered coding assistant (Cline) and VS Code (via code-server) into every student's JupyterHub container. Students get a fully pre-configured environment with no manual setup required.

**Quick Access**
ItemValueJupyterHub URLhttps://srp-jupyterhub.nairr240257.projects.jetstream-cloud.orgLoginGitHub OAuth (NCSU-NNDL-Spring26 org)LLM APIhttps://llm.jetstream-cloud.org/v1Default ModelKimi-K2.6Fallback ModelLlama-4-ScoutAPI Keyjetstream

**Architecture**
Student Browser
       │
       ▼
JupyterHub  ──  GitHub OAuth Authentication
       │
       ▼
DockerSpawner  ──  pytorch-cline:latest  (one container per user)
       │
       ├──  JupyterLab     (port 8888)   Notebooks and data science
       ├──  code-server    (port 8080)   VS Code with Cline extension
       └──  Cline CLI                    AI assistant in terminal
                    │
                    ▼
       Jetstream LLM API
       ├──  Kimi-K2.6       (default)
       └──  Llama-4-Scout   (fallback)
When a student logs in, JupyterHub spawns a personal container. All three tools share the same Jetstream LLM backend at no cost to students.

**Repository Files**
FilePurposeDockerfileBuilds the student container with code-server, Cline extension, Cline CLI, and all pre-configured settingsstart-code-server.shRuns on every container start. Writes Cline config files, authenticates the CLI, and launches code-serverjupyterhub_config.pyJupyterHub configuration with GitHub OAuth, DockerSpawner, GPU access, and allowed users

**How Students Use Cline**
Option 1: VS Code + Cline (Recommended)

Log into JupyterHub
Click the VS Code + Cline button in the JupyterLab launcher
The Cline sidebar opens with Kimi-K2.6 already configured
Type your coding task and press Enter

Option 2: Cline CLI in Terminal

Open a terminal in JupyterLab
Run your task directly

cline "write a PyTorch training loop"

**Available LLM Models**
ModelModel IDNotesKimi K2.6Kimi-K2.6Default, best for codingLlama 4 ScoutLlama-4-ScoutFallback if Kimi is unavailable
Switching Models in VS Code
Click the model name at the bottom of the Cline sidebar, scroll to Model ID, type the new model ID, and click Done.
Switching Models in CLI
cline auth -p openai-compatible -k jetstream -m Llama-4-Scout -b https://llm.jetstream-cloud.org/v1
Verifying API and Available Models
curl https://llm.jetstream-cloud.org/v1/models -H "Authorization: Bearer jetstream"

**Initial Deployment**
Prerequisites

Docker installed on the host VM
NVIDIA GPU with CUDA drivers
GitHub OAuth App credentials
jupyterhub-network Docker network created

**Steps**

Clone this repository onto the JupyterHub VM
Build the Docker image: docker build -t pytorch-cline:latest .
Update jupyterhub_config.py with your OAuth Client ID and Secret
Restart JupyterHub: docker restart jupyterhub
All users log in fresh to get new containers


**Managing Users**
Open jupyterhub_config.py and add or remove GitHub usernames from the allowed_users list, then restart JupyterHub. Only listed GitHub accounts can log in.
To force a user onto the latest image, remove their container. It will be recreated automatically on next login.
docker ps -a | grep jupyter- | awk '{print $1}' | xargs docker rm -f

**Known Issues**
IssueCauseSolutionKimi-K2.6 connection errorJetstream API temporarily downSwitch to Llama-4-Scout400 OAuth state missingBrowser cookie conflictUse a private/incognito windowDisk full during image buildDocker build cacheRun docker system prune -f before rebuildingVS Code + Cline button missingContainer built from old imageRemove old container and log in againCannot use checkpoints warningVS Code internal warningHarmless, safely ignored

**Security Notes**

Never commit your GitHub OAuth client_secret to the repository
The jupyterhub_config.py in this repo uses placeholder values. Real credentials are stored only on the VM
Each student container is fully isolated from others
HTTPS is enforced via Caddy with Let's Encrypt certificates
