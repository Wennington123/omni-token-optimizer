---
name: omni-token-optimizer
description: Orquestrador universal de otimização de tokens. Rotas cada tipo de contexto para a subskill certa — comunicação, execução, observação, estado e orçamento de prompt. Use em toda sessão longa, pipeline agêntico ou contexto apertado.
version: 1.0.0
---

# Omni Token Optimizer

Skill orquestradora. Não faz o trabalho pesado — decide **quem** faz e **quando**.

Cada token de saída é cobrado e lido. Filler custa duas vezes (gerar + ler). Contexto é orçamento finito: cada byte de prompt caro (cache miss, janela limitada, atenção diluída) rouba espaço do payload real.

## Roteamento

Diagnose o tipo de contexto antes de agir e aplique a subskill correspondente:

| Sintoma / Contexto | Subskill | Origem |
|---|---|---|
| Resposta longa, preâmbulos, cerimônia, linguagem inflada | [subskills/01-terse-communication.md](subskills/01-terse-communication.md) | Caveman + Punisher |
| Solução superdimensionada, abstrações prematuras, YAGNI violado | [subskills/02-lazy-execution.md](subskills/02-lazy-execution.md) | Ponytail + Responsibility Tuning |
| Logs gigantes, respostas de API inteiras, outputs repetitivos no contexto | [subskills/03-observation-trimmer.md](subskills/03-observation-trimmer.md) | CoACT + TRC |
| Histórico acumulado, sessão longa, estado redundante antes de compactação | [subskills/04-state-compactor.md](subskills/04-state-compactor.md) | ACON + TRACE |
| Contexto inicial gigante (system prompt, docs, few-shots) antes da primeira chamada | [subskills/05-prompt-budgeting.md](subskills/05-prompt-budgeting.md) | LLMLingua |

## Protocolo

1. **Meça antes de cortar.** Estime o orçamento: janela do modelo, custo/cache, quantidade de turnos esperados. Não otimize às cegas.
2. **Roteie.** Escolha a subskill pelo sintoma, não por preferência. Uma sessão pode ativar várias ao mesmo tempo (ex.: comunicação seca + estado compacto).
3. **Corte por prioridade de payload.** Ordem de preservação: comandos/paths/erros exatos > decisões e estado > raciocínio essencial > estilo > cerimônia. Nada de payload verbatim sai cortado.
4. **Valide pós-corte.** Após qualquer compressão, cheque: negações preservadas? números exatos? paths e nomes de API intactos? Compressão que quebra semântica não é otimização, é corrupção.
5. **Registre economia.** Quando possível, anote tokens antes/depois (ver `hooks/`). Dados batem estimativa.

## Regras duras

- Payload é verbatim: código, comandos, paths, nomes de API, mensagens de erro, números e unidades. Um caractere mudado quebra tudo.
- Negação nunca comprime: `not`, `never`, `no`, `only`, `except` sobrevivem a qualquer corte.
- Clareza vence compressão. Se a frase seca ficar ambígua, use a frase clara.
- Zero cerimônia: sem saudação, sem recapitulação, sem "espero ter ajudado".
- Prefira hooks de 0-token (scripts locais) a tokens de LLM sempre que o corte for determinístico (ver `hooks/`).

## Compatibilidade

Funciona como skill única ou como camada sobre skills existentes (Caveman, Ponytail, etc.): este orquestrador define **quando** cada estilo/diretriz se aplica; a skill original define **como**.
