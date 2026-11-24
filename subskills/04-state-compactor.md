# 04 — State Compactor

**Origem:** ACON (state compaction agêntica) + TRACE (protocolo de memória de estado com prioridade).
**Gatilho:** sessão longa, histórico acumulado, pré-compactação, handoff entre agentes, retomada após contexto perdido.

## Princípio

Estado compacto é operacional: o que a tarefa precisa para continuar, nada mais. Memória não é arquivo de tudo — é instrução de retomada.

## Ordem de prioridade (TRACE)

Corte de baixo para cima; pare quando couber:

1. **Payload verbatim** — código em aberto, comandos, paths, decisões pendentes. Nunca corta.
2. **Estado atual** — o que existe agora: arquivos mudados, servidores rodando, testes passando/falhando, bloco atual.
3. **Decisões tomadas** — com razão em uma linha ("usou SQLite: zero infra"). Sem razão, a decisão morre na próxima dúvida.
4. **Raciocínio essencial** — só o que muda passos futuros. O raciocínio que levou a caminho morto vira uma linha: "caminho X descartado: motivo".
5. **Histórico de conversa** — primeiro a morrer. Turnos concluídos comprimem para resultado ("corrigido bug Y em Z").

## Formato de estado compacto

```markdown
# Estado
Objetivo: <1 linha>
Feito: <bullets de 1 linha, passado>
Bloco: <o que está em andamento agora, com path/comando>
Próximo: <próximo passo concreto>
Bloqueios: <o que falta / erro atual>
Payload: <paths, comandos, erros exatos — verbatim>
```

Cada linha substitui vários turnos. Se uma linha precisa de parágrafo, ainda está inflada.

## Regras

1. **Compacte antes de estourar.** Aos ~70% da janela, reescreva o estado e descarte o histórico. Não espere a compactação automática cortar o que ela não sabe priorizar.
2. **Reescreva, não appende.** Estado compacto é um documento vivo: atualize a linha, não adicione "update:" embaixo. Apêndice é histórico disfarçado.
3. **Handoff autocontido.** Estado passado a outro agente lê sem o histórico. Se o novo agente pergunta "o que é X?", a linha de X estava mal escrita.
4. **Arquivos externos > contexto.** Estado grande demais (diffs, logs, dados) vai para arquivo em disco; contexto guarda path + o que procurar nele.
5. **Sem redundância entre camadas.** O que está no arquivo não repete no contexto; o que está no payload verbatim não parafraseia no estado.
6. **Retomada pós-compactação:** re-derivar estado caro (rodar testes, re-ler config) pode sair mais barato que carregar o histórico que o produziu. Prefira re-observar a re-lembrar quando a observação é barata.

## Anti-padrões

- Estado que descreve o processo ("primeiro tentei A, depois B...") em vez do resultado ("A falhou: motivo; B aplicado: path").
- Duplicar o repositório no contexto: código está no disco, leia quando precisar.
- Estado escrito para humanos, não para o próximo turno do agente.

## Métrica de sucesso

- Estado compacto cabe em dezenas de linhas, independente do tamanho da sessão.
- Retomada a partir do estado compacto produz o mesmo próximo passo que a retomada com histórico completo.
