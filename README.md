# autodev

AI 驱动的产品自动迭代改进引擎。

通过 [Copilot CLI](https://github.com/github/copilot-cli) 驱动「模拟用户试用 → 设计改进计划 → 实施代码改进」的循环，实现产品无人值守的自动迭代升级。

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

## 快速开始（Copilot Skill 方式，推荐）

Skill 方式无需脚本、无需配置文件模板，直接在 Copilot 会话中交互式使用。

### 安装

```bash
# 复制 skill 到用户级目录（所有项目可用）
mkdir -p ~/.copilot/skills/autodev
cp skill/SKILL.md ~/.copilot/skills/autodev/SKILL.md
```

> **Claude Code 用户**：也可复制到 `~/.claude/skills/autodev/SKILL.md`，格式通用。

### 前置条件

- [Copilot CLI](https://github.com/github/copilot-cli) 或 Claude Code 已安装
- 目标项目是一个 git 仓库

### 使用

在任何项目中启动 Copilot CLI，直接说：

```
帮我自动迭代这个项目 5 轮
```

首次使用会交互式询问产品信息（约 5 个问题），自动生成 `.autodev/config.yaml`，然后开始循环迭代。

### Skill 方式配置（config.yaml）

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

### Skill 方式输出结构

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

### Skill vs Shell 脚本

| 特性 | Copilot Skill（推荐） | Shell 脚本 |
|------|----------------------|-----------|
| 上下文 | 单一会话，持续记忆 | 每步冷启动 |
| Prompt | 动态推理，逐轮调整 | 静态模板 |
| 多角色 | 可中途添加角色 | 需预定义 |
| 错误修复 | 当场验证并修复 | 下一轮才发现 |
| 交互控制 | 可随时暂停、调整方向 | 无（全自动） |
| 安装 | 复制一个 .md 文件 | 复制脚本 + init |
| 兼容性 | Copilot CLI / Claude Code | 仅 Copilot CLI |

## 方式二：Shell 脚本（高级用法）

Shell 脚本方式适合需要 CI 集成或完全无人值守的场景。

### 安装

```bash
git clone https://github.com/<your-user>/autodev.git
cd autodev
ln -s "$(pwd)/autodev.sh" /usr/local/bin/autodev
```

### 使用

```bash
# 1. 初始化配置
autodev init ~/dev/my-app

# 2. 编辑配置文件
vim ~/dev/my-app/.autodev/config.sh

# 3. 运行自动迭代
autodev run ~/dev/my-app -n 5
```

### 命令参考

| 命令 | 说明 |
|------|------|
| `autodev init <路径>` | 初始化配置目录 |
| `autodev run <路径> [-n N] [-m model] [-s N] [--dry-run]` | 运行迭代 |
| `autodev status <路径>` | 查看迭代状态 |

### Shell 方式配置（config.sh）

```bash
PRODUCT_NAME="数学错题本"                    # 产品名
PRODUCT_DESC="帮助高中生整理和复习数学错题"     # 产品简介
USER_PERSONA="高三理科生，数学约110分"         # 用户画像
SOURCE_DIRS="miniprogram"                   # 源码目录
DOCS_DIR_REL="docs"                        # 文档目录
CODE_CONVENTIONS="微信小程序 WXML/WXSS/JS"   # 代码规范
MAX_ITEMS_PER_ROUND=6                      # 每轮改进项上限
COMMIT_PREFIX="feat: 迭代改进"               # commit 前缀
FOCUS_AREAS="用户体验、复习功能"               # 关注领域
FEEDBACK_FORMAT="总体印象、功能点评、Bug、建议" # 报告格式
```

### 自定义 Prompt 模板

编辑 `.autodev/prompts/` 下的模板文件，支持 `{{PRODUCT_NAME}}`、`{{ROUND}}` 等占位符。

### Shell 方式输出结构

```
your-project/
├── .autodev/
│   ├── config.sh
│   ├── prompts/
│   │   ├── feedback.md
│   │   ├── plan.md
│   │   └── implement.md
│   └── logs/
├── docs/
│   ├── feedback_round_1.md
│   ├── improvement_plan_round_1.md
│   └── ...
└── src/
```

## License

MIT
