#!/bin/bash

# OpenCode Jetstream Deployment Script

# SSH into instance
ssh exouser@149.165.173.45

# Update system
sudo apt update
sudo apt upgrade -y
sudo apt install -y python3-pip python3-venv git

# Clone repository
git clone https://gitlab.com/jetstream-cloud/jetstream2/eot/hubs/images/ai-unlocked-26.git
cd ai-unlocked-26

# Build Docker image
docker build -t ai-unlocked-26-opencode:local .

# Run container
docker run -d --rm -p 8888:8888 --name ai-unlocked-26-opencode ai-unlocked-26-opencode:local

# Verify status
docker ps

# View logs
docker logs ai-unlocked-26-opencode

# Access OpenCode
# http://149.165.173.45:8888
