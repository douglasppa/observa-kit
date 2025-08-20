# Runbook — {{ALERTA}}

**Trigger:** {{CONDICAO}}  
**Owner:** {{RESPONSAVEL}}  
**Severidade:** {{SEVERIDADE}}  
**Serviço:** {{SERVICO}} (ex.: Checkout)

## Passo a passo (3 checks rápidos)
1. **Logs**: verificar últimos erros e códigos 5xx no período afetado.
2. **Mudanças recentes**: deploys, configs, dependências (pagamentos, ERP, DB).
3. **Dependências**: status de gateway, DB, fila/mensageria, rede.

## Ação imediata
- {{ACAO_IMEDIATA}} (ex.: alternar para provedor B; aumentar réplicas; pausar job).

## Rollback
- {{COMO_ROLLBACK}} (link para doc/PR/comando).

## Escalonamento
- {{ESCALONAMENTO}} (pessoa/time, WhatsApp/Slack/telefone).

## Fechamento
- Registrar **causa-raiz** (quando conhecida), **tempo de detecção** e **MTTR**.
- Abrir PR/tarefa para correção definitiva e lições aprendidas.