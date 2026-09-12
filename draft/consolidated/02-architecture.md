# Skillforge architecture

## The five layers

| Layer | Owns |
|---|---|
| Source | Canonical skills, shared libraries, templates. One copy of everything. |
| Policy | The house profile on top of the Agent Skills specification. |
| Meta-skill | Agent-facing skills that create, review, and improve skills. |
| CLI | Deterministic framework mechanics, written in Rust. |
| Projection | One-way materialization into agent skill directories. |

Each layer depends only on the layers above it in that table.

## The base format

The Agent Skills open specification is the wire format. Skillforge does not
define a competing serialization.

```text
skill/
├── SKILL.md
├── scripts/
├── references/
└── assets/
```

The relationship matches other tool ecosystems.

```text
Agent Skills specification   →   base format
Skillforge profile           →   stricter conventions
Skillforge skills            →   instances
```

A produced skill stays valid against the upstream specification. A produced
skill also satisfies extra Skillforge rules that the upstream validator does not
check.

## Source tree

The development repository carries more than a distributable skill carries.

```text
skillforge/
├── crates/               # the Rust CLI
├── lib/                  # shared source, vendored at build time
│   ├── python/           # skillforge_std, plus sf- skill primitives
│   └── bash/
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md
│       ├── scripts/
│       ├── references/
│       ├── assets/
│       ├── tests/
│       └── evals/          # optional, unstructured
└── docs/
```

`evals/` and `tests/` belong to the development repository. A Skill Package
MUST NOT carry either one.

`evals/` is optional and carries no required shape. Skillforge defines no
evaluation format, because it runs no evaluation. The directory exists so that
an author who gathers evidence has a place to keep it that never ships.

### The user skill repository

A user who builds skills keeps them in their own repository. Skillforge is a
build tool outside that repository, the way Cargo is a build tool outside a
crate.

```text
my-skills/
├── AGENTS.md             # shared host; Skillforge owns one marked block
├── lib/                   # optional, primitives this repository's skills share
├── skills/
│   └── deploy-api/
│       ├── SKILL.md
│       ├── scripts/
│       ├── references/
│       ├── assets/
│       ├── tests/
│       └── evals/          # optional
└── dist/                  # build output, not committed
```

The shape matches the `skills/` subtree of the Skillforge repository, because
both repositories pass through the same verbs. The Skillforge repository carries
`crates/` in addition, because it also builds the CLI.

The `sf-setup` meta-skill creates this layout. It works on an empty repository
and on a repository that already holds skills.

### The agent entry document

A user skill repository carries `AGENTS.md` at its root. It is the conventional
entry document for an agent, and it is a shared host document rather than a
Skillforge-generated file. The repository and other tools may own everything
outside this region:

```markdown
<!-- BEGIN skillforge -->

## Skill development

- Canonical skill sources live under `skills/`; shared source lives under `lib/`.
- Treat `dist/` and host projections as generated output. Never edit them directly.
- Read the affected skill's `SKILL.md` before changing it; its procedural rules remain authoritative.
- Run `skillforge check --strict` before handoff.
- Run `skillforge project --check` when projections may have changed.

<!-- END skillforge -->
```

Skillforge owns exactly the two markers and the lines between them. The block
contains only stable Skillforge routing, source boundaries, precedence, and
release-assurance commands. A repository-specific introduction, reading order,
area map, and unrelated commands stay outside the markers under project
ownership. Another tool may own a differently named region in the same
document.

`sf-setup` creates `AGENTS.md` with the block when the file is absent. When the
file exists without the block, setup appends it. When one valid block exists,
setup renders the current block and previews the replacement. It changes the
existing block only after the user confirms. Every byte outside the markers
survives unchanged.

Setup refuses rather than guessing when `AGENTS.md` is a symlink, either marker
is missing, the markers are reversed, or more than one pair exists. Content
inside the markers is tool-owned rather than a customization surface; setup
warns that replacement discards edits there and tells the user to move local
instructions outside the region. Removing the Skillforge repository integration
removes only this region, and removes `AGENTS.md` only when no meaningful content
remains.

## Materialization

The repository source and the distributed skill are not the same tree.

```text
source                              distribution
──────                              ────────────

lib/python/skillforge_std/          skills/create/
        │                           └── scripts/
        ├────────────┐                  ├── inspect.py
        ▼            ▼                  └── skillforge_std/
skills/create   skills/review               ├── checks.py
                                            └── ...
```

Shared code stays DRY in source. A skill opts in through `skillforge.toml`, and
the build copies the whole `skillforge_std` package into that skill's
`scripts/`. The import reads the same in both trees, and nothing manipulates
`sys.path`. `04-script-runtime-profile.md` defines the package and the reason
the build copies all of it rather than a computed subset.

`skillforge_std` is the standard library of a skill script, not part of the CLI.
The Rust binary runs at build time on the author's machine. The library runs
later, on the user's host, inside a skill's own `scripts/`, where no CLI is
present. A vendored skill keeps working after the user removes Skillforge.

The result is an ordinary Agent Skill with no path outside its own directory.

### The package closure

The build works from an allowlist. A file ships because a rule names it, never
because no rule excluded it.

Materialized by default, when present:

```text
<skill>/
├── SKILL.md
├── scripts/
├── references/
├── assets/
├── agents/
├── LICENSE*
└── NOTICE*
```

Source only, and never included in a Skill Package:

```text
skillforge.toml   retired.toml      tests/
evals/            DERIVED.md        .coverage
.pytest_cache/    __pycache__/      *.pyc
editor files      temporary files   build output
```

Anything else ships only through an explicit entry in `skillforge.toml`.

```toml
[package]
include = ["schemas/**"]
```

An unrecognized top-level entry in a skill directory is an error. The build does
not copy it silently and does not drop it silently. The Agent Skills
specification permits extra files, so a fixed forever-list blocks a legitimate
extension. An explicit list keeps the closure both open and known.

Three rules follow from this.

`skillforge build --list` prints the exact sorted closure. An author sees what
ships before anything is published.

`skillforge pack` reads `dist/<skill>` and never the source tree. Packing from
source is how a development file reaches a user.

Skillforge Build checks the fresh Skill Package, and the pipeline then calls the
skill's own test runner against it. A skill that passes its own tests in the
source repository and fails in `dist/` has a vendoring defect, and only an
isolated run finds it. The two acts stay separate, because inspection belongs to
Skillforge and the tests belong to the skill.

### The self-containment rule

A distributable skill must be runtime-self-contained. A script inside
`skill-a/scripts/` must not reach into:

```text
../skill-b/
../../shared/
$SKILLFORGE_HOME/lib/
```

Cross-skill imports at runtime are prohibited. Cross-skill reuse happens at
build time through vendoring.

## Projection

Projection is one-way and idempotent.

```text
            repo/skills/<skill>/        authoritative
                     │
                  build
                     │
                     ▼
            dist/<skill>/               Skill Package
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
  ~/.agents/skills/     ~/.claude/skills/
      projection            projection
```

Installed trees are disposable. Skillforge never reads them back as a source.
The remedy for a hand edit or a stale installed tree is to re-project.

`skillforge project --check` proves whether a projection is current. It runs the
same planning and materialization path as `skillforge project`, but writes the
expected trees to temporary storage instead of to a host. It then compares each
fresh expected tree with its installed tree. The comparison covers missing,
unexpected, and changed entries, file contents, and executable permissions.

The check succeeds exactly when `skillforge project` would make no change. On a
difference it exits non-zero, reports the paths and kinds of change, and prints
the exact `skillforge project` command that repairs the projection. It never
compares against an existing `dist/` tree, because that tree may itself be
stale. The source repository is the start of every check.

The `sf-` pack ships a continuous integration job that runs the check for every
host it projects to. The result proves equality at the time of the run; it does
not claim that a host tree cannot be edited afterward.

A projection writes real files. It never writes a symlink, even when the host
accepts one. A symlink does not survive a Windows clone or a downloaded archive,
so a skill tree that depends on one breaks for a subset of users with no error
that names the cause.

The projection layer stays deliberately narrow. It covers the hosts the project
cares about. It does not grow into remote discovery, a registry, or a
provenance system.

### The `sf-` namespace

Installing Skillforge installs its meta-skills. They land beside the user's own
skills in the same flat directory, so they carry a reserved prefix.

```text
~/.agents/skills/
├── sf-setup/           projected, Skillforge owns it
├── sf-create/          projected, Skillforge owns it
├── sf-review/          projected, Skillforge owns it
└── deploy-api/         the user owns it
```

The prefix defines what `skillforge project` is allowed to destroy. Projection
rewrites a target directory, and re-projection is the remedy for a hand edit.
That verb is only safe with a boundary.

| Directory | `skillforge project` behavior |
|---|---|
| Matches `sf-*` | Deletes and rewrites it. |
| Anything else | Never touches it. |

A user skill named `create` and the shipped `sf-create` therefore never collide.

Two rules keep the namespace honest.

The prefix lives in the source tree. The directory is `skills/sf-create/`, not a
rename applied during the build. Projection stays a one-way copy that a reader
can diff by name.

The prefix carries no capability. The CLI must not treat an `sf-` skill
differently at authoring time, build time, or install time. It is a deletion
boundary and nothing else. A prefix that grants a privilege becomes the
privileged path that `01-vision.md` prohibits.

### `sf-setup` is the entry point

`sf-setup` prepares a repository to build skills with Skillforge. It is the
first meta-skill a user runs. It produces the layout above and installs the
Skillforge-owned block in the repository's `AGENTS.md`.

Setup is a skill rather than a tenth CLI verb, because most of the work is
judgment. The skill reads what the repository already contains, asks which hosts
the user targets, and decides what to create and what to leave alone. It never
replaces user-owned content. For a shared host file, it previews the change,
updates only its named region, and asks before it writes. Principle 1 in
`01-vision.md` puts that class of work in a skill.

The mechanical parts stay in the CLI. `sf-setup` calls `skillforge new` for a
skill directory and `skillforge doctor` for the runtime baseline. It does not
reimplement either one, so the CLI boundary below does not move.

### `sf-create` derives as well as creates

Most skills a user wants already exist in some form: a skill written by hand, a
skill copied from another project, or a prompt that grew into a file. Turning
one of those into a compliant skill is the same work as writing a new one, with
the starting point already on disk.

That is a mode of `sf-create`, not a second meta-skill. The skill takes an
existing skill directory or file as input.

```text
sf-create --from <path>
```

Five steps.

1. Read the source whole: frontmatter, body, `scripts/`, `references/`, `assets/`.
2. Write an inventory of what the source declares and what it does.
3. Rewrite each part against the authoring standard, and record one line per change.
4. Emit the new skill, plus `DERIVED.md` naming the source and listing the changes.
5. Run `skillforge check --strict`, and stop on the first finding.

`DERIVED.md` stays in the development repository and never materializes. It is
the record of what the house profile added, which is the only comparison this
framework makes between a starting point and a result.

The source is never modified. The output is a new skill directory.

## The CLI boundary

The Rust CLI implements the Skillforge model. It does not implement what any
particular skill wants to accomplish.

In core:

```text
skillforge new
skillforge check
skillforge build
skillforge project
skillforge install
skillforge list
skillforge doctor
skillforge pack
```

Outside core:

```text
parse a Python package
inspect Git history for one workflow
normalize YAML for one skill
query GitHub for one skill's needs
run a skill's own test suite
```

Those belong to the skill that needs them.

### Assurance domains and reserved names

Four subjects participate in release assurance. Name the subject whenever a
broad word such as "test," "validation," or "release" would leave it
ambiguous.

| Domain | Definition | Authority |
|---|---|---|
| Skillforge Framework | The Skillforge CLI, its libraries, and its Policy implementation. | Skillforge Tests |
| Skill Repository | The canonical skill sources, tests, and repository configuration maintained by a user or team. | The User Skill Release Gate in repository continuous integration |
| Skill Package | One freshly built, self-contained skill directory containing exactly what Skillforge will distribute or install. | Skill Package Test |
| Installed Skill | One Skill Package copied into one Host Installation. | Installed Skill Validation and, when configured, a Host Compatibility Test |

An **Agent Host** is a product or agent runtime that discovers and uses skills.
A **Host Installation** is one configured skill location belonging to one Agent
Host. An **Installed Skill** is the copy of a Skill Package at that location.
These names distinguish the product, its configured location, and the files
installed there.

Use these complete names for assurance work.

| Name | Exact meaning | Owner |
|---|---|---|
| Skillforge Check | Read a skill and report Agent Skills specification and Skillforge Policy findings without executing skill code. | `skillforge check` |
| Skillforge Build | Produce a fresh Skill Package from the allowlisted closure of canonical source. | `skillforge build` |
| Skill Package Test | Execute the tests owned by a skill against its freshly built Skill Package. | The Skill Repository's selected test runner |
| Skillforge Tests | Execute the tests of the Skillforge Framework, including Policy conformance fixtures. | The Skillforge Framework's test runner |
| Installed Skill Validation | Build the expected Skill Package and prove that its files equal the corresponding Installed Skill. | `skillforge project --check` |
| Host Compatibility Test | Install a Skill Package into a scratch Host Installation and ask that Agent Host whether it discovers and enables the skill. | One host-specific continuous integration job |
| Skill Package Review | Apply human or agent judgment to the authored skill and emit findings that deterministic checks cannot decide. | A human reviewer or `sf-review` |

A portable Skill Package can pass Skillforge Check and still fail a Host
Compatibility Test. The Agent Skills specification does not define every
host-specific manifest field, discovery rule, parser behavior, or supported
extension. The test answers only whether that version of that Agent Host can
discover and enable the package. It does not test the skill's behavior, and it
is optional because the host CLI may be unavailable.

Three complete names describe release decisions rather than checks:

- The **User Skill Release Gate** is the continuous integration decision that
  all required checks for one Skill Repository revision passed.
- A **User Skill Release** publishes or otherwise distributes the Skill
  Packages built from that approved revision.
- The **Skillforge Framework Release Gate** is the continuous integration
  decision that the Skillforge Framework, including Skillforge Tests, is ready
  for a Skillforge Framework Release.

**Skill Runtime Validation** belongs to a real use of a skill. It is an optional
step in that skill's workflow, owned by the skill and performed only when the
skill runs. It is not part of either release gate, and Skillforge does not run
it on the user's behalf.

Release assurance is the umbrella for the evidence produced before release. It
is not another operation. Never use unqualified "verification," "test,"
"validation," "review," "gate," or "release" where one of the complete names
above identifies the subject.

Skillforge Check reads a skill and executes no skill code. A Skill Package Test
belong to the Skill Repository, and Skillforge Tests belong to the Skillforge
Framework.

The CLI carries no verb that runs a skill's tests. Three rules already settle
it. A skill's assertions encode that skill's subject, and the CLI boundary above
excludes what one particular skill wants. `01-vision.md` keeps scripts with the
skill and prefers a standard ecosystem runner over a Skillforge-specific one.
The promotion path above runs one way, and a verb invented in core proves
nothing.

The finding classes below carry the last reason. Skillforge decides a claim a
skill makes about itself and never one it makes about the world. Skill Package
Tests assert exactly what Skillforge cannot know, so a `skillforge test` verb
would put the tool's name on a result it cannot read.

A continuous integration job still runs the Skill Package Test. The
`skill-package-test` stage in `03-skill-authoring-standard.md` section 16 calls
the Skill Repository's selected runner and records its exit code.

### Promotion path

A primitive earns a place in core by proving it is universal. The path runs one
way.

```text
skill-local script
      ↓ several skills need it
shared source library
      ↓ proven universal
possibly core
```

Never the reverse. Starting in core recreates the monolith the boundary exists
to prevent.

## Skillforge finding and compatibility classes

Skillforge keeps three classes separate. Conflating them makes the output less
actionable and hides which system supplied the evidence.

| Class | Question | Where it runs |
|---|---|---|
| Agent Skills Specification | Does the skill satisfy the portable Agent Skills specification? | Skillforge Check |
| Skillforge Policy | Does the skill satisfy the Skillforge house profile? | Skillforge Check |
| Host Compatibility | Does one Agent Host discover and enable the Skill Package? | An optional Host Compatibility Test for that host |

The Policy class covers three subjects, and all three are house profile. The
first is shape: density, language, structure, and context budget. The second is
safety: what the skill instructs an agent to do, and what the skill's own code
does. `03-skill-authoring-standard.md` section 15 defines it and lists the part
a program can match. A safety finding is an error, and it does not wait for
`--strict`.

The third is claims. A skill names a script, a reference, an asset, and a path
it writes, and the check compares each name against the package and against the
skill's own declarations. Section 12 of the same document defines the rows.
Skillforge decides a claim a skill makes about itself. It never decides a claim
a skill makes about the outside world, because it knows no skill's subject. That
claim belongs to the skill's own tests.

A safety finding reports a pattern, and a pattern is not a verdict. The CLI
reports what it matched and where. A reader decides whether the skill's declared
subject accounts for it. Skillforge never reports a skill as safe, because a
passing check means the author followed the house profile and nothing more.

### Repository safeguards

Installed Skill equality does not prove that its source is valid. The Skill
Repository enforces that boundary separately.

`skillforge new` and `sf-create` finish by running `skillforge check --strict`
on what they produced. `skillforge build` and `skillforge project` run the same
check before materialization and stop on a failure. During maintenance, the
repository runs it in a pre-commit hook for early feedback and in continuous
integration for enforcement. The hook is convenience, not authority, because
it can be absent or skipped.

`sf-setup` puts the strict check into the repository's hook and continuous
integration configuration. When either configuration already exists, setup
adds the command without replacing the user's other checks and asks before it
changes the file.

The written authoring standard and its executable Policy checks can also drift
apart. Every machine-verifiable rule in the standard has conformance fixtures
that name the rule and contain one accepted and one rejected case. The CLI test
suite asserts the expected Policy finding for those fixtures. A change to the
standard, its implementation, or its fixtures is incomplete until all three
agree, and the Skillforge Framework Release Gate runs that suite.

These safeguards establish six independent boundaries.

| Boundary | Safeguard |
|---|---|
| Authoring standard to repository | `skillforge check --strict` in creation, maintenance, and continuous integration. |
| A skill's prose to its own package | The claim checks in `skillforge check`, and the skill's own tests for an external literal. `03-skill-authoring-standard.md` section 12. |
| Skill Repository to Skill Package | Skillforge Build creates a fresh package from the allowlisted closure. |
| A skill's scripts to their packaged copy | The Skill Package Test runs against the freshly built package. |
| Skill Package to Installed Skill | Installed Skill Validation runs `skillforge project --check` without writing. |
| Authoring standard to Policy implementation | Rule-named conformance fixtures in the CLI test suite. |

Schema validity is never evidence of behavioral quality. The CLI must not report
a skill as ready because its frontmatter parses. No class of finding answers
whether the skill improves the task. That answer comes from using the skill, and
`03-skill-authoring-standard.md` section 13 states how to read it.

### Host Compatibility Tests

Three propositions can hold at once, and Agent Skills Specification and
Skillforge Policy together cover only the first two.

1. The file is valid YAML.
2. The file satisfies the Agent Skills specification.
3. The host loads the skill and enables it.

A duplicate hooks declaration is the example. Each declaration is well formed,
the manifest parses, a validator reports success, and the host then refuses the
skill.

The Host Compatibility Test asks the Agent Host. It installs the Skill Package
into a scratch Host Installation, runs the host's own list command, and asserts
the host's own report. It is deterministic, needs no grading, and takes one
command.

Compatibility runs once per Agent Host, never as one universal test. Each host
has its own Host Installation path, list command, and report format, so a target
host is added by adding a job rather than by extending a shared one.

Two limits keep it opt-in. It needs the target Agent Host CLI present on the
machine, and it writes to a scratch Host Installation. It never runs inside
Skillforge Check. It belongs on a flag to `skillforge build` or `skillforge
project`, and in continuous integration.

## The deterministic surface

Every skill has two surfaces, and Skillforge analyzes them independently.

```text
foo/
├── SKILL.md      ← agent surface
└── scripts/      ← deterministic surface
```

The agent surface is checked against the authoring standard. The deterministic
surface is checked against the runtime profile: shell and Python runtime rules,
PEP 723 metadata, ShellCheck, Ruff, tests, and the lifecycle contracts.

## CLI interface contract

The CLI serves two consumers with one implementation.

| Property | Rule |
|---|---|
| Interaction | Non-interactive by default. |
| stdout | Data. |
| stderr | Diagnostics. |
| Structured output | `--json` on every command that produces data. |
| Exit codes | Stable and documented. |
| Catalog | Machine-readable command list. |

Human rendering is a presentation layer over the same result, not a separate
code path.

```text
skillforge check foo          →  ✓ metadata
                                 ✗ description: weak trigger coverage

skillforge check foo --json   →  {"ok": false, "violations": [...]}
```

## Deferred decisions

WebAssembly action modules are attractive for portability and sandboxing. They
are not part of this design. Subprocess execution with explicit arguments is
simpler and sufficient.

A dynamic Rust plugin system is rejected. Native ABI and version coupling cost
more than the extension model is worth.
