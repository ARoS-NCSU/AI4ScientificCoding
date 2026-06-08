#!/bin/bash

set -e

echo "🚀 Starting Open WebUI Setup..."

# --- Step 1: Create Ollama Container ---
echo "📦 Starting Ollama (GPU-accelerated)..."
docker run -d \
  --gpus all \
  -p 11434:11434 \
  -v ollama:/root/.ollama \
  --name ollama \
  ollama/ollama:0.1.24

echo "⏳ Waiting for Ollama to start..."
sleep 10

# --- Step 2: Pull Models ---
echo "📥 Pulling models (this may take a while)..."
docker exec ollama ollama pull mistral
docker exec ollama ollama pull llama2
docker exec ollama ollama pull codellama

# --- Step 3: Start Open WebUI ---
echo "🌐 Starting Open WebUI..."
docker run -d \
  -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
  -e ENABLE_SIGNUP=true \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main

# --- Step 4: Verify ---
echo "✅ Verifying setup..."
docker ps | grep -E "ollama|open-webui"
docker exec ollama nvidia-smi
docker exec ollama ollama list

echo ""
echo "✅ Setup Complete!"
echo "🌐 Open WebUI: http://$(hostname -I | awk '{print $1}'):3000"
echo "📝 First account created will be admin"
echo "🔧 Enable signups: Admin Panel → Settings → General"
