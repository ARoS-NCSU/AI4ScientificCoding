# NCState AI Workshop — JupyterHub Deployment

> Standalone JupyterHub for the NCState AI Workshop. Each participant gets an isolated GPU-backed container with JupyterLab and Marimo pre-configured with Jetstream LLM — no setup required.

---

## 📌 Quick Access

| | |
|---|---|
| **Workshop Hub URL** | https://ncstate-ai-workshop.nairr240257.projects.jetstream-cloud.org |
| **Login** | GitHub OAuth (NCState-AI-Workshop org) |
| **Default Model** | gpt-oss-120b |
| **Fallback Model** | Llama-4-Scout |
| **GPU** | NVIDIA GRID A100X-10C — 10GB VRAM — CUDA 12.2 |

---

## 🏗️ Architecture

```
Participant Browser
       │
       ▼
JupyterHub (GitHub OAuth — NCState-AI-Workshop org)
       │
       ▼
DockerSpawner
       │
       ▼
Per-User Container (workshop-notebook:latest)
  ├── JupyterLab
  └── Marimo (AI pre-configured → Jetstream LLM)
       │
       ▼
Jetstream LLM API (gpt-oss-120b / Llama-4-Scout)
```

---

## 📁 Files in This Folder

| File | Purpose |
|------|---------|
| `Dockerfile` | Builds the participant container with JupyterLab, Marimo, and Jetstream LLM config |
| `marimo.toml` | Marimo AI config — sets Jetstream as the AI provider |
| `jupyterhub_config.py` | JupyterHub config with GitHub OAuth, DockerSpawner, and GPU access |
| `docker-compose.yml` | Runs JupyterHub and Caddy together |
| `Caddyfile` | HTTPS reverse proxy — automatic Let's Encrypt certificates |
| `.env.example` | Template for credentials — copy to `.env` and fill in real values |

---

## 🖥️ How Participants Use Marimo AI

1. Log into the workshop hub with your GitHub account
2. Click the **Marimo [↗]** tile in the JupyterLab launcher
3. Create a new notebook
4. Click **Generate with AI** or use the AI assistant panel
5. Type your prompt — powered by **gpt-oss-120b** on Jetstream GPU cluster

---

## 🤖 LLM Models

| Model | Role |
|-------|------|
| `gpt-oss-120b` | Default — Marimo AI |
| `Llama-4-Scout` | Fallback — all tools |

---

## ⚙️ Deployment Steps

```bash
# 1. Create Docker network
docker network create jupyterhub-network

# 2. Point Docker to the attached volume and add NVIDIA runtime
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "data-root": "/media/volume/workshop-volume/docker",
  "runtimes": {
    "nvidia": {
      "path": "nvidia-container-runtime",
      "runtimeArgs": []
    }
  }
}
EOF
sudo systemctl restart docker

# 3. Create .env from the example file
cp .env.example .env
# Fill in GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET, and JUPYTERHUB_CRYPT_KEY

# 4. Build the workshop image
docker build -t workshop-notebook:latest .

# 5. Launch
docker-compose --env-file .env up -d
```

---

## 👥 Managing Access

Anyone added to the **NCState-AI-Workshop** GitHub organisation gets access automatically.

To add a participant:
1. Go to `https://github.com/orgs/NCState-AI-Workshop/people`
2. Click **Invite member** and enter their GitHub username

To remove access, remove them from the organisation.

---

## ⚠️ Known Issues

| Issue | Solution |
|-------|---------|
| Marimo tile not showing | Remove old container and log in again |
| AI not responding | Switch to `Llama-4-Scout` in Marimo settings |
| 400 OAuth state missing | Use a private/incognito window |
| Disk full during image build | Run `docker system prune -f` before rebuilding |

---

## 🔐 Security Notes

- Never commit the real `.env` file — use `.env.example` as the template
- Credentials live only in `.env` on the VM
- Each participant container is fully isolated
- HTTPS enforced via Caddy with automatic Let's Encrypt certificates

---

*SHI-NAIRR SRP 2026 — NC State University, ECE Department*
