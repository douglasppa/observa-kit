# Makefile para trocar entre presets de alertas e recarregar o Prometheus
# Uso:
#   make demo    # copia alerts-demo.yml -> alerts.yml e recarrega
#   make prod    # copia alerts-prod.yml -> alerts.yml e recarrega
# Variáveis:
#   PROM_URL=http://localhost:9090  (padrão)

PROM_URL ?= http://localhost:9090
ALERTS_DIR := prometheus

.PHONY: demo prod

demo:
	cp $(ALERTS_DIR)/alerts-demo.yml $(ALERTS_DIR)/alerts.yml
	@curl -s -X POST $(PROM_URL)/-/reload >/dev/null && echo "Trocado para DEMO e Prometheus recarregado."

prod:
	cp $(ALERTS_DIR)/alerts-prod.yml $(ALERTS_DIR)/alerts.yml
	@curl -s -X POST $(PROM_URL)/-/reload >/dev/null && echo "Trocado para PROD e Prometheus recarregado."
