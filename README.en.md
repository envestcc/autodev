[中文](README.md) | English

<div align="center">

<h1>🤖 autodev</h1>

<p><strong>Let AI iterate your product — you sleep, it ships code.</strong></p>

<p>
  <a href="https://github.com/envestcc/autodev/stargazers"><img src="https://img.shields.io/github/stars/envestcc/autodev?style=social" alt="GitHub stars"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
  <a href="https://github.com/envestcc/autodev/commits/main"><img src="https://img.shields.io/github/last-commit/envestcc/autodev" alt="Last commit"></a>
  <a href="https://github.com/envestcc/autodev/issues"><img src="https://img.shields.io/github/issues/envestcc/autodev" alt="Issues"></a>
  <a href="https://github.com/envestcc/autodev/network/members"><img src="https://img.shields.io/github/forks/envestcc/autodev?style=social" alt="Forks"></a>
</p>

<p>
  AI role-plays your users, discovers issues → designs fixes → writes code → commits<br/>
  One-line install · Zero dependency · Pure Markdown · Works with <a href="https://docs.anthropic.com/en/docs/claude-code">Claude Code</a> & Copilot CLI
</p>

<br/>

```
"auto iterate this project for 5 rounds"
```

```
🔄 Round 1 | Persona: New Graduate
   📋 Simulating usage... found 5 issues
   📐 Designing fixes... 4×P1 + 1×P2
   🔧 Implementing... modified 3 files
✅ Commit: a1b2c3d

🔄 Round 2 | Persona: New Graduate
   📋 Verifying + deeper testing... 3 new issues
   📐 Designing fixes... 3 items
   🔧 Implementing... modified 2 files
✅ Commit: d4e5f6g

✅ Done! 11 improvements shipped.
```

</div>

---

## ✨ Features

<table>
<tr>
<td>🤖 <b>Fully Automated</b><br/>One command: AI reads code → finds issues → writes fixes → commits</td>
<td>🎭 <b>Multi-Persona</b><br/>Rotate user personas each round for diverse perspectives (<a href="personas/">templates included</a>)</td>
</tr>
<tr>
<td>🔄 <b>N-Round Progressive</b><br/>Each round builds on the last, spiral improvement</td>
<td>🪶 <b>Zero Dependency</b><br/>One Markdown file, one curl to install</td>
</tr>
<tr>
<td>🔍 <b>Dry-run</b><br/>Analyze without changing code, review first</td>
<td>🎯 <b>Focus Mode</b><br/><code>focus_paths</code> to scope analysis precisely</td>
</tr>
</table>

## 💡 Why autodev

> **Other AI tools:** You tell it what to change, it changes it.<br/>
> **autodev:** AI discovers problems itself and decides what to fix.

The **only** AI coding tool that works from the user's perspective — AI plays your users, not your obedient coder.

| | autodev | aider | OpenHands | Devin |
|---|---------|-------|-----------|-------|
| **Approach** | 🎭 Simulate users to find issues | 💬 Chat to edit code | 🎫 Solve Issues | 🤖 Autonomous engineer |
| **User persona simulation** | ✅ Multi-role rotation | ❌ | ❌ | ❌ |
| **Auto multi-round** | ✅ N rounds progressive | ❌ Single conversation | ❌ Single Issue | ❌ Single task |
| **Install** | One-line `curl` | pip install | Docker deploy | SaaS $500/mo |
| **Dependency** | Zero (pure Markdown) | Python | Docker + server | Closed-source cloud |

## Two Versions

| | v1 (`SKILL.md`) | v2 (`SKILL-multi-agent.md`) |
|---|---|---|
| Architecture | Single context, inline execution | Multi-agent, isolated context per Step |
| Models | Single model | Different model per role |
| Context isolation | ❌ All steps share context | ✅ Clean isolation per step |
| Long-run stability | ⚠️ Context may overflow after 3+ rounds | ✅ Fresh context every step |
| Compatibility | Any tool supporting Skills | Requires sub-agent support (task tool) |
| Complexity | Simple, ~220 lines | Richer, ~300 lines |

**Recommended**: Use v2 if your tool supports sub-agents (Copilot CLI, Claude Code). Otherwise use v1.

## 30-Second Quick Start

```bash
# 1. One-line install (Claude Code users)
mkdir -p ~/.claude/skills/autodev && curl -fsSL https://raw.githubusercontent.com/envestcc/autodev/main/skill/SKILL-multi-agent.md -o ~/.claude/skills/autodev/SKILL.md

# 2. Launch Claude Code in any project and say:
#    "auto iterate this project for 3 rounds"

# 3. Watch AI work ☕
```

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│                  autodev Iteration Loop                 │
│                                                         │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐         │
│   │ Step 1   │    │ Step 2   │    │ Step 3   │         │
│   │ Simulate │───▶│ Design   │───▶│ Implement│──┐      │
│   │ User Test│    │ Plan     │    │ Changes  │  │      │
│   └──────────┘    └──────────┘    └──────────┘  │      │
│        ▲                                        │      │
│        └────────────────────────────────────────┘      │
│                     Repeat N rounds                     │
└─────────────────────────────────────────────────────────┘
```

In each round, the AI will:
1. **Read source code + historical feedback**, simulate the product experience as the configured user persona, and output an experience report
2. **Read the feedback report**, design an actionable improvement plan sorted by priority
3. **Implement code changes** per the plan, auto git commit

## Quick Start

### Installation

**One-line install (recommended):**

```bash
# v2 Multi-Agent (recommended, Claude Code users)
mkdir -p ~/.claude/skills/autodev && curl -fsSL https://raw.githubusercontent.com/envestcc/autodev/main/skill/SKILL-multi-agent.md -o ~/.claude/skills/autodev/SKILL.md

# v2 Multi-Agent (Copilot CLI users)
mkdir -p ~/.copilot/skills/autodev && curl -fsSL https://raw.githubusercontent.com/envestcc/autodev/main/skill/SKILL-multi-agent.md -o ~/.copilot/skills/autodev/SKILL.md

# v1 Classic (if your tool doesn't support sub-agents)
# Replace SKILL-multi-agent.md with SKILL.md in the URL above
```

**Or install from source:**

```bash
git clone https://github.com/envestcc/autodev.git
# Recommended: v2 (multi-agent)
cp autodev/skill/SKILL-multi-agent.md ~/.claude/skills/autodev/SKILL.md
# For v1 (classic): cp autodev/skill/SKILL.md ~/.claude/skills/autodev/SKILL.md
```

Verify: `cat ~/.claude/skills/autodev/SKILL.md | head -3` should output `---`.

### Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) or Copilot CLI installed
- Target project is a git repository

### Usage

Launch Claude Code in any project and say:

```
auto iterate this project for 5 rounds
```

On first use, it will interactively ask about your product (5 questions), auto-generate `.autodev/config.yaml`, then start the iteration loop.

### Configuration (config.yaml)

Auto-generated on first run, or manually create `.autodev/config.yaml`:

```yaml
product:
  name: "Personal Budget Tracker"
  description: "Helps young professionals track daily expenses and analyze spending habits"

personas:
  - name: "New Graduate"
    description: "Earning entry-level salary, wants to build a budgeting habit"
    focus: ["expense logging speed", "spending analysis UX"]

source_dirs: ["miniprogram"]
docs_dir: "docs/autodev"
code_conventions: "WeChat Mini Program WXML/WXSS/JS"

iteration:
  max_rounds: 5
  max_items_per_round: 6
  commit_prefix: "feat(autodev):"
```

> See more examples in the [examples/](examples/) directory.

### Output Structure

```
your-project/
├── .autodev/
│   └── config.yaml                     ← Product config (auto-generated)
├── docs/autodev/
│   ├── feedback_round_1.md             ← AI-generated user experience feedback
│   ├── improvement_plan_round_1.md     ← AI-generated improvement plan
│   ├── feedback_round_2.md
│   └── ...
└── src/                                ← Code modified by AI
```

## Multi-Persona Support

Define multiple personas in config.yaml for automatic role rotation across rounds:

```yaml
personas:
  - name: "Beginner"
    description: "First time user, unfamiliar with jargon"
    focus: ["onboarding", "UI intuitiveness"]
  
  - name: "Power User"
    description: "Efficiency-focused, wants advanced features"
    focus: ["shortcuts", "customization"]
```

> 💡 Pre-built persona templates available in [personas/](personas/) — covering e-commerce, SaaS, mobile apps, and developer tools.

## Advanced Features

### Dry-run Mode

Analyze without modifying code — review feedback and plans before committing to changes:

```
dry run, iterate 3 rounds
```

Or set `iteration.dry_run: true` in config.yaml.

### Focus Mode

Limit AI analysis to specific modules in large projects:

```yaml
focus_paths: ["src/auth/", "src/api/"]
exclude_paths: ["src/vendor/", "dist/"]
```

### Lifecycle Hooks

Run custom commands at specific points:

```yaml
hooks:
  before_step3: "npm run lint"
  after_each_item: "npm test"
  after_step3: "npm run build"
  after_round: "npm run e2e"
```

### Verification Agent (v2)

Enable an independent verification step after code implementation:

```yaml
iteration:
  enable_verification: true
```

## Mid-Iteration Controls

During iteration, you can say at any time:
- **"pause"** → Pause after current step
- **"shift focus to XXX"** → Dynamically change focus
- **"add persona: XXX"** → Add a new persona to rotation
- **"show status"** → Output progress stats

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Star History

<a href="https://star-history.com/#envestcc/autodev&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=envestcc/autodev&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=envestcc/autodev&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=envestcc/autodev&type=Date" />
 </picture>
</a>

## 💪 Show Your Support

If you find this useful, please give it a ⭐ Star! It means a lot.

[![Star this repo](https://img.shields.io/github/stars/envestcc/autodev?style=social)](https://github.com/envestcc/autodev)

**Share with friends:**

[![Share on Twitter](https://img.shields.io/badge/Share-Twitter-1DA1F2?logo=twitter&logoColor=white)](https://twitter.com/intent/tweet?text=🤖%20autodev%20—%20AI%20simulates%20your%20users,%20finds%20issues,%20and%20ships%20fixes%20automatically.%20Zero%20dependency,%20one-line%20install!&url=https://github.com/envestcc/autodev)
[![Share on Reddit](https://img.shields.io/badge/Share-Reddit-FF4500?logo=reddit&logoColor=white)](https://www.reddit.com/submit?url=https://github.com/envestcc/autodev&title=autodev%20-%20AI-driven%20product%20auto-iteration%20engine)

## License

MIT
