[中文](README.md) | English

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/envestcc/autodev)](https://github.com/envestcc/autodev/stargazers)
[![GitHub last commit](https://img.shields.io/github/last-commit/envestcc/autodev)](https://github.com/envestcc/autodev/commits/main)

# autodev

> 💡 **Let AI iterate your product** — you sleep, it ships code.

Driven by [Copilot CLI](https://github.com/github/copilot-cli) / Claude Code, autodev automates the cycle of "Simulate User Testing → Design Improvement Plan → Implement Code Improvements" for hands-free product iteration.

- 🤖 **Fully Automated** — One command to start, AI reads code, finds issues, writes fixes, commits
- 🎭 **Multi-Persona** — Configure different user personas, each round discovers issues from a different perspective
- 🔄 **Continuous Iteration** — Supports 1~N rounds, each building on the previous round's feedback

## 30-Second Quick Start

```bash
# 1. One-line install (Copilot CLI users)
mkdir -p ~/.copilot/skills/autodev && curl -fsSL https://raw.githubusercontent.com/envestcc/autodev/main/skill/SKILL.md -o ~/.copilot/skills/autodev/SKILL.md

# 2. Launch Copilot CLI in any project and say:
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
# Copilot CLI users
mkdir -p ~/.copilot/skills/autodev && curl -fsSL https://raw.githubusercontent.com/envestcc/autodev/main/skill/SKILL.md -o ~/.copilot/skills/autodev/SKILL.md

# Claude Code users
mkdir -p ~/.claude/skills/autodev && curl -fsSL https://raw.githubusercontent.com/envestcc/autodev/main/skill/SKILL.md -o ~/.claude/skills/autodev/SKILL.md
```

**Or install from source:**

```bash
git clone https://github.com/envestcc/autodev.git
cp autodev/skill/SKILL.md ~/.copilot/skills/autodev/SKILL.md
```

Verify: `cat ~/.copilot/skills/autodev/SKILL.md | head -3` should output `---`.

### Prerequisites

- [Copilot CLI](https://github.com/github/copilot-cli) or Claude Code installed
- Target project is a git repository

### Usage

Launch Copilot CLI in any project and say:

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

## Mid-Iteration Controls

During iteration, you can say at any time:
- **"pause"** → Pause after current step
- **"shift focus to XXX"** → Dynamically change focus
- **"add persona: XXX"** → Add a new persona to rotation
- **"show status"** → Output progress stats

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Demo Output

```
$ copilot-cli
> auto iterate this project for 3 rounds

🔄 Round 1 | Persona: New Graduate
   📋 Step 1: Simulating user experience... found 5 issues
   📐 Step 2: Designing improvement plan... 4 P1 + 1 P2
   🔧 Step 3: Implementing changes... modified 3 files
✅ Round 1 complete | Commit: a1b2c3d

🔄 Round 2 | Persona: New Graduate
   📋 Step 1: Verifying Round 1 fixes + deep testing... found 3 new issues
   📐 Step 2: Designing improvement plan... 3 items
   🔧 Step 3: Implementing changes... modified 2 files
✅ Round 2 complete | Commit: d4e5f6g

🔄 Round 3 | Persona: New Graduate
   ...
✅ All 3 rounds complete! 11 improvements implemented.
```

## License

MIT
