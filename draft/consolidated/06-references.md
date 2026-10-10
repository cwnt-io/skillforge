# References

Every external source the Skillforge specification draws on. The other five
documents cite ideas from here without repeating the links.

Collected September 2026, except the skill format sources, which carry their own read dates. Tracking parameters are stripped from the URLs. Some of these projects move fast, so re-read a source before you treat it as current.

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
  adapters for nine Agent Hosts. The Host Compatibility Test in
  `02-architecture.md` comes from its
  [.github/workflows/plugin-load-check.yml](https://github.com/ayghri/i-have-adhd/blob/main/.github/workflows/plugin-load-check.yml),
  which installs the plugin into a scratch configuration directory and asserts
  the host's own report.
  [pi-load-check.yml](https://github.com/ayghri/i-have-adhd/blob/main/.github/workflows/pi-load-check.yml)
  is the same idea for a second Agent Host, which is why compatibility runs one
  job per host.

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
  source-of-truth rules, and the exact repository-check commands.
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

## Skill format and context budget

The basis for sections 9 and 11 of `03-skill-authoring-standard.md`: the character budget, the writing conventions, and the conflicts between sources. Each entry names its URL, the date it was read, and the finding the standard uses. A date in parentheses is the publication date. A quote keeps the source's own wording where the wording matters.


### Specifications and vendor guidance for skills

- [Agent Skills specification](https://agentskills.io/specification), read 2026-10-08: a required `SKILL.md` with optional `scripts/`, `references/`, and `assets/`. `name` is 1 to 64 lowercase characters and matches its directory. `description` is 1 to 1,024 characters and "Should describe both what the skill does and when to use it". The body takes "< 5000 tokens recommended" on activation, and "Keep your main `SKILL.md` under 500 lines" is a recommendation. "use relative paths from the skill root", and keep references "one level deep". Its validator checks the frontmatter only.
- [Agent Skills client implementation guide](https://agentskills.io/client-implementation/adding-skills-support), read 2026-10-08: the catalog costs "~50-100 tokens per skill", `.agents/skills/` is "a widely-adopted convention for cross-client skill sharing", and clients "exempt skill content from pruning".
- [Agent Skills best practices](https://agentskills.io/skill-creation/best-practices), read 2026-10-08: "Concise, stepwise guidance with a working example tends to outperform exhaustive documentation." The deletion test: "Would the agent get this wrong without this instruction? If the answer is no, cut it." "Provide defaults, not menus." A link carries its loading condition.
- [Agent Skills: evaluating skills](https://agentskills.io/skill-creation/evaluating-skills) and [optimizing descriptions](https://agentskills.io/skill-creation/optimizing-descriptions), read 2026-10-08: "Reasoning-based instructions ('Do X because Y tends to cause Z') work better than rigid directives ('ALWAYS do X, NEVER do Y')."
- [Claude skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices), read 2026-10-08: "The context window is a public good." Keep the body "under 500 lines". "All reference files should link directly from SKILL.md", because Claude can preview a nested file with `head -100`. A reference file over 100 lines opens with a table of contents. "Choose one term and use it throughout the Skill." No time-sensitive information. Descriptions are in the third person.
- [Claude Agent Skills overview](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview), read 2026-10-08: metadata "~100 tokens per Skill", instructions "Under 5k tokens", resources "None until accessed".
- [Claude Code skills](https://code.claude.com/docs/en/skills), read 2026-10-08: "every line is a recurring token cost." Write guidance that applies throughout a task "as standing instructions rather than one-time steps". After compaction, Claude Code re-attaches "the first 5,000 tokens of each" skill within a combined budget of 25,000 tokens, so the most important instructions go near the top. A rule that must hold every time moves into a hook.
- [Claude Code memory](https://code.claude.com/docs/en/memory) and [best practices](https://code.claude.com/docs/en/best-practices), read 2026-10-08: instructions "concrete enough to verify". "if two instructions contradict each other, Claude may pick one arbitrarily." "If you emphasize many lines, none of them stands out."
- [Anthropic, Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) (2025-10-16, updated 2025-12-18), read 2026-10-08: split an unwieldy `SKILL.md` and keep mutually exclusive contexts in separate files. No numeric size limit.
- [Anthropic skill-creator skill](https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md), read 2026-10-08: "Prefer using the imperative form in instructions." "If you find yourself writing ALWAYS or NEVER in all caps … that's a yellow flag." A table of contents for reference files over 300 lines. A sibling skill in the same repository has 605 lines, so the 500-line figure is not enforced.
- [Anthropic, The Complete Guide to Building Skills for Claude](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf) (2026-01), read 2026-10-08: "Keep SKILL.md under 5,000 words." "Put critical instructions at the top." "Code is deterministic; language interpretation isn't."
- [OpenAI, skills in Codex and ChatGPT](https://learn.chatgpt.com/docs/build-skills), read 2026-10-08: "Keep each skill focused on one job." "Write imperative steps with explicit inputs and outputs." The skill list takes "at most 2% of the model's context window, or 8,000 characters when the context window is unknown". Front-load the trigger words.
- [OpenAI skill-creator skill](https://github.com/openai/skills/blob/main/skills/.system/skill-creator/SKILL.md), read 2026-10-08: "Always use imperative/infinitive form." "Information should live in either SKILL.md or references files, not both." A body under 5,000 words, and a table of contents above 100 lines.
- [OpenAI, AGENTS.md in Codex](https://learn.chatgpt.com/docs/agent-configuration/agents-md), read 2026-10-08: Codex "stops adding files once the combined size reaches the limit defined by project_doc_max_bytes (32 KiB by default)". The 32,000-character reference cap follows it.
- [GitHub Copilot agent skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills), read 2026-10-08: skills hold "more detailed instructions that Copilot should only access when relevant".
- [VS Code agent skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills), read 2026-10-08: "Names with invalid characters cause the skill to silently fail to load."
- [Cursor skills](https://cursor.com/docs/skills), read 2026-10-08: reads `.agents/skills/`, `.cursor/skills/`, `.claude/skills/`, and `.codex/skills/`.
- [Gemini CLI skills](https://geminicli.com/docs/cli/skills/) and [creating skills](https://geminicli.com/docs/cli/creating-skills/), read 2026-10-08: the description "is how Gemini decides when to use the skill". No size limit is stated.
- [AGENTS.md](https://agents.md/), read 2026-10-08: "just standard Markdown. Use any headings you like". No size guidance.

### Context engineering and context windows

- [Anthropic, Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) (2025-09-29), read 2026-10-08: "Find the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome." Degradation is "a performance gradient rather than a hard cliff", and "minimal does not necessarily mean short".
- [Claude models overview](https://platform.claude.com/docs/en/docs/about-claude/models/overview) and [context windows](https://platform.claude.com/docs/en/build-with-claude/context-windows), read 2026-10-08: a 1M-token window by default, and "more context isn't automatically better. As token count grows, accuracy and recall degrade". The overview states "1M tokens is roughly 555k words or 2.5M Unicode characters", which is the 2.5 characters per token the budget uses.
- [Claude pricing](https://platform.claude.com/docs/en/about-claude/pricing), read 2026-10-08: "A 900k-token request is billed at the same per-token rate as a 9k-token request." It also states "1 token is approximately 4 characters or 0.75 words in English."
- [OpenAI models](https://developers.openai.com/api/docs/models) and [pricing](https://developers.openai.com/api/docs/pricing), read 2026-10-08: about 1.05M tokens, and prompts above 272K input tokens cost twice as much per input token.
- [Gemini 3.1 Pro](https://ai.google.dev/gemini-api/docs/models/gemini-3.1-pro-preview), [pricing](https://ai.google.dev/gemini-api/docs/pricing), and [long context](https://ai.google.dev/gemini-api/docs/long-context), read 2026-10-08: 1,048,576 input tokens, prompts above 200K cost twice as much, and "if you don't need tokens to be passed to the model, it is best to avoid passing them."
- [Anthropic, Claude Opus 4.6](https://www.anthropic.com/news/claude-opus-4-6) (2026-02-05), read 2026-10-08: on an 8-needle test at 1M tokens, "Opus 4.6 scores 76%, whereas Sonnet 4.5 scores just 18.5%." Use of the full window varies widely between models.

### Long-context degradation

- [Liu et al., Lost in the Middle](https://arxiv.org/abs/2307.03172) (2023-07-06), read 2026-10-08: performance "significantly degrades when models must access relevant information in the middle of long contexts".
- [Hsieh et al., RULER](https://arxiv.org/abs/2404.06654) (2024-04-09), read 2026-10-08: "only half of them can maintain satisfactory performance at the length of 32K."
- [Modarressi et al., NoLiMa](https://arxiv.org/abs/2502.05167) (2025-02-07), read 2026-10-08: "At 32K, for instance, 11 models drop below 50% of their strong short-length baselines."
- [Hong, Troynikov, Huber, Context Rot](https://www.trychroma.com/research/context-rot) (2025-07-14), read 2026-10-08: "Even a single distractor reduces performance relative to the baseline."
- [Shi et al., irrelevant context](https://arxiv.org/abs/2302.00093), read 2026-10-08: "Model performance is dramatically decreased when irrelevant information is included."
- [Levy, Jacoby, Goldberg](https://arxiv.org/abs/2402.14848), read 2026-10-08: reasoning degrades "at much shorter input lengths than their technical maximum."
- [Du et al.](https://arxiv.org/abs/2510.05381) (2025-10-06), read 2026-10-08: "Even when models can perfectly retrieve all relevant information, their performance still degrades substantially (13.9%–85%) as input length increases."
- [Bai et al., LongBench v2](https://arxiv.org/abs/2412.15204) (2024-12-19), read 2026-10-08: the best direct-answer model "achieves only 50.1% accuracy."
- [Paulsen, Maximum Effective Context Window](https://arxiv.org/abs/2509.21361), read 2026-10-08: the effective window is far below the advertised one. Weak evidence: one author and an unusual method.

### Instruction count and compliance

- [Zhou et al., IFEval](https://arxiv.org/abs/2311.07911) (2023-11-14), read 2026-10-08: the base benchmark for verifiable instructions.
- [Jiang et al., FollowBench](https://arxiv.org/abs/2310.20410), read 2026-10-08: compliance falls as constraints accumulate.
- [Jaroslawicz et al., IFScale](https://arxiv.org/abs/2507.11538) (2025-07-15), read 2026-10-08: "even the best frontier models only achieve 68% accuracy at the max density of 500 instructions", with a "bias towards earlier instructions".
- [Harada et al., ManyIFEval](https://arxiv.org/abs/2509.21051) (2025-09-25), read 2026-10-08: "performance consistently degrades as the number of instructions increases".
- [Qi et al., AgentIF](https://arxiv.org/abs/2505.16944), read 2026-10-08: real agent system prompts average "1,723 words" and "11.9 constraints per instruction", and current models "generally perform poorly".
- [Ding et al., OctoBench](https://arxiv.org/abs/2601.10343) (2026-01-15), read 2026-10-08: "a systematic gap between task-solving and scaffold-aware compliance", across system prompts, repository files, and skills.
- [Gloaguen et al., Evaluating AGENTS.md](https://arxiv.org/abs/2602.11988), read 2026-10-08: context files "do not generally improve task success rates, while increasing inference cost by over 20% on average".
- [Li et al., SkillsBench](https://arxiv.org/abs/2602.12670), read 2026-10-08: "Focused Skills with at most three modules outperform larger or exhaustive bundles". Compact skills gained 19.0 points and comprehensive skills 0.7. The figures changed between paper versions.
- [Eliav, Prompt Design at Scale](https://arxiv.org/abs/2607.19257) (2026-07-21), read 2026-10-08: with 80 or more rules, the rate of responses that satisfy every rule is near zero. Not peer reviewed. The same paper's VeyraBench finds "no model shows a consistent, meaningful markdown advantage", and Markdown costs about 26% more tokens than plain text.

### Prompt format

- [He et al.](https://arxiv.org/abs/2411.10541), read 2026-10-08: "there is no universally optimal format, even within the same generational lineage."
- [Sclar et al.](https://arxiv.org/abs/2310.11324), read 2026-10-08: spurious format changes moved accuracy by "up to 76 accuracy points" on a 13B model.
- [Claude prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices), read 2026-10-08: numbered lists or bullets "when the order or completeness of steps matters". A reason helps because "Claude is smart enough to generalize from the explanation." Replace "CRITICAL: You MUST use this tool when…" with "Use this tool when…", because Claude Opus 4.5 and 4.6 over-trigger on aggressive wording written for earlier models.
- [Prompting Claude Sonnet 5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-sonnet-5), read 2026-10-08: the model "interprets prompts literally and explicitly" and "does not silently generalize an instruction from one item to another."
- [OpenAI GPT-4.1 prompting guide](https://developers.openai.com/cookbook/examples/gpt4-1_prompting_guide), read 2026-10-08: the model follows instructions "more literally", and in a conflict it follows the one closer to the end.
- [OpenAI GPT-5 prompting guide](https://developers.openai.com/cookbook/examples/gpt-5/gpt-5_prompting_guide), read 2026-10-08: "contradictory or vague instructions can be more damaging".
- [OpenAI, Using GPT-6](https://developers.openai.com/api/docs/guides/latest-model), read 2026-10-08: "better able to follow longer instructions, but can also be more sensitive to information in context."
- [Google prompting strategies](https://ai.google.dev/gemini-api/docs/prompting-strategies) (updated 2026-09-17), read 2026-10-08: "Be precise and direct... Avoid unnecessary or overly persuasive language".

### Token proxies

- [Claude token counting](https://platform.claude.com/docs/en/build-with-claude/token-counting), read 2026-10-08: the new tokenizer "produces approximately 30 percent more tokens for the same text", and token counting is free.
- [Gemini tokens](https://ai.google.dev/gemini-api/docs/tokens), read 2026-10-08: "a token is equivalent to about 4 characters."
- [Roberts, Han, Albanie](https://arxiv.org/abs/2601.11518) (2026-01-16), read 2026-10-08: "token counts are not a stable unit of length." Compression varies by 20% to 50% between tokenizers.
- [Petrov et al.](https://arxiv.org/abs/2305.15425), read 2026-10-08: the same text in different languages differs in token length "up to 15 times".

### Installing a skill package

- [Atlassian TWG CLI skills](https://developer.atlassian.com/cloud/twg-cli/agents/skills/), read 2026-10-09: a CLI that installs the skills that operate it writes "the canonical skill bundle to `~/.agents/skills`" and gives Claude Code "a copy under `~/.claude/skills`". Each skill carries its own `references/`.
- [`gh skill install`](https://cli.github.com/manual/gh_skill_install), read 2026-10-09: local skills "are copied (not symlinked)", and several agents "share the `.agents/skills` directory".
- [Vercel `skills` CLI](https://github.com/vercel-labs/skills), read 2026-10-09: one canonical copy linked into each agent root. Its tracker records a link that never reached `~/.claude/skills` ([#744](https://github.com/vercel-labs/skills/issues/744)), copies turned back into links ([#1199](https://github.com/vercel-labs/skills/issues/1199)), and a request for a repair command ([#1025](https://github.com/vercel-labs/skills/issues/1025)).

### What the research could not verify

- The Cursor, GitHub Copilot, and Gemini CLI pages were read through a summarizing fetch, so their quotes are close but possibly not exact.
- No primary source prescribes Markdown decision tables. Section 9 chooses them for a closed choice on its own reasoning.
- No primary source caps an individual reference file beyond "focused" and "smaller". The 32,000-character cap follows the Codex 32 KiB limit for instruction files.
- Claude's tokenizer is not public, so the measurement in section 11 ran on OpenAI tokenizers. OQ-12 in `08-open-questions.md` tracks the check against Claude's own counts.
- The publication dates of the two OpenAI prompting guides do not appear on the pages.

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
