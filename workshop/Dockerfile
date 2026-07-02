FROM quay.io/jupyter/pytorch-notebook:cuda12-python-3.12

USER root

# Install Marimo, jupyter-marimo-proxy (adds launcher tile), Jupyter AI and dependencies
RUN pip install 'marimo>=0.6.21' jupyter-marimo-proxy jupyter-ai langchain-openai pydantic-ai

# Fix Marimo supports_thinking bug for OpenAI-compatible providers (Jetstream)
RUN sed -i \
    -e 's/model\.profile\.supports_thinking/False/g' \
    -e 's/model\.profile\.thinking_always_enabled/False/g' \
    -e 's/if profile\.supports_thinking/if False/g' \
    /opt/conda/lib/python3.12/site-packages/marimo/_server/ai/providers.py 2>/dev/null || true

# Bake Marimo AI config into image (points to Jetstream LLM)
RUN mkdir -p /home/jovyan/.config/marimo
COPY marimo.toml /home/jovyan/.config/marimo/marimo.toml

RUN fix-permissions /home/jovyan && fix-permissions /opt/conda

USER ${NB_UID}
