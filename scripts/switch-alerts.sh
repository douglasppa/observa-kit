#!/usr/bin/env bash
# scripts/switch-alerts.sh — alternativa ao Makefile
# Uso: ./scripts/switch-alerts.sh demo|prod
set -euo pipefail
MODE="${1:-}"
PROM_URL="${PROM_URL:-http://localhost:9090}"
if [[ "$MODE" == "demo" ]]; then
  cp prometheus/alerts-demo.yml prometheus/alerts.yml
elif [[ "$MODE" == "prod" ]]; then
  cp prometheus/alerts-prod.yml prometheus/alerts.yml
else
  echo "Uso: $0 {demo|prod}"; exit 1
fi
curl -s -X POST "${PROM_URL}/-/reload" >/dev/null
echo "Trocado para ${MODE^^} e Prometheus recarregado."
