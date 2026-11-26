# Sub-Skill 03: Observation Trimming & Tool-Result Clearing (CoACT + TRC)

## 1. Next-Action Preservation (CoACT)
When receiving tool returns (terminal logs, API responses, database queries):
- Truncate outputs keeping **only** the elements essential to the next decision:
  - Error messages and stack traces.
  - Modified/read file paths.
  - Resource IDs, access tokens or API parameters.
  - Relevant line numbers.
- Remove progress bars, repetitive success logs and clean build output.

## 2. Clearing Old Outputs (Tool-Result Clearing - TRC)
- Keep the 2-3 most recent tool observations intact.
- Replace older tool outputs in the history with placeholders in the format `[tool output cleared: exit 0]` or `[output cleared: 142 lines]`.
- This preserves *KV-Cache* alignment and cuts accumulated token cost by up to 43% without degrading the success rate.
