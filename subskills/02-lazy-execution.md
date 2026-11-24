# 02 — Lazy Execution

**Origem:** Ponytail (dev sênior preguiçoso) + Responsibility Tuning (responsabilidade mínima por camada).
**Gatilho:** escrever código, corrigir bug, adicionar feature, refatorar.

## Princípio

A menor mudança que resolve o problema inteiro — nada além. Todo código extra é dívida: escreve, lê, testa, mantém. Código que não existe não tem bug.

## Regras

1. **Escopo do pedido.** Sem feature extra, refatoração de arredores ou "melhoria" não pedida. Corrigir bug não exige limpar função vizinha. Feature simples não precisa de configurabilidade.
2. **Sem abstração de uso único.** Sem helper, util ou camada para operação que acontece uma vez. Três linhas parecidas no lugar de uma abstração prematura.
3. **Sem design para requisito hipotético.** "E se um dia precisar de X?" — não implementa X hoje. Flag de feature ou shim de retrocompatibilidade só quando impossível mudar o código direto.
4. **Sem validação fantasma.** Não valida cenário impossível. Confia em código interno e garantias de framework. Valida só na fronteira: input de usuário, API externa, parse de dados externos.
5. **Código morto morre.** Sem `_var` não usado, sem re-export de tipo, sem comentário `// removido`. Apaga completo.
6. **Responsability Tuning por camada:** cada módulo carrega exatamente as responsabilidades do seu papel — nem uma a mais (vira deus-object), nem a menos (vaza para vizinho). Quando um módulo cresce além do papel, extrai; quando encolhe a quase nada, inlina e deleta.
7. **Sem comentário** a não ser que pedido. Sem docstring em código que você não tocou. Comentário só onde a lógica não se explica.
8. **Padrão do projeto vence** preferência pessoal: siga convenção existente, formatação e nomenclatura incluídas.

## Teste de aceite (antes de dar a tarefa por pronta)

- Pergunte: "isso resolve o pedido?" — sim.
- Pergunte: "isso resolve algo que ninguém pediu?" — não.
- Pergunte: "posso deletar alguma linha e continuar correto?" — se sim, delete.

## Métrica de sucesso

- Diff mínimo: só arquivos e linhas que a tarefa exige.
- Zero novo nome público (classe/função/config) sem necessidade real.
- Testes passam sem fixture ou mock extra inventado para o caminho feliz.
