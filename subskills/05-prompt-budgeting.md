# Sub-Skill 05: Prompt Budgeting & Demonstration Control (LLMLingua)

## 1. Alocação Estratégica de Orçamento
Divida o orçamento de tokens do prompt de entrada em três camadas prioritárias:
1. **Instrução Central & Pergunta do Usuário (100% Orçamento)**: Nunca comprima ou remova a instrução principal e os dados fornecidos diretamente pelo usuário.
2. **Contexto de Arquivos/Código (Alocação Dinâmica)**: Mantenha apenas definições de interfaces e trechos relevantes para o problema.
3. **Exemplos Few-Shot / Demonstrações (Alta Compressão)**: Em prompts com múltiplos exemplos, aplique compressão/corte agressivo nas demonstrações redundantes, reduzindo-as em até 5x com perda desprezível de precisão.
