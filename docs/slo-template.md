# SLO — {{SERVICO}} (ex.: Checkout)

## Contexto
Usuário-alvo: {{USUARIO}} (ex.: cliente B2C)  
Jornada: {{JORNADA}} (ex.: pedido → pagamento → confirmação)

## SLIs (indicadores)
- **Latência** (p95) < **{{LATENCIA_MS}} ms**
- **Erros** < **{{ERROS_PCT}} %** do total de requisições

## SLO (alvo)
- **Disponibilidade/Desempenho:** {{ALVO_PCT}}% das requisições cumprindo SLIs por mês.

## Orçamento de erro
- {{ORCAMENTO}}% ao mês. Se estourado: congelar lançamentos e priorizar correções.

## Medição
- Fonte: Prometheus (métricas `http_request_duration_seconds_bucket`, `http_requests_total`)
- Janela: móvel de 28–30 dias.