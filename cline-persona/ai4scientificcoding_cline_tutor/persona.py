"""Neural Networks Teaching Assistant personas for Cline (VS Code extension and CLI)."""

from __future__ import annotations

import json
import os
from pathlib import Path
from typing import ClassVar

DEFAULT_BASE_URL = "https://llm.jetstream-cloud.org/v1"
DEFAULT_ALLOWED_MODELS = (
    "Kimi-K2.6",
    "gpt-oss-120b",
    "Llama-4-Scout",
)

CLINE_TUTOR_SYSTEM_PROMPT = """
You are a Neural Networks Teaching Assistant at NC State University (SHI-NAIRR SRP 2026).

TEACHING PHILOSOPHY:
- Guide students to discover solutions themselves, never write complete solutions
- Ask Socratic questions to help students think through problems
- Explain concepts clearly before showing any code
- Encourage students to read error messages carefully
- Be encouraging, patient and supportive

WHAT YOU CAN DO:
- Explain what a function is supposed to do conceptually
- Point out which part of the code has an error without fixing it
- Show small unrelated examples to illustrate a concept
- Help debug error messages by explaining what they mean
- Suggest what documentation or resources to read

WHAT YOU CANNOT DO:
- Complete assignment functions directly
- Give away expected test outputs
- Write more than 5 lines of assignment-related code at once

Keep answers concise, practical, and notebook-friendly.
""".strip()

CLINE_RULES = """
# Neural Networks Teaching Assistant Rules (NC State SHI-NAIRR SRP 2026)

- Guide students to discover solutions themselves, never write complete solutions
- Ask Socratic questions to help students think through problems
- Explain concepts clearly before showing any code
- Point out errors without fixing them directly
- Never complete assignment functions (kfold_split, kfold_crossval, polyfit, vector calculus)
- Never give away expected test outputs
- Write no more than 5 lines of assignment-related code at once
- Be encouraging, patient and supportive
- Keep answers concise
""".strip()


def _provider_settings() -> tuple[str, str, str]:
    api_key = (
        os.environ.get("CLINE_API_KEY")
        or os.environ.get("OPENAI_API_KEY")
        or "jetstream"
    )
    base_url = (
        os.environ.get("CLINE_BASE_URL")
        or os.environ.get("OPENAI_BASE_URL")
        or DEFAULT_BASE_URL
    )
    model = (
        os.environ.get("CLINE_MODEL")
        or "gpt-oss-120b"
    )
    return api_key, base_url, model


class BaseClineTutorPersona:
    """Base class for Cline teaching assistant personas."""

    name: ClassVar[str] = "Cline Neural Networks Tutor"
    description: ClassVar[str] = (
        "A Neural Networks Teaching Assistant for NC State SHI-NAIRR SRP 2026."
    )
    fallback_model: ClassVar[str | None] = None

    def apply(self, home_dir: str | Path = "/home/jovyan") -> None:
        """Write Cline config files to bake in the teaching assistant persona."""
        home = Path(home_dir)

        # Write custom instructions to globalState.json (VS Code extension)
        state_file = home / ".cline" / "data" / "globalState.json"
        state_file.parent.mkdir(parents=True, exist_ok=True)

        state = {}
        if state_file.exists():
            try:
                state = json.loads(state_file.read_text())
            except Exception:
                pass

        api_key, base_url, model = _provider_settings()
        if self.fallback_model:
            model = self.fallback_model

        state["customInstructions"] = CLINE_TUTOR_SYSTEM_PROMPT
        state["welcomeViewCompleted"] = True
        state["planModeApiProvider"] = "openai-compatible"
        state["actModeApiProvider"] = "openai-compatible"
        state["openAiBaseUrl"] = base_url
        state["planModeOpenAiModelId"] = model
        state["actModeOpenAiModelId"] = model
        state["azureApiVersion"] = ""

        state_file.write_text(json.dumps(state, indent=2))

        # Write .clinerules (CLI)
        clinerules_file = home / ".clinerules"
        clinerules_file.write_text(CLINE_RULES)

        print(f"Cline tutor persona '{self.name}' applied to {home}")


class ClineTutorPersona(BaseClineTutorPersona):
    """Default Cline tutor persona using the configured model."""


class GptOssClineTutorPersona(BaseClineTutorPersona):
    """Cline tutor persona pinned to gpt-oss-120b."""

    name = "Cline Neural Networks Tutor (GPT OSS)"
    description = "Neural Networks Teaching Assistant using GPT-OSS 120B."
    fallback_model = "gpt-oss-120b"


class LlamaScoutClineTutorPersona(BaseClineTutorPersona):
    """Cline tutor persona pinned to Llama-4-Scout."""

    name = "Cline Neural Networks Tutor (Llama Scout)"
    description = "Neural Networks Teaching Assistant using Llama-4-Scout."
    fallback_model = "Llama-4-Scout"
