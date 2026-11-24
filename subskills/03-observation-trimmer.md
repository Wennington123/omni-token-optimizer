# Sub-Skill 03: Observation Trimming & Tool-Result Clearing (CoACT + TRC)

## 1. Preservação da Próxima Ação (CoACT - Next-Action Preservation)
Ao receber retornos de ferramentas (logs de terminal, respostas de API, consultas a banco de dados):
- Truncar saídas mantendo **apenas** os elementos essenciais para a próxima decisão:
  - Mensagens e stack traces de erro.
  - Caminhos de arquivo modificados/lidos.
  - IDs de recursos, tokens de acesso ou parâmetros de API.
  - Números de linhas relevantes.
- Elimine barras de progresso, logs de sucesso repetitivos e saídas limpas de compilação.

## 2. Limpeza de Saídas Antigas (Tool-Result Clearing - TRC)
- Mantenha na íntegra apenas as 2-3 observações de ferramentas mais recentes.
- Substitua saídas de ferramentas mais antigas no histórico por placeholders no formato `[tool output cleared: exit 0]` ou `[output cleared: 142 lines]`.
- Isso preserva o alinhamento de *KV-Cache* e reduz o custo acumulado de tokens em até 43% sem degradar a taxa de sucesso.
