import { Plugin } from "@opencode/plugin"
import { estimateTokens, trimContent, type TrimOptions } from "./trim.ts"

interface Options {
  contextThreshold?: number
  contextRewarnRatio?: number
  contextRewarnMs?: number
  trimTools?: string | string[]
  trimMaxChars?: number
  trimMaxLines?: number
  debug?: boolean
}

const num = (value: unknown, fallback: number) => {
  const n = Number(value)
  return Number.isFinite(n) && n > 0 ? n : fallback
}

const list = (value: string | string[] | undefined) =>
  (Array.isArray(value) ? value : (value ?? "").split(","))
    .map((item) => item.trim())
    .filter(Boolean)

export default Plugin.define({
  id: "omni-token-optimizer",
  async setup(ctx) {
    const options = (ctx.options ?? {}) as Options

    // Context monitor (subskill 04): warn when the assembled history gets big.
    const contextThreshold = num(
      options.contextThreshold ?? process.env.OMNI_TOKEN_THRESHOLD,
      120_000,
    )
    const rewarnRatio = num(options.contextRewarnRatio, 1.25)
    const rewarnMs = num(options.contextRewarnMs, 120_000)

    // Observation trimmer (subskill 03): only noisy tools, only past a size guard.
    const trimTools = new Set(list(options.trimTools ?? process.env.OMNI_TRIM_TOOLS ?? "shell"))
    const trimOptions: TrimOptions = {
      maxChars: num(options.trimMaxChars ?? process.env.OMNI_TRIM_MAX_CHARS, 6_000),
      maxLines: num(options.trimMaxLines ?? process.env.OMNI_TRIM_MAX_LINES, 160),
    }
    const debug = options.debug === true || process.env.OMNI_DEBUG === "1"

    const lastWarn = new Map<string, { tokens: number; at: number }>()

    await ctx.tool.hook("execute.after", (event) => {
      if (event.status !== "completed") return
      if (!trimTools.has(event.tool)) return
      const content = trimContent(event.result.content as Parameters<typeof trimContent>[0], trimOptions)
      if (!content) return
      if (debug) console.log(`[omni-token-optimizer] trimmed ${event.tool} (${event.id})`)
      event.result = { ...event.result, content: content as typeof event.result.content }
    })

    await ctx.session.hook("context", (event) => {
      const tokens = estimateTokens(event.messages)
      if (debug) console.log(`[omni-token-optimizer] session ${event.sessionID}: ~${tokens} tokens`)
      if (tokens < contextThreshold) return

      const previous = lastWarn.get(event.sessionID)
      const now = Date.now()
      if (previous && tokens < previous.tokens * rewarnRatio && now - previous.at < rewarnMs) return

      if (lastWarn.size > 200) lastWarn.clear()
      lastWarn.set(event.sessionID, { tokens, at: now })
      if (debug) console.log(`[omni-token-optimizer] context warning injected (~${tokens} tokens)`)

      event.system.push({
        type: "text",
        text:
          `[TOKEN_WARNING] Session history estimated at ~${tokens} tokens (limit: ${contextThreshold}). ` +
          "RECOMMENDED ACTION: summarize the state in a <HISTORY_SUMMARY> block (REASONING, VARS, TODO, COMPLETED, GUARDRAILS) " +
          "— subskills/04-state-compactor.md — and replace older tool results with [output cleared] placeholders.",
      })
    })

    if (debug) {
      console.log(
        `[omni-token-optimizer] loaded (threshold=${contextThreshold}, trimTools=${[...trimTools].join(",")}, ` +
          `maxChars=${trimOptions.maxChars}, maxLines=${trimOptions.maxLines})`,
      )
    }

    return () => lastWarn.clear()
  },
})
