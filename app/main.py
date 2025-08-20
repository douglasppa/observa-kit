import time
import random
import asyncio
from typing import Dict, Any

from fastapi import FastAPI, Request, Response
from fastapi.responses import JSONResponse
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = FastAPI(title="Observa Demo App", version="1.0.0")

# Simulation flags
_simulate_error_until = 0.0
_simulate_slow_until = 0.0

# Metrics
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["route", "method", "status"],
)
REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "Request latency (seconds)",
    ["route", "method"],
    buckets=(0.05, 0.1, 0.2, 0.3, 0.5, 0.8, 1.0, 1.5, 2.0, 3.0, 5.0)
)

CHECKOUT_SUCCESS = Counter(
    "checkout_transactions_total",
    "Total successful checkout transactions",
)
CHECKOUT_FAILURE = Counter(
    "checkout_failures_total",
    "Total failed checkout attempts",
)

ALERTS_RECEIVED = Counter(
    "alerts_received_total",
    "Total alerts received from Alertmanager webhooks",
    ["alertname", "status"]
)

def _route_label(request: Request) -> str:
    try:
        return request.scope.get("route").path  # template path
    except Exception:
        return request.url.path

@app.middleware("http")
async def metrics_middleware(request: Request, call_next):
    route = _route_label(request)
    method = request.method
    start = time.perf_counter()
    status_code = 500
    try:
        response: Response = await call_next(request)
        status_code = response.status_code
        return response
    finally:
        elapsed = time.perf_counter() - start
        REQUEST_LATENCY.labels(route=route, method=method).observe(elapsed)
        REQUEST_COUNT.labels(route=route, method=method, status=str(status_code)).inc()

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.get("/checkout")
async def checkout():
    now = time.time()
    if now < _simulate_error_until:
        CHECKOUT_FAILURE.inc()
        return JSONResponse({"ok": False, "error": "simulated failure"}, status_code=500)

    base = random.uniform(0.1, 0.3)
    if now < _simulate_slow_until:
        base += random.uniform(0.8, 1.2)
    await asyncio.sleep(base)

    CHECKOUT_SUCCESS.inc()
    return {"ok": True, "latency_s": round(base, 3)}

@app.get("/simulate/error")
async def simulate_error(minutes: int = 2):
    global _simulate_error_until
    _simulate_error_until = time.time() + minutes * 60
    return {"simulating": "error", "minutes": minutes}

@app.get("/simulate/slow")
async def simulate_slow(minutes: int = 2):
    global _simulate_slow_until
    _simulate_slow_until = time.time() + minutes * 60
    return {"simulating": "slow", "minutes": minutes}

@app.post("/alerts")
async def alerts_webhook(payload: Dict[str, Any]):
    status_val = payload.get("status", "unknown")
    for alert in payload.get("alerts", []):
        name = alert.get("labels", {}).get("alertname", "unknown")
        ALERTS_RECEIVED.labels(alertname=name, status=status_val).inc()
    return {"received": True}

@app.get("/metrics")
async def metrics():
    data = generate_latest()
    return Response(content=data, media_type=CONTENT_TYPE_LATEST)