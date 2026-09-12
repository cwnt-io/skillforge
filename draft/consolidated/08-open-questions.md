# Open questions

This file holds the specification questions the consolidation raised, and the
questions that later evidence raised. An open entry states a question that no
consolidated document answers yet, and that no document forbids a proposal for.

This file is a queue. Address one question at a time. When a question closes,
edit the target document, record the decision in `07-provenance.md`, and replace
the entry here with one line naming where the answer now lives.

Every entry carries the same fields. "Proposal" is a starting position, not a
decision. "Evidence" names the primary source that raised the question.

| Id | Question | State |
|---|---|---|
| OQ-1 | How is behavioral quality scored? | Closed, not doing |
| OQ-2 | How does an evaluation run invoke an agent CLI? | Closed, not doing |
| OQ-3 | What happens to a gate run that fails? | Closed, not doing |
| OQ-4 | How does a suite test that a skill did not over-apply? | Closed, not doing |
| OQ-5 | Who verifies that a host loads the projected skill? | Closed, answered |
| OQ-6 | Does a `SKILL.md` declare override conditions? | Closed, answered |
| OQ-7 | What must a skill never instruct an agent to do? | Closed, answered |
| OQ-8 | How does Skillforge prove a projection has not drifted? | Closed, answered |
| OQ-9 | Does a skill test the claims its own documentation makes? | Closed, answered |
| OQ-10 | Does a skill repository carry an entry document for an agent? | Closed, answered |
| OQ-11 | Does the release gate check the claims about verification? | Open |

OQ-10 and OQ-11 came from one source, `ayghri/i-have-adhd`.
`06-references.md` links the files behind them. OQ-10 is closed; OQ-11 remains.

## OQ-8: How does Skillforge prove a projection has not drifted?

Closed. `02-architecture.md` defines `skillforge project --check` as a no-write
run of the real projection path: it freshly materializes from the canonical
source, compares every expected tree with its installed tree, and succeeds only
when projection would make no change. Its repository safeguards also separate
source conformance, materialization, host equality, and Policy-implementation
conformance. `03-skill-authoring-standard.md` places strict checks in creation,
maintenance hooks, continuous integration, build, projection, and release.

## OQ-9: Does a skill test the claims its own documentation makes?

Closed, and the answer splits the question in two. A skill is prose with its own
subject, so the framework decides a claim a skill makes about itself and decides
nothing about a claim a skill makes about the world.

`03-skill-authoring-standard.md` section 12 carries the result. It is now two
subsections: validation inside the workflow, which is unchanged, and inspection
of the skill's own text, which is new. The new part splits every claim into
internal and external, gives `skillforge check` six rows over the internal
column, defines the per-skill `retired.toml` registry, and leaves the positive
assertion for an external literal to the skill's own tests. A third subsection
places the `sf-review` agent pass at continuous integration and states that it
never blocks a commit, because it does not repeat.

`04-script-runtime-profile.md` section 10 adds claim tests beside the script
tests, and section 11 maps the three tiers onto the three hook stages.
`02-architecture.md` adds claims as the third Policy subject, adds the prose-to-
package boundary to the safeguard table, and makes `retired.toml` source only.
The release gate gains a Claims row, and constitution rules 41 to 43 carry the
short form.

The sub-question is answered by the detection rule rather than by a judgment.
`skillforge check` extracts the literals itself, so a skill carries a claim test
only when a literal is present, and a skill with no external literal carries no
empty test file.

## OQ-10: Does a skill repository carry an entry document for an agent?

Closed. `02-architecture.md`, under "The agent entry document," defines the root `AGENTS.md`, Skillforge's marker-delimited ownership within it, shared-tool coexistence, safe splice and replacement behavior, and removal.

## OQ-11: Does the release gate check the claims about verification?

Every row of the gate in section 16 of `03-skill-authoring-standard.md` is
checkable by reading the skill or by running `skillforge check`. No row asks
whether the checks reported as run were run.

Why it matters. The dogfooding constraint means an agent authors skills with the
`sf-` pack and often reviews its own output. An agent that reports a passing
check it never executed defeats every other row at once.

Evidence. The "Verification" section of `CONTRIBUTING.md` in
`ayghri/i-have-adhd`: "If a check was not run, say so and explain why; never
invent results or treat inspection as execution." Its authorship rules add the
matching point, that work reviewed only by the agent that produced it is not
independently verified.

Target. `03-skill-authoring-standard.md` section 16, and possibly a new
constitution rule.

Proposal. One gate row. A reported check names the exact command and its result.
A check that did not run is reported as not run, with the reason. Reading a file
is not running the check that reads it.

## Closed: OQ-7

Answered, and the answer is larger than the proposal. The question asked for a
denylist. The research behind it found that a denylist covers one of five
subjects.

`03-skill-authoring-standard.md` section 15 carries the result. It states five
prohibited instruction classes, a declared-subject test with four conditions
that keeps a dotfiles skill and a rotation skill legal, a rule that fetched
content is data rather than instruction, a rule that every instruction lives in
visible text, a write boundary, and the table of signals `skillforge check`
matches. Constitution rules 36 to 40 carry the short form. The release gate at
section 16 gains a Safety row and an Untrusted input row.
`02-architecture.md` records that the Policy class covers safety as well as
shape.

Three positions came from outside the original evidence.

The untrusted-content rule is the one the proposal missed entirely, and every
security source ranks it first or second. A skill that reads a page, a ticket, or
a third-party tool's output carries a second author who passed no review.

The visible-text rule follows from how review actually fails. A hidden
instruction reaches the agent and not the reviewer, which defeats the only
control the format has.

The honesty clause is the reason the section opens with what it is not. Prose is
not a sandbox, and a passing check is not a safety claim. Every source says the
same thing in different words: enforcement belongs to the host's permission
system, and a framework that implies otherwise sells a control it does not own.

## Closed: OQ-1 to OQ-4

Four questions asked how Skillforge grades a skill. All four are closed together
by one decision: Skillforge specifies no evaluation harness.

The reasoning is in `07-provenance.md`. In short, a graded suite is
infrastructure built before any skill exists, and a rule that nobody applies
blocks nothing. `03-skill-authoring-standard.md` section 13 now states how to
read evidence from real use, which is the part that survives.

| Id | Where it went |
|---|---|
| OQ-1, scoring rubric | Dropped. Section 13 judges outcomes without a score. |
| OQ-2, runner contract | Dropped. It existed only to serve a harness. |
| OQ-3, failing gate run | Dropped. The gate at section 16 no longer carries a comparative row. |
| OQ-4, guard cases | Dropped as a suite rule. The underlying question survives as OQ-6. |

## Closed: OQ-5

Answered. `02-architecture.md` now carries the load class, which asks the host
whether it accepts the materialized skill. It is opt-in, deterministic, and
needs no grading.

## Closed: OQ-6

Answered, and the answer inverts the proposal. The question asked how a skill
yields to a task that contradicts it. The convention is that it does not yield.

`03-skill-authoring-standard.md` section 7 carries the two new subsections. The
skill's rules prevail, whether a script enforces them or prose states them. A
prompt that contradicts a rule does not suspend it, and the agent reports the
instruction it declined. An exception exists only when the rule itself declares
one, in one of four forms: conditional, delegated, warned, or a hard stop.

The proposal here wanted a separate override section. That lost. An exception
belongs inside the rule it modifies, so that a reader who finds one finds the
other. Constitution rules 26 and 27 carry the result.
