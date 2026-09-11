# References

Every external source the Skillforge specification draws on. The other five
documents cite ideas from here without repeating the links.

Collected September 2026. Tracking parameters are stripped from the URLs. Some
of these projects move fast, so re-read a source before you treat it as current.

## Authority ranking

`03-skill-authoring-standard.md` ranks these sources when they disagree.

| Rank | Source class |
|---|---|
| 1 | Behavior observed in this project's own use. |
| 2 | The Agent Skills specification. |
| 3 | The Agent Skills authoring and evaluation guides. |
| 4 | Vendor skill creators from Anthropic, OpenAI, and Google. |
| 5 | Community projects such as Superpowers. |

The first row outranks the rest inside this project. What a skill actually does
on real work beats a published recommendation.

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

## Working exemplars

Projects that implement a section of the standard rather than describe it.

- [gubasso/release-kit](https://github.com/gubasso/release-kit): owns one
  marker-delimited region in a target repository's `AGENTS.md`, preserves the
  host text outside it, and coexists with a spec-driven-docs region in its own
  repository.
- [gubasso/spec-driven-docs](https://github.com/gubasso/spec-driven-docs):
  validates marker count and order, refuses a symlinked `AGENTS.md`, records the
  installed region's digest, and stops an upgrade before it overwrites a locally
  edited managed block.

- [ayghri/i-have-adhd](https://github.com/ayghri/i-have-adhd): one skill with
  host adapters for nine runtimes. The load class in `02-architecture.md` comes
  from its
  [.github/workflows/plugin-load-check.yml](https://github.com/ayghri/i-have-adhd/blob/main/.github/workflows/plugin-load-check.yml),
  which installs the plugin into a scratch configuration directory and asserts
  the host's own report.
  [pi-load-check.yml](https://github.com/ayghri/i-have-adhd/blob/main/.github/workflows/pi-load-check.yml)
  is the same idea for a second host, which is why the load class runs one job
  per host.

Five more files in that repository raised the questions OQ-7 to OQ-11 in
`08-open-questions.md`.

- [.github/workflows/cursor-skill-sync.yml](https://github.com/ayghri/i-have-adhd/blob/main/.github/workflows/cursor-skill-sync.yml):
  one `cmp` between the canonical skill and its projected copy, with the repair
  command in the failure message. The header comment records why the copy is a
  real file and not a symlink.
- [CONTRIBUTING.md](https://github.com/ayghri/i-have-adhd/blob/main/CONTRIBUTING.md):
  the "Safety and side effects" section states what a skill must never instruct
  an agent to do. The "Verification" section states that a check nobody ran is
  reported as not run.
- [AGENTS.md](https://github.com/ayghri/i-have-adhd/blob/main/AGENTS.md): a
  repository map for an agent, with a reading order, an entry point per runtime,
  source-of-truth rules, and the exact verification commands.
- [tests/test_install_docs.py](https://github.com/ayghri/i-have-adhd/blob/main/tests/test_install_docs.py):
  a test that asserts a documented path is present and that an abandoned path is
  absent by name.

The same repository carries a full evaluation harness under
[evals/](https://github.com/ayghri/i-have-adhd/tree/main/evals): a weighted
rubric, blind judging, and a published run that fails its own release gate.
Skillforge does not adopt it. `07-provenance.md` records why. Read it as
evidence of what a harness costs, not as a pattern to copy.

## Skill safety

The basis for section 15 of `03-skill-authoring-standard.md`. Read these as
threat models rather than as authoring guides. Skillforge takes the authoring
half and leaves host enforcement to the host.

- [OWASP Agentic Skills Top 10](https://owasp.org/www-project-agentic-skills-top-10/):
  ten risk classes for the skill format itself. AST03 over-privileged skills and
  [AST05 untrusted external instructions](https://owasp.org/www-project-agentic-skills-top-10/ast05.html)
  are the two the authoring standard acts on.
- [OWASP Top 10 for Agentic Applications](https://genai.owasp.org/2025/12/09/owasp-top-10-for-agentic-applications-the-benchmark-for-agentic-security-in-the-age-of-autonomous-ai/):
  the wider list. ASI01 goal hijack and ASI02 tool misuse are the entries a skill
  can cause. The Least Agency framing is the source of the narrowest-capability
  rule.
- [Agent Skills overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview)
  and [Skills for enterprise](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/enterprise):
  the vendor position. Use skills from trusted sources, audit every bundled file,
  and look for an instruction that reads sensitive data and then writes, sends,
  or encodes it.
- [Snyk, from SKILL.md to shell access](https://snyk.io/articles/skill-md-shell-access/):
  the concrete attack shapes. Credential harvesting, a pipe from a network fetch
  into a shell, and a write to an agent memory file that outlives the task.
- [CSA, SKILL.md agent context poisoning](https://labs.cloudsecurityalliance.org/research/csa-research-note-skill-md-agent-context-poisoning-20260506/):
  the source of the visible-text rule. Instructions hidden in HTML comments and
  in invisible Unicode reach the agent and not the reviewer.
- [Datadog, malicious skills in coding agents](https://securitylabs.datadoghq.com/articles/malicious-skills-supply-chain-risks-in-coding-agents-with-dynamic-context/)
  and [Red Hat, Agent Skills threats and controls](https://developers.redhat.com/articles/2026/03/10/agent-skills-explore-security-threats-and-controls):
  the supply-chain view, and the reason a skill pins every version it names.
- [Codex CLI deny-read policies](https://codex.danielvaughan.com/2026/04/25/codex-cli-filesystem-security-deny-read-policies-credential-protection/):
  a host-side deny list, and the gap it leaves. A file deny rule does not cover a
  credential that lives in an environment variable.
- [Auth0, do not give agents secrets](https://auth0.com/blog/want-ai-agents-that-don-t-spill-secrets-don-t-give-them-secrets/):
  the source of the rule that a credential never enters the agent's context. The
  skill passes the secret to a tool and never reads the value.

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
