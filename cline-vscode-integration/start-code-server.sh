#!/bin/bash
export HOME=/home/jovyan
export XDG_DATA_HOME=/home/jovyan/.local/share

mkdir -p /home/jovyan/.local/share/code-server/User
mkdir -p /home/jovyan/.cline/data/settings

cat > /home/jovyan/.local/share/code-server/User/settings.json << 'SETTINGS'
{
  "security.workspace.trust.enabled": false,
  "files.autoSave": "onFocusChange",
  "terminal.integrated.defaultProfile.linux": "bash"
}
SETTINGS

echo '{"version":1,"lastUsedProvider":"openai-compatible","providers":{"openai-compatible":{"settings":{"provider":"openai-compatible","apiKey":"jetstream","model":"Kimi-K2.6","baseUrl":"https://llm.jetstream-cloud.org/v1"}}}}' \
  > /home/jovyan/.cline/data/settings/providers.json

echo '{"welcomeViewCompleted":true,"clineVersion":"3.88.1","planModeApiProvider":"openai-compatible","actModeApiProvider":"openai-compatible","openAiBaseUrl":"https://llm.jetstream-cloud.org/v1","planModeOpenAiModelId":"Kimi-K2.6","actModeOpenAiModelId":"Kimi-K2.6","azureApiVersion":""}' \
  > /home/jovyan/.cline/data/globalState.json

cline auth -p openai-compatible -k jetstream -m Kimi-K2.6 -b https://llm.jetstream-cloud.org/v1

code-server \
  --auth none \
  --bind-addr 0.0.0.0:8080 \
  --user-data-dir /home/jovyan/.local/share/code-server \
  /home/jovyan &

echo "code-server started (PID $!)"
