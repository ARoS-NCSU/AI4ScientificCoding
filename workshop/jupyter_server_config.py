c.ServerProxy.servers["marimo"] = {
    "command": ["marimo", "edit", "--no-token", "--host", "0.0.0.0", "--port", "{port}"],
    "port": 2718,
    "launcher_entry": {
        "enabled": True,
        "title": "Marimo"
    }
}
