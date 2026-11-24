# 05 — Prompt Budgeting

**Origem:** LLMLingua (compressão de prompt por perplexidade) + orçamento de contexto inicial.
**Gatilho:** antes da primeira chamada — system prompt, docs embutidas, few-shots, regras estáticas, ferramentas carregadas.

## Princípio

O contexto inicial é fixo em cada turno da sessão: cada byte economizado lá multiplica por todo turno. Carregue no prompt só o que o primeiro turno precisa; o resto carrega sob demanda.

## Orçamento

Reserve a janela antes de encher:

| Faixa | Destino |
|---|---|
| ~10% | system prompt / regras estáticas (use `AGENTS.md` enxuto, não o manual completo) |
| ~15% | ferramentas/schemas declarados (declare só as que o domínio usa) |
| ~25% | contexto da tarefa: código e dados essenciais ao primeiro turno |
| ~40% | espaço de trabalho: observações, raciocínio e iterações |
| ~10% | folga para resposta e margem de segurança |

Ajuste as faixas ao domínio; mantenha a folga.

## Regras

1. **Lazy loading de instruções.** Skill/manifest carrega metadados; o corpo completo carrega só quando o domínio exige. Manifest não é skill carregada.
2. **Regras estáticas versionadas duas vezes:** `AGENTS.md` enxuto (sempre carregado) aponta para o guia completo (carregado sob demanda). Nunca cole o guia inteiro no system prompt.
3. **Few-shots mínimos.** 1–3 exemplos curtos que cobrem os casos divergentes valem mais que 10 exemplos parecidos. Exemplo repetido é token queimado.
4. **Compressão seletiva (LLMLingua-estilo).** Comprima onde a perplexidade é baixa (conectivos, repetição de template, boilerplate) e preserve onde é alta (nomes, paths, valores, negações, código). Nunca comprima payload verbatim — se não pode regenerar byte a byte, não comprima.
5. **Deduplicação inter-documento.** Mesma regra em 3 docs? Uma vira fonte da verdade, as outras apontam. Regras repetidas divergem na manutenção e custam tripla leitura.
6. **Cache amigável.** Prefixo estável primeiro (regras, ferramentas), conteúdo volátil depois. Contexto ordenado por estabilidade maximiza cache hit e reduz custo real.
7. **Ferramentas não declaradas não existem.** Remover da declaração é mais barato que descrever "não use X".
8. **Corte determinístico em script** (regex, whitelist, dedupe por hash) antes de qualquer compressão por LLM (ver `hooks/`). Script é gratuito e reversível.

## Anti-padrões

- System prompt com manual completo de todas as skills "por garantia".
- Contexto do arquivo inteiro quando a função basta.
- Documentação de ferramenta embutida que o modelo já conhece (API pública estável — nome basta).

## Métrica de sucesso

- Contexto inicial cabe na faixa de orçamento com folga sobrando.
- Nenhum payload verbatim comprimido; nenhuma regra conflitante duplicada.
- Cache hit alto: prefixo estável entre turnos.
