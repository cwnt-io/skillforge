# References

Every external source the Skillforge specification draws on. The other five
documents cite ideas from here without repeating the links.

Collected September 2026. Tracking parameters are stripped from the URLs. Some
of these projects move fast, so re-read a source before you treat it as current.

## Authority ranking

`03-skill-authoring-standard.md` ranks these sources when they disagree.

| Rank | Source class |
|---|---|
| 1 | The project's own evaluation suite. |
| 2 | The Agent Skills specification. |
| 3 | The Agent Skills authoring and evaluation guides. |
| 4 | Vendor skill creators from Anthropic, OpenAI, and Google. |
| 5 | Community projects such as Superpowers. |

The first row outranks the rest inside this project. Evidence from a local
evaluation run beats a published recommendation.

## The base format

The wire format Skillforge produces.

- [Agent Skills](https://agentskills.io/home)
- [Agent Skills specification](https://agentskills.io/specification): canonical
  structure, metadata constraints, progressive disclosure, validation.

## Official authoring method

The strongest upstream reference for the lifecycle in
`03-skill-authoring-standard.md`.

- [Best practices for skill creators](https://agentskills.io/skill-creation/best-practices):
  scope, context economics, defaults, workflows, references, scripts.
- [Evaluating skill output quality](https://agentskills.io/skill-creation/evaluating-skills):
  baseline comparison, assertions, grading, token and runtime measurement.
- [Optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions):
  activation testing, positive and negative trigger evaluations.
- [Using scripts in skills](https://agentskills.io/skill-creation/using-scripts):
  agent-oriented executable interfaces and deterministic helpers.
- [Anthropic skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator)
  and its [plugin page](https://claude.com/plugins/skill-creator).

## Vendor skill creators

Implementation evidence for how other vendors solve the same problem.

- [OpenAI Codex skill-creator sample](https://github.com/openai/codex/blob/main/codex-rs/skills/src/assets/samples/skill-creator/SKILL.md):
  scope, non-obvious guidance, minimal context.
- [OpenAI skills skill-creator](https://github.com/openai/skills/blob/main/skills/.system/skill-creator/SKILL.md):
  degrees of freedom, progressive disclosure, resource partitioning.

## Host implementations

Evidence that the format is portable across agents, which is why law 5 exists.

- [Cursor Agent Skills](https://prod.cursor.com/docs/skills): cross-runtime
  discovery.
- [OpenCode Agent Skills](https://opencode.ai/docs/skills): portable discovery,
  frontmatter, permissions.

## Prior art

`05-landscape.md` analyzes these projects. The links are the primary sources for
that analysis.

Source of truth and synchronization:

- [cortesi/skills](https://github.com/cortesi/skills): Rust CLI, single source,
  target rendering, two-way sync.
- [itsHabib/skill-sync](https://github.com/itsHabib/skill-sync) and
  [vikasagarwal101/skill-sync](https://github.com/vikasagarwal101/skill-sync).

Methodology and meta-skills:

- [obra/superpowers](https://github.com/obra/superpowers): methodology as
  composable skills.
- [Superpowers writing-skills](https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md)
  and its [current home](https://github.com/obra/superpowers-skills/blob/main/skills/meta/writing-skills/SKILL.md):
  the RED, GREEN, REFACTOR pattern for skill testing.
- [Porting to a new harness](https://github.com/obra/superpowers/blob/main/docs/porting-to-a-new-harness.md):
  harness-agnostic core with thin platform edges.
- [Shared module refactor](https://github.com/obra/superpowers/issues/1267) and
  the [release notes](https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md).

Validation and lint:

- [skill-tools](https://github.com/skill-tools/skill-tools): parse, lint, score,
  route, SARIF, pre-commit.
- [skill-validator](https://github.com/agent-ecosystem/skill-validator):
  structure, internal links, orphan resources, content density.
- [agent-skills-lint](https://github.com/swarmclawai/agent-skills-lint): the CLI
  interface contract that `02-architecture.md` adopts.

Distribution, which Skillforge does not rebuild:

- [gh skill](https://cli.github.com/manual/gh_skill) and its
  [announcement](https://github.blog/changelog/2026-04-16-manage-agent-skills-with-github-cli/).
- [vercel-labs/skills](https://github.com/vercel-labs/skills), its
  [documentation](https://www.skills.sh/docs/cli), and
  [antfu/skills-cli](https://github.com/antfu/skills-cli).
- [darrenr/skills-cli](https://github.com/darrenr/skills-cli),
  [OpenSkills](https://github.com/numman-ali/openskills),
  [skm](https://github.com/reorx/skm),
  [skills-man](https://github.com/nomyfan/skills-man).

## Controlled English

The source of the writing profile in `03-skill-authoring-standard.md`.
Skillforge takes the structural ideas and not the full vocabulary control. No
tool guarantees compliance with ASD-STE100, and the official dictionary is free.

- [ASD-STE100](https://asd-ste100.org/).
- [SimpleEnglish](https://github.com/AminBlg/SimpleEnglish) and its
  [use cases](https://github.com/AminBlg/SimpleEnglish/blob/main/skills/simple-english/references/use-cases.md):
  an adaptation of the standard for agent instructions.

## Runtime and tooling

The basis for the policy in `04-script-runtime-profile.md`.

- [PEP 723](https://peps.python.org/pep-0723/) and the
  [inline script metadata specification](https://packaging.python.org/en/latest/specifications/inline-script-metadata/).
- [uv scripts guide](https://docs.astral.sh/uv/guides/scripts/): the execution
  model for every Python script in a skill.
- [cargo-nextest](https://www.nexte.st/): the Rust test runner for the CLI.
