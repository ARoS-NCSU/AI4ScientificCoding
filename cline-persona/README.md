# Cline Teaching Assistant Persona

Custom Neural Networks Teaching Assistant persona for the Cline VS Code extension and CLI.

## What it provides

- `ClineTutorPersona` — default tutor using configured model
- `GptOssClineTutorPersona` — tutor pinned to gpt-oss-120b
- `LlamaScoutClineTutorPersona` — tutor pinned to Llama-4-Scout

## Install

The notebook image installs this package from the repository source tree:

```bash
pip install ./cline-persona
```

## Usage

The persona is applied automatically on container start via `start-code-server.sh`.
It writes custom instructions to `~/.cline/data/globalState.json` (VS Code extension)
and `.clinerules` (CLI).

## Updating

After changing the persona, rebuild the notebook image:

```bash
docker build -f jupyterhub/Dockerfile.notebook -t ai4scientificcoding-notebook:latest .
```
