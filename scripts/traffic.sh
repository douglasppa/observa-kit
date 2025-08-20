#!/usr/bin/env bash
# Uso:
#   ./scripts/traffic.sh start [URL] [BURST] [SLEEP]
#   ./scripts/traffic.sh stop
#
# Exemplos:
#   ./scripts/traffic.sh start http://localhost:8000/checkout 20 0.5
#   ./scripts/traffic.sh stop
#
# O loop gera ~ (BURST * 2) req/s (porque dorme SLEEP e repete ~2x/seg se SLEEP=0.5)

set -euo pipefail

ACTION="${1:-}"
URL="${2:-http://localhost:8000/checkout}"
BURST="${3:-20}"     # quantas requisições paralelas por ciclo
SLEEP="${4:-0.5}"    # pausa entre ciclos

PID_FILE="/tmp/observa-traffic.pid"

start() {
  if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "Já está rodando (PID $(cat "$PID_FILE")). Pare antes de iniciar de novo."
    exit 1
  fi
  echo "Iniciando tráfego em $URL (BURST=$BURST, SLEEP=${SLEEP}s)..."
  # roda em background e salva o PID
  nohup bash -c "
    while true; do
      for i in \$(seq 1 $BURST); do
        curl -s \"$URL\" >/dev/null &
      done
      wait
      sleep $SLEEP
    done
  " >/dev/null 2>&1 & echo $! > "$PID_FILE"
  echo "✅ Rodando em background (PID $(cat "$PID_FILE"))."
}

stop() {
  if [[ -f "$PID_FILE" ]]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
      kill "$PID" || true
      rm -f "$PID_FILE"
      echo "🛑 Tráfego parado (PID $PID)."
      exit 0
    fi
  fi
  echo "Nenhum gerador encontrado. Se necessário, finalize processos manuais de curl."
}

case "$ACTION" in
  start) start ;;
  stop)  stop  ;;
  *) echo "Uso: $0 {start|stop} [URL] [BURST] [SLEEP]"; exit 1 ;;
esac
