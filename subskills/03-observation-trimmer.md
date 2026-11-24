# 03 — Observation Trimmer

**Origem:** CoACT (Observation — Action loop: a observação entra no contexto antes da próxima ação) + TRC (Token-Rationed Context).
**Gatilho:** logs de build/teste, respostas de API, resultados de comando, erro de ferramenta — qualquer output que vai virar contexto.

## Princípio

A observação inteira raramente importa; a linha decisiva sempre. Cortar em script local custa 0 token; deixar passar custa leitura + cache + atenção em cada turno seguinte.

## Regras

1. **Extraia, não ingira.** Antes de colar output no contexto, passe por filtro:
   - erro: linha decisiva mais curta + 2–5 linhas de stack imediatamente relevante;
   - log: grep pelo padrão de erro antes de ler; tail antes de cat; ranged read antes de arquivo inteiro;
   - API: só os campos que a decisão usa. Nunca JSON inteiro quando 3 campos bastam.
2. **Output grande vai para arquivo.** Log completo em arquivo (ou output log da ferramenta), não no chat. Referencie path + offset no contexto.
3. **Dedupe.** Stack trace repetido, linha de teste repetida 200×, poll que não mudou: uma ocorrência + contagem (`(×200)`). Nunca 200 ocorrências.
4. **Ranged reads.** Ferramenta que lê arquivo suporta offset/limit — use. Read truncado diz o offset de continuação: continue dali, não releia tudo.
5. **Whitelist de padrões.** Em pipeline, defina regex de sucesso/erro e capture só matches. Ex.: `status|error|fail|panic|exit code` — o resto descarta em script.
6. **Snapshot só do estado atual.** Polling/diff: última observação + delta, não histórico de todas.
7. **Truncamento com marcador.** Cortou? Diga onde e como continuar (`truncated at offset N`, `truncated at line K`). Cortar sem marcador = dado perdido silencioso.
8. **Filtro determinístico em script de 0 token** (ver `hooks/`). LLM resumindo log custa tokens e pode alucinar; `grep`/`sed`/`awk` não.

## Anti-padrões

- Colar traceback inteiro de 400 linhas quando a exceção está na linha 3.
- Ler arquivo de 10k linhas para achar uma função que `grep` acha em 1 linha.
- Re-observar o que não mudou desde a última checagem.

## Métrica de sucesso

- Zero observação repetida idêntica no contexto.
- Toda linha de erro decisiva presente, todo resto cortado.
- Bytes de observação por turno caem uma ordem de grandeza em pipeline longo.
