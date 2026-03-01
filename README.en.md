[中文](README.md) | English

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/envestcc/autodev)](https://github.com/envestcc/autodev/stargazers)
[![GitHub last commit](https://img.shields.io/github/last-commit/envestcc/autodev)](https://github.com/envestcc/autodev/commits/main)

# autodev

AI-powered product auto-iteration engine.

Driven by [Copilot CLI](https://github.com/github/copilot-cli) / Claude Code, it automates the cycle of "Simulate User Testing → Design Improvement Plan → Implement Code Improvements" for hands-free product iteration.

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

```bash
# Copilot CLI users: copy skill to user-level directory
mkdir -p ~/.copilot/skills/autodev
cp skill/SKILL.md ~/.copilot/skills/autodev/SKILL.md

# Claude Code users: copy to Claude directory
mkdir -p ~/.claude/skills/autodev
cp skill/SKILL.md ~/.claude/skills/autodev/SKILL.md
```

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
  name: "Math Mistake Book"
  description: "Helps high school students organize and review math mistakes"

personas:
  - name: "Senior Student"
    description: "Preparing for exams, math ~110/150, weak in analytic geometry"
    focus: ["mistake entry efficiency", "review experience"]

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

## License

MIT
