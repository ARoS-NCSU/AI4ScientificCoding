c.ServerProxy.servers = {
    "vscode": {
        "command": [
            "code-server",
            "--auth",
            "none",
            "--bind-addr",
            "0.0.0.0:{port}",
            "--user-data-dir",
            "/home/jovyan/.local/share/code-server",
            "--extensions-dir",
            "/opt/code-server/extensions",
            "/home/jovyan",
        ],
        "timeout": 30,
        "launcher_entry": {
            "enabled": True,
            "title": "VS Code + Cline",
        },
    }
}

# Marimo launcher
c.ServerProxy.servers["marimo"] = {
    "command": ["marimo", "edit", "--no-token", "--host", "0.0.0.0", "--port", "{port}"],
    "launcher_entry": {
        "enabled": True,
        "title": "Marimo"
    }
}
