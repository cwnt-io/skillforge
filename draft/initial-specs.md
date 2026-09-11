# initial specs


I want to create a project... a repo that is my coding agent skill builder and framework...

this project will:

- have skill(s) that I'll use to build skills
- have it's own skills that will land in the user's host (as \~/.agents/skills for any conding agent + \~/.claude/skills)
- manage everything SoT/DRY... so skill can land both for agents and claude, but still share the same SoT...
- rust cli as a helper: skills have deterministic steps... so those deterministic steps will land as this cli subcommands... it will be a full helper to execute routines for our project's own skills as deterministic steps...

\---

ok... skillforge it is...

now, another question... do a deep web resarch and look for projects that already does what I am willing to do

I found several projects that overlap strongly with Skillforge, including one that is **surprisingly close** to part of your architecture. But after comparing the landscape, I did **not** find one project that combines all four things you described:

**skill-authoring framework + project-owned meta-skills + strict SoT/multi-agent projection + deterministic native CLI used by the skills themselves.**

That combination is where Skillforge can be distinct.

I also produced the full research report here:

[Download the full Skillforge landscape research](sandbox:/mnt/data/skillforge-landscape-research.md)

## The closest project: `cortesi/skills`

This one deserves your attention first:

[cortesi/skills on GitHub](https://github.com/cortesi/skills?utm_source=chatgpt.com)

It describes itself as:

> “A CLI for managing AI coding assistant skills from a single source.”

And it is **written in Rust**.

Its model is remarkably similar to part of what you proposed:

```text
canonical skills
       │
       ├──> ~/.claude/skills/
       │
       └──> ~/.agents/skills/
```

It supports:

```text
skills list
skills push
skills pull
skills sync
skills diff

skills new
skills edit
skills mv
skills validate
skills render

skills pack
skills import
skills unload
skills promote
```

It also has global and project-local canonical sources, dry-run support, target-specific rendering through MiniJinja, and explicit Claude/Agents projection. ([GitHub][1])

So the **SoT → Claude + Agents** idea already has direct prior art.

But there is an important difference.

`cortesi/skills` is fundamentally a **skill synchronization/management CLI**.

Skillforge, as you're describing it, can instead be a **skill engineering system**.

That's a substantially larger abstraction.

---

# The landscape I found

I would divide the existing projects into four categories.

| Project                     | Main concern                         | Relevance to Skillforge |
| --------------------------- | ------------------------------------ | ----------------------: |
| **cortesi/skills**          | SoT + sync + rendering               |                   ★★★★★ |
| **Anthropic skill-creator** | Author/build/evaluate skills         |                   ★★★★★ |
| **obra/superpowers**        | Meta-skills + methodology            |                   ★★★★★ |
| **skill-tools**             | Deterministic lint/quality           |                   ★★★★★ |
| **agent-skills-lint**       | Cross-agent deterministic validation |                   ★★★★☆ |
| **skill-validator**         | Deep structural/content validation   |                   ★★★★☆ |
| **Vercel `skills`**         | Distribution/install/update          |                   ★★★★☆ |
| **GitHub `gh skill`**       | Official-ish ecosystem distribution  |                   ★★★★☆ |
| **skill-sync** variants     | SoT + host synchronization           |                   ★★★☆☆ |
| **OpenSkills**              | Universal skill loader               |                   ★★★☆☆ |

The interesting thing is that **no one project owns the entire vertical**.

---

# 1. Anthropic's `skill-creator`

This should probably become one of Skillforge's primary upstream references.

[Anthropic skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator?utm_source=chatgpt.com)

Anthropic now treats skill creation as an engineering lifecycle rather than “write some Markdown.”

Their official skill covers:

```text
understand intent
      ↓
draft skill
      ↓
create test prompts
      ↓
execute skill
      ↓
evaluate outputs
      ↓
quantitative grading
      ↓
A/B comparison
      ↓
analyze failures
      ↓
improve
      ↓
benchmark
```

Their official Skill Creator plugin specifically exposes **Create, Eval, Improve and Benchmark** workflows and uses executor, grader, comparator and analyzer roles. ([Claude][2])

They also strongly embrace progressive disclosure:

```text
metadata
  ↓ always loaded

SKILL.md
  ↓ loaded on activation

references / scripts / assets
  ↓ loaded only when required
```

The Agent Skills specification formalizes the same general structure. ([Agent Skills][3])

### What Skillforge can do differently

Anthropic's system still leaves a lot of procedure to the agent.

Your architecture could explicitly say:

> If something can be deterministic, don't explain to the LLM how to do it. Put it in `skillforge` and tell the LLM when to invoke it.

That's a strong principle.

---

# 2. `skill-tools`

This is perhaps the strongest reference for your **deterministic CLI philosophy**.

[skill-tools/skill-tools](https://github.com/skill-tools/skill-tools?utm_source=chatgpt.com)

It describes itself as essentially:

> ESLint + Lighthouse for Agent Skills.

It provides deterministic:

```text
parse
validate
lint
score
route
watch
generate
```

with spec checks, lint rules, hardcoded-path and secret checks, quality scoring, pre-commit integration, GitHub Actions and SARIF. ([GitHub][4])

That's very aligned with your thinking.

But their CLI operates **on skills**.

Your interesting addition would be that the CLI also operates **for skills**.

For example:

```text
Agent
 │
 │ activates skill-create
 ▼
SKILL.md
 │
 ├─ judgment / reasoning ──────────────> Agent
 │
 └─ deterministic operation ──────────> skillforge inspect
                                        skillforge scaffold
                                        skillforge validate
                                        skillforge references check
                                        skillforge eval prepare
                                        skillforge project
```

That boundary is important.

---

# 3. `agent-skills-lint`

Another excellent architectural reference:

[agent-skills-lint](https://github.com/swarmclawai/agent-skills-lint?utm_source=chatgpt.com)

It validates different agent flavors, catches collisions, installs skills and generates indexes. ([GitHub][5])

But the part I particularly like **for your Rust CLI** is its agent-facing CLI contract:

```text
non-interactive by default
JSON output
stable exit codes
stdout = data
stderr = diagnostics
machine-readable command catalog
```

For example, it intentionally produces structured envelopes rather than forcing agents to parse pretty terminal output. ([GitHub][5])

I would strongly consider the same philosophy for Skillforge:

```bash
skillforge check foo
skillforge check foo --json
```

Human:

```text
✓ metadata
✓ references
✓ structure
✗ description: weak trigger coverage
```

Agent:

```json
{
  "ok": false,
  "violations": [...]
}
```

Same underlying implementation.

---

# 4. `agent-ecosystem/skill-validator`

Another one worth mining heavily:

[agent-ecosystem/skill-validator](https://github.com/agent-ecosystem/skill-validator?utm_source=chatgpt.com)

This goes much further than basic YAML validation.

It checks things such as:

* directory structure
* frontmatter
* internal links
* orphan resources
* Markdown correctness
* extraneous files
* content density
* contamination
* structural conformance

It even treats malformed Markdown fences as errors because they can change how an agent interprets everything following them. ([GitHub][6])

This suggests a useful Skillforge architecture:

```text
skillforge check
    │
    ├── spec
    │    Agent Skills compliance
    │
    ├── policy
    │    Skillforge conventions
    │
    └── behavior
         eval/test expectations
```

I'd keep those explicitly separate.

---

# 5. `obra/superpowers`

Conceptually, this might be **the most important project for you to study**.

[obra/superpowers](https://github.com/obra/superpowers?utm_source=chatgpt.com)

Superpowers isn't primarily a skill manager.

It's a **methodology implemented as a collection of composable skills**.

It has skills for:

```text
brainstorming
planning
TDD
worktrees
execution
code review
parallel agents
debugging
...
```

And critically, it has a meta-skill:

```text
writing-skills
```

that contributors are expected to use when creating and modifying the project's own skills. It also has behavioral/evaluation infrastructure for testing skills. ([GitHub][7])

That's almost exactly your recursive idea:

```text
Skillforge
   │
   ├── builds skills
   │
   ├── contains skills
   │
   └── its skills teach agents how
       to build Skillforge skills
```

In other words:

```text
Skillforge builds Skillforge.
```

Superpowers demonstrates that this pattern can work very well.

Where you diverge is that **skill engineering itself** is your product.

---

# 6. Vercel's `skills`

This one changes an important design decision.

[skills CLI](https://github.com/vercel-labs/skills?utm_source=chatgpt.com)

The `skills` CLI now supports a broad set of coding agents and can:

```text
add
find
list
remove
check
update
init
generate-lock
```

It supports both copy and symlink installations and explicitly describes symlinks to a canonical copy as a **single source of truth** approach. ([GitHub][8])

That means Skillforge probably shouldn't try to win by saying:

> “We install SKILL.md files into lots of agents.”

That problem is rapidly becoming commoditized.

---

# 7. GitHub `gh skill`

Even more importantly, GitHub itself entered this space in April 2026.

`gh skill` now provides:

```text
gh skill install
gh skill list
gh skill preview
gh skill publish
gh skill search
gh skill update
```

It understands different hosts, project/user scope, provenance, local repositories, version pinning and updates. ([The GitHub Blog][9])

GitHub currently documents a very large list of supported hosts, including Claude Code, Codex, Cursor, Gemini CLI, OpenCode and others. ([GitHub CLI][10])

So I would **not build Skillforge as a package manager**.

Let GitHub/Vercel/etc. fight that problem.

---

# 8. More direct SoT competitors

There are actually several.

### `vikasagarwal101/skill-sync`

It explicitly treats:

```text
~/.agents/skills/
```

as canonical and synchronizes real copies elsewhere, including Claude Code.

It has:

```text
create
edit
sync
validate
deploy
doctor
```

plus a manifest. ([GitHub][11])

### `itsHabib/skill-sync`

Similar idea, but with explicit source/target providers, drift detection and policy manifests. ([GitHub][12])

### `reorx/skm`

Has a central store and projects it into:

```text
~/.agents/skills
~/.claude/skills
~/.codex/skills
~/.openclaw/skills
```

using symlinks by default. ([GitHub][13])

### `skills-man`

Another **Rust** implementation, focused on installing/managing skill collections from GitHub. ([GitHub][14])

So there is definitely a growing **skill-manager** category.

---

# And this leads to the key conclusion

I would **not** define Skillforge as:

> A CLI to manage agent skills from one source.

That's dangerously close to:

```text
cortesi/skills
skill-sync
skm
skills-man
Vercel skills
gh skill
```

Instead:

> **Skillforge is a skill engineering framework.**

Something closer to:

```text
                   SKILLFORGE

              ┌─────────────────┐
              │ authoring rules │
              │ specs / policy  │
              └────────┬────────┘
                       │
                ┌──────▼──────┐
                │ meta-skills │
                │             │
                │ create      │
                │ review      │
                │ improve     │
                │ test        │
                └──────┬──────┘
                       │
        judgment       │       deterministic
           ┌───────────┴───────────┐
           ▼                       ▼
       coding agent          skillforge CLI
                                  │
                         ┌────────┼────────┐
                         │        │        │
                       lint     eval    render
                       check   prepare   project
                         │        │        │
                         └────────┼────────┘
                                  ▼
                           canonical skills
                                  │
                             projections
                         ┌────────┴────────┐
                         ▼                 ▼
                  ~/.agents/skills  ~/.claude/skills
```

That is much more compelling.

---

# I would also make one architectural change to your original idea

You said:

> manage everything SoT/DRY so skill can land both for agents and Claude but still share the same SoT.

I would make that **strictly one-way**.

Not:

```text
source ↔ ~/.agents ↔ ~/.claude
```

like some sync tools do.

Instead:

```text
                  authoritative
                       │
                       ▼
repo/skills/<skill>/
                       │
              ┌────────┴────────┐
              ▼                 ▼
      ~/.agents/skills    ~/.claude/skills
          projection          projection
```

Installed trees are disposable build artifacts.

Never edit them.

That gives you:

```text
one authoritative representation
no conflict resolution
no timestamps
no pull semantics
no drift ambiguity
idempotent install
easy checksum verification
```

Much cleaner.

---

# Another architectural decision I think is particularly strong

Use the **Agent Skills specification as the substrate**, rather than inventing a Skillforge skill format.

The open specification already defines the core:

```text
skill/
├── SKILL.md
├── scripts/
├── references/
└── assets/
```

with `name`, `description`, progressive disclosure and validation rules. ([Agent Skills][3])

Therefore:

```text
Agent Skills specification
        │
        │ base format
        ▼
Skillforge profile
        │
        │ stricter conventions
        ▼
Skillforge skills
```

Think:

```text
HTML       → WHATWG conventions
Rust       → rustfmt + clippy
SKILL.md   → Skillforge
```

rather than creating a new serialization format.

---

# The part of your idea I found least represented elsewhere

This:

> **Centralize deterministic mechanics in one native CLI, and have the project's skills invoke it.**

Most projects do one of two things:

```text
SKILL.md
└── scripts/foo.py
```

or:

```text
external CLI
└── manages SKILL.md
```

Your model can instead be:

```text
SKILL.md
    │
    ├── reasoning
    ├── decision rules
    └── invokes
          │
          ▼
    skillforge <operation>
```

So instead of teaching every skill:

```markdown
Walk the directory.
Find SKILL.md.
Parse the YAML.
Check that name matches the directory.
Check all relative links.
Calculate...
```

the skill says:

```text
Run:

    skillforge inspect <skill>

Use its structured result to determine the next action.
```

That is **dramatically better for determinism, token usage and maintainability**.

And because the CLI is Rust:

```text
one static-ish binary
fast startup
strong typing
single implementation
easy agent execution
predictable behavior
```

This can become one of Skillforge's core design principles:

> **Reason in skills. Execute mechanics in code.**

That may actually be the project's defining idea.

---

## My current competitive assessment

If I scored the intended architecture:

| Capability                        | cortesi | Anthropic | skill-tools | Superpowers | **Skillforge** |
| --------------------------------- | ------: | --------: | ----------: | ----------: | -------------: |
| Canonical skill SoT               |   ★★★★★ |         ★ |           ★ |         ★★★ |      **★★★★★** |
| Multi-agent projection            |    ★★★★ |         ★ |           ★ |        ★★★★ |      **★★★★★** |
| Skill authoring methodology       |      ★★ |     ★★★★★ |         ★★★ |        ★★★★ |      **★★★★★** |
| Meta-skills                       |       ★ |     ★★★★★ |           ★ |       ★★★★★ |      **★★★★★** |
| Deterministic validation          |     ★★★ |       ★★★ |       ★★★★★ |         ★★★ |      **★★★★★** |
| Behavioral evals                  |       ★ |     ★★★★★ |          ★★ |       ★★★★★ |      **★★★★★** |
| Native helper for skill execution |      ★★ |        ★★ |          ★★ |          ★★ |      **★★★★★** |
| Rust                              |   ★★★★★ |         — |           — |           — |      **★★★★★** |

So I think **Skillforge is worth building**, but only if you deliberately make it the intersection of those disciplines rather than another skill manager.

The strongest upstream inspirations I would study in depth next are **Anthropic `skill-creator` for methodology, `obra/superpowers` for recursive/meta-skill architecture, `skill-tools` + `agent-skills-lint` for deterministic enforcement, `cortesi/skills` for Rust/SoT mechanics, and agentskills.io as the base specification**. ([GitHub][15])

A logical next step is to turn this landscape into a **concrete Skillforge architecture/specification**: repository tree, SoT model, projection rules, CLI command surface, responsibility boundary between `SKILL.md` and Rust, validation layers, and the initial meta-skills.

[1]: https://github.com/cortesi/skills "GitHub - cortesi/skills · GitHub"
[2]: https://claude.com/plugins/skill-creator?utm_source=chatgpt.com "Skill Creator Plugin | Claude by Anthropic"
[3]: https://agentskills.io/specification?utm_source=chatgpt.com "Specification - Agent Skills"
[4]: https://github.com/skill-tools/skill-tools?utm_source=chatgpt.com "GitHub - skill-tools/skill-tools: Lint, score, and route SKILL.md files. Parse, validate, and quality-score Agent Skills per the agentskills.io spec. BM25 skill routing. Zero LLM dependencies. · GitHub"
[5]: https://github.com/swarmclawai/agent-skills-lint?utm_source=chatgpt.com "GitHub - swarmclawai/agent-skills-lint: Cross-agent skill validator and installer — Claude Code, Codex, OpenCode, Aider, Copilot, Cursor, Gemini, Droid, Trae, Kiro, and more. Built for agents. · GitHub"
[6]: https://github.com/agent-ecosystem/skill-validator?utm_source=chatgpt.com "GitHub - agent-ecosystem/skill-validator: Validate Skill content against Agent Skill specification, with additional content density and quality checks. · GitHub"
[7]: https://github.com/obra/Superpowers?utm_source=chatgpt.com "GitHub - obra/superpowers: An agentic skills framework & software development methodology that works. · GitHub"
[8]: https://github.com/antfu/skills-cli "GitHub - antfu/skills-cli: The open agent skills tool - npx skills · GitHub"
[9]: https://github.blog/changelog/2026-04-16-manage-agent-skills-with-github-cli/ "Manage agent skills with GitHub CLI - GitHub Changelog"
[10]: https://cli.github.com/manual/gh_skill_install?utm_source=chatgpt.com "GitHub CLI | Take GitHub to the command line"
[11]: https://github.com/vikasagarwal101/skill-sync/blob/main/README.md?utm_source=chatgpt.com "skill-sync/README.md at main · vikasagarwal101/skill-sync · GitHub"
[12]: https://github.com/itsHabib/skill-sync?utm_source=chatgpt.com "GitHub - itsHabib/skill-sync: CLI tool to sync custom skills from various providers · GitHub"
[13]: https://github.com/reorx/skm?utm_source=chatgpt.com "GitHub - reorx/skm: A better skills manager · GitHub"
[14]: https://github.com/nomyfan/skills-man?utm_source=chatgpt.com "GitHub - nomyfan/skills-man: A CLI to manage your agent skills. · GitHub"
[15]: https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md?utm_source=chatgpt.com "skills/skills/skill-creator/SKILL.md at main · anthropics/skills · GitHub"

---


Yes... I want exaclyt that... 

but let me ask you something... 

the intention of this project is to be "user agnostic"...

yes, we can land our own set of skills (something that is already usefull for me and can be useful for others)... but I want something extensible... 

I think if I embed the determinism in the cli itself... I am coupling particular skill behavior (my preferences) into the cli logic...

it is ok... but is there a better alternative?

---

Yes. I think your instinct is correct: if `skillforge` itself accumulates the deterministic implementation of every skill, you eventually turn the CLI into a monolith whose behavior reflects the bundled skills rather than the framework.

A cleaner model is:

> **Skillforge owns the execution contract, not the skill-specific deterministic logic.**

In other words, make the CLI a **runtime/orchestrator for deterministic steps**, while each skill—or skill package—owns its own executable mechanics.

The architecture I would recommend is something like this:

```text
skillforge
├── framework/runtime
│   ├── discover skills
│   ├── validate manifests
│   ├── resolve dependencies
│   ├── invoke deterministic actions
│   ├── normalize input/output
│   ├── enforce exit codes
│   ├── sandbox/capability policy
│   └── install/project skills
│
└── skills
    ├── skill-a/
    │   ├── SKILL.md
    │   ├── skillforge.toml
    │   └── actions/
    │       ├── inspect
    │       └── normalize
    │
    └── skill-b/
        ├── SKILL.md
        ├── skillforge.toml
        └── actions/
            └── analyze
```

Then instead of baking:

```text
skillforge inspect-skill
skillforge normalize-foo
skillforge generate-bar
```

into Rust, the framework exposes something generic:

```bash
skillforge run skill-a inspect
skillforge run skill-a normalize
skillforge run skill-b analyze
```

or perhaps an ergonomic alias:

```bash
skillforge skill-a inspect
```

The important point is that `skillforge` does **not know what `inspect` means**. It only knows how to discover, validate, invoke, constrain, and report it.

That makes the project user-agnostic.

## The sweet spot: declarative manifest + external executable

I would avoid making the first version a dynamic Rust plugin system. Native plugins introduce ABI/versioning pain very quickly.

A much cleaner contract is:

```toml
[skill]
name = "skill-review"

[action.inspect]
command = "./actions/inspect"
input = "json"
output = "json"
timeout = 30

[action.fix]
command = "./actions/fix"
input = "json"
output = "json"
writes = true
```

Then an action can be anything executable:

```text
Rust binary
Python script
shell script
Node program
compiled Go executable
WASM module later
```

Skillforge provides the stable execution envelope:

```json
{
  "skill": "skill-review",
  "action": "inspect",
  "args": {},
  "context": {
    "cwd": "...",
    "skill_root": "..."
  }
}
```

and expects something like:

```json
{
  "ok": true,
  "data": {},
  "diagnostics": []
}
```

Now the framework remains generic while deterministic behavior remains local to the skill.

That separation is very strong.

## Even better: distinguish three layers

I would define Skillforge around three explicit layers.

```text
1. SKILL.md
   reasoning / workflow / decisions / agent instructions

2. skill manifest
   declares deterministic capabilities

3. executable actions
   implements deterministic mechanics
```

So:

```text
SKILL.md
   |
   | "run the canonical inspection action"
   v
skillforge run self inspect
   |
   v
manifest
   |
   v
actions/inspect
```

That gives you a very clean rule:

> **Skills decide when. Actions define how. Skillforge guarantees execution.**

I like that more than “reason in skills, execute mechanics in Skillforge,” because the latter still implies Skillforge owns the mechanics.

I would refine it to:

> **Reason in skills. Execute mechanics through Skillforge.**

That one word—**through**—is the architectural distinction.

## Your bundled skills then become ordinary consumers

This is important for keeping the system honest.

Your own skills should not get privileged hooks like:

```rust
match skill {
    "skill-create" => create_skill(),
    "skill-review" => review_skill(),
}
```

Instead they should use exactly the same public extension model as third-party skills:

```text
skills/
└── skill-create/
    ├── SKILL.md
    ├── skillforge.toml
    └── actions/
        ├── scaffold
        ├── validate-name
        └── collect-metadata
```

That gives you a powerful design constraint:

> **If Skillforge's own skills cannot be implemented using the public extension API, the extension API is incomplete.**

This is analogous to dogfooding an SDK.

## I would not put every deterministic step into scripts, though

There is one nuance.

Some deterministic functionality **is framework-level** and belongs in the CLI.

For example:

```text
skillforge validate
skillforge install
skillforge project
skillforge list
skillforge run
skillforge doctor
skillforge pack
```

Those operations are about the **Skillforge model itself**.

But this:

```text
parse a Python package
inspect Git history
normalize YAML for one workflow
generate a release-specific structure
query GitHub for one skill
```

belongs to the skill or an extension package.

The rule I would use:

> If the behavior is necessary to implement the Skillforge specification, it belongs in core.
>
> If the behavior exists because of what a particular skill wants to accomplish, it belongs outside core.

That boundary will save you from a lot of architectural drift.

## You could also introduce reusable “tools”

There's another useful abstraction between core and skills.

Some deterministic actions will be reusable across many unrelated skills:

```text
git
filesystem
markdown
yaml
json
http
process
template rendering
```

Instead of every skill shipping its own implementation, Skillforge could expose a small stable toolkit:

```bash
skillforge tool git changed-files
skillforge tool markdown links
skillforge tool fs hash-tree
```

But I'd be conservative here. Only promote something into core once several skills independently require it.

Otherwise you recreate the monolith problem.

A healthier lifecycle is:

```text
skill-local action
      ↓
used by several skills
      ↓
shared extension/library
      ↓
proven universal primitive
      ↓
possibly Skillforge core
```

Not the reverse.

## Longer-term: WASM is attractive

If Skillforge eventually needs strong portability and sandboxing, WebAssembly could be a very good plugin target.

Then a deterministic action could be:

```text
actions/
└── inspect.wasm
```

with explicit capabilities:

```toml
[action.inspect]
module = "actions/inspect.wasm"

capabilities = [
    "fs:read",
    "git:read"
]
```

Advantages:

```text
portable
language-agnostic
sandboxable
versionable
deterministic-ish execution boundary
no native ABI plugin headache
```

But I would not start there.

For v1, executable subprocesses with JSON stdin/stdout are much simpler and extremely Unix-like.

## I think the ideal Skillforge architecture becomes

```text
                     Skillforge
                         │
            ┌────────────┼────────────┐
            │            │            │
         discover      validate      run
            │            │            │
            └────────────┴────────────┘
                         │
                 stable execution API
                         │
         ┌───────────────┼────────────────┐
         │               │                │
     your skills     user skills     community skills
         │               │                │
    ┌────┴────┐      ┌───┴────┐       ┌───┴────┐
 SKILL.md actions   SKILL.md actions  SKILL.md actions
              │
              └── deterministic mechanics
```

And critically:

```text
Skillforge core
≠
your skill implementation
```

Your repository can still ship an opinionated default skill pack, but architecturally that becomes:

```text
skillforge-core
skillforge-standard-skills
```

even if both live in the same repo initially.

That gives you both things you want:

**opinionated enough to be immediately useful, but structurally neutral enough for someone else to build a completely different skill ecosystem on top of it.**

If I were making the architectural call now, I would choose **manifest-declared subprocess actions + JSON protocol + zero privileged bundled skills** as the initial extension model. It is probably the cleanest balance of DRY, determinism, extensibility, portability, and implementation simplicity.


---

If the behavior is necessary to implement the Skillforge specification, it belongs in core.

If the behavior exists because of what a particular skill wants to accomplish, it belongs outside core.

---

I agree...

But inside a skill... the skill itself (de-coupled from skillforge)...

We, as skillforge, the maker of the skill... would guide a coding agent to... when create our skills... to drive the skill creation at a direction where: determinstic steps would become deterministic scripts... and probabilistic steps would be the skill body instruction... where the skill is the orchestrator of both: where and when execute the script and where and when order a descriptive task to the agent...

---

Yes — that is the cleaner abstraction.

The **skill itself should be the orchestration unit**, independent of Skillforge. Skillforge’s job is then to **author, validate, and enforce this design discipline**, not to own the skill’s execution model.

Conceptually:

```text
Skillforge
   ↓
helps create a well-structured skill
   ↓

skill/
├── SKILL.md
├── scripts/
│   ├── inspect.py
│   ├── normalize.sh
│   └── validate.py
└── references/
```

Then the skill itself coordinates two classes of work:

```text
                   SKILL
                     │
          ┌──────────┴──────────┐
          │                     │
   probabilistic work     deterministic work
          │                     │
          ▼                     ▼
   agent reasoning          script/tool
   judgment                 exact operation
   interpretation           parsing
   synthesis                validation
   decisions                transformation
   writing                  calculation
```

The key principle could be:

> **Use the agent for judgment. Use code for mechanics. Let the skill orchestrate both.**

That is stronger than making Skillforge the runtime.

## The skill becomes the workflow definition

For example, imagine a `skill-review` skill.

Its `SKILL.md` might effectively encode:

```text
1. Determine what kind of skill is being reviewed.
2. Run scripts/inspect.py against the skill directory.
3. Interpret the deterministic findings.
4. Review semantic qualities that cannot be reliably linted.
5. If structural problems exist, run scripts/fix-frontmatter.py when safe.
6. Reassess the resulting skill.
7. Produce the final recommendation.
```

There are three distinct kinds of instruction there:

```text
Agent reasoning
    "Determine what kind of skill this is"

Deterministic execution
    "Run scripts/inspect.py"

Agent reasoning over deterministic evidence
    "Interpret the findings and assess semantic quality"
```

That is a very natural agent workflow.

## I would make this an explicit Skillforge authoring rule

Something like:

### Determinism boundary

For every workflow step, determine whether the result should be:

```text
same input → same result
```

If yes, prefer a deterministic implementation.

If not, or if the task fundamentally requires interpretation, synthesis, ambiguity resolution, or contextual judgment, keep it in the skill instructions.

So when Skillforge's `skill-create` meta-skill is designing a new skill, it should actively classify steps:

```text
Step: validate frontmatter
Classification: deterministic
Implementation: script

Step: decide whether description is semantically clear
Classification: probabilistic
Implementation: agent instruction

Step: find broken relative links
Classification: deterministic
Implementation: script

Step: determine whether references are actually useful
Classification: probabilistic
Implementation: agent instruction
```

That classification itself should be part of the skill-authoring methodology.

## This also gives you an important anti-pattern

Skillforge should discourage this:

```markdown
Look through every Markdown link in the skill.
Resolve each relative path.
Check whether the target exists.
Record any broken links.
```

That's making the LLM simulate a deterministic program.

Prefer:

```markdown
Run:

    python scripts/check-links.py .

Use the reported violations when reviewing the skill.
```

Likewise, discourage a script that tries to decide things like:

```text
"Is this instruction pedagogically clear?"
"Is this workflow well designed?"
"Would an agent understand the intent?"
```

Those belong on the probabilistic side.

So the framework establishes a **bidirectional boundary**:

> Do not use an LLM where a deterministic program is sufficient.

and:

> Do not force deterministic code to approximate a judgment task that the model is better suited to perform.

## Scripts should belong to the skill

This is also important for portability.

A Skillforge-produced skill should remain useful after Skillforge disappears:

```bash
cp -r my-skill ~/.agents/skills/
```

and the agent should still be able to use:

```text
my-skill/
├── SKILL.md
└── scripts/
```

No requirement for:

```text
skillforge run ...
```

That means your output remains compatible with the broader Agent Skills ecosystem rather than creating a proprietary runtime dependency.

I think that's a substantial improvement over the earlier model.

## You can take it one step further: scripts are implementation details

The agent shouldn't necessarily need to understand the implementation.

For example:

```markdown
### Inspect the repository

Run:

    ./scripts/inspect-repository

Treat its JSON output as authoritative for:
- repository structure
- detected languages
- manifests
- current branch
```

The skill owns the interface to the script.

This lets you later replace:

```text
inspect-repository.py
```

with:

```text
inspect-repository.rs
```

without changing the conceptual workflow.

The SKILL.md describes **what deterministic capability to invoke**, not necessarily how it works.

## A useful internal model is four step types

When Skillforge authors a skill, I would have it classify every meaningful step as one of:

```text
R — Reason
    Agent judgment / interpretation.

A — Act
    Agent performs an inherently contextual action.

D — Deterministic
    Execute code/tooling with predictable behavior.

V — Verify
    Check whether the result satisfies the intended condition.
```

A well-designed skill often becomes:

```text
R → D → R → A → D → V
```

For example:

```text
R  Understand requested change

D  Inspect repository structure

R  Decide the correct implementation strategy

A  Modify the relevant source

D  Run formatter/tests/static checks

V  Assess whether the request is fully satisfied
```

That is a very good mental model for agentic workflow design.

You don't necessarily need to expose `R/A/D/V` syntax in `SKILL.md`; it can just be part of Skillforge's authoring methodology.

## Another important rule: prefer existing deterministic tools first

When the meta-skill sees a deterministic step, it shouldn't immediately generate a new script.

The hierarchy should probably be:

```text
1. Existing project command/tool
2. Existing standard CLI
3. Existing library/toolchain
4. Small skill-local script
5. New complex implementation
```

For example:

Bad:

```text
write scripts/git-status.py
```

when:

```bash
git status --porcelain=v1
```

already gives deterministic structured-ish output.

Likewise:

```text
ruff
cargo metadata
jq
git
fd
rg
pytest
cargo test
```

should be reused before creating wrappers.

So another Skillforge principle could be:

> **Automate deterministic steps with the smallest existing deterministic primitive.**

This keeps skills lean.

## And scripts themselves should have standards

This could become part of the Skillforge profile.

Skill-local scripts should ideally be:

* non-interactive
* idempotent where possible
* explicit about inputs
* predictable about outputs
* machine-readable when their output feeds the agent
* clean stdout/stderr separation
* meaningful exit codes
* no hidden global state
* relative to the skill/project context rather than hardcoded host paths
* dependency-light
* safe to rerun

For example:

```bash
./scripts/inspect .
```

stdout:

```json
{
  "ok": true,
  "findings": [...]
}
```

stderr:

```text
warning: optional git metadata unavailable
```

exit status:

```text
0 = operation succeeded
1 = expected validation failure
2 = invocation/configuration failure
```

That is exactly the kind of deterministic contract agents handle well.

## This gives Skillforge a much clearer identity

Not:

> Skillforge is a runtime for skills.

And not merely:

> Skillforge creates skills.

More precisely:

> **Skillforge is an engineering framework for creating reliable agent skills.**

Its methodology teaches authors and coding agents to produce skills where:

```text
SKILL.md
    =
workflow orchestration
+ judgment instructions
+ deterministic capability invocation
```

while:

```text
scripts/
    =
repeatable mechanics
```

and:

```text
references/
    =
knowledge loaded only when required
```

That gives you a very elegant separation:

```text
                 skill/
                   │
        ┌──────────┼──────────┐
        │          │          │
     SKILL.md   scripts/   references/
        │          │          │
   reasoning    mechanics    knowledge
        │          │          │
        └──────────┴──────────┘
                   │
              orchestrated by
                SKILL.md
```

I think **this should become one of Skillforge's foundational design laws**, because it simultaneously improves determinism, portability, context efficiency, debuggability, testability, and agent reliability.


---

ok... now\... what about the script itself... we would allow python and bash? and... as a framework... how would we define... design... (best practices... geting inspiration from the other preojcts):

- shared libraries/functions/methods/patterns
- setup and manage the runtime for those scripts


---


I would define this as a small **script runtime profile** inside the Skillforge methodology, not as a Skillforge-specific execution engine.

The goal should be:

> A Skillforge-authored skill may ship executable helpers, but those helpers remain ordinary portable files that any capable coding agent can run without Skillforge being installed.

That keeps the skill decoupled.

And yes: I would support **Python and POSIX shell as the canonical first-class languages**.

Anthropic’s own skill guidance explicitly treats `scripts/` as executable code such as Python/Bash for deterministic or repeatedly rewritten tasks. ([GitHub][1])

## 1. Language policy

I would make the default hierarchy:

```text
Need deterministic logic?
        │
        ├─ Can an existing CLI do it cleanly?
        │      └─ use the CLI
        │
        ├─ Tiny orchestration / process glue?
        │      └─ POSIX shell
        │
        ├─ Parsing / structured data / non-trivial logic?
        │      └─ Python
        │
        └─ Exceptional requirement?
               └─ another language, explicitly justified
```

So not:

```text
Python OR Bash depending on author's taste
```

but rather:

### Shell

Use for:

* invoking existing tools
* pipelines
* filesystem glue
* simple branching
* environment checks
* very small wrappers

Example:

```sh
#!/bin/sh
set -eu

git diff --name-only --cached
```

### Python

Use when you have:

* JSON/YAML/TOML processing
* recursive traversal
* complex validation
* substantial branching
* data structures
* portability concerns
* nontrivial error handling
* tests worth writing

This prevents 250-line shell scripts.

I would probably codify something like:

> Shell is glue. Python is logic.

Not an absolute rule, but a strong default.

---

# 2. Don't invent a Skillforge runtime format unnecessarily

For Python specifically, there is now a very good standard we can leverage: **PEP 723 inline script metadata**.

A skill-local script can be completely self-describing:

```python
#!/usr/bin/env -S uv run --script

# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "pydantic>=2",
# ]
# ///

from pydantic import BaseModel
...
```

PEP 723 is a standardized Python packaging mechanism for putting `requires-python` and dependencies directly inside a single-file script. ([Python Packaging][2])

And `uv` supports this model directly:

```bash
uv run scripts/inspect.py
```

It creates an isolated environment with the declared dependencies, respects the required Python version, and ignores unrelated project dependencies when executing an inline-metadata script. ([Astral Docs][3])

For Skillforge, this is almost ideal.

Instead of inventing:

```yaml
runtime:
  python: 3.12
  dependencies:
    - pydantic
```

you simply use the existing ecosystem standard.

---

# 3. My preferred runtime model

I would therefore establish three runtime tiers.

```text
Tier 0
Existing system command
git / rg / jq / cargo / etc.

Tier 1
Dependency-free script
POSIX shell or Python stdlib

Tier 2
Self-contained Python script
PEP 723 + uv
```

Prefer the lowest tier that cleanly solves the problem.

For example:

```text
scripts/
├── changed-files.sh        # Tier 1
├── inspect_skill.py        # Tier 1
└── query_metadata.py       # Tier 2
```

And `SKILL.md` simply says:

```markdown
Run:

    uv run scripts/query_metadata.py <path>
```

or:

```markdown
Run:

    scripts/changed-files.sh
```

No Skillforge runtime required.

---

# 4. But what about whether `uv` exists?

This is where I would distinguish **skill portability** from **zero-dependency portability**.

Agent Skills already support a `compatibility` field for describing environmental requirements such as tooling/system packages. ([GitHub][4])

So a skill requiring `uv` can legitimately declare that requirement.

For example:

```yaml
---
name: repository-analyzer
description: ...
compatibility: Requires Python 3.11+ and uv.
---
```

But the Skillforge authoring methodology should encourage dependency minimization:

```text
Python stdlib solves it?
    ↓ yes
Don't require uv dependencies.

Needs third-party Python packages?
    ↓
PEP 723 + uv.
```

You could even make:

```bash
uv run scripts/foo.py
```

the standard Skillforge recommendation for **all Python scripts**, including scripts with no dependencies.

Why?

Because then execution semantics are consistent and `requires-python` can still be honored.

However, I wouldn't make that mandatory in v1. It would unnecessarily exclude users who have Python but not uv.

---

# 5. Shared libraries are where things get interesting

You raised exactly the right issue:

```text
skill-a/scripts/foo.py
skill-b/scripts/bar.py

both need:
- subprocess handling
- JSON output
- error structure
- repo discovery
- common validation
```

We don't want copy/paste.

But we also don't want:

```text
import skillforge
```

because then the generated skill is coupled to Skillforge.

I think there are **three scopes of reuse**, and Skillforge should distinguish them.

---

# Scope A — within one skill

Easy.

```text
my-skill/
├── SKILL.md
└── scripts/
    ├── inspect.py
    ├── validate.py
    └── lib/
        ├── __init__.py
        ├── output.py
        └── repository.py
```

Then:

```python
from lib.output import result
```

This is perfectly fine.

The skill remains self-contained.

---

# Scope B — shared by several skills in one skill pack

Suppose Skillforge ships:

```text
skills/
├── skill-create/
├── skill-review/
├── skill-improve/
└── skill-test/
```

and they all need the same machinery.

This creates tension.

You could make:

```text
skills/
├── _lib/
│   └── python/
└── skill-create/
```

but now an individual skill is no longer portable when copied by itself.

That's bad.

I would therefore **not allow runtime cross-skill imports by default**.

This should probably be a core rule:

> A distributable skill must be runtime-self-contained.

Meaning:

```text
skill-a/scripts/foo.py
```

must not depend upon:

```text
../skill-b/
../../shared/
$SKILLFORGE_HOME/lib/
```

This dramatically improves portability.

---

# So how do we stay DRY?

At **authoring/build time**, not runtime.

This is where Skillforge itself has a legitimate role.

Your repo can have:

```text
skillforge/
├── lib/
│   └── python/
│       ├── output.py
│       ├── process.py
│       └── git.py
│
└── skills/
    ├── skill-create/
    └── skill-review/
```

But when building/projecting skills, common code is **vendored into the skill**:

```text
source
──────

lib/python/output.py
          │
          ├──────────┐
          ▼          ▼
skill-create      skill-review


distribution
────────────

skill-create/
└── scripts/
    └── _lib/
        └── output.py

skill-review/
└── scripts/
    └── _lib/
        └── output.py
```

So you achieve:

```text
SoT / DRY at authoring time
+
self-contained portability at runtime
```

That is exactly the kind of distinction Skillforge should make.

---

# 6. This resembles compilation

I think this is an important conceptual evolution for Skillforge.

Your repository source doesn't necessarily have to equal the final skill tree byte-for-byte.

You can have:

```text
Canonical Skillforge source
        │
        ├── shared libs
        ├── skill definitions
        ├── shared templates
        └── policy
        │
        ▼
   materialization
        │
        ▼
portable Agent Skill
```

For example:

```text
src/
├── lib/
│   └── python/
│       └── process.py
└── skills/
    └── create/
        ├── SKILL.md
        ├── scripts/
        │   └── inspect.py
        └── skillforge.toml
```

Materialized:

```text
dist/create/
├── SKILL.md
└── scripts/
    ├── inspect.py
    └── _lib/
        └── process.py
```

Then:

```text
dist/create/
```

is a completely ordinary Agent Skill.

No Skillforge dependency.

This is a strong architecture.

---

# 7. Shared functions should be very small

I would resist creating a huge:

```python
skillforge_common
```

library.

That will become a framework inside the framework.

Instead, shared helpers should be narrowly scoped primitives:

```text
python/
├── json_output.py
├── subprocesses.py
├── filesystem.py
├── git.py
└── diagnostics.py
```

And ideally a skill vendors only what it uses:

```text
skill-create
  ↓ needs
json_output.py
filesystem.py
```

rather than copying everything.

Skillforge can determine the transitive dependency graph during materialization.

---

# 8. Shared patterns are different from shared libraries

This distinction matters.

Some reuse should be **code**:

```python
def emit_result(...):
```

Some should merely be an **authoring pattern**.

For example, Skillforge can prescribe:

### Deterministic command contract

Every deterministic helper should:

```text
stdin / argv   → explicit inputs
stdout         → intended machine/result output
stderr         → diagnostics
exit code      → operation status
```

That's a pattern, not necessarily a library.

Likewise:

### Path behavior

Scripts should:

```text
accept target path explicitly
or derive it predictably from cwd

never:
- assume ~/...
- assume Skillforge checkout
- assume user's username
```

Again, that's policy.

Don't solve every convention by introducing runtime code.

---

# 9. Define a script contract

I would make this part of the Skillforge profile.

At minimum:

```text
Scripts MUST:
  - be non-interactive
  - terminate deterministically
  - use explicit arguments
  - return meaningful exit codes
  - send diagnostics to stderr
  - avoid hidden mutable global state
  - avoid hardcoded host paths

Scripts SHOULD:
  - be idempotent when applicable
  - produce machine-readable output when consumed by the agent
  - validate inputs
  - fail fast
  - be safe to rerun
  - minimize runtime dependencies
```

And potentially:

```text
0   success
1   expected negative result / validation failed
2+  execution/config/runtime failure
```

Though I'd think carefully before globally reserving specific codes beyond `0`; many Unix tools already have useful conventions.

---

# 10. JSON shouldn't be mandatory

I would not say:

> Every script must output JSON.

That's unnecessary.

Consider:

```bash
scripts/current_branch.sh
```

Its natural output is:

```text
main
```

Great.

Or:

```bash
scripts/list_files.sh
```

newline-delimited paths are probably better than JSON.

Use structured JSON when the result has structure:

```json
{
  "valid": false,
  "violations": [
    {
      "rule": "missing-description",
      "file": "SKILL.md",
      "line": 3
    }
  ]
}
```

So:

> Prefer the simplest stable output format sufficient for the consumer.

---

# 11. Python shared runtime

For Python specifically I'd establish this progression:

### Simple

```text
scripts/check.py
```

stdlib only.

### Multiple scripts sharing code

```text
scripts/
├── check.py
├── fix.py
└── _lib/
    ├── output.py
    └── model.py
```

### Third-party dependency

Use PEP 723:

```python
# /// script
# requires-python = ">=3.11"
# dependencies = ["tomli-w>=1"]
# ///
```

That standard explicitly exists so standalone scripts can declare runtime requirements without becoming full Python projects. ([Python Packaging][2])

That's almost exactly your use case.

---

# 12. What about a `pyproject.toml`?

I'd avoid one inside most skills.

This:

```text
skill/
├── SKILL.md
├── pyproject.toml
├── uv.lock
├── src/
└── scripts/
```

starts turning a skill into a Python application.

That's too heavy for most deterministic helpers.

PEP 723 is better for isolated scripts. ([Python Packaging][2])

Only move to a proper package if the deterministic component has become large enough that it is legitimately software in its own right.

At that point I'd actually question whether it belongs inside the skill at all.

---

# 13. Shell runtime

For shell, I'd favor:

```sh
#!/bin/sh
set -eu
```

over Bash-specific scripts where practical.

Because:

```text
POSIX sh
    ↓
greater portability
```

But Bash should still be allowed when it materially simplifies the implementation:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

So maybe officially:

```text
Shell:
  preferred: POSIX sh
  allowed: bash when Bash features are justified
```

Rather than saying “Bash is our scripting language.”

That makes the framework more user-agnostic.

---

# 14. Runtime requirements should be discoverable

I think every skill should make its requirements machine-checkable somehow.

The Agent Skills spec already has `compatibility`, but that's human-facing/freeform enough that I'd avoid overloading it into a dependency manager. ([GitHub][4])

Skillforge source could contain additional build metadata:

```toml
[runtime]
commands = ["git", "uv"]

[runtime.python]
requires = ">=3.11"
```

This metadata does **not necessarily land in the final SKILL.md**.

Skillforge could use it for:

```bash
skillforge check
skillforge build
skillforge doctor
```

and produce appropriate `compatibility` prose in the materialized skill.

That preserves the upstream format while allowing stronger authoring validation.

---

# 15. Runtime setup should mostly be verification, not installation

Very important.

I would **not** have a skill silently do:

```bash
apt install ...
pip install ...
curl ... | sh
```

Skill execution should not mutate the user's base system just because a helper needs something.

Better:

```text
skill activates
    ↓
checks prerequisites
    ↓
available?
 ┌──────┴───────┐
yes             no
 │               │
run         agent reports
            missing requirement
```

For Python dependency environments, `uv run` is an elegant exception because it creates an isolated environment rather than installing arbitrary packages into system Python. ([Astral Docs][3])

And the PEP itself explicitly notes the security implications of automatically downloading dependencies, so this should be treated as an explicit trust boundary. ([Python Enhancement Proposals (PEPs)][5])

---

# 16. Locking / reproducibility

There's a tradeoff here.

This:

```python
dependencies = [
    "requests",
]
```

is convenient but not perfectly reproducible.

This:

```python
dependencies = [
    "requests==2.33.0",
]
```

is reproducible-ish but makes maintenance heavier.

I'd define two profiles:

```text
portable
  sensible bounded dependency specs

reproducible
  exact versions / generated lock material where needed
```

But I would **not start by forcing locks onto every tiny skill script**.

Skillforge should be lean first.

---

# 17. Testing

Every non-trivial deterministic helper should be testable independently of the agent.

That is one of the major wins of this architecture.

```text
SKILL.md
     ↓ behavioral/eval testing

scripts/
     ↓ conventional deterministic testing
```

For Python:

```text
pytest
```

or even stdlib `unittest` if dependency minimization matters.

For shell:

* fixture-driven command tests
* ShellCheck for static analysis
* possibly bats if complexity warrants it

And Skillforge could enforce:

```text
skillforge check
    │
    ├── skill structure
    ├── script syntax
    ├── script policy
    ├── dependency declarations
    └── tests
```

This is where the framework itself adds significant value.

---

# 18. Inspirations from the projects we looked at

There are a few ideas I'd explicitly borrow.

Anthropic:

> Put deterministic/repeated logic in scripts; scripts can execute without being loaded into context. ([GitHub][1])

Superpowers:

> Keep the core skill content harness-agnostic and put platform-specific translation into thin edges. ([GitHub][6])

Superpowers also refactored duplicated discovery/parsing into a shared `skills-core.js`, showing the value of a single implementation for genuinely shared infrastructure. ([GitHub][7])

Interestingly, there is even a recent Superpowers issue proposing essentially the exact principle we're discussing:

> deterministic steps → scripts; judgment calls → prose. ([GitHub][8])

So your direction is well aligned with where the ecosystem itself is converging.

---

# My proposed Skillforge model

I'd formalize it approximately like this:

```text
                         SKILLFORGE SOURCE
                               │
           ┌───────────────────┼──────────────────┐
           │                   │                  │
       policies          shared sources       skills
           │                   │                  │
           │          ┌────────┴────────┐         │
           │          │                 │         │
           │      python libs       templates     │
           │                                      │
           └──────────────────┬───────────────────┘
                              │
                           build
                              │
                              ▼
                    SELF-CONTAINED SKILL
                              │
             ┌────────────────┼────────────────┐
             │                │                │
          SKILL.md         scripts/        references/
             │                │
          reasoning       mechanics
                           │
                   ┌───────┴────────┐
                   │                │
               POSIX sh          Python
                                  │
                         stdlib or PEP 723
```

And the governing laws:

> **The skill orchestrates.**

> **The agent handles judgment.**

> **Scripts handle deterministic mechanics.**

> **Scripts belong to the skill, not Skillforge.**

> **Skills are runtime-self-contained.**

> **Shared implementation is DRY in source and vendored at materialization time.**

> **Prefer existing tools over new scripts.**

> **Prefer POSIX shell for glue and Python for logic.**

> **Prefer standard ecosystem runtime mechanisms over Skillforge-specific ones.**

That last one is especially important. If we can use **Agent Skills + POSIX + Python + PEP 723 + uv**, we should. Skillforge then remains an **engineering methodology and build system**, rather than inventing another runtime ecosystem.

[1]: https://github.com/ZachBeta/anthropics-skills/blob/main/skill-creator/SKILL.md?utm_source=chatgpt.com "anthropics-skills/skill-creator/SKILL.md at main · ZachBeta/anthropics-skills · GitHub"
[2]: https://packaging.python.org/en/latest/specifications/inline-script-metadata/?utm_source=chatgpt.com "Inline script metadata - Python Packaging User Guide"
[3]: https://docs.astral.sh/uv/guides/scripts/?utm_source=chatgpt.com "Running scripts | uv"
[4]: https://github.com/davisbuilds/anthropics-skills/blob/main/skills/skill-creator/SKILL.md?utm_source=chatgpt.com "anthropics-skills/skills/skill-creator/SKILL.md at main · davisbuilds/anthropics-skills · GitHub"
[5]: https://peps.python.org/pep-0723/?utm_source=chatgpt.com "PEP 723 – Inline script metadata | peps.python.org"
[6]: https://github.com/obra/superpowers/blob/main/docs/porting-to-a-new-harness.md?utm_source=chatgpt.com "superpowers/docs/porting-to-a-new-harness.md at main · obra/superpowers · GitHub"
[7]: https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md?utm_source=chatgpt.com "superpowers/RELEASE-NOTES.md at main · obra/superpowers · GitHub"
[8]: https://github.com/obra/superpowers/issues/1267?utm_source=chatgpt.com "writing-skills: missing guidance on when to extract deterministic steps to scripts vs prose · Issue #1267 · obra/superpowers · GitHub"


---

However, I wouldn't make that mandatory in v1. It would unnecessarily exclude users who have Python but not uv.

we can setup uv as a requirement dependency from day 1, no problem...

---

PEP 723 is better for isolated scripts. 

Only move to a proper package if the deterministic component has become large enough that it is legitimately software in its own right.

At that point I'd actually question whether it belongs inside the skill at all.

ok... and we can add that progression as a policy... start small and open the possibilty to add pyproject.toml if things get big...

---

13. Shell runtime

no... let's assume bash as our standard from day one... bash is portable enough

---

14. Runtime requirements should be discoverable

we can have our hard fail fast rules from day one... like uv and bash

---

for other per-skill runtime requirements and checks we need to define the best way to do it... some skills would have some pre-flight checks and requirements... those can be in the skills itself... or even better in the scripts itself...

we could have some "skillforge" convention for some pre-defined phases, like: pre-flight, post-flight, and so on....

---

pytest for python... bats for bash... nexttest for rust (and bare cargo test for doctests)
and all the relevant pre-commit hooks for everything... shellcheck, linters, fixture-driven command tests... etc....


---

Yes. With those decisions, I’d make the Skillforge scripting model much more opinionated from day one.

The key is to separate three things:

```text
framework runtime baseline
skill-specific runtime requirements
workflow lifecycle hooks
```

## 1. Hard runtime baseline

Skillforge-generated skills assume these are present:

```text
bash
python
uv
```

And for development/validation of the Skillforge repository itself:

```text
pytest
bats
cargo-nextest
shellcheck
pre-commit
```

For Rust specifically:

```bash
cargo nextest run
cargo test --doc
```

because nextest still does not run doctests, so `cargo test --doc` remains a separate required step. ([Nextest][1])

I’d make missing baseline tooling a **hard fail** rather than supporting degraded execution paths.

That simplifies everything considerably.

---

# 2. Python policy

I like your proposed progression.

### Level 1 — isolated script

Default:

```text
scripts/
└── inspect.py
```

with PEP 723:

```python
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
```

Executed consistently through:

```bash
uv run scripts/inspect.py
```

Even with zero dependencies.

That gives us one standard invocation model.

### Level 2 — several scripts + shared local code

```text
scripts/
├── inspect.py
├── validate.py
└── lib/
    ├── __init__.py
    ├── diagnostics.py
    └── repo.py
```

Still:

```bash
uv run scripts/inspect.py
```

### Level 3 — proper Python project

Once complexity justifies it:

```text
scripts/
├── pyproject.toml
├── uv.lock
├── src/
│   └── my_skill_runtime/
└── tests/
```

Then it becomes a legitimate package/project.

That transition should be explicitly permitted by policy rather than treated as an architectural failure.

Something like:

> Start with standalone PEP 723 scripts. Introduce shared modules when duplication appears. Introduce a `pyproject.toml` and package structure only when the deterministic component has grown enough to benefit from conventional package management, testing, or dependency locking.

That's a good progressive-complexity policy.

---

# 3. Bash policy

Agreed: just standardize on Bash.

No need to optimize around `/bin/sh`.

```bash
#!/usr/bin/env bash
set -euo pipefail
```

should be the canonical starting point.

And probably:

```bash
IFS=$'\n\t'
```

only where actually needed rather than boilerplating it into every script.

Policy:

> Bash is the standard shell runtime for Skillforge-authored skills. Do not restrict scripts to POSIX `sh`.

That gives authors access to arrays, `[[ ]]`, `mapfile`, parameter expansion, `pipefail`, etc., without pretending shell portability is more important than maintainability.

---

# 4. Skill requirements: baseline vs local

This is where I would introduce a clean distinction.

## Framework baseline

Implicit and universal:

```text
bash
python
uv
```

Skillforge validates these globally.

For example:

```bash
skillforge doctor
```

could hard-fail if the environment doesn't satisfy the framework baseline.

## Skill-local requirements

Declared by the skill because of its particular behavior:

```text
git
gh
jq
docker
cargo
rg
kubectl
aws
...
```

Those should **not** become Skillforge core requirements.

And I agree with your idea that the actual checks should usually live with the skill.

---

# 5. Introduce lifecycle phases

This is where I think we can create a very strong Skillforge convention.

I'd define a small set of **semantic phases**, not dozens of hooks.

Something like:

```text
preflight
execute
verify
cleanup
```

Possibly:

```text
preflight
run
verify
postflight
```

I prefer the latter vocabulary for an agent skill.

Conceptually:

```text
              SKILL WORKFLOW

                   │
                   ▼
             ┌───────────┐
             │ preflight │
             └─────┬─────┘
                   │
                   ▼
        ┌─────────────────────┐
        │ main orchestration  │
        │                     │
        │ agent reasoning     │
        │ + deterministic     │
        │   scripts           │
        └─────────┬───────────┘
                  │
                  ▼
              ┌────────┐
              │ verify │
              └────┬───┘
                   │
                   ▼
            ┌────────────┐
            │ postflight │
            └────────────┘
```

But I would be very careful:

**these should be conventions available to a skill, not mandatory executable files.**

A trivial skill may not need any of them.

---

# 6. `preflight`

This should answer:

> Can this deterministic portion of the skill execute correctly in the current environment?

For example:

```text
scripts/
└── preflight
```

or:

```text
scripts/
└── preflight.py
```

It checks things such as:

```text
required commands
required environment variables
repository state
expected files
authentication state
minimum tool versions
platform assumptions
configuration
permissions
```

Example:

```bash
#!/usr/bin/env bash
set -euo pipefail

command -v git >/dev/null ||
    { echo "git is required" >&2; exit 1; }

command -v gh >/dev/null ||
    { echo "gh is required" >&2; exit 1; }

gh auth status >/dev/null 2>&1 ||
    { echo "GitHub authentication is required" >&2; exit 1; }
```

But we'd want better conventions around diagnostics than ad hoc strings.

---

# 7. Preflight should be deterministic and authoritative

This is important.

Don't write in `SKILL.md`:

```markdown
Check whether GitHub CLI seems to be installed and authenticated.
```

Instead:

```markdown
Run the skill preflight:

    uv run scripts/preflight.py

Do not proceed if preflight fails.
```

Then the agent doesn't need to reason about whether the environment is acceptable.

The script tells it.

That fits our earlier rule perfectly:

```text
environment suitability
        ↓
deterministic?
        ↓
yes
        ↓
script
```

---

# 8. A standard result contract

I'd define a Skillforge convention for lifecycle scripts.

Not necessarily JSON for every helper, but **preflight/verify/postflight specifically should use structured output** because Skillforge can standardize their semantics.

For example:

```json
{
  "status": "fail",
  "checks": [
    {
      "id": "gh-installed",
      "status": "pass"
    },
    {
      "id": "gh-authenticated",
      "status": "fail",
      "message": "GitHub CLI is not authenticated.",
      "remediation": "Run gh auth login."
    }
  ]
}
```

Then exit code:

```text
0  phase succeeded
1  phase completed and requirements were not satisfied
2  phase could not execute correctly
```

This is one place where defining exit-code semantics globally **does** make sense because Skillforge owns the lifecycle convention.

Individual utility scripts need not follow those exact semantics.

---

# 9. `verify`

This is equally important.

Preflight answers:

```text
Can I run?
```

Verify answers:

```text
Did the deterministic outcome satisfy the expected invariants?
```

Examples:

```text
files were generated
repository is clean
tests pass
output conforms to schema
required metadata now exists
expected branch exists
artifact checksum matches
```

Again:

```markdown
After applying the changes:

    uv run scripts/verify.py

Do not report success unless verification passes.
```

This reduces one of the classic coding-agent problems:

> “I changed it, therefore it's done.”

No.

```text
change
 ↓
verify
 ↓
success
```

---

# 10. `postflight`

I would define postflight differently from verify.

It should handle deterministic **finalization**, not determine correctness.

Examples:

```text
generate summary data
remove temporary files
restore temporary state
write output manifest
collect metrics
emit changed-file list
```

So:

```text
preflight
   ↓
main workflow
   ↓
verify
   ↓
postflight
```

And I'd strongly recommend:

> Verification must happen before success-producing postflight behavior.

Though cleanup that must always happen complicates this.

Which suggests another lifecycle concept.

---

# 11. We may actually want `cleanup`, not just `postflight`

There's an important distinction:

```text
postflight
    runs after successful workflow

cleanup
    runs regardless of success/failure where necessary
```

Example:

```text
create temporary worktree
      ↓
do operation
      ↓
operation fails
      ↓
temporary worktree still needs removing
```

That is not postflight.

So the lifecycle could be:

```text
preflight
     │
     ▼
   workflow
     │
     ▼
   verify
     │
     ▼
 postflight


cleanup
   ↑
runs on termination when required
```

However, I would avoid exposing too many lifecycle constructs initially.

My v1 would define:

```text
preflight
verify
cleanup
```

and leave “postflight” as ordinary workflow logic unless we discover a compelling universal semantic.

Why?

Because these three have clear meanings:

```text
preflight = establish prerequisites
verify    = establish correctness
cleanup   = restore transient state
```

`postflight` is much vaguer.

---

# 12. More importantly: lifecycle phases belong to the skill

Not Skillforge runtime.

This distinction remains crucial.

Skillforge defines:

```text
"What does preflight mean?"
"What contract should a preflight script follow?"
"How should skills instruct agents to use it?"
```

But the deployed skill contains:

```text
my-skill/
├── SKILL.md
└── scripts/
    ├── preflight.py
    ├── execute.py
    ├── verify.py
    └── cleanup.py
```

An arbitrary agent can execute that skill without:

```text
skillforge preflight
```

being available.

That preserves decoupling.

---

# 13. The skill does not need every phase as a script

This is another important policy.

Suppose a skill uses:

```text
preflight → deterministic
workflow  → mostly agent reasoning
verify    → deterministic
```

Then:

```text
SKILL.md
scripts/
├── preflight.py
└── verify.py
```

Perfect.

Another skill may have:

```text
SKILL.md
scripts/
└── analyze.py
```

No preflight needed.

Don't generate empty framework ceremony such as:

```text
preflight.py
postflight.py
verify.py
cleanup.py
```

just because a convention exists.

That would be bloat.

---

# 14. Runtime dependencies can be checked by preflight

Now we get a very elegant model.

Suppose skill `github-release` requires:

```text
gh >= 2.80
git
jq
```

Instead of Skillforge inventing its own dependency resolver:

```text
SKILL.md
scripts/
├── preflight.py
└── ...
```

The preflight owns those checks.

But we don't want every skill reimplementing:

```python
shutil.which()
subprocess.run(["gh", "--version"])
semver parsing
diagnostics
JSON result formatting
```

This is where your shared libraries become very valuable.

---

# 15. A shared `preflight` library

At source level:

```text
lib/
└── python/
    └── skillforge_runtime/
        ├── checks.py
        ├── command.py
        ├── result.py
        └── version.py
```

Then skill source:

```python
from skillforge_runtime.checks import (
    require_command,
    require_env,
)

def main():
    require_command("git")
    require_command("gh", min_version="2.80")
    require_env("FOO_TOKEN")
```

During materialization, only required modules are vendored:

```text
scripts/
├── preflight.py
└── _lib/
    ├── checks.py
    ├── command.py
    └── result.py
```

So again:

```text
DRY source
+
portable artifact
```

This is probably one of the strongest areas for Skillforge to provide value.

---

# 16. But shared libraries should be split by language

I would structure something like:

```text
lib/
├── python/
│   └── skillforge/
│       ├── checks.py
│       ├── diagnostics.py
│       ├── process.py
│       ├── paths.py
│       └── results.py
│
└── bash/
    ├── checks.bash
    ├── diagnostics.bash
    └── process.bash
```

Then:

```bash
source "${SCRIPT_DIR}/_lib/checks.bash"
```

and:

```python
from _lib.checks import require_command
```

Keep both language ecosystems idiomatic.

Don't try to create some cross-language abstraction.

---

# 17. We should define what belongs in those libraries

Very narrowly.

Good shared primitives:

```text
require_command()
require_env()
require_file()
require_directory()
require_git_repo()

command_version()

emit_error()
emit_warning()
emit_result()

run_command()

resolve_project_root()
resolve_skill_root()
```

Potentially:

```text
temporary_directory()
atomic_write()
```

Bad candidates:

```text
create_release()
analyze_skill_quality()
fix_python_package()
generate_github_issue()
```

Those are domain behavior.

They belong to individual skills.

Same core rule again:

> Shared runtime libraries provide execution primitives, not skill semantics.

---

# 18. Testing policy

With your chosen stack, I'd make this first-class.

## Python

```text
pytest
ruff
```

Potentially:

```text
mypy/pyright
```

depending on how strict we want to be.

I'd lean toward **ruff + pytest** initially.

PEP 723 standalone scripts can still have unit tests without necessarily requiring a full package.

---

## Bash

```text
bats
shellcheck
```

And fixture-driven tests.

Example:

```text
tests/
├── fixtures/
│   ├── valid-repo/
│   └── missing-config/
└── preflight.bats
```

Tests become:

```bash
@test "fails when config is missing" {
    run "$SCRIPT" "$FIXTURES/missing-config"

    [ "$status" -eq 1 ]
}
```

That's exactly how I'd want deterministic scripts tested.

---

## Rust / Skillforge itself

```bash
cargo nextest run
cargo test --doc
cargo clippy --all-targets --all-features -- -D warnings
cargo fmt --check
```

And nextest provides useful CI-oriented execution features including retries, profiles and machine-readable test listings. ([Nextest][1])

---

# 19. Pre-commit

Yes, and I would make it comprehensive.

Conceptually:

```text
generic
├── trailing whitespace
├── EOF
├── YAML/TOML validation
└── large-file checks

Python
├── ruff check
├── ruff format --check
└── pytest targeted/fast suite

Bash
├── shellcheck
└── bats targeted suite

Rust
├── cargo fmt
├── cargo clippy
└── perhaps targeted nextest
```

But I would **not run the complete expensive test suite on every pre-commit**.

Better separation:

```text
pre-commit
    fast static checks

pre-push
    relevant tests

CI
    complete suite
```

That preserves developer UX.

---

# 20. A conventional skill layout starts emerging

For a small skill:

```text
foo/
├── SKILL.md
└── scripts/
    └── inspect.py
```

Medium:

```text
foo/
├── SKILL.md
├── scripts/
│   ├── preflight.py
│   ├── inspect.py
│   ├── verify.py
│   └── _lib/
│       └── ...
└── tests/
    ├── test_inspect.py
    └── fixtures/
```

Complex deterministic component:

```text
foo/
├── SKILL.md
├── scripts/
│   ├── pyproject.toml
│   ├── uv.lock
│   ├── src/
│   │   └── foo_runtime/
│   └── tests/
└── references/
```

The framework encourages progression rather than starting at maximum complexity.

---

# 21. I would introduce one particularly important concept

Call it the **deterministic surface**.

Every skill has:

```text
agent surface
+
deterministic surface
```

For example:

```text
foo/
│
├── SKILL.md             ← agent surface
│
└── scripts/             ← deterministic surface
```

Skillforge can analyze both independently.

```text
skillforge check foo
```

could eventually report:

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
```

That's a very coherent framework concept.

---

# 22. One change I would make from your wording

You mentioned:

> pre-flight, post-flight, and so on

I would establish **only three canonical lifecycle semantics initially**:

```text
preflight
verify
cleanup
```

Not generic `before`, `after`, `setup`, `teardown`, `postflight`, etc.

Because each has a crisp contract:

| Phase       | Question                                   |
| ----------- | ------------------------------------------ |
| `preflight` | **Can this workflow safely run?**          |
| `verify`    | **Did it produce a valid result?**         |
| `cleanup`   | **What transient state must be restored?** |

The actual work remains explicitly orchestrated by `SKILL.md`.

That keeps the skill readable:

```text
PRE-FLIGHT
    deterministic

        ↓

REASON / ACT / SCRIPT / REASON / ACT
    skill-specific orchestration

        ↓

VERIFY
    deterministic

        ↓

CLEANUP
    where applicable
```

And importantly, it does **not** turn skills into a generic CI pipeline DSL.

---

## So I think our current policy is getting very strong

We can now state it approximately as:

> **Skillforge-authored skills use Bash and Python as their standard deterministic runtimes. Python scripts execute through `uv`, use PEP 723 by default, and may graduate to a `pyproject.toml` when complexity warrants it. Bash scripts assume Bash and follow strict shell practices.**
>
> **Skill-specific prerequisites are owned by the skill and should be checked deterministically through a standardized `preflight` capability. Outcome correctness should be established through deterministic `verify` capabilities where possible. Temporary state should be handled through explicit cleanup.**
>
> **Skillforge provides reusable source-level primitives and patterns for these concerns, but materialized skills remain self-contained and have no runtime dependency on Skillforge itself.**
>
> **Python is tested with pytest, Bash with Bats, and Rust with nextest plus `cargo test --doc`; static analysis and formatting are enforced through the appropriate pre-commit/CI tooling.**

I think this is now sufficiently concrete that the next useful step is to turn everything we've established so far into an actual **Skillforge architecture and policy specification**—the kind of document that can become the first SoT inside the repository.

[1]: https://www.nexte.st/?utm_source=chatgpt.com "Home - cargo-nextest"


