# Script runtime profile

This document defines the deterministic surface of a Skillforge skill: the
languages, the execution model, the lifecycle phases, the script contracts, and
the tests.

A Skillforge skill can ship executable helpers. Those helpers stay ordinary
portable files. Any capable coding agent runs them without Skillforge installed.

## 1. Runtime baseline

A Skillforge skill assumes these three commands exist.

```text
bash
python
uv
```

A missing baseline command is a hard failure. Skillforge supports no degraded
execution path. `skillforge doctor` reports the missing command and stops.

Development of the Skillforge repository itself additionally requires:

```text
pytest  bats  cargo-nextest  shellcheck  ruff  pre-commit
```

## 2. Language policy

```text
Need deterministic logic?
    │
    ├─ Can an existing CLI do it cleanly?   → use the CLI
    │
    ├─ Small orchestration or process glue? → Bash
    │
    ├─ Parsing, structured data, real logic? → Python
    │
    └─ Exceptional requirement?             → another language, justified
```

The short form: shell is glue, Python is logic. This is a strong default, not an
absolute rule.

### Bash

Bash is the standard shell runtime. Do not restrict scripts to POSIX `sh`.
Authors get arrays, `[[ ]]`, `mapfile`, and `pipefail` without pretending that
shell portability outweighs maintainability.

```bash
#!/usr/bin/env bash
set -euo pipefail
```

Add `IFS=$'\n\t'` only where a script actually needs it. Do not boilerplate it.

Use Bash for invoking existing tools, pipelines, filesystem glue, simple
branching, environment checks, and very small wrappers.

### Python

Use Python for JSON, YAML, and TOML processing, recursive traversal, complex
validation, substantial branching, data structures, careful error handling, and
anything worth a unit test. This rule exists to prevent 250-line shell scripts.

## 3. Python execution model

Every Python script runs through `uv`, including a script with no dependencies.

```bash
uv run scripts/inspect.py
```

One invocation model keeps execution semantics consistent and honors
`requires-python`.

Every Python script declares its own metadata with PEP 723 inline script
metadata.

```python
#!/usr/bin/env -S uv run --script

# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
```

Skillforge does not invent a runtime declaration format. PEP 723 exists for
exactly this case, and `uv` builds an isolated environment from it.

### Complexity progression

Start at level 1. Move up only when the code earns it.

Level 1, one isolated script:

```text
scripts/
└── inspect.py
```

Level 2, several scripts with shared local code:

```text
scripts/
├── inspect.py
├── validate.py
└── _lib/
    ├── __init__.py
    ├── diagnostics.py
    └── repo.py
```

Level 3, a real Python project:

```text
my-skill/
├── scripts/
│   ├── pyproject.toml
│   ├── uv.lock
│   └── src/
│       └── my_skill_runtime/
└── tests/
```

Tests live at the skill root at every level, never under `scripts/`. The build
copies `scripts/` whole, so a `scripts/tests/` directory reaches the host.
One location keeps the exclusion rule in `02-architecture.md` unambiguous.

The move to level 3 is permitted policy, not an architectural failure. It
becomes appropriate when the deterministic component benefits from conventional
package management, dependency locking, or a substantial test suite.

When a component reaches that size, ask one further question: does it still
belong inside the skill at all?

## 4. Lifecycle phases

Skillforge defines three lifecycle semantics and no more.

| Phase | Question | When it runs |
|---|---|---|
| `preflight` | Can this workflow safely run? | Before the workflow. |
| `verify` | Did it produce a valid result? | After the workflow. |
| `postflight` | What must be restored and recorded before the skill ends? | Always, on success and on failure. |

Generic names such as `before`, `after`, `setup`, and `teardown` are rejected.
Each defined phase answers one question whose answer changes what the agent does
next. Three constructs keep a skill from turning into a CI pipeline DSL.

```text
preflight
    ↓
main orchestration: agent reasoning plus deterministic scripts
    ↓
verify
    ↓
postflight
```

`postflight` runs unconditionally. That is what makes it a phase rather than the
tail of the workflow. A temporary worktree still needs removal after a failed
operation, and a failed run still needs its diagnostics written down.

`verify` decides success. `postflight` never does. A skill must not report
success because `postflight` exited 0, and must not withhold a verified success
because `postflight` reported leftover state. `postflight` reports what it could
not restore, and the agent surfaces that alongside the real outcome.

### Each phase has an encouraged sub-step

The phase is the slot. The sub-step is the practice Skillforge encourages inside
it. Neither is mandatory, and a phase can carry work beyond its encouraged
sub-step.

| Phase | Encouraged sub-step | Typical content |
|---|---|---|
| `preflight` | Fail-fast requirement checks | Required commands, minimum versions, environment variables, authentication state, repository state, expected files, permissions. |
| `postflight` | Cleanup of transient state | Temporary directories, worktrees, scratch branches, stashed state, background processes, restored configuration. |

Beyond cleanup, `postflight` is also the right home for a run summary, an output
manifest, the changed-file list, and collected metrics.

Skillforge encourages two habits. A skill that creates transient state carries
`postflight` with a cleanup step. A skill that depends on external tooling
carries `preflight` with requirement checks.

Neither habit is a rule. `skillforge check` reports a missing one as advice, and
an author is free to ignore the advice.

### Every phase is optional

All three phases are absent by default. Each one appears in a skill because that
skill has a reason for it.

A skill with no environmental prerequisite carries no `preflight`. A skill whose
result is not machine-checkable carries no `verify`. A skill that creates no
transient state and produces no summary carries no `postflight`. A skill can
carry one phase and not the others.

Do not generate empty ceremony.

```text
scripts/
├── preflight.py    ← only because this skill needs gh authentication
└── verify.py       ← only because correctness is machine-checkable
```

### Phases couple a skill to nothing

The phases are a naming convention plus a result contract. No runtime enforces
them.

| Property | Consequence |
|---|---|
| The skill carries the script. | The file ships inside the skill directory. |
| `SKILL.md` invokes it by path. | `uv run scripts/preflight.py`, like any other script. |
| No manifest declares the phases. | Nothing outside the skill needs to know they exist. |
| The agent reads the result. | The exit code and the JSON go to the agent, not to a framework. |
| `skillforge check` runs at authoring time. | Its advice never reaches an installed skill. |

A materialized skill runs on any agent that can execute a script. Copy it to a
machine with no Skillforge installed and the phases still work.

The contract exists so that a reader of any Skillforge skill meets the same
three words with the same three meanings. That is the whole benefit, and it
costs no dependency.

### Preflight is authoritative

Do not write this in `SKILL.md`:

```markdown
Check whether GitHub CLI seems to be installed and authenticated.
```

Write this:

```markdown
Run the skill preflight:

    uv run scripts/preflight.py

Do not proceed if preflight fails.
```

The agent then does not reason about environmental suitability. The script
decides.

### Verify is authoritative

Verify answers whether the deterministic outcome satisfies the expected
invariants: files exist, the repository is clean, tests pass, output conforms to
a schema, a checksum matches.

```markdown
After applying the changes:

    uv run scripts/verify.py

Do not report success unless verification passes.
```

This removes one classic agent failure: "I changed it, therefore it is done."

### Postflight is unconditional

Write the invocation so that the failure path reaches it too.

```markdown
Run postflight before you report anything, whether the workflow succeeded or
failed:

    uv run scripts/postflight.py

Report any state that postflight could not restore.
```

A `postflight` script must be safe to run against a half-finished workflow. It
removes what exists, ignores what does not, and never fails because the workflow
failed first. Idempotence matters more here than in any other script a skill
ships.

### Lifecycle result contract

The three lifecycle scripts use structured output, because Skillforge owns their
semantics. Ordinary utility scripts do not have to.

```json
{
  "status": "fail",
  "checks": [
    { "id": "gh-installed", "status": "pass" },
    {
      "id": "gh-authenticated",
      "status": "fail",
      "message": "GitHub CLI is not authenticated.",
      "remediation": "Run gh auth login."
    }
  ]
}
```

Exit codes for lifecycle scripts:

```text
0  the phase succeeded
1  the phase completed and the expected condition was not satisfied
2  the phase could not execute correctly
```

Exit code 1 reads differently in each phase, and each reading gates a different
decision.

| Phase | Exit 1 means | The agent then |
|---|---|---|
| `preflight` | A requirement is not satisfied. | Stops before the workflow. |
| `verify` | The result is not valid. | Does not report success. |
| `postflight` | Some state could not be restored. | Reports the leftover state with the outcome. |

These codes are reserved for lifecycle scripts only. An ordinary utility script
follows the conventions of the Unix tools around it.

## 5. Script contract

Scripts MUST:

```text
be non-interactive
terminate deterministically
take explicit arguments
return meaningful exit codes
send diagnostics to stderr
avoid hidden mutable global state
avoid hardcoded host paths
```

Strong defaults, which a script departs from only with a stated reason:

```text
be idempotent when applicable
produce machine-readable output when the agent consumes it
validate their inputs
fail fast
stay safe to rerun
minimize runtime dependencies
```

### Closed choices

If an option accepts a finite set of values, the parser enforces that set.

```text
--format {json,text}
--mode {check,fix}
```

The rule is closed accepted values, not a particular language construct. In
Python, `argparse` `choices` is the normal form, because it produces the help
text and the error message for free.

An open `--mode <string>` moves the validation into the script and gives the
agent no way to discover the valid values.

### Mutation policy

What a script can destroy decides what interface it must expose.

| Operation | Required interface |
|---|---|
| Read only | Run it directly. |
| Reversible or local mutation | `--dry-run`, or an equivalent preview mode. |
| Irreversible, destructive, remote, or broadly scoped mutation | Separate `plan` and `apply` phases. |
| Applying an approved plan | Consume the exact saved plan artifact. Reject a stale or mismatched input. |

For an irreversible operation, `--dry-run` alone is not enough. The state can
change between the preview and the execution, so the applied change stops
matching the reviewed one.

A script that can cause an irreversible or remotely destructive effect MUST
separate planning from application. Planning performs no mutation and emits a
reviewable summary plus a saved plan artifact. Application takes that artifact
explicitly and refuses it when the inputs or the observed state no longer match.

Do not commit a plan artifact. It can contain sensitive data.

### Stream discipline

```text
stdin and argv   explicit inputs
stdout           the intended result
stderr           diagnostics
exit code        operation status
```

### Path behavior

A script takes its target path explicitly, or derives it predictably from the
current working directory. A script never assumes a home directory layout, a
Skillforge checkout, or a username.

### Output format

JSON is not mandatory. Use the simplest stable format the consumer needs.

`scripts/current_branch.sh` prints `main`. `scripts/list_files.sh` prints
newline-delimited paths. Both are correct. Use JSON when the result has real
structure.

```json
{
  "valid": false,
  "violations": [
    { "rule": "missing-description", "file": "SKILL.md", "line": 3 }
  ]
}
```

### Bounded output

Bounded does not mean silently truncated. A truncation the caller cannot detect
turns a partial answer into a wrong one.

If the size of the output depends on the input, the script MUST carry a limit, a
pagination mechanism, or an artifact-output mode. If the script abbreviates the
result, it reports the total, the emitted count, and the truncation flag, and it
gives a cursor or the path to the complete result.

```json
{
  "valid": false,
  "total": 1837,
  "emitted": 50,
  "truncated": true,
  "violations": [],
  "full_result": "/tmp/skillforge-result.json"
}
```

Standard output carries the concise result the caller decides on. Large detail
belongs in an artifact. Diagnostics stay on stderr.

### The skill owns the interface, not the implementation

`SKILL.md` states which deterministic capability to invoke and what its output
is authoritative for.

```markdown
### Inspect the repository

Run:

    ./scripts/inspect-repository

Treat its JSON output as authoritative for repository structure, detected
languages, manifests, and the current branch.
```

The implementation can move from Python to Rust later without touching the
workflow.

## 6. Shared code

Three scopes of reuse exist, and they have different answers.

### Scope A, inside one skill

Straightforward and encouraged.

```text
my-skill/scripts/
├── inspect.py
├── validate.py
└── _lib/
    ├── output.py
    └── repository.py
```

The skill stays self-contained.

### Scope B, across skills in one pack

Runtime cross-skill imports are prohibited. A skill copied out on its own must
still work.

DRY happens at authoring time. The source keeps one copy, and the build vendors
it into each skill that declares it. `02-architecture.md` describes the
materialization step.

### Scope C, the framework

The shared source libraries split by language and stay idiomatic in each. Do not
build a cross-language abstraction.

The build copies the whole package into `scripts/`, under its own name.

```text
source                              materialized skill
──────                              ──────────────────

lib/python/skillforge_runtime/      scripts/
├── __init__.py                     ├── inspect.py
├── checks.py                       └── skillforge_runtime/
├── diagnostics.py                      ├── __init__.py
├── paths.py                            ├── checks.py
└── results.py                          ├── diagnostics.py
                                        ├── paths.py
lib/bash/                               ├── results.py
├── checks.bash                         └── bash/
└── diagnostics.bash                        ├── checks.bash
                                            └── diagnostics.bash
```

The import is the same in the source repository and in the materialized skill.

```python
from skillforge_runtime.checks import require_command, require_env

def main():
    require_command("git")
    require_command("gh", min_version="2.80")
    require_env("FOO_TOKEN")
```

```bash
source "${SCRIPT_DIR}/skillforge_runtime/bash/checks.bash"
```

This works with no build-time rewriting and no path manipulation. Python puts
the directory of the executed script first on the module search path, so
`uv run scripts/inspect.py` makes `scripts/skillforge_runtime/` importable by
name. A script MUST NOT write to `sys.path`, and the build MUST NOT rewrite an
import statement.

### Vendor the whole package, never a subset

A skill opts in once, and the build copies the complete package.

```toml
[runtime.python]
vendor-skillforge-runtime = true
```

Skillforge does not resolve which modules a script imports and copy only those.
That needs real import analysis, and it breaks on a dynamic import and on a
re-export from `__init__.py`. The failure it introduces costs more than the few
kilobytes it saves.

Keep the runtime small enough that copying all of it stays cheap. If measured
use later justifies it, split it into two or three named packages that a skill
selects explicitly. Do not start with a transitive-import resolver.

### What belongs in a shared library

Shared runtime libraries provide execution primitives, never skill semantics.

Good:

```text
require_command()   require_env()        require_file()
require_directory() require_git_repo()   command_version()
emit_error()        emit_warning()       emit_result()
run_command()       resolve_project_root()  resolve_skill_root()
temporary_directory()  atomic_write()
```

Bad:

```text
create_release()    analyze_skill_quality()
fix_python_package()  generate_github_issue()
```

Those are domain behavior and belong to one skill.

Keep the libraries small. A large `skillforge_common` becomes a framework inside
the framework.

### Patterns are not libraries

Some reuse is code. Some reuse is an authoring convention. The stream discipline
and the path rules above are policy, enforced by `skillforge check`. Do not
solve a convention by adding runtime code.

## 7. Environment setup is verification, not installation

A skill never mutates the base system because a helper needs something.

```text
skill activates
    ↓
preflight checks prerequisites
    ↓
available?
  yes → run
  no  → the agent reports the missing requirement
```

Prohibited inside a skill:

```bash
apt install ...
pip install ...
curl ... | sh
```

`uv run` is the one accepted exception, because it builds an isolated
environment instead of installing packages into the system Python. PEP 723 notes
the security implications of automatic dependency download, so treat it as an
explicit trust boundary and keep dependency lists small.

## 8. Dependency policy

Two profiles exist.

| Profile | Dependency specification |
|---|---|
| portable | Sensible bounded specifications, for example `requests>=2,<3`. |
| reproducible | Exact versions, with generated lock material where needed. |

Portable is the default. Do not force a lockfile onto a small script.
Reproducible becomes appropriate at Level 3 of the complexity progression.

## 9. Per-skill requirements

The framework baseline is `bash`, `python`, and `uv`, and Skillforge validates
it globally.

Anything else is a skill-local requirement: `git`, `gh`, `jq`, `docker`,
`cargo`, `rg`, `kubectl`, `aws`, and so on. A skill-local requirement never
becomes a framework requirement.

`skillforge` itself is a skill-local requirement, with no special status. The
`sf-` meta-skills declare it the way a deployment skill declares `kubectl`,
because Skillforge is their subject.

```yaml
name: sf-review
compatibility: Requires the skillforge CLI on PATH.
```

The declaration carries a limit. A skill depends on a tool when the tool is its
subject. A skill never depends on a tool because the framework put it on the
machine. An ordinary skill that names `skillforge` in `compatibility` has
violated law 5, and `skillforge check` reports it.

The skill's `preflight` script owns the check. The Agent Skills `compatibility`
field carries the human-facing statement.

```yaml
---
name: repository-analyzer
description: ...
compatibility: Requires Python 3.11+, uv, and an authenticated GitHub CLI.
---
```

Skillforge source can carry richer build metadata in `skillforge.toml`. That
file is source only. It never lands in the materialized skill.

```toml
[package]
include = ["schemas/**"]

[runtime]
commands = ["git", "uv"]

[runtime.python]
requires = ">=3.11"
vendor-skillforge-runtime = true
```

`skillforge check`, `skillforge build`, and `skillforge doctor` consume that
metadata and generate the `compatibility` prose. `compatibility` stays
human-facing. Skillforge does not overload it into a dependency manager.

## 10. Testing

Every non-trivial deterministic helper is testable without an agent. That is one
of the main wins of this architecture.

```text
SKILL.md   → behavioral and trigger evaluations
scripts/   → conventional deterministic tests
```

| Language | Tests | Static analysis |
|---|---|---|
| Python | pytest | ruff check, ruff format |
| Bash | bats | shellcheck |
| Rust | cargo nextest run, cargo test --doc | cargo clippy, cargo fmt |

`cargo nextest` does not run doctests, so `cargo test --doc` stays a separate
required step.

A PEP 723 standalone script still gets unit tests without becoming a package.

Bash tests are fixture-driven.

```text
tests/
├── fixtures/
│   ├── valid-repo/
│   └── missing-config/
└── preflight.bats
```

```bash
@test "fails when config is missing" {
    run "$SCRIPT" "$FIXTURES/missing-config"

    [ "$status" -eq 1 ]
}
```

## 11. Hook layering

Do not run the complete test suite on every commit. Developer experience
degrades, and the hooks get bypassed.

| Stage | Scope |
|---|---|
| pre-commit | Fast static checks: whitespace, EOF, YAML and TOML parsing, large files, ruff, shellcheck, cargo fmt, cargo clippy. |
| pre-push | Relevant tests for the changed area. |
| CI | The complete suite. |

## 12. Reported surface

`skillforge check <skill>` reports both surfaces separately.

```text
Skill
  ✓ Agent Skills specification
  ✓ instruction policy
  ✓ progressive disclosure
  ✓ deterministic boundary

Deterministic surface
  ✓ Bash runtime
  ✓ Python runtime
  ✓ PEP 723 metadata
  ✓ ShellCheck
  ✓ Ruff
  ✓ tests
  ✓ preflight contract
  ✓ verify contract
  ✓ postflight contract
```
