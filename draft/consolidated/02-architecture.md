# Skillforge architecture

## The six layers

| Layer | Owns |
|---|---|
| Source | Canonical skills, shared libraries, templates. One copy of everything. |
| Policy | The house profile on top of the Agent Skills specification. |
| Meta-skill | Agent-facing skills that create, review, improve, and test skills. |
| CLI | Deterministic framework mechanics, written in Rust. |
| Evaluation | Trigger evaluations and behavioral evaluations. |
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
│       └── evals/
│           ├── evals.json
│           ├── trigger-evals.json
│           └── fixtures/
└── docs/
```

`evals/` and `tests/` belong to the development repository. A materialized skill
MUST NOT carry either one.

### The user skill repository

A user who builds skills keeps them in their own repository. Skillforge is a
build tool outside that repository, the way Cargo is a build tool outside a
crate.

```text
my-skills/
├── lib/                   # optional, primitives this repository's skills share
├── skills/
│   └── deploy-api/
│       ├── SKILL.md
│       ├── scripts/
│       ├── references/
│       ├── assets/
│       ├── tests/
│       └── evals/
└── dist/                  # build output, not committed
```

The shape matches the `skills/` subtree of the Skillforge repository, because
both repositories pass through the same verbs. The Skillforge repository carries
`crates/` in addition, because it also builds the CLI.

The `sf-setup` meta-skill creates this layout. It works on an empty repository
and on a repository that already holds skills.

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

Source only, and never materialized:

```text
skillforge.toml   tests/            evals/
.coverage         .pytest_cache/    __pycache__/
*.pyc             editor files      temporary files
build output
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

The build validates and runs the scripts from a fresh materialized tree before
it reports success. A skill that passes its tests in the source repository and
fails in `dist/` has a vendoring defect, and only an isolated run finds it.

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
            dist/<skill>/               materialized
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
  ~/.agents/skills/     ~/.claude/skills/
      projection            projection
```

Installed trees are disposable. Skillforge never reads them back as a source. A
checksum comparison is enough to detect a hand edit, and the remedy is to
re-project.

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
first meta-skill a user runs, and it produces the layout above.

Setup is a skill rather than a tenth CLI verb, because most of the work is
judgment. The skill reads what the repository already contains, asks which hosts
the user targets, decides what to create and what to leave alone, and stops
before it overwrites an existing file. Principle 1 in `01-vision.md` puts that
class of work in a skill.

The mechanical parts stay in the CLI. `sf-setup` calls `skillforge new` for a
skill directory and `skillforge doctor` for the runtime baseline. It does not
reimplement either one, so the CLI boundary below does not move.

## The CLI boundary

The Rust CLI implements the Skillforge model. It does not implement what any
particular skill wants to accomplish.

In core:

```text
skillforge new
skillforge check
skillforge validate
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
```

Those belong to the skill that needs them.

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

## Validation layers

`skillforge check` reports three classes of finding, and keeps them separate.
Conflating them makes the output less actionable.

| Class | Question |
|---|---|
| Spec | Does the skill satisfy the Agent Skills specification? |
| Policy | Does the skill satisfy the Skillforge house profile? |
| Behavior | Do the evaluations show that the skill works? |

Schema validity is never evidence of behavioral quality. The CLI must not report
a skill as ready because its frontmatter parses.

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
