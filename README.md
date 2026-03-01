[English](README.en.md) | 中文

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/envestcc/autodev)](https://github.com/envestcc/autodev/stargazers)
[![GitHub last commit](https://img.shields.io/github/last-commit/envestcc/autodev)](https://github.com/envestcc/autodev/commits/main)

# autodev

AI 驱动的产品自动迭代改进引擎。

通过 [Copilot CLI](https://github.com/github/copilot-cli) / Claude Code 驱动「模拟用户试用 → 设计改进计划 → 实施代码改进」的循环，实现产品无人值守的自动迭代升级。

## 工作原理

```
┌─────────────────────────────────────────────────────────┐
│                    autodev 迭代循环                       │
│                                                         │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐         │
│   │ Step 1   │    │ Step 2   │    │ Step 3   │         │
│   │ 模拟用户  │───▶│ 改进计划  │───▶│ 实施改进  │──┐      │
│   │ 试用反馈  │    │ 设计     │    │ 写代码   │  │      │
│   └──────────┘    └──────────┘    └──────────┘  │      │
│        ▲                                        │      │
│        └────────────────────────────────────────┘      │
│                     重复 N 轮                           │
└─────────────────────────────────────────────────────────┘
```

每一轮迭代中，AI 会：
1. **阅读源代码 + 历史反馈**，以配置的用户画像身份试用产品，输出体验报告
2. **阅读反馈报告**，按优先级设计可执行的改进计划
3. **按计划实施代码修改**，自动 git commit

## 快速开始

### 安装

```bash
# Copilot CLI 用户：复制 skill 到用户级目录
mkdir -p ~/.copilot/skills/autodev
cp skill/SKILL.md ~/.copilot/skills/autodev/SKILL.md

# Claude Code 用户：复制到 Claude 目录
mkdir -p ~/.claude/skills/autodev
cp skill/SKILL.md ~/.claude/skills/autodev/SKILL.md
```

### 前置条件

- [Copilot CLI](https://github.com/github/copilot-cli) 或 Claude Code 已安装
- 目标项目是一个 git 仓库

### 使用

在任何项目中启动 Copilot CLI，直接说：

```
帮我自动迭代这个项目 5 轮
```

首次使用会交互式询问产品信息（约 5 个问题），自动生成 `.autodev/config.yaml`，然后开始循环迭代。

### 配置（config.yaml）

首次运行时自动生成，也可手动编辑 `.autodev/config.yaml`：

```yaml
product:
  name: "数学错题本"
  description: "帮助高中生整理和复习数学错题"

personas:
  - name: "高三理科生"
    description: "数学约110分，弱项为解析几何"
    focus: ["错题录入效率", "复习体验"]

source_dirs: ["miniprogram"]
docs_dir: "docs/autodev"
code_conventions: "微信小程序 WXML/WXSS/JS"

iteration:
  max_rounds: 5
  max_items_per_round: 6
  commit_prefix: "feat(autodev):"
```

> 更多示例见 [examples/](examples/) 目录。

### 输出结构

```
your-project/
├── .autodev/
│   └── config.yaml                     ← 产品配置（自动生成）
├── docs/autodev/
│   ├── feedback_round_1.md             ← AI 生成的用户体验反馈
│   ├── improvement_plan_round_1.md     ← AI 生成的改进计划
│   ├── feedback_round_2.md
│   └── ...
└── src/                                ← AI 直接修改的代码
```

## 多 Persona 支持

在 config.yaml 中定义多个 persona，AI 会按轮次自动轮换角色视角：

```yaml
personas:
  - name: "新手用户"
    description: "第一次使用，不熟悉术语"
    focus: ["上手引导", "界面直觉性"]
  
  - name: "高级用户"
    description: "追求效率和高级功能"
    focus: ["快捷操作", "自定义配置"]
```

## 中途控制

迭代过程中可以随时说：
- **"暂停"** → 完成当前 step 后暂停
- **"调整方向：更关注 XXX"** → 动态修改关注重点
- **"加一个角色：XXX"** → 添加新 persona
- **"看看目前的状态"** → 输出进度统计

## 贡献

请参阅 [CONTRIBUTING.md](CONTRIBUTING.md)。

## License

MIT
