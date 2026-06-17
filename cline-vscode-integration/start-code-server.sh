#!/bin/bash
# Start code-server and prepare Cline for a JupyterHub single-user container.
# DockerSpawner runs this before the Jupyter single-user server starts so the
# VS Code + Cline launcher is ready when the user opens JupyterLab.
set -euo pipefail

# Jupyter Docker Stacks run notebook containers as the jovyan user. Set HOME and
# XDG_DATA_HOME explicitly so code-server and Cline write settings in the user
# workspace instead of a root-owned or unset location.
export HOME=/home/jovyan
export XDG_DATA_HOME=/home/jovyan/.local/share

# Cline provider defaults. JupyterHub passes CLINE_API_KEY from .env when set.
# Keep the key out of tracked files; leave it empty here if not provided.
export CLINE_API_PROVIDER=${CLINE_API_PROVIDER:-openai-compatible}
export CLINE_API_KEY=${CLINE_API_KEY:-}
export CLINE_MODEL=${CLINE_MODEL:-Kimi-K2.6}
export CLINE_BASE_URL=${CLINE_BASE_URL:-https://llm.jetstream-cloud.org/v1}
export CLINE_VERSION=${CLINE_VERSION:-3.88.1}

# Ensure the per-user settings directories exist before writing config files.
mkdir -p /home/jovyan/.local/share/code-server/User
mkdir -p /home/jovyan/.cline/data/settings

# Configure code-server defaults for classroom use: disable workspace trust
# prompts, enable autosave, and use bash as the integrated terminal shell.
cat > /home/jovyan/.local/share/code-server/User/settings.json << SETTINGS
{
  "security.workspace.trust.enabled": false,
  "files.autoSave": "onFocusChange",
  "terminal.integrated.defaultProfile.linux": "bash"
}
SETTINGS

# Write Cline extension state as JSON. Python handles quoting safely, which is
# less fragile than assembling nested JSON with shell string interpolation.
python3 - << PY
import json
import os
from pathlib import Path

provider = os.environ["CLINE_API_PROVIDER"]
api_key = os.environ["CLINE_API_KEY"]
model = os.environ["CLINE_MODEL"]
base_url = os.environ["CLINE_BASE_URL"]
version = os.environ["CLINE_VERSION"]

settings_dir = Path("/home/jovyan/.cline/data/settings")
settings_dir.mkdir(parents=True, exist_ok=True)

(settings_dir / "providers.json").write_text(json.dumps({
    "version": 1,
    "lastUsedProvider": provider,
    "providers": {
        provider: {
            "settings": {
                "provider": provider,
                "apiKey": api_key,
                "model": model,
                "baseUrl": base_url,
            }
        }
    },
}))

Path("/home/jovyan/.cline/data/globalState.json").write_text(json.dumps({
    "welcomeViewCompleted": True,
    "clineVersion": version,
    "planModeApiProvider": provider,
    "actModeApiProvider": provider,
    "openAiBaseUrl": base_url,
    "planModeOpenAiModelId": model,
    "actModeOpenAiModelId": model,
    "azureApiVersion": "",
}))
PY

# Authenticate the Cline CLI when it is available. Do not fail container startup
# if the auth command changes or the provider is temporarily unreachable.
if command -v cline >/dev/null 2>&1; then
  cline auth -p "${CLINE_API_PROVIDER}" -k "${CLINE_API_KEY}" -m "${CLINE_MODEL}" -b "${CLINE_BASE_URL}" || true
fi

# Start code-server in the background. JupyterLab reaches it through
# jupyter-server-proxy using the launcher registered in jupyter_server_config.py.
code-server \
  --auth none \
  --bind-addr 0.0.0.0:8080 \
  --user-data-dir /home/jovyan/.local/share/code-server \
  --extensions-dir /opt/code-server/extensions \
  /home/jovyan &

echo "code-server started (PID $!)"
