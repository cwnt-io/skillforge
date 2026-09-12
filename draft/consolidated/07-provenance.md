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
| Every skill maintains two evaluation suites: 10 positive and 10 negative trigger cases at 3 runs each, plus a baseline-against-candidate behavioral suite. | `skill-creation-methodology.md` 973 to 1334 | The framework's product is conventions and defaults, not a measurement rig. Specifying a harness before any skill exists sets a scoring rule by guesswork and adds ceremony nobody performs. `03-skill-authoring-standard.md` section 13 keeps the reading rules and drops the apparatus. |

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
| The shared library vendors whole, as `scripts/skillforge_std/`, with no import rewriting and no `sys.path` edit. | `02-architecture.md`, `04-script-runtime-profile.md` | Python puts the executed script's directory first on the module search path, so the package imports by name in both trees. Selective module copying needs import analysis and breaks on dynamic imports. |
| The package is named `skillforge_std` rather than `skillforge_runtime`. | `04-script-runtime-profile.md` | It is the standard library of a skill script, and it runs where the CLI is absent. "Runtime" read as the runtime the CLI needs, which is the opposite of what the package is. |
| Tests live at the skill root at every complexity level, never under `scripts/`. | `04-script-runtime-profile.md` | The build copies `scripts/` whole, so `scripts/tests/` would ship to the host. |
| The semantic contract stays an authoring artifact and does not become a checked-in manifest. | `03-skill-authoring-standard.md` | No verb reads it yet. Mandating storage before a tool consumes it adds ceremony without capability. |
| The authoring standard is one canonical file at `docs/skill-authoring-standard.md`, and both `skillforge check` and the `sf-` meta-skills derive from it. | `03-skill-authoring-standard.md` | The dogfooding constraint requires one standard for the bundled pack and for a user's own skills. Two copies of the rules drift, and a derived copy that adds a rule becomes the privileged path the constraint prohibits. |
| An unresolved question lives in a numbered entry in `08-open-questions.md`, never as a hedge inside the document it will change. | `00-README.md`, `08-open-questions.md` | A consolidated document records the latest state. A question written into it reads as a decision nobody made. A separate queue keeps each question addressable on its own, with its target document named. |
| Skillforge specifies no evaluation harness, no scoring rubric, and no graded test suite. | `01-vision.md`, `03-skill-authoring-standard.md`, `02-architecture.md` | The framework's product is conventions, rules, and sane defaults. A harness is infrastructure designed before any skill exists, so its scoring rule encodes a guess. Drift and adjustment surface through daily use, and a framework cannot predict them in advance. |
| The release gate drops its Trigger, Behavior, and Regression rows. | `03-skill-authoring-standard.md` | Each one depends on a graded run. A gate row nobody can apply blocks nothing, and it makes the gate look stronger than it is. Every remaining row is checkable by reading or by `skillforge check`. |
| The method is renamed from Eval-Driven Skill Engineering to Contract-Driven Skill Engineering, and the verb Measure is dropped. | `01-vision.md`, `03-skill-authoring-standard.md` | The name promised a measurement loop the project does not implement. The contract in phase 1 is what actually drives the method. |
| Phase 2 becomes Observe, and it accepts a source skill as the starting point. | `03-skill-authoring-standard.md` | The old Baseline phase required running tasks with no skill loaded. When a skill already exists, the source skill is the starting point, and reading it is cheaper and more informative than a synthetic run. |
| `sf-create` takes an existing skill as input through a `--from` mode, and emits `DERIVED.md`. | `02-architecture.md` | Deriving a compliant skill from an existing one is the same work as authoring, with the starting point on disk. A separate migration skill would duplicate the authoring path. `DERIVED.md` is the only comparison the framework makes between a starting point and a result. |
| The Behavior class in the validation layers is replaced by a Load class. | `02-architecture.md`, `05-landscape.md` | The Behavior class asked whether evaluations show the skill works, and no evaluations exist. The Load class asks the host whether it accepts the skill, which is deterministic, cheap, and catches a defect class schema validation misses. |
| A skill's rules prevail over a contradicting prompt, and the agent reports the instruction it declined. | `03-skill-authoring-standard.md` | The user selected the skill for the task, so the skill is the contract. A skill that drops its rules on request guarantees nothing, and a prose rule that yields while a script rule holds makes enforcement depend on the implementation rather than on the rule. |
| An exception lives inside the rule it modifies, in one of four declared forms, rather than in a separate override section. | `03-skill-authoring-standard.md` | A reader who finds a rule must find its exception in the same place. A separate list splits one decision across two sections and goes stale. |
| A projection writes real files and never a symlink. | `02-architecture.md` | A symlink does not survive a Windows clone or a downloaded archive. `ayghri/i-have-adhd` hit this and converted its projected copy back to a real file, which is why its sync check exists. |
| `skillforge project --check` freshly materializes from the canonical source and compares that result with every installed tree. | `02-architecture.md` | Comparing a host with an existing `dist/` tree can prove equality between two stale copies. Reusing the real projection plan without writing makes the check pass exactly when projection would be a no-op. |
| Skill repositories run strict validation during creation, before materialization, in a pre-commit hook, and in continuous integration. | `02-architecture.md`, `03-skill-authoring-standard.md` | Projection equality says nothing about whether the canonical source follows the house profile. Local hooks give early feedback, while continuous integration supplies enforcement when hooks are absent or skipped. |
| Every machine-verifiable rule in the authoring standard has accepted and rejected conformance fixtures for its Policy implementation. | `02-architecture.md`, `03-skill-authoring-standard.md` | A canonical standard and a passing repository check can still disagree if the checker implements an old rule. Rule-named fixtures make that disagreement fail the CLI release gate. |
| The load class runs one check per host rather than one universal check. | `02-architecture.md` | Each host has its own install path, list command, and report format. The same repository carries two load workflows for two hosts, not one parameterized workflow. |
| The house profile gains a safety policy that governs what a skill instructs an agent to do. | `03-skill-authoring-standard.md`, `02-architecture.md` | The Policy class checked shape only. A skill that told an agent to read a token, edit a shell profile, or pipe a remote script into a shell passed every check the framework defined. |
| Fetched or third-party content is data, and a skill states that rule at the step that reads it. | `03-skill-authoring-standard.md` | This is the first or second entry in every current threat model, and the original proposal missed it. OWASP lists it as AST05, and the Agent Skills vendors warn that a fetched page is a second author who passed no review. |
| Every instruction lives in visible text, with no exception. | `03-skill-authoring-standard.md` | Documented attacks hide instructions in HTML comments and invisible Unicode so that the agent reads what the reviewer cannot. Review is the only control the format has, so text that bypasses review defeats it entirely. |
| Three prohibitions admit a declared subject, under four conditions together. | `03-skill-authoring-standard.md` | A dotfiles skill edits a shell profile and a hook skill installs a hook. A flat ban would forbid the legitimate case and teach authors to ignore the list. The prohibition is on the undeclared and the unnecessary. |
| A credential never reaches the agent's context, even in a skill whose subject is secret handling. | `03-skill-authoring-standard.md` | A skill cannot un-disclose a value the model has read. The secret goes to a tool, a broker, or a vault CLI, and the value never returns to the model. |
| Skillforge never reports a skill as safe, and a safety finding is an error rather than a strict-mode warning. | `02-architecture.md`, `03-skill-authoring-standard.md` | Prose is not a sandbox, and enforcement belongs to the host permission system. A framework that implies otherwise sells a control it does not own. A safety rule is also not a style preference, so it does not wait for a flag. |
| A claim a skill makes about itself is checked by the framework, and a claim a skill makes about the outside world is checked by the skill's own tests. | `03-skill-authoring-standard.md`, `02-architecture.md` | A skill is prose with its own subject, and the framework knows no skill's subject. Only the internal column is decidable without domain knowledge, and it is decidable for every skill, which is what makes one rule bind all of them. |
| The prose and `side_effects` must agree about every path a skill writes. | `03-skill-authoring-standard.md` | A skill that moves its output path edits one of the two places and forgets the other. The check cannot tell which one is correct, and it does not need to. A disagreement inside one package is always a defect. |
| A retired path or command is banned by name in a per-skill `retired.toml`, and the ban never expires. | `03-skill-authoring-standard.md`, `02-architecture.md` | `ayghri/i-have-adhd` asserts the absence of an abandoned path, and that negative assertion is the part worth copying. A stale sentence is well formed and reads like every other sentence, so only a list that remembers the old value catches it. The registry is per skill so that it travels when the skill moves between packs. |
| A claim test is required when `skillforge check` detects an external literal, never for every skill. | `03-skill-authoring-standard.md`, `04-script-runtime-profile.md` | A blanket rule gives a skill about commit messages an empty test file, and an empty test file teaches the author to skip the file. Extracting the literals turns "when a skill states one" from a judgment call into a match. |
| The `sf-review` agent pass runs in continuous integration and never in a pre-commit hook. | `03-skill-authoring-standard.md`, `04-script-runtime-profile.md` | Judgment rows in the release gate need a reader, and an agent is the available reader. The pass is not deterministic, so two runs on the same input can disagree. It emits findings rather than a verdict, and only a deterministic check blocks a commit. |
| Four acts carry four verbs that never cross: Skillforge inspects a skill, a skill's own suite tests it, the CLI suite self-tests the crate, and a skill validates its output at run time. | `02-architecture.md`, `03-skill-authoring-standard.md`, `04-script-runtime-profile.md` | One word covering two domains hides a boundary. Section 12 of the authoring standard held run-time validation and static inspection under one heading, and the architecture document described a build that "validates and tests" in one clause. Naming the verbs separates the domains without moving any rule. |
| The CLI carries no verb that runs a skill's tests, and running a skill's suite is listed outside core. | `02-architecture.md` | A skill's assertions encode that skill's subject, and the CLI boundary excludes what one particular skill wants. `01-vision.md` keeps scripts with the skill and prefers a standard ecosystem runner. The promotion path runs one way, so a verb invented in core proves nothing. A `skillforge test` verb would also put the tool's name on a result about the outside world, which the validation layers already forbid. |
| The release-gate stage that runs a skill's tests is named `skill-tests`, not `test-scripts`. | `03-skill-authoring-standard.md` | A continuous integration job is not a CLI verb, so the pipeline can still call the skill's runner. The stage name has to say whose tests it delegates to, because `test-scripts` reads like a Skillforge capability. |
| `evals/` stays in the tree as an optional directory with no required shape. | `02-architecture.md`, `03-skill-authoring-standard.md` | An author who gathers evidence needs a place to keep it that never ships. Prescribing `evals.json` and `trigger-evals.json` would define a format nothing reads. |
| A user skill repository carries a root `AGENTS.md`, and Skillforge owns only a marker-delimited region inside it. | `02-architecture.md` | `AGENTS.md` is a conventional agent entry point, but it is also a shared host for project instructions and other tools. The release-kit and spec-driven-docs exemplars show that named regions can coexist while each tool updates only its own instructions. |
| The Skillforge region contains stable framework routing and commands; repository-specific maps and prose remain project-owned outside it. | `02-architecture.md` | A managed region must be safely replaceable. Bespoke setup prose is not safely replaceable, while canonical paths, precedence, and exact verification commands are. |
| `sf-setup` preserves text outside its `AGENTS.md` markers, refuses ambiguous markers and symlinks, and requires confirmation before it replaces its region. | `02-architecture.md` | Skillforge has no project manifest that can distinguish an older installed block from a local edit. Preview and confirmation fit the judgment-owning setup skill without inventing persistent state, while the markers keep its ownership narrower than the host document. |

## How to add to this record

Every later decision that reverses a consolidated document gets a row in
"Superseded positions" and an edit to the document itself. Do not delete a
document section without recording where the idea went. A missing row means the
project lost an input.
