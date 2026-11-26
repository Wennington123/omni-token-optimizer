# Sub-Skill 04: Structured State Compaction (ACON + TRACE)

## 1. Compaction Trigger (Threshold Trigger)
When the session history crosses the configured budget limit (e.g. 4,096 or 8,000 tokens), the agent must trigger state compaction.

## 2. Mandatory Memory Structure (<HISTORY_SUMMARY>)
Replace the accumulated history with the following structured block:

```markdown
<HISTORY_SUMMARY>
1. REASONING
- Short paraphrase of the central progress and decisions made.

2. VARS
| name | value | purpose |
|------|-------|---------|
- Record every runtime variable, access token, ID and file path needed for the next steps.

3. TODO
- Pointed list of the immediate pending actions.

4. COMPLETED
- List of what has already been finished and verified.

5. GUARDRAILS
- Short reminders of environment pitfalls already discovered, to avoid repetition (e.g. "API X requires the access_token parameter in the header").
</HISTORY_SUMMARY>
```

This structure prevents the agent from falling into regressive exploration loops and losing its local anchoring point.
