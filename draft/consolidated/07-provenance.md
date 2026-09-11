# Provenance

The consolidated documents carry the latest state of the specification. The
drafts carry how the project reached that state. Both stay in the repository.

If a consolidated document and a draft disagree, the consolidated document wins.
The drafts explain why a decision exists. They never define what the decision is.

## The sources

Three files in `draft/`, committed in `03bdfdf` and never edited after that
commit.

| File | Lines | Content |
|---|---|---|
| `initial-specs.md` | 3706 | The architecture, the runtime policy, and the lifecycle debate. |
| `skill-creation-methodology.md` | 1642 | The authoring method, the writing style, the evaluation approach. |
| `skillforge-landscape-research.md` | 305 | The prior-art survey. |

Git history holds them. Do not rewrite the drafts to match a later decision.
Record the later decision here instead.

## Where each draft section landed

| Draft section | Consolidated home |
|---|---|
| `initial-specs.md` 29 to 475 and all of `skillforge-landscape-research.md` | `05-landscape.md` |
| `initial-specs.md` 475 to 706 | `01-vision.md`, the definition and the refusals |
| `initial-specs.md` 1083 to 1594 | `01-vision.md` principles, `02-architecture.md` CLI boundary |
| `initial-specs.md` 1594 to 2494 | `04-script-runtime-profile.md` language and shared-code policy |
| `initial-specs.md` 2494 to 2798 | `04-script-runtime-profile.md` runtime baseline and requirements |
| `initial-specs.md` 2798 to 3423 | `04-script-runtime-profile.md` lifecycle phases |
| `initial-specs.md` 3423 to 3586 | `04-script-runtime-profile.md` testing and hooks |
| `initial-specs.md` 3586 to 3638 | `02-architecture.md`, the deterministic surface |
| `skill-creation-methodology.md` 35 to 466 | `03-skill-authoring-standard.md` phases 0 to 3 |
| `skill-creation-methodology.md` 466 to 973 | `03-skill-authoring-standard.md` phase 4 and the writing profile |
| `skill-creation-methodology.md` 973 to 1334 | `03-skill-authoring-standard.md` evaluations and the release gate |
| `skill-creation-methodology.md` 1334 to 1511 | `03-skill-authoring-standard.md` constitution and registry |
| `skill-creation-methodology.md` 1580 | `06-references.md` |

## Superseded positions

The drafts argue a position and then reverse it. The consolidated documents
carry the later position. The earlier one is recorded here so that nobody
reopens a settled argument without the reason it closed.

| Earlier position | Draft | Why it lost |
|---|---|---|
| Skillforge is a runtime that invokes manifest-declared actions, as in `skillforge run skill-a inspect`. | `initial-specs.md` 823, 885, 1083 | It couples every produced skill to the framework and breaks law 5. `01-vision.md` records the reversal. |
| The third lifecycle phase is `cleanup`, and `postflight` is dropped. | `initial-specs.md` 3088, 3638 | The objection was that cleanup must run on the failure path. An unconditional `postflight` removes the objection, so cleanup becomes a sub-step. `04-script-runtime-profile.md` carries the result. |
| Prefer POSIX `sh` for portability. | `initial-specs.md` 2281, 2723 | Bash is present wherever a coding agent runs, and the portability gain did not pay for the loss of arrays and `pipefail`. |
| Treat `uv` as optional and carry a fallback path. | `initial-specs.md` 1759 | A fallback doubles the execution model for no real coverage. `uv` is a day-one hard requirement. |

## Deferred, not rejected

These ideas survive the consolidation as possibilities. No document commits to
them, and no document forbids them.

| Idea | Draft | State |
|---|---|---|
| WebAssembly action modules. | `initial-specs.md` 1045 | Recorded as deferred in `02-architecture.md`. Subprocess execution is sufficient today. |
| A `skillforge tool <domain> <verb>` toolkit for git, filesystem, and template primitives. | `initial-specs.md` 1000 | No consolidated home. It stays behind the promotion path in `02-architecture.md`. Nothing enters core before several skills need it. |
| A dynamic Rust plugin system. | `initial-specs.md` 1000 to 1045 | Rejected in `02-architecture.md`. Native ABI coupling costs more than the extension model returns. |

## Absorbed with new wording

The idea survives and the draft phrasing does not. Search the consolidated
document, not the draft, when you want the current wording.

| Draft idea | Now reads as |
|---|---|
| Optimize for information density, not shortness. | `03-skill-authoring-standard.md` 399: lean means behavior improvement divided by context cost. |
| What I would not copy from existing skill repositories. | The authority ranking in `06-references.md` and the transfer limits in `05-landscape.md`. |
| The deterministic surface and the agent surface. | `02-architecture.md`, under the same name. |
| Four step types for classifying a workflow step. | `03-skill-authoring-standard.md` phase 3. |

## Decisions made after the drafts

These decisions have no draft origin. They were settled while consolidating, and
this table is their only record of where they came from.

| Decision | Home | Reason |
|---|---|---|
| Skillforge installs its meta-skills onto the user host under the `sf-` prefix. | `01-vision.md`, `02-architecture.md` | The prefix defines what `skillforge project` is allowed to delete, so re-projection never touches a user skill. |
| The prefix lives in the source tree rather than in a projection-time rename. | `02-architecture.md` | Projection stays a one-way copy that a reader can diff by name. |
| The prefix grants no capability. | `02-architecture.md` | A prefix that carries a privilege becomes the privileged path that the dogfooding constraint prohibits. |
| `skillforge` is a skill-local requirement with no special status. | `04-script-runtime-profile.md` | A skill depends on a tool when the tool is its subject. It never depends on a tool because the framework installed it. |
| A user who builds skills keeps them in their own repository, which has the same shape as the Skillforge `skills/` subtree. | `02-architecture.md` | The drafts describe one development repository. Two exist, and both pass through the same verbs. |
| `sf-setup` is the entry point that prepares a user repository. | `01-vision.md`, `02-architecture.md` | Setup reads existing state and decides what to leave alone, which is judgment work. Principle 1 puts judgment in a skill, not in a CLI verb. |
| An irreversible or remotely destructive script separates `plan` from `apply` and consumes the saved plan artifact. | `04-script-runtime-profile.md` | `--dry-run` alone leaves a window in which the state changes between the preview and the execution. Terraform's saved plan closes it. |
| Bounded output reports total, emitted, and truncated, and names an artifact holding the full result. | `04-script-runtime-profile.md` | A truncation the caller cannot detect turns a partial answer into a wrong one. |
| Size limits split into specification errors, upstream warnings, and house targets, with `check --strict` for continuous integration. | `03-skill-authoring-standard.md` | The upstream 5,000-token and 500-line figures are recommendations. Reporting them as errors makes a style preference look normative. |
| Revisions compare lexicographically: constraints, behavior, routing, stability, then cost. | `03-skill-authoring-standard.md` | The draft's additive objective at `skill-creation-methodology.md` 1534 sums quantities with incompatible units. Choice entropy survives as the countable proxy `unconstrained_choice_count`. |
| The build materializes an allowlisted package closure, and an unknown top-level entry is an error. | `02-architecture.md` | Cargo's model. An exclusion list silently ships whatever it failed to anticipate. |
| The framework runtime vendors whole, as `scripts/skillforge_runtime/`, with no import rewriting and no `sys.path` edit. | `02-architecture.md`, `04-script-runtime-profile.md` | Python puts the executed script's directory first on the module search path, so the package imports by name in both trees. Selective module copying needs import analysis and breaks on dynamic imports. |
| Tests live at the skill root at every complexity level, never under `scripts/`. | `04-script-runtime-profile.md` | The build copies `scripts/` whole, so `scripts/tests/` would ship to the host. |
| The semantic contract stays an authoring artifact and does not become a checked-in manifest. | `03-skill-authoring-standard.md` | No verb reads it yet. Mandating storage before a tool consumes it adds ceremony without capability. |

## How to add to this record

Every later decision that reverses a consolidated document gets a row in
"Superseded positions" and an edit to the document itself. Do not delete a
document section without recording where the idea went. A missing row means the
project lost an input.
