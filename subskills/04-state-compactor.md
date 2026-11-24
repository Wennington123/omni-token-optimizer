# Sub-Skill 04: Structured State Compaction (ACON + TRACE)

## 1. Gatilho de Compactação (Threshold Trigger)
Quando o histórico da sessão ultrapassar o limite orçamentário configurado (ex.: 4.096 ou 8.000 tokens), o agente deve acionar a compaginação de estado.

## 2. Estrutura Obrigatória de Memória (<HISTORY_SUMMARY>)
Substitua o histórico acumulado pelo seguinte bloco estruturado:

```markdown
<HISTORY_SUMMARY>
1. REASONING
- Breve paráfrase do progresso central e decisões tomadas.

2. VARS
| name | value | purpose |
|------|-------|---------|
- Registre todas as variáveis de runtime, tokens de acesso, IDs e caminhos de arquivo necessários para os próximos passos.

3. TODO
- Lista pontual das ações pendentes imediatas.

4. COMPLETED
- Lista do que já foi concluído e verificado.

5. GUARDRAILS
- Lembretes curtos de erros descobertos no ambiente para evitar repetição (ex.: "A API X exige o parâmetro access_token no header").
</HISTORY_SUMMARY>
```

Esta estrutura previne que o agente entre em loops de exploração regressiva e perca o ponto de ancoragem local.
