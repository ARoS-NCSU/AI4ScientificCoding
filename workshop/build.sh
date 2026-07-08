#!/bin/bash
set -e
cd /media/volume/workshop-volume/workshop-hub

# ── jupyter_server_config.py ────────────────────────────────────
cat > jupyter_server_config.py << 'EOF'
c.ServerProxy.servers["marimo"] = {
    "command": ["marimo", "edit", "--no-token", "--host", "0.0.0.0", "--port", "{port}"],
    "port": 2718,
    "launcher_entry": {
        "enabled": True,
        "title": "Marimo"
    }
}
EOF

# ── marimo.toml ─────────────────────────────────────────────────
cat > marimo.toml << 'EOF'
[ai]
enabled = true
inline_tooltip = false
mode = "agent"
rules = ""

[ai.custom_providers.jetstream]
api_key = "jetstream"
base_url = "https://llm.jetstream-cloud.org/v1"

[ai.models]
autocomplete_model = "jetstream/gpt-oss-120b"
chat_model = "jetstream/gpt-oss-120b"
custom_models = ["jetstream/gpt-oss-120b", "jetstream/Llama-4-Scout"]
displayed_models = ["jetstream/gpt-oss-120b", "jetstream/Llama-4-Scout"]

[completion]
activate_on_typing = true
copilot = "custom"
EOF

# ── Dockerfile ──────────────────────────────────────────────────
cat > Dockerfile << 'EOF'
FROM quay.io/jupyter/pytorch-notebook:cuda12-python-3.12

USER root

# Install packages
RUN pip install marimo jupyter-server-proxy jupyter-ai langchain-openai

# Fix Marimo supports_thinking bug for OpenAI-compatible providers
RUN sed -i \
    -e 's/model\.profile\.supports_thinking/False/g' \
    -e 's/model\.profile\.thinking_always_enabled/False/g' \
    -e 's/if profile\.supports_thinking/if False/g' \
    /opt/conda/lib/python3.12/site-packages/marimo/_server/ai/providers.py 2>/dev/null || true

# Marimo launcher via server proxy
RUN mkdir -p /home/jovyan/.jupyter
COPY jupyter_server_config.py /home/jovyan/.jupyter/jupyter_server_config.py

# Marimo AI config
RUN mkdir -p /home/jovyan/.config/marimo
COPY marimo.toml /home/jovyan/.config/marimo/marimo.toml

RUN fix-permissions /home/jovyan && fix-permissions /opt/conda

USER ${NB_UID}
EOF

# ── Build ────────────────────────────────────────────────────────
echo "Building workshop-notebook image..."
docker build -t workshop-notebook:latest .

# ── Remove old containers so users get fresh ones ────────────────
docker ps -a | grep jupyter- | awk '{print $1}' | xargs docker rm -f 2>/dev/null || true

# ── Restart JupyterHub ───────────────────────────────────────────
docker restart jupyterhub

echo ""
echo "✅ Done! Test at: https://ncstate-ai-workshop.nairr240257.projects.jetstream-cloud.org"
