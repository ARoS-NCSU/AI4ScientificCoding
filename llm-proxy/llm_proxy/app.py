from __future__ import annotations

import json
import os
import threading
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import httpx
from fastapi import FastAPI, Request, Response

UPSTREAM_BASE_URL = os.environ.get(
	"LLM_UPSTREAM_BASE_URL",
	os.environ.get("OPENAI_BASE_URL", "https://llm.jetstream-cloud.org/v1"),
).rstrip("/")
LOG_DIR = Path(os.environ.get("LLM_LOG_DIR", "/var/log/llm-proxy"))
LOG_DIR.mkdir(parents=True, exist_ok=True)
USER_NAME = os.environ.get("JUPYTERHUB_USER") or os.environ.get("USER") or "unknown"
LOG_FILE = LOG_DIR / f"{USER_NAME}.jsonl"

app = FastAPI(title="AI4ScientificCoding LLM Logging Proxy")
client = httpx.AsyncClient(timeout=httpx.Timeout(300.0, connect=30.0))
log_lock = threading.Lock()


def _decode_json_or_text(raw: bytes) -> Any:
	if not raw:
		return None
	try:
		return json.loads(raw)
	except Exception:
		return raw.decode("utf-8", errors="replace")


def _filtered_headers(headers: httpx.Headers) -> dict[str, str]:
	hop_by_hop = {
		"connection",
		"keep-alive",
		"proxy-authenticate",
		"proxy-authorization",
		"te",
		"trailers",
		"transfer-encoding",
		"upgrade",
		"content-length",
	}
	return {
		key: value
		for key, value in headers.items()
		if key.lower() not in hop_by_hop
	}


def _append_log(event: dict[str, Any]) -> None:
	line = json.dumps(event, ensure_ascii=True, sort_keys=True)
	with log_lock:
		with LOG_FILE.open("a", encoding="utf-8") as handle:
			handle.write(line + "\n")


@app.on_event("shutdown")
async def _shutdown_client() -> None:
	await client.aclose()


@app.get("/")
async def healthcheck() -> dict[str, str]:
	return {"status": "ok", "upstream": UPSTREAM_BASE_URL, "user": USER_NAME}


@app.api_route("/v1/{path:path}", methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "HEAD"])
async def proxy(path: str, request: Request) -> Response:
	started_at = time.perf_counter()
	body = await request.body()
	request_payload = _decode_json_or_text(body)
	upstream_url = f"{UPSTREAM_BASE_URL}/{path}"
	if request.url.query:
		upstream_url = f"{upstream_url}?{request.url.query}"

	headers = dict(request.headers)
	headers.pop("host", None)
	headers.pop("content-length", None)

	try:
		upstream_response = await client.request(
			request.method,
			upstream_url,
			content=body,
			headers=headers,
		)
		response_body = upstream_response.content
		response_payload = _decode_json_or_text(response_body)
		status_code = upstream_response.status_code
		response_headers = _filtered_headers(upstream_response.headers)
		media_type = upstream_response.headers.get("content-type", "application/json")
	except httpx.HTTPError as exc:
		status_code = 502
		response_body = json.dumps({"error": str(exc)}).encode("utf-8")
		response_payload = {"error": str(exc)}
		response_headers = {"content-type": "application/json"}
		media_type = "application/json"

	elapsed_ms = round((time.perf_counter() - started_at) * 1000, 2)
	log_event = {
		"timestamp": datetime.now(timezone.utc).isoformat(),
		"user": USER_NAME,
		"method": request.method,
		"path": f"/v1/{path}",
		"query": request.url.query,
		"status_code": status_code,
		"duration_ms": elapsed_ms,
		"request": request_payload,
		"response": response_payload,
	}
	_append_log(log_event)

	return Response(
		content=response_body,
		status_code=status_code,
		headers=response_headers,
		media_type=media_type,
	)