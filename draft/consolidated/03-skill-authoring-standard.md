# Skill authoring standard

This document defines how a Skillforge skill is designed, written, tested, and
released. It is the house profile on top of the Agent Skills specification.

## 1. The method

The method is Eval-Driven Skill Engineering. Its shape is spec-first,
evidence-driven, progressively disclosed, executable where deterministic,
eval-driven, and aggressively pruned.

Six verbs summarize the lifecycle.

```text
Route → Guide → Execute → Validate → Measure → Prune
```

Four architectural principles carry it: Portable Contract, Progressive
Disclosure, Executable Determinism, and Empirical Minimization.

## 2. The ten phases

| Phase | Question | Deliverable |
|---|---|---|
| 0. Classify | Is this a skill at all? | Scope decision |
| 1. Contract | What behavior must change? | Skill brief |
| 2. Baseline | What does the agent do without it? | Failure evidence |
| 3. Partition | What belongs in prose, scripts, references, assets? | Architecture |
| 4. Author | What is the minimum control plane? | `SKILL.md` |
| 5. Harden | What can become deterministic? | Scripts and validators |
| 6. Trigger-test | Does it activate correctly? | Trigger results |
| 7. Behavior-test | Does activation improve results? | Behavioral results |
| 8. Prune | What can be deleted? | Lean final skill |
| 9. Release | Is it reproducible and portable? | Versioned artifact |

## 3. Phase 0: decide whether a skill must exist

The wrong question is whether the behavior can be represented as a skill. Almost
anything can. The right question is whether loading reusable procedural
knowledge at task time improves this class of task.

```text
Is the behavior reusable?
        no  → no skill
        yes ↓
Does the model already do it reliably?
        yes → no skill
        no  ↓
Is the missing behavior purely mechanical?
        yes → write a script or use a tool
        no  ↓
Does it apply to every session in this repository?
        yes → repository instructions, AGENTS.md
        no  ↓
      SKILL
```

Each mechanism has one correct home.

| Requirement | Home |
|---|---|
| Always true for this repository | `AGENTS.md` |
| Reusable procedure for certain work | Skill |
| Exact mechanical transformation | Script or tool |
| Large factual knowledge | `references/` |
| Exact output shape | Asset or template |
| Access to an external system | MCP server or tool |
| Enforcement of an invariant | Script, test, or schema |
| Activation of the procedure | `description` |

## 4. Phase 1: write the contract before the prose

Do not start with `SKILL.md`. Start with a small internal specification.

```yaml
goal:
triggers:
non_triggers:
inputs:
outputs:
hard_invariants:
defaults:
decision_points:
side_effects:
failure_behavior:
done_when:
```

Filled in, for a release skill:

```yaml
goal:
  Prepare a repository release safely and reproducibly.

triggers:
  - prepare a release
  - publish a release
  - cut version X
  - create release notes

non_triggers:
  - explain semantic versioning
  - review an existing changelog
  - ordinary git tagging questions

inputs:
  - repository
  - requested version or version intent

outputs:
  - validated release artifacts
  - concise completion report

hard_invariants:
  - never publish before validation passes
  - never change the requested version silently

defaults:
  - infer the version only when repository policy permits it

decision_points:
  - package ecosystem
  - prerelease or stable release

side_effects:
  - tags
  - release publication

failure_behavior:
  - stop before publication
  - report the failed invariant

done_when:
  - the release validator passes
```

Three fields get misread most often.

`non_triggers` holds plausible near misses, not unrelated requests. "Explain
semantic versioning" belongs there. "How tall is the Eiffel Tower" does not.

`side_effects` names externally observable mutations, not internal computation.

`done_when` states an observable completion condition that an evaluator can
check without reading the agent's prose.

This is the semantic contract. It compiles into agent-facing instructions later,
and it gives the evaluation suite something objective to test.

The contract is an authoring artifact, not build configuration. Skillforge does
not require it in the repository and no verb reads it. Do not turn it into a
checked-in manifest before a tool consumes it.

## 5. Phase 2: baseline before authoring

If nobody observes the agent without the skill, nobody knows which behavior the
skill must change.

Baseline evaluation is mandatory for a nontrivial skill. A first baseline needs
three to five representative tasks, at least one edge case, and at least one
tempting failure case. Run them with no skill loaded.

Record what went wrong.

```text
wrong decisions
unnecessary work
missing steps
hallucinated assumptions
incorrect tools
unsafe side effects
human corrections required
```

Author against those observed failures. Do not author against imagined ones.

## 6. Phase 3: partition by degree of freedom

Degree of freedom is how much implementation choice remains after the
requirement fixes the outcome and the invariants.

| Degree | The requirement leaves | Represent it as |
|---|---|---|
| High | The approach itself. | Prose and heuristics. |
| Medium | Parameters or bounded branches inside a prescribed procedure. | A decision rule or a decision table. |
| Low | Nothing. The operation is fixed. | Tested code, a schema, or an exact template. |

Lower the freedom as the cost of an error, the fragility, or the need for
repeatability increases. Raise it when contextual variation makes a fixed
procedure harmful.

Classify every requirement before writing it.

| Requirement | Representation |
|---|---|
| Judge whether an abstraction makes sense | Reasoning instruction |
| Prefer repository convention X unless Y | Decision rule |
| Choose one of exactly three modes | Decision table |
| Produce this file format exactly | Template or schema |
| Parse these records | Script |
| Calculate this value | Script |
| Confirm this manifest is well formed | Validator |
| Perform a destructive migration | Plan, validate, then execute |

The maxim: let the model decide, let code calculate, let validators enforce.

### The four step types

Classify each meaningful workflow step during authoring. This vocabulary does
not appear in `SKILL.md`.

```text
R — Reason        model judgment or interpretation
A — Act           an inherently contextual action
D — Deterministic execute code with predictable behavior
V — Verify        establish that the result satisfies the condition
```

A well-designed skill often reads as `R → D → R → A → D → V`.

### Prefer the smallest existing primitive

A deterministic step does not automatically justify a new script.

```text
1. An existing project command
2. An existing standard CLI
3. An existing library or toolchain
4. A small skill-local script
5. A new complex implementation
```

Do not write `scripts/git-status.py` when `git status --porcelain=v1` already
produces a stable result. Reuse `git`, `jq`, `rg`, `fd`, `ruff`, `cargo
metadata`, and `pytest` before wrapping them.

## 7. Phase 4: `SKILL.md` is a control plane

A skill is a compact routing and decision document that coordinates model
reasoning, deterministic resources, and task-specific knowledge. It is not
documentation. It is not a prompt. It is not everything known about a topic.

| Component | Contains |
|---|---|
| `description` | The activation contract |
| `SKILL.md` | Workflow, decisions, invariants |
| `references/` | Knowledge needed only in certain branches |
| `scripts/` | Repeatable or fragile mechanical behavior |
| `assets/` | Templates used in outputs |
| `evals/` | Evidence that the skill works. Source only. |

`SKILL.md`, `references/`, `scripts/`, and `assets/` ship to the host. `evals/`
and `tests/` stay in the repository. `02-architecture.md` defines the exact
package closure.

Every token in `SKILL.md` competes with the conversation, the system context, and
every other skill. The deletion criterion follows from that: if removing an
instruction does not measurably hurt behavior, remove it.

### The standard layout

```markdown
---
name: <kebab-case-name>
description: <what it provides>. Use when <concrete user intents>.
---

# <Human-readable name>

## Outcome

<One or two sentences defining the result and the completion condition.>

## Constraints

- <Hard invariant only.>

## Workflow

1. <First action.>
2. If <condition>, <action>.
3. Validate the result with `<validator>`.
4. If validation fails, fix the reported issue and validate again.

## Decision rules

| Condition | Action |
|---|---|
| <condition A> | <default action> |
| <condition B> | <alternate action> |

## Resources

- Read `references/foo.md` only when <condition>.
- Run `scripts/bar.py` when <condition>.

## Failure handling

- If <unrecoverable condition>, stop before <side effect>.
- Report <the information needed to recover>.
```

No skill needs every section. A simple skill can carry a workflow and a
verification step and nothing else. Do not add a section because the template
contains it.

### Prohibited sections

These headings are prohibited unless the individual skill genuinely needs one.

```text
Introduction      Background        Benefits
Why this matters  Best practices    General considerations
Tips              Conclusion        Summary
FAQ               Installation instructions
```

A coding agent already understands programming. Do not explain what testing is.
State the command and the rule.

## 8. `description` is the router

At discovery time the agent receives roughly the name and the description. The
body loads after activation.

The description encodes what plus when plus distinctive vocabulary, and
optionally one important near-miss boundary. The description never encodes how.

Too vague:

```yaml
description: Helpful utilities for repositories.
```

Too long, and it starts to act as a substitute for the skill body:

```yaml
description: Performs a fourteen-step workflow that first analyzes the
repository, then creates...
```

Correct:

```yaml
description: Validate and prepare Python package releases. Use when the user
asks to cut, prepare, verify, or publish a Python package release.
```

## 9. Controlled English profile

Skillforge adopts the structural ideas of ASD-STE100 and rejects full vocabulary
control. Terms such as idempotent, worktree, rebase, lockfile, and webhook are
exactly the precise vocabulary a coding agent needs.

| Rule | Form |
|---|---|
| Voice | Active |
| Procedures | Imperative |
| Conditions | Condition first |
| Behavioral units | One requirement per sentence |
| Terminology | One concept, one canonical term |
| Sentences | Short and grammatically complete |
| Pronouns | Avoid when the antecedent is ambiguous |
| Alternatives | State a default |
| Requirements | `must` for real invariants only |
| Preferences | `prefer`, `default to` |
| Capability | `can` |
| Optionality | Explicit `optional` |
| Vague modal | Avoid `should` |
| Filler | Remove |
| Code, paths, identifiers | Preserve exactly |

Bad:

```text
You should probably check the config and maybe use the existing package
manager if appropriate, while ensuring that everything is valid.
```

Better:

```text
Read the repository configuration first.

If a lockfile exists, use its package manager.

Validate the generated files before continuing.
```

### Normative vocabulary

Reserve `MUST` and `MUST NOT` for safety, data integrity, scope preservation,
irreversible operations, protocol contracts, and machine-verifiable invariants.
Use plain imperatives for ordinary procedure. Use `Default to X` for policy. Use
`Prefer X when Y` for a heuristic.

Louder words do not create robustness. For a non-obvious constraint, give the
reason in one short sentence.

```text
Do not regenerate the lockfile during validation.
Regeneration can hide an inconsistent dependency state.
```

That beats a capitalized prohibition, because the model gains a principle it can
generalize.

### Condition-first syntax

Write `If <condition>, <action>.` Do not write `<Action> if <condition>.`

```text
If `pyproject.toml` contains `[tool.uv]`, use `uv`.
```

For a closed decision set, use a table instead of prose.

| Condition | Action |
|---|---|
| `uv.lock` exists | Use `uv`. |
| `poetry.lock` exists | Use Poetry. |
| `pdm.lock` exists | Use PDM. |
| No recognized lockfile exists | Stop and ask for the package manager. |

### Defaults, not menus

A list of equally valid alternatives adds almost no information.

Bad:

```text
You can use ripgrep, grep, fd, find, Python, or another suitable tool.
```

Better:

```text
Use `rg` for repository text search.

If `rg` is unavailable, use `grep -R`.
```

The pattern is one default plus one explicit exception.

## 10. Progressive disclosure

A generic link forces the agent to decide what to open. Give every reference an
activation condition.

```markdown
If the repository uses GitHub Actions, read `references/github-actions.md`.

If release signing is enabled, read `references/signing.md`.
```

Keep the reference graph one level deep. Every reference must be reachable
directly from `SKILL.md`. Do not build an index that points at another index.

Do not duplicate content between `SKILL.md` and a reference.

## 11. Context budget

Three different kinds of limit apply, and Skillforge reports them at three
different severities. Conflating them turns a style preference into a false
specification error.

| Class | Limit | Result |
|---|---|---|
| Specification constraint | `description` at most 1,024 characters. Valid metadata structure. | Error |
| Upstream recommendation | Catalog metadata about 50 to 100 tokens. `SKILL.md` under 5,000 tokens and under 500 lines. | Warning |
| Skillforge house target | The table below. | Advisory, and a failure under the strict profile |

`skillforge validate` reports specification errors only. `skillforge check`
reports house-policy warnings. `skillforge check --strict` turns those warnings
into a non-zero exit, which is the form continuous integration uses.

House targets:

| Component | House target |
|---|---|
| `description` | 1 to 3 short sentences |
| Typical `SKILL.md` | 500 to 1,500 tokens |
| Complex `SKILL.md` | 1,500 to 2,500 tokens |
| Review threshold | about 2,500 tokens |
| Strong signal to split | about 3,000 tokens |
| Inline examples | usually 0 to 2 |
| Reference depth | 1 |
| Generic explanatory prose | approximately zero |

A line count is a cheap signal and not a semantic measure. Report it, and never
report it as a specification error.

Lean does not mean short. Lean means behavior improvement divided by context
cost. A 1,500-token skill that prevents a recurring catastrophic failure is
lean. A 200-token skill of generic advice is bloated.

The cheapest token is the one an author proves is unnecessary.

### Examples

Examples steer a model strongly and cost a lot of context.

```text
algorithmic behavior       → script
closed decisions           → table
simple procedure           → instructions
specific output format     → example or template
complex unusual reasoning  → example
```

Do not add an example to make a skill look complete. If an example serves one
uncommon branch, move it to `references/examples.md` and state when to load it.

## 12. Validation inside the workflow

A robust workflow validates as part of its own definition.

```text
inspect → plan → validate plan → execute → validate result → finish
```

For a low-risk task, `execute → validate → fix → validate` is enough. For a
destructive task, discover the source of truth, write a machine-readable plan,
validate the plan, execute exactly that plan, then validate the resulting state.

Every loop needs a termination condition. Do not write "continue until
everything is correct."

```text
Run `scripts/validate.py`.

If validation fails, fix only the reported violations and run it again.

If the validator cannot complete because a prerequisite is missing, stop and
report the missing prerequisite.
```

Completion becomes externally observable.

## 13. Two evaluation suites

Trigger evaluation asks whether the skill loads. Behavioral evaluation asks
whether loading improved the task. Keep them separate.

### Trigger evaluation

The house suite is 10 positive cases, 10 negative cases, and 3 runs of each.
Activation is nondeterministic, so repetition matters.

Negative cases must be near misses. For a release skill, "How tall is the Eiffel
Tower?" proves nothing. "Can you explain how semantic versioning works?" tests
whether the skill over-triggers on the word version.

Vary the phrasing across the suite.

```text
formal        casual        typos
abbreviations implicit      explicit
long requests with unrelated context
requests with trigger words and the wrong intent
```

Split the dataset 60 percent development and 40 percent holdout. After the
description is final, write a few fresh unseen cases. This protects against
overfitting the description to its own test set.

### Behavioral evaluation

Compare a baseline run with no skill or the previous skill against a candidate
run with the new skill. Use fresh context for each run. Record runtime and token
cost so an improvement is judged against its price.

Assert observable outcomes, never wording.

| Bad assertion | Good assertion |
|---|---|
| The response contains the heading "Verification". | The release was not published when validation failed. |
| The response says "uv". | The command used the package manager identified by the lockfile. |
| The agent mentioned tests. | The configured test command completed before publication. |

An assertion on wording teaches the agent to satisfy the grader instead of the
requirement.

### Evaluate traces

A final answer can look perfect while the agent read twenty unnecessary files,
tried four package managers, retried one failing command three times, and
stumbled onto the right method. That skill is not good.

Capture the trace.

```text
skill triggered      references loaded     tools called
commands executed    retries               validator results
final correctness    token consumption     duration
side effects
```

Optimize for correct, direct, reliable, and cheap together.

### Choosing between two revisions

Quality and cost do not share a unit. Adding them into one score produces a
formula nobody can apply. Compare in order instead, and move to the next step
only when the current step ties.

```text
1. hard constraints    safety, correctness invariants, portability,
                       no unauthorized side effects
2. behavior            held-out task success
3. routing             trigger precision and recall on held-out queries
4. stability           variance across repeated runs
5. cost                tokens, tool calls, retries, duration, loaded resources
```

The rule in one sentence:

```text
Prefer a revision only when it improves held-out task or trigger performance
without violating a safety or portability constraint. When quality ties inside
the evaluation tolerance, choose the cheaper revision.
```

Step 1 is a gate rather than a score. A revision that violates it loses to a
worse-performing revision that does not.

Three further quantities stay review signals and never enter the comparison:
human comprehension, duplicated knowledge, and unconstrained choice count. The
last one is the checkable proxy for choice entropy, which is the idea behind
defaults over menus, closed enumerations, and decision tables. Count the
unconstrained choices. Do not claim to measure entropy without defining a
distribution.

## 14. RED, GREEN, HARDEN, PRUNE

```text
RED      observe the baseline failure
GREEN    add the minimum instruction that fixes it
HARDEN   try variants, near misses, edge cases, malformed inputs
PRUNE    delete instructions and see whether the tests stay green
```

The last phase matters most. A skill must survive subtraction, not only
addition.

```text
For each paragraph:
    remove it
    rerun the evaluations
    same quality? delete it permanently
    quality falls?  restore it
```

This gives context minimization an empirical mechanism instead of an opinion.

## 15. The release gate

A skill is not production-ready because its YAML parses.

| Gate | Requirement |
|---|---|
| Syntax | The Agent Skills validator passes. |
| Scope | One coherent reusable capability. |
| Trigger | Positive and near-negative holdout cases pass. |
| Behavior | Beats the no-skill or previous baseline. |
| Determinism | Mechanical invariants live in code where practical. |
| Scripts | Executed and tested. |
| Context | Every major block justifies its cost. |
| References | Conditional and directly linked. |
| Output | Templates or schemas used where structure matters. |
| Failure | Explicit stopping behavior. |
| Side effects | Guarded and observable. |
| Security | No bundled secrets and no hidden privileges. |
| Portability | The core does not depend on a vendor extension. |
| Regression | The existing evaluation suite stays green. |

The pipeline that enforces it:

```text
validate-spec → validate-files → test-scripts → eval-trigger
→ eval-behavior → measure-context → release
```

## 16. Portable core, vendor adapters

Never put vendor-specific metadata in the portable behavioral core unless the
core requires it.

```yaml
---
name: release-package
description: ...
---
```

The specification also permits `license`, `compatibility`, and `metadata`. The
`allowed-tools` field is experimental, so treat it as unstable.

Vendor metadata layers outside the skill body. OpenAI recommends an optional
`agents/openai.yaml` for interface metadata. Cursor adds its own scoping.
OpenCode adds external permission configuration. The behavioral contract stays
portable across all of them.

## 17. The constitution

These 35 rules are normative for every Skillforge skill.

1. Use the Agent Skills `SKILL.md` specification as the portable format.
2. Create a skill only for reusable behavior the base agent does not already perform reliably.
3. Keep always-on repository policy outside skills.
4. Define triggers, non-triggers, outcome, invariants, defaults, side effects, failure behavior, and completion criteria before authoring.
5. Baseline the agent before adding a nontrivial skill.
6. Keep `description` about activation, not implementation.
7. Treat `SKILL.md` as a control plane, not a knowledge base.
8. Write procedural instructions in active imperative language.
9. Write one behavioral requirement per sentence or step.
10. Put conditions before actions.
11. Use one canonical term for each concept.
12. Give one default rather than several equal choices.
13. Reserve `MUST` and `MUST NOT` for genuine invariants.
14. Explain a non-obvious constraint briefly when the reason improves generalization.
15. Represent closed branching logic as decision tables when practical.
16. Move deterministic, fragile, repeated, or machine-verifiable behavior into scripts.
17. Make scripts non-interactive, idempotent where practical, structured, bounded, and agent-friendly.
18. Use templates or schema validation when output structure matters.
19. Load a detailed reference only when an explicit condition applies.
20. Keep reference navigation shallow.
21. Do not duplicate information between `SKILL.md` and a reference.
22. Do not explain concepts the coding agent already understands.
23. Use an example only when it materially disambiguates behavior.
24. Require explicit validation before an irreversible side effect.
25. Define termination and failure conditions for every loop.
26. Maintain separate trigger and behavioral evaluation suites.
27. Use realistic positive and near-negative trigger cases.
28. Evaluate against a no-skill or previous-skill baseline.
29. Test observable invariants, not exact wording.
30. Inspect execution traces as well as final results.
31. Measure context and token overhead.
32. Run deletion tests and remove instructions that do not improve results.
33. Keep the portable core independent of vendor-specific extensions.
34. Version skills and rerun evaluations when behavior, models, or runtimes change materially.
35. Never equate schema validation with behavioral correctness.

## 18. Reference registry

| Source | Authority |
|---|---|
| agentskills.io specification | Format |
| agentskills.io authoring and evaluation guides | Method |
| OpenAI, Anthropic, and Gemini skill creators | Implementation evidence |
| Strong community projects such as Superpowers | Experimental patterns |
| The project's own evaluation suite | Final authority |

The last row outranks the rest inside this project.

`06-references.md` holds the links behind every row.
