#!/bin/bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "${SCRIPT_DIR}/.." && pwd)
ENV_FILE=${ENV_FILE:-"${REPO_ROOT}/.env"}
HUB_IMAGE=${HUB_IMAGE:-jupyterhub-complete:latest}
HUB_NAME=${HUB_NAME:-jupyterhub}
HUB_NETWORK=${HUB_NETWORK:-jupyterhub-network}
HUB_PORT=${HUB_PORT:-8000}

if ! docker network inspect "${HUB_NETWORK}" >/dev/null 2>&1; then
  docker network create "${HUB_NETWORK}"
fi

if docker ps -a --format "{{.Names}}" | grep -qx "${HUB_NAME}"; then
  echo "Container ${HUB_NAME} already exists. Remove it first with: docker rm -f ${HUB_NAME}"
  exit 1
fi

docker run -d \
  --name "${HUB_NAME}" \
  --network "${HUB_NETWORK}" \
  -p "${HUB_PORT}:8000" \
  --env-file "${ENV_FILE}" \
  -v "${SCRIPT_DIR}:/etc/jupyterhub" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jupyterhub-data:/data \
  "${HUB_IMAGE}" \
  jupyterhub -f /etc/jupyterhub/jupyterhub_config.py

echo "JupyterHub started at http://localhost:${HUB_PORT}"
