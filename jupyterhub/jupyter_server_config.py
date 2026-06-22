c.ServerProxy.servers = {
    "vscode": {
        "command": [
            "code-server",
            "--auth",
            "none",
            "--bind-addr",
            "0.0.0.0:8080",
            "/home/jovyan",
        ],
        "port": 8080,
        "launcher_entry": {
            "enabled": True,
            "title": "VS Code + Cline",
        },
    }
}

# Marimo launcher
c.ServerProxy.servers["marimo"] = {
    "command": ["marimo", "edit", "--no-token", "--host", "0.0.0.0", "--port", "{port}"],
    "port": 2718,
    "launcher_entry": {
        "enabled": True,
        "title": "Marimo"
    }
}
