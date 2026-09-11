# Skillforge vision

## Definition

Skillforge is an engineering framework for building reliable coding-agent
skills.

A skill is a packaged unit of procedural knowledge that a coding agent loads at
task time. Skillforge does not invent that format. The Agent Skills open
specification defines it. Skillforge adds a stricter authoring profile, a method
for developing skills against evidence, a deterministic Rust CLI for the
mechanics of skill development, and a one-way projection of canonical sources
into the directories that coding agents read.

## What Skillforge is not

Skillforge is not a package manager. GitHub `gh skill` and the Vercel/antfu
`skills` CLI already install skills into many agent hosts, with provenance,
version pinning, and update tracking. That layer is commodity infrastructure.

Skillforge is not a marketplace, a registry, or a second `SKILL.md` linter that
stands alone. It is not a Claude-only tool. It is not a runtime that installed
skills depend on.

A skill that Skillforge produces must keep working after Skillforge disappears
from the machine.

## The four principles

### 1. Reason in skills. Execute mechanics in code.

For every workflow step, ask whether the same input must produce the same
result. If yes, a script owns the step. If the step needs interpretation,
synthesis, ambiguity resolution, or contextual judgment, the skill instructions
own it.

The boundary runs in both directions. Do not use a model where a deterministic
program is sufficient. Do not force deterministic code to approximate a judgment
task that the model performs better.

### 2. The skill orchestrates. Skillforge does not.

`SKILL.md` decides when to reason and when to run a script. Skillforge helps an
author produce that file and the scripts beside it. Skillforge is absent at
skill execution time.

An earlier design made Skillforge a runtime that invoked manifest-declared
actions. That design is superseded. It coupled every produced skill to the
framework.

### 3. One authoritative source, disposable projections.

The repository holds the canonical skill. Installed trees under
`~/.agents/skills/` and `~/.claude/skills/` are build artifacts. Nobody edits
them. Projection runs one way and stays idempotent.

This removes conflict resolution, timestamp comparison, pull semantics, and
drift ambiguity from the design.

### 4. Evidence decides, not taste.

When deciding whether to add, remove, or change an instruction in a skill, look
at what the agent does. Run the same task with the same agent, change only that
instruction, and see what changed.

Keep an instruction if it improves the task result, even if it sounds awkward.
Remove it if it sounds good but does not help.

When there is no evidence, choose the simpler option. Call it a hypothesis, not
a standard, and settle it the next time the skill runs on real work.

Evidence is local. An instruction that works for one agent, model, or
environment can fail elsewhere. If the environment changes, look again.

Skillforge specifies no evaluation harness. Evidence comes from daily use, not
from a graded suite built in advance. A framework that demands a test rig before
the first skill exists buys a number nobody trusts with work nobody does.

This still makes skills easier to prune. Remove an instruction, run the task,
and keep it out if nothing gets worse. This is subtraction testing, defined in
`03-skill-authoring-standard.md`.

## The governing laws

These sentences resolve most design arguments.

1. The skill orchestrates.
2. The agent handles judgment.
3. Scripts handle deterministic mechanics.
4. Scripts belong to the skill, not to Skillforge.
5. Skills are runtime-self-contained.
6. Shared implementation is DRY in source and vendored at materialization time.
7. Prefer existing tools over new scripts.
8. Prefer standard ecosystem mechanisms over Skillforge-specific ones.
9. If the behavior implements the Skillforge specification, it belongs in core.
10. If the behavior exists because one skill wants it, it belongs outside core.

## The dogfooding constraint

Skillforge builds its own skills with its own public tool.

Those skills are the meta-skills: agent-facing skills that create, review,
improve, and check other skills, and that prepare a repository to build them.
They are the project's main product alongside the CLI, and they are also its
main test of the CLI.

The constraint is one rule. The meta-skills get no privileged path. They pass
through the same `new`, `check`, `build`, and `project` verbs that a stranger's
skills pass through, and they obey the same authoring standard and the same
self-containment rule.

If a meta-skill cannot be built with the public model, the public model is
incomplete. Fix the model. Do not add an exception for the bundled pack.

### Shipping is allowed, privilege is not

The constraint governs the build path, not distribution. Skillforge installs its
meta-skills onto the user host under the `sf-` prefix, as `sf-create`,
`sf-review`, and so on. `02-architecture.md` defines that namespace.

Shipping them strengthens the constraint rather than weakening it. The artifact
on a user machine is the same materialized output the public pipeline produces,
so anybody can open it and see what the public model can express.

### The line the meta-skills must not cross

A meta-skill runs `skillforge check` because Skillforge is its subject, the way
a Docker skill runs `docker`. That is an ordinary skill-local requirement, and
`04-script-runtime-profile.md` records it as one.

The prohibited thing is the reverse dependency. No skill needs Skillforge on the
machine in order to run. A user's own skill must never acquire a dependency on
`skillforge` because the installer happened to put it there.

A skill can depend on a tool because the tool is its subject. A skill must not
depend on a tool because the framework requires it.

## Naming

The method carries its own name: Contract-Driven Skill Engineering. Its five
verbs are Route, Guide, Execute, Validate, and Prune.
`03-skill-authoring-standard.md` defines them.
