# Omni-Token Optimizer Suite

Uma suíte universal de otimização de tokens de uso geral (código, escrita, pesquisa e análise) que combina **Hooks Locais de Custo Zero** com **Skills e Sub-Skills de Prompts** fundamentadas em 6 estudos científicos empíricos e nas técnicas dos projetos **Caveman**, **Punisher Mode** e **Ponytail**.

## Arquitetura do Repositório

```text
omni-token-optimizer/
├── SKILL.md                          # Master Skill (Orquestrador Principal)
├── AGENTS.md                         # Regras rápidas para arquivos de sistema/agente
├── subskills/
│   ├── 01-terse-communication.md     # Estilo conciso e execução sem confirmação (Caveman + Punisher)
│   ├── 02-lazy-execution.md          # Desenvolvimento enxuto, YAGNI e papéis (Ponytail + Refactoring)
│   ├── 03-observation-trimmer.md     # Corte de observações e limpeza de ferramentas (CoACT + TRC)
│   ├── 04-state-compactor.md         # Memória de estado estruturada (ACON + TRACE)
│   └── 05-prompt-budgeting.md        # Alocação orçamentária de prompts (LLMLingua)
└── hooks/
    ├── observation_trimmer.py        # Hook local Python para truncar logs/ferramentas antes da API
    └── context_monitor.py            # Hook local Python para monitorar limite de tokens da sessão
```

## Como Instalar e Usar

1. **Agentes baseados em Skills (Claude Code, Cursor, Command Code, OpenCode)**:
   - Copie o arquivo `SKILL.md` ou importe a pasta `subskills/` para a pasta `.claude/skills/` ou diretório equivalente do seu agente.
2. **Hooks Locais (Opcional - Custo Zero de Tokens)**:
   - Integre `hooks/observation_trimmer.py` no seu fluxo de execução de ferramentas bash/terminal para truncar logs automaticamente antes que atinjam o LLM.

## Fundamentação Científica & Repositórios

- **Caveman & Punisher Mode**: Comunicação concisa e eliminação de confirmações intermediárias.
- **Ponytail**: Redução de código escrito, reuso e edição em patch/diff (-53% código, -45% tokens).
- **Study on Code Smells & CoT**: Refatoração prévia e Responsibility Tuning reduzem o raciocínio CoT em ~50%.
- **CoACT & TRC**: Preservação da próxima ação e remoção de ferramentas antigas salvam até 55.9% em observações.
- **ACON & TRACE**: Memória de estado estruturada (`VARS`, `TODO`, `GUARDRAILS`) reduz tokens de pico de 22.6k para 7.2k.
- **LLMLingua**: Alocação seletiva de orçamento de prompt mantendo instruções centrais.
