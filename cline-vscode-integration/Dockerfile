FROM quay.io/jupyter/pytorch-notebook:cuda12-python-3.12
USER root

RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN pip install jupyter-server-proxy
RUN code-server --install-extension saoudrizwan.claude-dev

RUN conda install -c conda-forge nodejs -y && \
    npm install -g cline && \
    npm cache clean --force && \
    conda clean -afy

RUN mkdir -p /home/jovyan/.cline/data/settings && \
    echo '{"version":1,"lastUsedProvider":"openai-compatible","providers":{"openai-compatible":{"settings":{"provider":"openai-compatible","apiKey":"jetstream","model":"Kimi-K2.6","baseUrl":"https://llm.jetstream-cloud.org/v1"}}}}' \
    > /home/jovyan/.cline/data/settings/providers.json && \
    echo '{"welcomeViewCompleted":true,"clineVersion":"3.88.1","planModeApiProvider":"openai-compatible","actModeApiProvider":"openai-compatible","openAiBaseUrl":"https://llm.jetstream-cloud.org/v1","planModeOpenAiModelId":"Kimi-K2.6","actModeOpenAiModelId":"Kimi-K2.6","azureApiVersion":""}' \
    > /home/jovyan/.cline/data/globalState.json

RUN mkdir -p /home/jovyan/.jupyter && \
    echo 'c.ServerProxy.servers = {"vscode": {"command": ["code-server", "--auth", "none", "--bind-addr", "0.0.0.0:8080", "/home/jovyan"], "port": 8080, "launcher_entry": {"enabled": True, "title": "VS Code + Cline"}}}' \
    > /home/jovyan/.jupyter/jupyter_server_config.py

COPY start-code-server.sh /usr/local/bin/start-code-server.sh
RUN chmod +x /usr/local/bin/start-code-server.sh
RUN fix-permissions /home/jovyan && fix-permissions /opt/conda

USER ${NB_UID}
CMD ["bash", "-c", "/usr/local/bin/start-code-server.sh && start-notebook.py"]
