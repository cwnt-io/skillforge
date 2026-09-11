# Landscape and positioning

Survey date: September 2026. Re-run this survey before any major architectural
commitment. This space moves fast, and GitHub entered it in April 2026.

## Conclusion

No single project combines all four things Skillforge intends: a skill-authoring
framework, project-owned meta-skills, a strict one-way source-of-truth
projection, and a deterministic native CLI that serves skill development.

Several projects own individual layers well. One project, `cortesi/skills`, is
architecturally close to the source-of-truth layer and is also written in Rust.

## The categories

| Project | Main concern | Relevance |
|---|---|---|
| cortesi/skills | Source of truth, sync, rendering | Very high |
| Anthropic skill-creator | Authoring and evaluation lifecycle | Very high |
| obra/superpowers | Meta-skills and methodology | Very high |
| skill-tools | Deterministic lint and quality | Very high |
| agent-skills-lint | Cross-agent validation, agent-first CLI | High |
| skill-validator | Deep structural and content validation | High |
| Vercel and antfu `skills` | Distribution, install, update | High |
| GitHub `gh skill` | Platform distribution | High |
| skill-sync variants | Source of truth and host sync | Medium |
| OpenSkills, skm, skills-man | Universal loaders and managers | Medium |

## cortesi/skills

A Rust CLI for managing skills from a single source. It pushes to
`~/.claude/skills/` and `~/.agents/skills/`, supports global and project-local
sources, and renders target-specific sections with MiniJinja. Its verbs include
`push`, `pull`, `sync`, `diff`, `new`, `edit`, `mv`, `validate`, `render`,
`pack`, `import`, `unload`, and `promote`.

It converges independently on the same DRY problem.

Where Skillforge differs: its primary abstraction is synchronization, not a
skill-engineering method. Its validation is structural and template-oriented.
Its two-way sync treats installed copies as editable peers. Skillforge makes
projections disposable and keeps the canonical source strict, which is simpler
than timestamp-based reconciliation.

## Anthropic skill-creator

The strongest reference for the lifecycle. It covers requirement discovery,
drafting, test prompts, execution, qualitative review, quantitative grading,
blind A/B comparison, failure analysis, iteration, description optimization, and
packaging. It codifies progressive disclosure across metadata, `SKILL.md`, and
loaded-on-demand resources.

Skillforge treats it as a major upstream method reference. Skillforge does not
copy it wholesale. The official skill is broad and interactive. Skillforge
encodes a stricter, leaner house style and moves mechanical steps into code.

## skill-tools and skill-validator

`skill-tools` positions itself as ESLint and Lighthouse for Agent Skills. It
parses, validates, lints, scores, routes, watches, and generates, with no model
dependency in its core checks. It covers secret detection, hardcoded paths,
quality scoring, pre-commit integration, GitHub Actions, and SARIF.

`skill-validator` goes past YAML checks into structure, internal links, orphan
resources, Markdown correctness, extraneous files, content density, and
contamination. It treats a malformed Markdown fence as an error, because a bad
fence changes how an agent reads everything after it.

The lesson for Skillforge: keep spec conformance, house policy, and host load in
three separate report classes.

## agent-skills-lint

The best reference for the CLI interface, not the checks. Its contract is
non-interactive by default, JSON output, stable exit codes, stdout for data,
stderr for diagnostics, and a machine-readable command catalog. Skillforge
adopts that contract directly.

## obra/superpowers

Conceptually the closest project. It is a methodology implemented as composable
skills, with a `writing-skills` meta-skill that contributors use to build the
project's own skills. It carries behavioral testing infrastructure and treats
cross-agent compatibility as a contribution requirement.

Skillforge shares the recursive structure. Skillforge differs in what sits at
the center: skill engineering itself, rather than one software development
methodology.

Superpowers also demonstrates two patterns worth borrowing. It keeps the core
skill content harness-agnostic and pushes platform translation to thin edges. It
refactored duplicated discovery and parsing into one shared module.

Not everything transfers. Some of its metadata conventions and its deliberately
forceful prose are specific to that ecosystem rather than to the portable
standard.

## GitHub `gh skill` and Vercel `skills`

`gh skill` shipped in April 2026 with install, list, preview, publish, search,
and update. It understands many hosts, project and user scope, provenance,
version pinning, and update tracking.

The Vercel and antfu `skills` CLI covers a broad agent set with copy or symlink
installation, and describes the symlink mode as a single-source-of-truth
approach.

The implication is direct. Generic installation across many agents is commodity
infrastructure with platform backing. Skillforge must not spend its complexity
budget there. Its projection layer stays narrow and deterministic for the hosts
it cares about.

## The gap

Existing projects do one of two things.

```text
SKILL.md                 or        external CLI
└── scripts/foo.py                 └── manages SKILL.md
```

The least represented idea is a deterministic native tool that serves skill
development while the produced skills stay portable and free of any dependency
on it. That is the combination Skillforge builds around.

## Competitive matrix

| Capability | cortesi | Anthropic | skill-tools | Superpowers | Skillforge |
|---|---|---|---|---|---|
| Canonical source of truth | strong | none | none | repository | strict |
| Multi-agent projection | strong | none | none | strong | strong |
| Authoring methodology | light | strongest | medium | strong | strong |
| Meta-skills | none | strong | none | strongest | strong |
| Deterministic validation | medium | medium | strongest | medium | strong |
| Behavioral evaluations | none | strongest | scoring only | strong | none, by choice |
| Native tooling for skill development | light | light | external | some | core feature |
| Rust | yes | no | no | no | yes |

## What to borrow

| From | Take |
|---|---|
| cortesi/skills | Source directories, target rendering, dry-run and diff UX, Rust implementation. |
| Anthropic skill-creator | The create and improve lifecycle, and progressive disclosure. |
| skill-tools, skill-validator | Strict deterministic lint layers and quality gates. |
| agent-skills-lint | JSON mode, stable exit codes, stream discipline, no prompts by default. |
| Superpowers | Project-native meta-skills. |
| gh skill, Vercel skills | The lesson to not rebuild generic distribution. |

## Positioning statement

Skillforge is an opinionated engineering framework for building, validating,
and projecting portable Agent Skills. Agent-facing skills encode
judgment and workflow. Deterministic scripts own repeatable mechanics. One
repository is the source of truth, and host-specific skill trees are generated
projections.

The naive version of this project is redundant. A tool whose main pitch is
keeping `~/.agents/skills` and `~/.claude/skills` synchronized already exists
several times over. The differentiated version puts skill engineering at the
center.
