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
