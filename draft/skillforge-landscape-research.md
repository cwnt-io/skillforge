# Skillforge Landscape Research

## Executive conclusion

As of September 2026, there is no single project I found that fully matches Skillforge's intended architecture: a canonical repository for authoring and managing skills, its own meta-skills for creating skills, deterministic workflow steps implemented behind a native helper CLI, and multi-host projection to standard Agent Skills locations such as `~/.agents/skills` and Claude Code's `~/.claude/skills`.

Several projects overlap strongly with individual layers. The closest architectural neighbor is `cortesi/skills`, a Rust CLI explicitly designed to maintain skills from one source and push them to both Claude and generic agent directories. Anthropic's `skill-creator` is the strongest reference for the authoring/evaluation lifecycle. `skill-tools` and `agent-skills-lint` are the strongest references for deterministic validation and machine-friendly checks. `obra/superpowers` is the strongest reference for a repo whose own composable skills govern how agents work and how new skills are authored. GitHub's `gh skill` and Vercel's `skills` CLI increasingly commoditize generic skill installation and distribution.

The most differentiated version of Skillforge should therefore not position itself as another skill installer. It should position itself as a **skill engineering framework**: source-of-truth authoring conventions + meta-skills + deterministic native tooling + tests/evals + host projections.

## 1. Closest direct match: cortesi/skills

Repository: https://github.com/cortesi/skills

This is the closest project to the SoT/distribution portion of Skillforge. Its README describes it as "A CLI for managing AI coding assistant skills from a single source." It supports source directories configured in `~/.skills.toml`, pushes skills to both `~/.claude/skills/` and `~/.agents/skills/`, supports project-local equivalents, and provides two-way synchronization.

Important capabilities:

- canonical source directories
- global and project-local sources
- `push`, `pull`, `sync`, and `diff`
- `new`, `edit`, `mv`, and `validate`
- `render` with target-specific MiniJinja sections
- `pack`, `import`, `unload`, and `promote`
- Rust implementation and Cargo distribution
- explicit `claude` versus `agents` target rendering

This is significant because it independently converges on almost exactly the same DRY problem: avoiding separate maintained copies under Claude and generic Agent Skills locations.

Where it differs from Skillforge's intended scope:

- its primary abstraction is synchronization/management, not a skill-engineering methodology
- it does not appear to make a meta-skill-driven authoring framework the center of the system
- validation is structural/template-oriented rather than a broad quality/evaluation methodology
- deterministic helper commands are management operations, rather than domain routines invoked by the repo's own skills
- its two-way synchronization model treats installed copies as editable peers; Skillforge can instead make projections disposable and keep a stricter canonical-source model

That last distinction is important. A strict SoT model is simpler and more deterministic than timestamp-based two-way sync.

## 2. skill-sync projects: direct overlap in canonical projection

### vikasagarwal101/skill-sync

Repository: https://github.com/vikasagarwal101/skill-sync

This project treats `~/.agents/skills/` as a canonical source and copies skills into host-specific locations such as Claude Code. It has create/edit/sync/validate/deploy/doctor operations and a manifest. It explicitly exists because agent products scan different directories and copies otherwise drift.

This validates Skillforge's premise, but the project is predominantly a deployment/synchronization utility. Its canonical source is typically an installed host directory rather than a repository-owned engineering source tree.

### itsHabib/skill-sync

Repository: https://github.com/itsHabib/skill-sync

Another explicit SoT tool. It declares a source provider and synchronizes to target providers, with drift detection and a policy manifest for cases where targets intentionally differ.

Useful ideas for Skillforge:

- read-only status/drift checks
- explicit policy manifest
- collision-safe projection
- machine-readable output

Again, this is deployment infrastructure rather than an authoring framework.

## 3. Vercel/Antfu `skills` CLI: generic ecosystem installer

Repository: https://github.com/vercel-labs/skills (current development is also visible through the `antfu/skills-cli` lineage)
Documentation: https://www.skills.sh/docs/cli

This CLI has become a broad cross-agent installation layer. It supports dozens of agents, project/global scopes, source repositories, symlink or copy installation, listing, discovery, updates, lock generation, removal, and `skills init`.

Especially relevant is its symlink mode: the CLI recommends a canonical copy and symlinks individual agent directories to it, explicitly describing this as a single-source-of-truth approach.

Implication for Skillforge: generic "install this skill into N coding agents" is increasingly commodity infrastructure. Skillforge should either delegate to such tooling or keep its own projection layer deliberately narrow and deterministic for the hosts you care about.

## 4. GitHub `gh skill`: distribution is becoming platform infrastructure

Documentation: https://cli.github.com/manual/gh_skill
Announcement: https://github.blog/changelog/2026-04-16-manage-agent-skills-with-github-cli/

As of 2026, GitHub CLI has native `gh skill` commands for discovery, preview, install, publish/validation, update, and target-host selection. GitHub documents support for Claude Code, Codex, Gemini CLI, Cursor, GitHub Copilot, OpenCode, and many more hosts.

Notable capabilities:

- install from GitHub or local directories
- project or user scope
- target-specific installation
- source provenance
- version pinning to tags or commits
- update tracking
- preview before installation
- publishing validation and auto-fix

This materially changes the design space. Skillforge should avoid spending much of its complexity budget rebuilding remote discovery, package registries, provenance, or generic multi-agent installers unless its stricter SoT semantics require it.

## 5. Anthropic `skill-creator`: strongest authoring methodology

Repository: https://github.com/anthropics/skills/tree/main/skills/skill-creator
Official plugin: https://claude.com/plugins/skill-creator

Anthropic's skill creator is the strongest current reference for the skill engineering lifecycle. It covers creation, modification, improvement, evaluation, benchmarking, and trigger-description optimization.

Its authoring model includes:

- requirements/intention discovery
- draft creation
- test prompts
- execution against the skill
- qualitative review
- quantitative grading
- blind A/B comparison
- analysis and iteration
- description optimization
- packaging

It also codifies progressive disclosure: metadata remains always visible, `SKILL.md` loads on activation, and scripts/references/assets load only when needed. It recommends keeping the main skill concise and moving detail to referenced resources.

For Skillforge, this should be treated as a major upstream methodological reference, but not copied wholesale. The official skill is intentionally broad and interactive. Skillforge can encode a stricter, leaner house style and move mechanical tasks into the Rust CLI.

## 6. `skill-tools`: deterministic quality tooling

Repository: https://github.com/skill-tools/skill-tools

`skill-tools` describes itself as an ESLint/Lighthouse-style toolkit for Agent Skills. It parses, validates, lints, scores, routes, watches, and generates skills, with zero LLM dependencies for its core checks.

Relevant ideas:

- specification validation
- deterministic lint rules
- content-quality checks
- secret/hardcoded-path checks
- objective quality scoring
- pre-commit integration
- GitHub Actions/SARIF
- routing tests
- machine automation rather than prompting an LLM to inspect everything

This is very close to the philosophy behind your Rust helper: if a task has a deterministic implementation, it should be code rather than prose asking an agent to improvise it.

Skillforge could go further by making these deterministic commands first-class dependencies of the skills themselves. For example, a meta-skill could instruct the agent to use `skillforge lint`, `skillforge inspect`, `skillforge eval prepare`, or `skillforge project` rather than reimplement those algorithms in shell snippets.

## 7. `agent-skills-lint`: agent-first deterministic CLI design

Repository: https://github.com/swarmclawai/agent-skills-lint

This project is particularly useful as a CLI-design reference. It validates per-agent schemas, checks collisions, installs skills, and generates indexes. More importantly, its interface is explicitly designed for coding agents:

- non-interactive by default
- JSON output
- stable exit codes
- stdout for data, stderr for diagnostics
- a machine-readable command catalog

This is an excellent pattern for Skillforge's Rust CLI. Human-friendly terminal UX and agent-friendly deterministic APIs do not need to conflict: expose stable structured output and predictable exit semantics, then add rich human rendering as a presentation layer.

## 8. `agent-ecosystem/skill-validator`: deeper structural/content validation

Repository: https://github.com/agent-ecosystem/skill-validator

This validator goes beyond simple YAML checks. It validates structure, links, content density, contamination, orphan resources, markdown correctness, and other packaging issues. It also recognizes the importance of progressive disclosure and avoiding unnecessary files in a skill directory.

Useful design lesson: Skillforge's validator should distinguish at least three classes of checks:

1. open-spec conformance
2. deterministic Skillforge house-style rules
3. model/eval-based behavioral quality

Conflating those layers makes lint output less actionable.

## 9. `obra/superpowers`: closest conceptual framework reference

Repository: https://github.com/obra/superpowers

Superpowers is not primarily a skill manager. It is a complete coding methodology encoded as composable agent skills. It supports multiple coding agents, ships meta-skills, and explicitly uses a `writing-skills` skill to create and test skills contributed to the project.

This is conceptually very close to the "project has skills that build its own skills" part of Skillforge.

Important patterns:

- repository-native skill library
- meta-skill for writing skills
- skills that reinforce a coherent methodology rather than existing as isolated prompts
- behavior/eval testing for skills
- cross-agent compatibility as a contribution requirement
- deterministic/systematic process emphasized over ad-hoc agent behavior

Where Skillforge can differ is architectural cleanliness: make the skill-engineering framework itself the product, rather than a particular software-development methodology.

## 10. OpenSkills and other universal loaders

### numman-ali/openskills
Repository: https://github.com/numman-ali/openskills

A universal skills loader that brings Claude-style skills to other coding agents, including systems that consume AGENTS.md. It is a useful compatibility reference but not a full authoring/engineering framework.

### darrenr/skills-cli
Repository: https://github.com/darrenr/skills-cli

A Go CLI for browsing, installing, updating, and tracking skills from curated registries. Useful as a registry/discovery reference.

### reorx/skm
Repository: https://github.com/reorx/skm

A skill manager with a central store and host-specific symlinks. Useful for studying skill discovery rules and canonical-store projection strategies.

### nomyfan/skills-man
Repository: https://github.com/nomyfan/skills-man

A Rust CLI for installing and managing skills from GitHub. Relevant mostly as implementation prior art for Rust packaging and update workflows.

## 11. The standards layer: Agent Skills

Specification: https://agentskills.io/specification
Overview: https://agentskills.io/home

The open Agent Skills format is now the obvious baseline. The spec defines `SKILL.md`, required `name` and `description` metadata, optional `scripts/`, `references/`, and `assets/`, and progressive disclosure behavior. It also supplies a reference validator.

Skillforge should not invent a competing base format. Its cleanest architecture is:

- Agent Skills specification = wire/package format
- Skillforge conventions = stricter authoring profile
- Skillforge CLI = deterministic implementation and validation
- Skillforge meta-skills = agent-facing workflow/orchestration
- target projections = deployment adapter

That makes Skillforge an opinionated engineering layer on top of an open standard rather than another incompatible skills format.

## 12. Competitive matrix

| Project | Skill authoring methodology | SoT | Multi-agent projection | Deterministic validation | Native helper used by skills | Behavioral evals | Rust |
|---|---:|---:|---:|---:|---:|---:|---:|
| cortesi/skills | light | strong | Claude + agents | medium | no | no | yes |
| Vercel `skills` | light/init | strong-ish | very strong | light | no | no | no |
| GitHub `gh skill` | no | provenance-based | very strong | publishing checks | no | no | Go/gh |
| Anthropic skill-creator | very strong | no | no | scripts + checks | partial | very strong | no |
| skill-tools | generation support | no | no | very strong | no | scoring/routing, not full behavioral eval loop | no |
| agent-skills-lint | no | no | strong | strong | no | no | no |
| skill-validator | no | no | no | very strong | no | some LLM scoring | no |
| Superpowers | strong meta-skill | repository | multi-agent packaging | some | some scripts/hooks | strong | no |
| Skillforge concept | **strong** | **strict** | **strong** | **strong** | **core architectural feature** | **strong** | **yes** |

The most distinctive column is "native helper used by skills." Existing projects generally place executable scripts inside each skill or provide a CLI that manages skills from outside. Skillforge's proposed inversion is more interesting: the repository's skill prose becomes orchestration, while deterministic mechanics are centralized in one tested native CLI.

## 13. Recommended positioning for Skillforge

Avoid positioning it as:

- another marketplace
- another universal skill installer
- another `SKILL.md` linter
- another Claude-only skill creator

Those spaces already have substantial implementations and, in the case of installation, increasingly official platform support.

A stronger definition is:

> **Skillforge is an opinionated engineering framework for building, testing, validating, and projecting portable Agent Skills. Agent-facing skills encode judgment and workflow; a deterministic Rust CLI owns repeatable mechanics. One repository is the source of truth, and host-specific skill trees are generated projections.**

This gives the project a clean separation of concerns:

### 1. Source layer

Canonical skills and supporting references live once in the repository. Installed copies are generated artifacts, never authoritative sources.

### 2. Policy/spec layer

A small set of Skillforge rules defines the house profile on top of agentskills.io: language, structure, progressive disclosure, naming, deterministic-vs-agent boundary, references, and testing requirements.

### 3. Meta-skill layer

The repo includes skills such as `skill-create`, `skill-review`, `skill-improve`, or one consolidated `skillforge` skill. These tell agents how to reason about skill design and when to invoke deterministic commands.

### 4. Deterministic CLI layer

Rust commands implement anything that should not rely on LLM interpretation: scaffolding, parsing, normalization, linting, reference checking, projections, diffing, manifests, hashes, packaging, test fixture preparation, and perhaps result aggregation.

### 5. Evaluation layer

Behavioral correctness remains model-based where appropriate. Keep deterministic structural tests distinct from probabilistic activation/output evals.

### 6. Projection layer

Generate or copy the canonical skills to `~/.agents/skills/`, `~/.claude/skills/`, and future targets. Prefer one-way idempotent projection over bidirectional sync unless a compelling editing workflow requires otherwise.

## 14. The strongest ideas to borrow

From `cortesi/skills`: source directories, target rendering, dry-run/diff UX, Rust implementation.

From Anthropic `skill-creator`: iterative create/eval/improve/benchmark lifecycle and progressive disclosure.

From `skill-tools` and `skill-validator`: strict deterministic lint layers and quality gates.

From `agent-skills-lint`: JSON mode, stable exit codes, no prompts by default for agent-facing execution, stdout/stderr discipline.

From Superpowers: project-native meta-skills that govern creation of other skills and behavioral testing of those skills.

From GitHub `gh skill` / Vercel `skills`: do not overbuild generic ecosystem distribution that platform tooling already solves.

## Bottom line

The idea is not redundant, but the naive version would be. A project whose main pitch is "keep `~/.agents/skills` and `~/.claude/skills` synchronized" already exists almost exactly in `cortesi/skills` and several `skill-sync` projects.

Skillforge becomes differentiated when the center of gravity is **engineering skills themselves**: a canonical authoring framework, meta-skills that encode judgment, deterministic Rust subcommands that encode mechanics, layered validation, behavioral evals, and generated host projections.

That combination is the gap I would build around.
