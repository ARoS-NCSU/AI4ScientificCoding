#!/bin/bash
# Start a new Docker container in detached (background) mode
docker run -d \

  # Assign the container the name "jupyterhub"
  --name jupyterhub \

  # Connect the container to the Docker network used by JupyterHub
  # and the notebook containers it spawns
  --network jupyterhub-network \

  # Map port 8000 on the host machine to port 8000 inside the container
  # so users can access JupyterHub via http://<host>:8000
  -p 8000:8000 \

  # Load environment variables from the specified .env file
  # (e.g., OAuth credentials, API keys, configuration settings)
  --env-file ~/AI4ScientificCoding/.env \

  # Mount the local JupyterHub configuration directory into the container
  # so jupyterhub_config.py and related files can be edited without rebuilding
  -v ~/AI4ScientificCoding/jupyterhub:/etc/jupyterhub \

  # Mount the host Docker socket into the container
  # allowing DockerSpawner to create, start, stop, and manage notebook containers
  -v /var/run/docker.sock:/var/run/docker.sock \

  # Mount a persistent Docker volume for JupyterHub data
  # so data survives container restarts and upgrades
  -v jupyterhub-data:/data \

  # Docker image to run
  jupyterhub-complete:latest \

  # Command executed inside the container:
  # start JupyterHub using the specified configuration file
  jupyterhub -f /etc/jupyterhub/jupyterhub_config.py