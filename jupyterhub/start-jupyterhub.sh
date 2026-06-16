#!/bin/bash
docker run -d \
  --name jupyterhub \
  --network jupyterhub-network \
  -p 8000:8000 \
  --env-file ~/AI4ScientificCoding/.env \
  -v ~/AI4ScientificCoding/jupyterhub:/etc/jupyterhub \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jupyterhub-data:/data \
  jupyterhub-complete:latest \
  jupyterhub -f /etc/jupyterhub/jupyterhub_config.py
