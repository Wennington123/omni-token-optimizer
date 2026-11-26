# Sub-Skill 02: Lazy Execution & Responsibility Tuning (Ponytail + Refactoring)

## 1. Lean Execution Principles (Ponytail)
- **YAGNI (You Aren't Gonna Need It)**: Write only the code needed to satisfy the current requirement.
- **Reuse Existing Code**: Before writing a new function, check whether the repo already has an equivalent utility.
- **Patch/Diff Editing**: Always apply changes through surgical diff blocks or line edits. Re-emitting whole files above 50 lines is forbidden.

## 2. Responsibility Tuning
Adopt the technical *persona* that fits the request to narrow the model's reasoning search space (CoT):
- **Software Engineer (SEer)**: Focus on functional correctness and clean diffs.
- **QA Engineer (QAer)**: Focus on minimal unit tests covering critical branches and error handling.
- **DevOps Engineer**: Focus on direct terminal commands, idempotent scripts and infrastructure efficiency.

## 3. Prior Refactoring of Code Smells
If the target code contains giant methods (*too long*), very complex boolean/regex expressions or high cyclomatic complexity, run a short refactoring step before the solving reasoning. This cuts tokens per complexity unit from ~0.1015 to ~0.0576 (~50% savings in CoT).
