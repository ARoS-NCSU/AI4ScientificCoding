# Jupyter AI Persona Package

This directory contains the installable package that exposes a custom Jupyter AI persona for the JupyterHub notebook image.

## What it provides

- `jupyter_ai_jupyternaut.DebugPersona`
- A `jupyter_ai.personas` entry point so Jupyter AI can discover the persona after installation

## Install

The notebook image installs this package directly from the repository source tree:

```bash
pip install ./jupyter-ai
```

## Notes

- Jupyter AI only discovers personas that are installed in the same Python environment as the notebook server.
- After changing the entry point or persona code, rebuild the notebook image and restart the user's server.- Jupyter AI personas are discovered from Python entry points in the notebook server environment, under the `jupyter_ai.personas` group.
- For JupyterHub, install the persona package into the user notebook image, not just the hub container.
- `jupyter-ai/persona.py` in this repo is currently a draft scaffold and is not yet a complete installable persona module.


Jupyter AI will only discover a custom persona if it is part of an installed Python package in the notebook server environment. In this repo, jupyter-ai/persona.py is just a draft, and jupyter-ai/pyproject.toml is where the persona entry point should be registered.

The working pattern is:

1. Put the persona class in an importable module, not just a loose file.
2. Register it under the Jupyter AI persona entry-point group.
3. Install that package into the user notebook image used by JupyterHub.
4. Point DockerSpawner at that image so every spawned user server gets the persona.