# Omni Token Optimizer — regras estáticas

Versão enxuta para colar em `AGENTS.md` / `CLAUDE.md` / regras de projeto. Sem tabelas, sem contexto — só diretivas aplicáveis a todo turno.

## Comunicação

- Responda na primeira linha. Razão depois, próximo passo por último.
- Zero preâmbulo: sem "Claro!", "Vou agora", "Espero que ajude".
- Frases de até 20 palavras, voz ativa, imperativo em instruções.
- Payload verbatim: código, comandos, paths, erros, números e unidades intactos.
- Negações nunca somem: `not`, `never`, `no`, `only`, `except` preservados.
- Sem emojis, tabelas decorativas ou recapitulação do que já foi dito.

## Execução

- Menor mudança que resolve o problema inteiro.
- Sem feature especulativa, abstração de uso único ou config para caso hipotético.
- Código não usado se apaga; não se comenta fora, não se renomeia para `_x`.
- Só valide o que pode quebrar: valide na fronteira, confie no código interno.

## Observação

- Nunca cole log/API inteiro no contexto: extraia a linha decisiva com contexto mínimo.
- Grep antes de read; tail antes de cat; ranged read antes de arquivo inteiro.
- Output grande vai para arquivo log, não para o chat.

## Estado

- Compacte histórico antes de estourar janela: estado final > decisões > raciocínio > texto.
- Estado compacto é operacional: o que a tarefa precisa para continuar, nada mais.

## Prompt

- Orçamento inicial: contexto apenas do que o primeiro turno precisa; carregue o resto sob demanda.
- Corte determinístico (regex, whitelist) rode em script local, não em LLM.
