# Sub-Skill 05: Prompt Budgeting & Demonstration Control (LLMLingua)

## 1. Strategic Budget Allocation
Split the input prompt token budget into three priority layers:
1. **Core Instruction & User Question (100% Budget)**: Never compress or remove the main instruction and the data the user provided directly.
2. **File/Code Context (Dynamic Allocation)**: Keep only interface definitions and excerpts relevant to the problem.
3. **Few-Shot Examples / Demonstrations (High Compression)**: In prompts with multiple examples, aggressively compress/cut redundant demonstrations, shrinking them by up to 5x with negligible accuracy loss.
