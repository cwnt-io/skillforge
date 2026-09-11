# skill creation methodology


Do a deep web resaerch...

there are many coding agent skills out there... what I want: the best state of the art skill creator method...

the format... the language... the laytout... structure... requirements... everything...

something that is easy for human readability... easy and enforces deterministic behavior for the coding agent side... yet lean, clean, without bloat... context light so it cooperates with the coding agent usability... etc...

search for the criterias... search for the best state of the art... current... latest... specs and docs...

and give me the methodology for that


---

As of **September 11, 2026**, there is no single document that defines the complete “state of the art” for coding-agent skills. But after comparing the current Agent Skills specification, OpenAI/Codex, Anthropic, Cursor, OpenCode, Gemini-era conventions, the official Agent Skills authoring/evaluation guidance, and strong community approaches such as Superpowers, there is now a fairly clear convergence.

My recommendation is to standardize on this principle:

> **Use `SKILL.md` as a small control plane. Put knowledge in conditional references, deterministic behavior in executable code, output shape in templates, and reliability in evals.**

That is much stronger than trying to make one enormous, perfectly worded prompt.

The resulting methodology is:

**spec-first → evidence-driven → progressively disclosed → executable where deterministic → eval-driven → aggressively pruned.**

([Agent Skills][1])

---

# 1. The architecture I would standardize on

The portable foundation should be the **Agent Skills open format**.

At minimum:

```text
<skill-name>/
├── SKILL.md
├── scripts/        # optional
├── references/     # optional
└── assets/         # optional
```

The specification defines `SKILL.md` as YAML frontmatter followed by Markdown. `name` and `description` are required. `scripts/`, `references/`, and `assets/` are conventional optional directories. The standard explicitly recommends progressive disclosure and keeping `SKILL.md` below 5,000 tokens / 500 lines. ([Agent Skills][1])

For a **source repository that develops skills**, however, I would extend that slightly:

```text
skills/
└── <skill-name>/
    ├── SKILL.md
    │
    ├── scripts/
    │   ├── ...
    │   └── ...
    │
    ├── references/
    │   ├── ...
    │   └── ...
    │
    ├── assets/
    │   └── ...
    │
    └── evals/
        ├── evals.json
        ├── trigger-evals.json
        └── fixtures/
```

`evals/` is especially important for the **development repository**, even though an installed/runtime copy does not necessarily need every evaluation artifact. The official Agent Skills evaluation guide itself uses `evals/evals.json` and recommends comparing runs with and without the skill. ([Agent Skills][2])

For cross-agent installation, `.agents/skills/` is becoming a particularly useful interoperability location. Cursor and OpenCode both currently recognize it in addition to their native locations and compatibility directories. ([Cursor][3])

So I would separate:

| Layer                   | Purpose                                                     |
| ----------------------- | ----------------------------------------------------------- |
| **Portable skill**      | `SKILL.md`, scripts, references, assets                     |
| **Development harness** | evals, fixtures, benchmarks, validation                     |
| **Agent adapter**       | Codex/Claude/Cursor/etc. installation metadata              |
| **Repository policy**   | `AGENTS.md`, project rules, not duplicated into every skill |

That separation is important.

---

# 2. A skill is not where all agent instructions belong

This is one of the most important architectural decisions.

Think of these mechanisms differently:

| Requirement                                     | Correct home                          |
| ----------------------------------------------- | ------------------------------------- |
| Always true for this repository                 | `AGENTS.md` / repository instructions |
| Reusable procedure needed only for certain work | Skill                                 |
| Exact/mechanical transformation                 | Script/tool                           |
| Large factual/domain knowledge                  | `references/`                         |
| Exact output shape                              | Asset/template/schema                 |
| Access to an external system                    | MCP/tool/plugin                       |
| Validation of an invariant                      | Script/test/schema                    |
| Triggering the procedure                        | `description`                         |

A repository-wide rule such as:

> Always run `ruff check` before committing Python changes.

probably belongs in repo instructions if it applies to essentially every development session.

Something like:

> Prepare and validate a PyPI release using our release process.

is a skill.

Something like:

> Calculate the next semantic version from these inputs.

should probably be executable code.

This distinction is what prevents the skill ecosystem from becoming a second giant system prompt.

Current Cursor documentation makes essentially the same conceptual distinction: skills are particularly appropriate for reusable procedural knowledge loaded dynamically rather than permanently active instructions. ([Cursor][3])

---

# 3. The core design rule: skills are control planes

I would formally define a skill this way:

> **A skill is a compact routing and decision document that coordinates model reasoning, deterministic resources, and task-specific knowledge.**

It is **not** primarily documentation.

It is **not** primarily a prompt.

And it is definitely not a dump of everything known about a topic.

This gives each component a very clear job:

| Component     | Contains                                    |
| ------------- | ------------------------------------------- |
| `description` | Activation contract                         |
| `SKILL.md`    | Workflow + decisions + invariants           |
| `references/` | Knowledge required only in certain branches |
| `scripts/`    | Repeatable or fragile mechanical behavior   |
| `assets/`     | Templates/resources used in outputs         |
| `evals/`      | Evidence that the skill works               |

The official guidance explicitly says every token in `SKILL.md` competes with the conversation, system context, and other skills. It recommends asking whether the agent would actually get something wrong without each instruction. ([Agent Skills][4])

This leads to an excellent deletion criterion:

> **If removing an instruction does not measurably hurt behavior, remove it.**

That is much better than asking whether the instruction sounds useful.

---

# 4. The state-of-the-art creation methodology

I would make your skill creator follow this lifecycle.

| Phase                | Question                                         | Deliverable          |
| -------------------- | ------------------------------------------------ | -------------------- |
| **0. Classify**      | Is this actually a skill?                        | Scope decision       |
| **1. Contract**      | What behavior must change?                       | Skill brief          |
| **2. Baseline**      | What does the agent do without it?               | Failure evidence     |
| **3. Partition**     | What belongs in prose/scripts/references/assets? | Architecture         |
| **4. Author**        | What is the minimum control plane?               | `SKILL.md`           |
| **5. Harden**        | What can become deterministic?                   | Scripts + validators |
| **6. Trigger-test**  | Does it activate correctly?                      | Trigger eval results |
| **7. Behavior-test** | Does activation improve results?                 | Behavioral evals     |
| **8. Prune**         | What can be deleted?                             | Lean final skill     |
| **9. Release**       | Is it reproducible and portable?                 | Versioned artifact   |

That is the methodology I would implement in an actual `skill-creator` skill.

Let's unpack it.

---

# 5. Phase 0 — decide whether a skill should exist

Before generating anything, the creator should perform a classification test.

The question is not:

> “Can this be represented as a skill?”

Almost anything can.

The better question is:

> **“Does loading reusable procedural knowledge at task time improve this class of tasks?”**

The official best-practices guidance explicitly warns against skills whose contents are generic knowledge the model already has. It also argues that a skill should represent a coherent unit of work, analogous to a well-scoped function. ([Agent Skills][4])

A useful test is:

```text
Is the behavior reusable?
        |
        no --> do not create a skill
        |
       yes
        |
Does the model already perform it reliably?
        |
       yes --> probably do not create a skill
        |
        no
        |
Is the missing behavior purely mechanical?
        |
       yes --> create a script/tool instead
        |
        no
        |
Is it always applicable in this repository?
        |
       yes --> repository instructions / AGENTS.md
        |
        no
        |
      SKILL
```

This alone will keep a skill repository considerably cleaner.

---

# 6. Phase 1 — define the behavioral contract first

Do not start with `SKILL.md`.

Start with a tiny internal specification:

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

For example:

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
  - infer version only when the repository policy permits it

decision_points:
  - package ecosystem
  - prerelease vs stable release

side_effects:
  - tags
  - release publication

failure_behavior:
  - stop before publication
  - report the failed invariant

done_when:
  - release validator passes
```

This is the **semantic contract**.

Only after this exists should it be compiled into agent-facing instructions.

This also gives your eval generator something objective to test.

---

# 7. Phase 2 — baseline before writing

This is where one of the best community ideas deserves to be adopted.

Superpowers treats skill development as **TDD for process documentation**:

```text
RED       agent without skill fails
GREEN     skill causes correct behavior
REFACTOR  remove loopholes and unnecessary instructions
```

Its most useful insight is:

> if you never observe the agent without the skill, you don't actually know which behavior the skill needs to change.

That is not part of the formal Agent Skills specification, but it aligns extremely well with the official Agent Skills evaluation methodology, which explicitly recommends testing the skill against a no-skill or old-skill baseline. ([GitHub][5])

I would therefore make **baseline evaluation mandatory** for nontrivial skills.

Not necessarily hundreds of runs.

Initially:

```text
3-5 representative tasks
+
at least 1 edge case
+
at least 1 tempting failure case
```

Run them without the skill.

Record:

```text
wrong decisions
unnecessary work
missing steps
hallucinated assumptions
incorrect tools
unsafe side effects
human corrections required
```

Then author against **actual failure modes**, not imagined ones.

This is a substantial improvement over:

```text
"Create a comprehensive skill for doing X."
```

---

# 8. Phase 3 — partition by degree of freedom

This is perhaps the strongest point of agreement between OpenAI's current skill creator and the Agent Skills authoring guide.

OpenAI describes three useful degrees of freedom:

**high freedom** → prose/heuristics
**medium freedom** → parameterized procedure/pseudocode
**low freedom** → exact tested scripts

([GitHub][6])

I would make this classification explicit for every requirement:

| Requirement                                    | Representation                    |
| ---------------------------------------------- | --------------------------------- |
| “Review whether this abstraction makes sense.” | Reasoning instruction             |
| “Prefer repository convention X unless Y.”     | Decision rule                     |
| “Choose one of exactly these three modes.”     | Decision table / enum             |
| “Generate this file format exactly.”           | Template/schema                   |
| “Parse these records.”                         | Script                            |
| “Calculate this value.”                        | Script                            |
| “Validate this manifest.”                      | Validator                         |
| “Perform destructive migration.”               | plan → validate → execute scripts |

This gives you an extremely useful maxim:

> **Let the LLM decide. Let code calculate. Let validators enforce.**

Do not ask natural-language instructions to provide guarantees that normal software can provide more reliably.

---

# 9. Real determinism requires moving behavior outside the LLM

This needs emphasis because it is frequently misunderstood in agent engineering.

A skill cannot make an LLM truly deterministic.

You can make the **system behavior substantially more deterministic** by constraining the interfaces around it.

For example:

```text
Agent
  |
  | choose mode
  v
scripts/plan.py
  |
  | JSON
  v
scripts/validate.py
  |
  | valid
  v
scripts/apply.py
  |
  v
tests / validator
```

This is far stronger than:

```markdown
Carefully create the correct plan.
Double-check everything.
Make sure all inputs are valid.
Never make mistakes.
```

The Agent Skills script guidance recommends precisely the characteristics you would expect from an agent-oriented CLI: structured output, useful errors, predictable interfaces, and compact output. ([Agent Skills][7])

For skill scripts, I would enforce this contract:

| Property               | Standard                            |
| ---------------------- | ----------------------------------- |
| Input                  | CLI arguments, stdin or known files |
| Choices                | closed enums where possible         |
| Interactive prompts    | prohibited                          |
| Output                 | structured when consumed by agent   |
| Diagnostics            | stderr                              |
| Errors                 | actionable                          |
| Exit status            | meaningful                          |
| Repeated execution     | idempotent where possible           |
| Destructive operations | `--dry-run` or plan stage           |
| Dependencies           | pinned/reproducible                 |
| Output volume          | bounded                             |
| Side effects           | explicit                            |
| Tests                  | mandatory for nontrivial scripts    |

That is where your deterministic behavior comes from.

---

# 10. The ideal `SKILL.md` structure

The official specification intentionally does **not** prescribe body headings. ([Agent Skills][1])

For coding-agent skills, I would standardize your repository on this layout:

```markdown
---
name: <kebab-case-name>
description: <what it provides>. Use when <concrete user intents or situations>.
---

# <Human-readable name>

## Outcome

<One or two sentences defining the result and completion condition.>

## Constraints

- <Hard invariant only.>
- <Hard invariant only.>

## Workflow

1. <First action.>
2. If <condition>, <action>.
3. <Next action>.
4. Validate the result with `<validator>`.
5. If validation fails, fix the reported issue and validate again.

## Decision rules

| Condition | Action |
|---|---|
| <condition A> | <default action> |
| <condition B> | <alternate action> |

## Resources

- Read `references/foo.md` only when <condition>.
- Run `scripts/bar.py` when <condition>.
- Use `assets/template.ext` when <condition>.

## Failure handling

- If <unrecoverable condition>, stop before <side effect>.
- Report <specific information needed to recover>.
```

Not every skill needs every section.

That is deliberate.

For a simple skill, this might only be:

```markdown
---
name: foo
description: ...
---

# Foo

## Workflow

1. ...
2. ...
3. ...

## Verification

Run `scripts/verify.py`.
```

Do **not** add sections merely because the template contains them.

---

# 11. Notice what is deliberately missing

I would normally prohibit these generic sections:

```text
Introduction
Background
Benefits
Why this matters
Best practices
General considerations
Tips
Conclusion
Summary
FAQ
README-like installation instructions
```

unless the specific skill genuinely needs one.

OpenAI's own skill-creator guidance explicitly warns against auxiliary files and documentation that merely create clutter, and the official Agent Skills guidance says generic knowledge should be omitted. ([GitHub][6])

A coding agent already understands programming.

You do not need:

```markdown
## What is testing?

Testing is an important software engineering practice...
```

You need:

```markdown
Run `uv run pytest tests/release/` before publishing.
Do not publish if any release test fails.
```

---

# 12. `description` is not documentation — it is the router

This deserves its own standard.

At discovery time, the agent may initially receive only something roughly equivalent to:

```text
name
description
```

The body is loaded after activation. ([Agent Skills][1])

Therefore this is bad:

```yaml
description: Helpful utilities for repositories.
```

And so is this:

```yaml
description: Performs a fourteen-step workflow that first analyzes the
repository, then creates...
```

The first does not route accurately.

The second wastes global discovery context and can accidentally act as a miniature substitute for the actual skill.

The best pattern is:

```yaml
description: Validate and prepare Python package releases. Use when the user
asks to cut, prepare, verify, or publish a Python package release.
```

The description should encode:

```text
WHAT
+
WHEN
+
distinctive vocabulary
+
optionally an important near-miss boundary
```

Not:

```text
HOW
```

The formal spec requires what + when and recommends relevant keywords. The dedicated trigger-optimization guidance treats description quality as something to **measure**, not guess. ([Agent Skills][1])

---

# 13. Trigger descriptions should have their own eval suite

This is one of the newer and more important developments.

The current Agent Skills guidance recommends approximately **20 trigger queries**, roughly balanced between positive and negative cases, with repeated runs because activation itself is nondeterministic. Three runs per query is offered as a reasonable starting point. ([Agent Skills][8])

I would adopt:

```text
10 should-trigger cases
10 should-not-trigger cases
3 runs each
```

But the negative cases should be **near misses**.

Weak negative:

```text
How tall is the Eiffel Tower?
```

for a release skill.

Useless.

Strong negative:

```text
Can you explain how semantic versioning works?
```

The latter tests whether the skill is over-triggering on “version”.

Also vary:

```text
formal phrasing
casual phrasing
typos
abbreviations
implicit requests
explicit requests
long requests containing unrelated context
requests containing trigger words but wrong intent
```

Do not optimize against the entire dataset indefinitely.

Use something like:

```text
60% development
40% holdout
```

Then after finalizing the description, create a few **fresh unseen cases**.

That protects against prompt-level overfitting.

---

# 14. Language: use controlled technical English, but not full STE

There is a useful idea here from Simplified Technical English.

ASD-STE100 is an actual controlled technical-language standard; Issue 9 was released January 15, 2025. Its purpose is reducing ambiguity in technical documentation. ([ASD-STE100][9])

Community adaptations such as SimpleEnglish apply several STE principles specifically to agent instructions: imperative procedures, condition-first sentences, stable terminology, and one instruction per sentence. ([GitHub][10])

I think the **structural ideas are excellent** for skills.

I would **not** require complete ASD-STE100 compliance.

Full vocabulary control would become counterproductive for software engineering because terms such as:

```text
idempotent
worktree
rebase
dependency graph
artifact
lockfile
webhook
```

are exactly the precise technical vocabulary you want.

So I would create an internal **controlled-English profile for agent instructions** instead.

| Rule                   | Recommended form                   |
| ---------------------- | ---------------------------------- |
| Voice                  | Active                             |
| Procedures             | Imperative                         |
| Conditions             | Condition first                    |
| Behavioral units       | One requirement per sentence       |
| Terminology            | One concept → one canonical term   |
| Sentences              | Short and grammatically complete   |
| Pronouns               | Avoid when antecedent is ambiguous |
| Alternatives           | State a default                    |
| Requirements           | `must` only for real invariants    |
| Preferences            | `prefer` / `default to`            |
| Capability             | `can`                              |
| Optionality            | explicit `optional` or `may`       |
| Vague modal            | avoid `should`                     |
| Filler                 | remove                             |
| Code/paths/identifiers | preserve exactly                   |

For example:

Bad:

```text
You should probably check the config and maybe use the existing
package manager if appropriate, while ensuring that everything is valid.
```

Better:

```text
Read the repository configuration first.

If a lockfile exists, use its package manager.

Validate the generated files before continuing.
```

This is easier for humans **and** easier to translate into atomic agent behaviors.

---

# 15. Do not abuse `MUST`, `ALWAYS`, and `NEVER`

There is a subtle but important current trend here.

Simply screaming stronger words at a model does not create robustness.

The Agent Skills evaluation guidance notes that explaining the reason behind a rule can outperform blanket rigid instructions in judgment-heavy situations. ([Agent Skills][11])

I recommend a small normative vocabulary:

```text
MUST / MUST NOT
```

Use only for:

```text
safety
data integrity
scope preservation
irreversible operations
protocol contracts
machine-verifiable invariants
```

Use ordinary imperative language for normal procedure:

```text
Run the validator.
Read the manifest.
Compare the generated files.
```

Use:

```text
Default to X.
```

for normal policy.

Use:

```text
Prefer X when Y.
```

for heuristics.

And for non-obvious constraints, add a short reason:

```text
Do not regenerate the lockfile during validation.
Regeneration can hide an inconsistent dependency state.
```

That is stronger than:

```text
NEVER EVER REGENERATE THE LOCKFILE!!!
```

because the model now has a decision principle it can generalize.

---

# 16. Condition-first syntax is particularly valuable

For branching workflows, standardize on:

```text
If <condition>, <action>.
```

rather than:

```text
<Action> if <condition>.
```

Example:

```text
If `pyproject.toml` contains `[tool.uv]`, use `uv`.
```

not:

```text
Use `uv` if the project appears to be configured for it.
```

And definitely not:

```text
Choose the appropriate package manager based on the project.
```

Condition-first instructions give you a crude declarative decision language.

For closed decision sets, go one step further:

```markdown
| Condition | Action |
|---|---|
| `uv.lock` exists | Use `uv`. |
| `poetry.lock` exists | Use Poetry. |
| `pdm.lock` exists | Use PDM. |
| No recognized lockfile exists | Stop and ask for the package manager. |
```

This is much more deterministic than prose paragraphs.

---

# 17. Defaults, not menus

The official authoring guidance is explicit about this: **provide defaults rather than presenting the agent with a menu of equally valid alternatives.** ([Agent Skills][4])

Bad:

```text
You can use ripgrep, grep, fd, find, Python, or another suitable tool.
```

That sentence adds almost zero useful information.

Better:

```text
Use `rg` for repository text search.

If `rg` is unavailable, use `grep -R`.
```

This pattern is extremely powerful:

```text
DEFAULT
+
EXPLICIT EXCEPTION
```

It reduces search space while preserving adaptability.

---

# 18. References need activation conditions too

A common mistake with progressive disclosure is writing:

```markdown
See `references/` for more details.
```

That still forces the agent to decide what to inspect.

Instead:

```markdown
If the repository uses GitHub Actions, read
`references/github-actions.md`.

If release signing is enabled, read
`references/signing.md`.

If the registry returns an authentication error, read
`references/registry-auth.md`.
```

The official guide specifically recommends these conditional references over generic links. ([Agent Skills][4])

This turns progressive disclosure into actual routing.

Also:

```text
SKILL.md
    |
    +--> references/a.md
    |
    +--> references/b.md
```

is preferable to:

```text
SKILL.md
  -> references/index.md
       -> protocols/index.md
            -> details.md
```

The spec recommends keeping reference links shallow—ideally directly reachable from `SKILL.md`. ([Agent Skills][1])

---

# 19. Context budget: I would be stricter than the official maximum

The specification says roughly:

```text
metadata           ~100 tokens
SKILL.md           <5,000 tokens recommended
SKILL.md           <500 lines
resources          loaded on demand
```

([Agent Skills][1])

Those should be treated as upper bounds, **not targets**.

For a repository deliberately optimizing agent efficiency, my recommended targets would be:

| Component                 |        House target |
| ------------------------- | ------------------: |
| `description`             | 1–3 short sentences |
| Typical `SKILL.md`        |    500–1,500 tokens |
| Complex `SKILL.md`        |  1,500–2,500 tokens |
| Review threshold          |       ~2,500 tokens |
| Strong split signal       |       ~3,000 tokens |
| Specification ceiling     |       <5,000 tokens |
| Inline examples           |         usually 0–2 |
| Reference depth           |                   1 |
| Generic explanatory prose |  approximately zero |

Those numbers are **my recommended engineering budget**, not requirements from the Agent Skills specification.

The principle is:

> **The cheapest token is the one you prove you don't need.**

---

# 20. Examples are useful, but expensive

Examples are one of the strongest steering mechanisms available to LLMs.

But examples also take considerable context.

Therefore:

```text
algorithmic behavior        -> script
closed decisions            -> table
simple procedure            -> instructions
specific output format      -> example/template
complex unusual reasoning   -> example
```

Do not add examples merely to make a skill look complete.

If an example exists only for one uncommon branch, put it in:

```text
references/examples.md
```

and tell the agent exactly when to load it.

If the output must have an exact shape, a concrete template is generally stronger than several paragraphs explaining that shape. This is also explicitly recommended by the Agent Skills authoring guide. ([Agent Skills][4])

---

# 21. Validation should be part of the workflow, not an afterthought

A robust skill workflow frequently looks like:

```text
inspect
   ↓
plan
   ↓
validate plan
   ↓
execute
   ↓
validate result
   ↓
finish
```

For low-risk tasks:

```text
execute
   ↓
validate
   ↓
fix
   ↘
    validate
```

For destructive tasks:

```text
discover source of truth
        ↓
create machine-readable plan
        ↓
validate plan
        ↓
execute exact plan
        ↓
validate resulting state
```

The official Agent Skills best-practices guide specifically calls out both **validation loops** and **plan → validate → execute** as recommended patterns. ([Agent Skills][4])

The important detail is that loops need a **termination condition**.

Don't write:

```text
Continue fixing problems until everything is correct.
```

Prefer something like:

```text
Run `scripts/validate.py`.

If validation fails, fix only the reported violations and run it again.

If the validator cannot complete because its prerequisites are missing,
stop and report the missing prerequisite.
```

Now “done” is externally observable.

---

# 22. Behavioral evals are as important as trigger evals

There are really **two different test suites**.

### Trigger evaluation

Tests:

```text
Should this skill load?
```

### Behavioral evaluation

Tests:

```text
After loading, did it improve the task?
```

The latter should compare:

```text
baseline: no skill / previous skill
candidate: new skill
```

using fresh context for each run. Official Agent Skills evaluation guidance recommends precisely this comparative approach and also recommends recording runtime/token effects so improvements can be judged against their cost. ([Agent Skills][2])

Assertions should test **observable outcomes**, not wording.

Bad assertion:

```text
The response contains the heading "Verification".
```

Good assertion:

```text
The release was not published when validation failed.
```

Bad:

```text
The response says "uv".
```

Good:

```text
The command used the package manager identified by the repository lockfile.
```

Bad:

```text
Agent mentioned tests.
```

Good:

```text
The command specified by the repository's test configuration completed successfully before publication.
```

Otherwise the agent learns to satisfy the evaluator without satisfying the actual requirement.

---

# 23. Evaluate traces, not only final answers

This is another high-value current recommendation.

A final answer might look perfect while the agent:

```text
read 20 unnecessary files
tried four package managers
generated a helper script
deleted it
retried the same failing command three times
finally stumbled onto the right method
```

That skill is not good.

The official best-practices guidance specifically recommends inspecting execution traces for wasted work and identifies vague instructions, irrelevant instructions, and excessive options as common causes. ([Agent Skills][4])

Your eval system should therefore capture:

```text
skill triggered?
references loaded
tools called
commands executed
retries
validator results
final correctness
token consumption
duration
side effects
```

Then optimize not merely for:

```text
correct
```

but:

```text
correct
+
direct
+
reliable
+
cheap
```

---

# 24. Skill development should use RED → GREEN → PRUNE

I would slightly modify Superpowers' TDD framing.

Instead of only:

```text
RED → GREEN → REFACTOR
```

use:

```text
RED → GREEN → HARDEN → PRUNE
```

Where:

### RED

Observe baseline failure.

### GREEN

Add the minimum instruction that fixes it.

### HARDEN

Try variants, near misses, edge cases, pressure cases, malformed inputs.

### PRUNE

Delete instructions and see whether tests remain green.

That final phase matters enormously for your specific goal.

A skill should not only survive additions.

It should survive **subtraction testing**.

For each paragraph:

```text
remove it
rerun evals

same quality?
    delete permanently

quality falls?
    restore
```

That gives you an empirical mechanism for context minimization.

It also matches the official recommendation to remove instructions when eval traces show they are unnecessary or when additional rules stop improving results. ([Agent Skills][11])

---

# 25. The skill creator itself should enforce a release gate

I would not allow your skill-building system to call something “production-ready” merely because its YAML parses.

A **gold skill** would have to satisfy this:

| Gate         | Requirement                                         |
| ------------ | --------------------------------------------------- |
| Syntax       | Agent Skills validator passes                       |
| Scope        | One coherent reusable capability                    |
| Trigger      | Positive + near-negative holdout tests              |
| Behavior     | Beats no-skill/previous baseline                    |
| Determinism  | Mechanical invariants moved to code where practical |
| Scripts      | Executed/tested                                     |
| Context      | Every major block justifies its cost                |
| References   | Conditional and directly linked                     |
| Output       | Templates/schema used where structure matters       |
| Failure      | Explicit stopping behavior                          |
| Side effects | Guarded and observable                              |
| Security     | No bundled secrets or hidden privileges             |
| Portability  | Portable core does not depend on vendor extensions  |
| Regression   | Existing eval suite remains green                   |

Only then release it.

The formal specification validator checks structural correctness such as frontmatter and naming; it cannot establish behavioral quality. ([Agent Skills][1])

That distinction should be explicit in your tooling:

```text
validate-spec
validate-files
test-scripts
eval-trigger
eval-behavior
measure-context
release
```

---

# 26. Portable core, vendor adapters

Another thing I would establish as policy:

**Never contaminate the portable behavioral core with vendor-specific metadata unless required.**

Portable:

```yaml
---
name: release-package
description: ...
---
```

The Agent Skills spec also permits standard optional fields such as `license`, `compatibility`, and `metadata`; `allowed-tools` is currently explicitly experimental. ([Agent Skills][1])

Vendor-specific additions should be layered separately where possible.

For example, OpenAI's current skill creator recommends an optional/recommended:

```text
agents/openai.yaml
```

for UI-facing metadata. ([GitHub][6])

Cursor has its own additional scoping capabilities. OpenCode has its own external permission configuration. ([Cursor][3])

So architect this like:

```text
                 ┌─ OpenAI adapter
                 │
Portable Skill ──┼─ Claude installer
                 │
                 ├─ Cursor adapter
                 │
                 ├─ Gemini adapter
                 │
                 └─ OpenCode adapter
```

The **behavioral contract remains portable**.

---

# 27. Requirements that I would encode in your project's skill standard

Here is the one list I would treat as your normative “constitution”:

1. **Use the Agent Skills `SKILL.md` specification as the portable format.**
2. **Create a skill only for reusable behavior the base agent does not already perform reliably.**
3. **Keep always-on repository policy outside skills.**
4. **Define triggers, non-triggers, outcome, invariants, defaults, side effects, failure behavior, and completion criteria before authoring.**
5. **Baseline the agent before adding a nontrivial skill.**
6. **Keep `description` about activation, not implementation.**
7. **Treat `SKILL.md` as a control plane, not a knowledge base.**
8. **Write procedural instructions in active imperative language.**
9. **Write one behavioral requirement per sentence or step.**
10. **Put conditions before actions.**
11. **Use one canonical term for each concept.**
12. **Give one default rather than several equal choices.**
13. **Reserve `MUST`/`MUST NOT` for genuine invariants.**
14. **Explain non-obvious constraints briefly when the reason improves generalization.**
15. **Represent closed branching logic as decision tables when practical.**
16. **Move deterministic, fragile, repeated, or machine-verifiable behavior into scripts.**
17. **Make scripts non-interactive, idempotent where practical, structured, bounded, and agent-friendly.**
18. **Use templates/schema validation when output structure matters.**
19. **Load detailed references only when an explicit condition applies.**
20. **Keep reference navigation shallow.**
21. **Do not duplicate information between `SKILL.md` and references.**
22. **Do not explain concepts the coding agent already understands.**
23. **Use examples only when they materially disambiguate behavior.**
24. **Require explicit validation before irreversible side effects.**
25. **Define termination and failure conditions for loops.**
26. **Maintain separate trigger and behavioral eval suites.**
27. **Use realistic positive and near-negative trigger cases.**
28. **Evaluate against a no-skill or previous-skill baseline.**
29. **Test observable invariants, not exact wording.**
30. **Inspect execution traces as well as final results.**
31. **Measure context/token overhead.**
32. **Run deletion tests and remove instructions that do not improve eval results.**
33. **Keep the portable core independent of vendor-specific extensions.**
34. **Version skills and rerun evals when behavior, models, or runtimes materially change.**
35. **Never equate schema validation with behavioral correctness.**

That, to me, is the strongest synthesis of the current state of the art.

---

# 28. The resulting mental model

The architecture becomes extremely clean:

```text
                         USER TASK
                            │
                            ▼
                    name + description
                    "Does this apply?"
                            │
                            ▼
                       SKILL.md
                     CONTROL PLANE
                            │
              ┌─────────────┼─────────────┐
              │             │             │
              ▼             ▼             ▼
         references/     scripts/       assets/
          KNOWLEDGE      MECHANICS       SHAPE
              │             │             │
              └─────────────┼─────────────┘
                            ▼
                        VALIDATION
                            │
                            ▼
                           DONE
```

And outside runtime:

```text
                       evals/
                          │
             ┌────────────┴────────────┐
             ▼                         ▼
      trigger correctness       task correctness
             │                         │
             └────────────┬────────────┘
                          ▼
                   execution traces
                          │
                          ▼
                RED → GREEN → HARDEN
                          │
                          ▼
                        PRUNE
                          │
                          ▼
                       RELEASE
```

This is the model I would build around.

---

# 29. What I would **not** copy from existing skill repositories

There are many impressive skill collections, but I would not blindly reproduce their conventions.

For example, Superpowers has an excellent **testing philosophy**, particularly baseline/pressure testing. But some of its metadata conventions and deliberately forceful prose are specific to that ecosystem rather than the portable Agent Skills standard. ([GitHub][5])

Likewise, vendor examples often contain conveniences intended for that vendor.

The right approach is:

```text
Agent Skills specification       → format authority

Official Agent Skills guides     → authoring/eval authority

OpenAI / Anthropic / Gemini etc. → implementation evidence

Strong community projects        → experimental patterns worth adopting

Your own eval suite              → final authority for your environment
```

That last line matters most.

A convention that sounds beautiful but reduces task success should lose.

A strange-looking five-line rule that repeatedly prevents a real failure should stay.

---

# 30. The key insight: optimize for information density, not shortness

“Lean” should not mean:

```text
shortest possible SKILL.md
```

It should mean:

```text
behavior improvement
────────────────────
context cost
```

A 1,500-token skill that prevents a recurring catastrophic failure is lean.

A 200-token skill containing generic advice is bloated.

So the optimization objective for your skill creator could literally be thought of as:

```text
maximize:

    task_success_gain
  + trigger_accuracy
  + behavioral_consistency
  + portability
  + human_comprehension

while minimizing:

    loaded_tokens
  + unnecessary_tool_calls
  + retries
  + duplicated_knowledge
  + choice_entropy
```

That is much closer to the actual engineering problem than “make prompts concise.”

---

# 31. My proposed name for the methodology

For your project documentation, I would call it simply:

## **Eval-Driven Skill Engineering**

with four architectural principles:

```text
Portable Contract
Progressive Disclosure
Executable Determinism
Empirical Minimization
```

Or even more compactly:

> **Route → Guide → Execute → Validate → Measure → Prune**

That is the full lifecycle in six verbs.

It incorporates the strongest parts of the current official guidance without coupling you to one coding agent.

---

# 32. Primary sources I would use as your reference registry

* [Agent Skills — Specification](https://agentskills.io/specification?utm_source=chatgpt.com) — canonical portable structure, metadata constraints, progressive disclosure and validation.
* [Agent Skills — Best practices for skill creators](https://agentskills.io/skill-creation/best-practices?utm_source=chatgpt.com) — scope, context economics, defaults, workflows, validation, references and scripts.
* [Agent Skills — Evaluating skill output quality](https://agentskills.io/skill-creation/evaluating-skills?utm_source=chatgpt.com) — baseline comparison, assertions, grading, token/runtime evaluation and iteration.
* [Agent Skills — Optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions?utm_source=chatgpt.com) — activation testing and positive/negative trigger evals.
* [Agent Skills — Using scripts in skills](https://agentskills.io/skill-creation/using-scripts?utm_source=chatgpt.com) — agent-oriented executable interfaces and deterministic helpers.
* [OpenAI — current Codex skill-creator sample](https://github.com/openai/codex/blob/main/codex-rs/skills/src/assets/samples/skill-creator/SKILL.md?utm_source=chatgpt.com) — particularly valuable for scope, non-obvious guidance and minimal context.
* [OpenAI — Skills skill-creator](https://github.com/openai/skills/blob/main/skills/.system/skill-creator/SKILL.md?utm_source=chatgpt.com) — degrees of freedom, progressive disclosure and resource partitioning.
* [Cursor — Agent Skills documentation](https://prod.cursor.com/docs/skills?utm_source=chatgpt.com) — current implementation and cross-runtime discovery.
* [OpenCode — Agent Skills documentation](https://opencode.ai/docs/skills?utm_source=chatgpt.com) — portable discovery, frontmatter and permission implementation.
* [Superpowers — Writing Skills](https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md?utm_source=chatgpt.com) — useful community reference for RED/GREEN/REFACTOR skill testing.
* [ASD-STE100 official site](https://asd-ste100.org/?utm_source=chatgpt.com) — source standard for controlled technical English concepts.
* [SimpleEnglish — software/agent adaptation of STE principles](https://github.com/AminBlg/SimpleEnglish?utm_source=chatgpt.com) — useful practical interpretation for agent instructions. ([Agent Skills][1])

## Bottom line

If I were establishing the convention for a repository whose **sole purpose is building high-quality coding-agent skills**, I would **not** make “good prompt writing” the core discipline.

I would make **skill engineering** a tested software discipline:

```text
real task / real failure
        ↓
behavioral contract
        ↓
minimal SKILL.md
        ↓
deterministic scripts where possible
        ↓
conditional knowledge
        ↓
trigger evals
        ↓
behavior evals
        ↓
pressure / edge testing
        ↓
context-cost measurement
        ↓
deletion testing
        ↓
versioned release
```

The critical distinction is this:

> **Prose tells the agent how to reason. Code enforces what must be exact. Evals prove that the combination works. Progressive disclosure keeps the price low.**

That is the methodology I would use as the foundation for a state-of-the-art `skill-creator` in 2026.

[1]: https://agentskills.io/specification "Specification - Agent Skills"
[2]: https://agentskills.io/skill-creation/evaluating-skills "Evaluating skill output quality - Agent Skills"
[3]: https://prod.cursor.com/docs/skills?utm_source=chatgpt.com "Agent Skills | Cursor Docs"
[4]: https://agentskills.io/skill-creation/best-practices "Best practices for skill creators - Agent Skills"
[5]: https://github.com/obra/superpowers-skills/blob/main/skills/meta/writing-skills/SKILL.md?utm_source=chatgpt.com "superpowers-skills/skills/meta/writing-skills/SKILL.md at main · obra/superpowers-skills · GitHub"
[6]: https://github.com/openai/skills/blob/main/skills/.system/skill-creator/SKILL.md?utm_source=chatgpt.com "skills/skills/.system/skill-creator/SKILL.md at main · openai/skills · GitHub"
[7]: https://agentskills.io/skill-creation/using-scripts "Using scripts in skills - Agent Skills"
[8]: https://agentskills.io/skill-creation/optimizing-descriptions?utm_source=chatgpt.com "Optimizing skill descriptions - Agent Skills"
[9]: https://asd-ste100.org/?utm_source=chatgpt.com "ASD-STE100 HOME PAGE"
[10]: https://github.com/AminBlg/SimpleEnglish/blob/main/skills/simple-english/references/use-cases.md?utm_source=chatgpt.com "SimpleEnglish/skills/simple-english/references/use-cases.md at main · AminBlg/SimpleEnglish · GitHub"
[11]: https://agentskills.io/skill-creation/evaluating-skills?utm_source=chatgpt.com "Evaluating skill output quality - Agent Skills"

