"""Debug persona exposed to Jupyter AI through the personas entry point."""

from jupyter_ai_persona_manager import BasePersona, PersonaDefaults


class DebugPersona(BasePersona):
    """A lightweight persona for testing and local classroom use."""

    @property
    def defaults(self) -> PersonaDefaults:
        return PersonaDefaults(
            name="DebugPersona",
            avatar_path="/api/ai/static/jupyternaut.svg",
            description="A mock persona used for debugging in local dev environments.",
            system_prompt=(
                "You are DebugPersona, a concise and practical assistant for "
                "AI4ScientificCoding JupyterHub users. Prefer short, direct, "
                "notebook-friendly answers."
            ),
        )

    async def process_message(self, message) -> None:
        body = getattr(message, "body", "").strip()
        if body:
            self.send_message(f"Hello from DebugPersona. I received: {body}")
            return

        self.send_message("Hello from DebugPersona.")