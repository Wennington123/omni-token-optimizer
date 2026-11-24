export interface TrimOptions {
  maxChars: number
  maxLines: number
  headLines?: number
  tailLines?: number
  maxErrorLines?: number
}

export type ContentPart = { type: string; text?: string }

const ERROR_RE = /error|exception|failed|fatal|traceback|panic/i

/**
 * CoACT/TRC-style compression: keep the head, the tail, and error lines from the
 * middle. Returns undefined when the text is below the size guard, so callers can
 * leave the original untouched.
 */
export function trimText(text: string, options: TrimOptions): string | undefined {
  const headLines = options.headLines ?? 40
  const tailLines = options.tailLines ?? 30
  const maxErrorLines = options.maxErrorLines ?? 10

  if (text.length <= options.maxChars) return undefined
  const lines = text.split("\n")
  if (lines.length <= options.maxLines) return undefined
  if (lines.length <= headLines + tailLines) return undefined

  const head = lines.slice(0, headLines)
  const tail = lines.slice(-tailLines)
  const middle = lines.slice(headLines, -tailLines)
  const errors = middle.filter((line) => ERROR_RE.test(line)).slice(0, maxErrorLines)

  const kept = [...head]
  if (errors.length > 0) {
    kept.push(`[... ${errors.length} error lines kept from the middle ...]`, ...errors)
  }
  kept.push(`[... omni-token-optimizer: ${middle.length - errors.length} lines / ${text.length} chars trimmed ...]`)
  kept.push(...tail)

  const out = kept.join("\n")
  return out.length < text.length ? out : undefined
}

/**
 * Trims a tool result's `content`, which may be a plain string or a list of parts.
 * Lists containing attachments (images, PDFs) are never touched.
 */
export function trimContent(
  content: string | readonly ContentPart[] | undefined,
  options: TrimOptions,
): string | ContentPart[] | undefined {
  if (typeof content === "string") return trimText(content, options)
  if (!Array.isArray(content) || content.length === 0) return undefined
  if (content.some((part) => part?.type !== "text")) return undefined

  let changed = false
  const next = content.map((part) => {
    const trimmed = typeof part.text === "string" ? trimText(part.text, options) : undefined
    if (trimmed === undefined) return part
    changed = true
    return { ...part, text: trimmed }
  })
  return changed ? next : undefined
}

/**
 * Rough token estimate over a message tree: ~4 chars per token. Skips `native`
 * (raw provider payloads duplicate the same content) and is cycle-safe.
 */
export function estimateTokens(value: unknown): number {
  const seen = new WeakSet<object>()
  let chars = 0

  const walk = (node: unknown, depth: number) => {
    if (depth > 10 || node == null) return
    if (typeof node === "string") {
      chars += node.length
      return
    }
    if (typeof node !== "object") return
    if (seen.has(node as object)) return
    seen.add(node as object)
    if (Array.isArray(node)) {
      for (const item of node) walk(item, depth + 1)
      return
    }
    for (const key of Object.keys(node)) {
      if (key === "native" || key === "time") continue
      walk((node as Record<string, unknown>)[key], depth + 1)
    }
  }

  try {
    walk(value, 0)
  } catch {
    return 0
  }
  return Math.round(chars / 4)
}
