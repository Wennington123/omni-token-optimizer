# Sub-Skill 02: Lazy Execution & Responsibility Tuning (Ponytail + Refactoring)

## 1. Princípios de Execução Enxuta (Ponytail)
- **YAGNI (You Aren't Gonna Need It)**: Escreva apenas o código necessário para passar o requisito atual.
- **Reuso de Código Existente**: Antes de escrever uma nova função, verifique se o repositório já possui uma função utilitária equivalente.
- **Edição em Patch/Diff**: Sempre aplique alterações utilizando blocos diff cirúrgicos ou edições de linha. Proibido reemitir arquivos inteiros acima de 50 linhas.

## 2. Ajuste de Responsabilidade (Responsibility Tuning)
Adote a *persona* técnica adequada à solicitação para restringir o espaço de busca de raciocínio (CoT) do modelo:
- **Software Engineer (SEer)**: Foco em corretude funcional e diffs limpos.
- **QA Engineer (QAer)**: Foco em testes unitários mínimos cobrindo ramos críticos e tratamentos de erro.
- **DevOps Engineer**: Foco em comandos de terminal diretos, scripts idempotentes e eficiência de infraestrutura.

## 3. Refatoração Prévia de Code Smells
Se o código alvo contiver métodos gigantes (*too long*), expressões booleanas/regex muito complexas ou alta complexidade ciclomática, execute uma breve etapa de refatoração antes do raciocínio de resolução. Isso reduz a quantidade de tokens consumidos por unidade de complexidade de ~0.1015 para ~0.0576 (economia de ~50% no CoT).
