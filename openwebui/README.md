# 🤖 Open WebUI Deployment — SHI-NAIRR SRP 2026

> GPU-accelerated Open WebUI with Ollama backend for conversational AI and RAG (Retrieval Augmented Generation). Deployed on Jetstream2 for instructor use.

---

## 📌 Quick Access

| | |
|---|---|
| **URL** | http://149.165.173.45:3000 |
| **Login** | Sign up with email |
| **GPU** | 2x NVIDIA GRID A100X-10C (10GB each, CUDA 12.2) |
| **Version** | Open WebUI v0.9.6 |

---

## 🏗️ Architecture
Instructor/Student Browser
│
▼
Open WebUI (port 3000)
│
▼
Ollama 0.1.24 (port 11434)
│
▼
2x NVIDIA GRID A100X-10C GPUs

---

## 🧠 Deployed Models

| Model | Size | Use Case |
|-------|------|----------|
| `mistral:latest` | 4.4GB | General purpose, best performance |
| `llama2:latest` | 3.8GB | General purpose |
| `codellama:latest` | 3.8GB | Code generation |

> ⚠️ Use Ollama 0.1.24 specifically - newer versions have CUDA kernel compatibility issues with GRID A100X.

---

## ⚙️ Initial Setup

### Step 1: Run Ollama (GPU-accelerated)
```bash
docker run -d \
  --gpus all \
  -p 11434:11434 \
  -v ollama:/root/.ollama \
  --name ollama \
  ollama/ollama:0.1.24
```

### Step 2: Pull Models
```bash
docker exec ollama ollama pull mistral
docker exec ollama ollama pull llama2
docker exec ollama ollama pull codellama
```

### Step 3: Run Open WebUI
```bash
docker run -d \
  -p 3000:8080 \
  -e OLLAMA_BASE_URL=http://host.docker.internal:11434 \
  -e ENABLE_SIGNUP=true \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

### Step 4: Create Admin Account
1. Visit http://149.165.173.45:3000
2. First account created becomes admin automatically

### Step 5: Enable Sign-ups
1. Go to **Admin Panel → Settings → General**
2. Toggle **Enable New Sign Ups** → ON
3. Click **Save**

---

## 👥 Managing Users

### Enable/Disable Sign-ups
- Admin Panel → Settings → General → Enable New Sign Ups

### Change User Role
- Admin Panel → Users → Click on user → Change role
- Roles: **Admin**, **User**, **Pending**

---

## 📚 RAG (Document Chat)

### Upload Documents
1. Click **+** (attachment) in chat
2. Select **Attach Knowledge**
3. Upload PDF or document
4. Use `#DocumentName` in chat to reference it

---

## 🔧 Common Commands

```bash
# Check status
docker ps | grep -E "ollama|open-webui"

# Check GPU usage
docker exec ollama nvidia-smi

# List models
docker exec ollama ollama list

# Add new model
docker exec ollama ollama pull <model-name>

# View logs
docker logs open-webui --tail 50
docker logs ollama --tail 50

# Restart services
docker restart ollama
docker restart open-webui
```

---

## ✅ Verify GPU Access

```bash
docker exec ollama nvidia-smi
# Expected: 2x GRID A100X-10C, 10240MiB each
```

---

## ⚠️ Important Notes

- Use **Ollama 0.1.24** only - newer versions fail with CUDA kernel errors on GRID A100X
- HTTP only for now - HTTPS setup pending
- First registered user becomes admin automatically

---

## Maintainers

| Name | GitHub |
|------|--------|
| Samson Quaye | @qsamson |
| Ren Butler | @darrendbutler |
| Prof. Edgar Lobaton | @lobaton |
---

*SHI-NAIRR SRP 2026 — NC State University, ECE Department*
