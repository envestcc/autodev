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

## 快速开始

### 安装

```bash
# 克隆仓库
git clone https://github.com/<your-user>/autodev.git
cd autodev

# 添加到 PATH（可选）
ln -s "$(pwd)/autodev.sh" /usr/local/bin/autodev
```

### 前置条件

- [Copilot CLI](https://github.com/github/copilot-cli) 已安装并登录
- 目标项目是一个 git 仓库

### 使用

```bash
# 1. 在你的项目中初始化配置
autodev init ~/dev/my-app

# 2. 编辑配置文件，填入产品信息和用户画像
vim ~/dev/my-app/.autodev/config.sh

# 3. 运行自动迭代
autodev run ~/dev/my-app -n 5
```

## 命令参考

### `autodev init <项目路径>`

在目标项目中创建 `.autodev/` 配置目录，包含：

| 文件 | 用途 |
|------|------|
| `config.sh` | 产品名称、用户画像、代码规范等核心配置 |
| `prompts/feedback.md` | 试用反馈的 prompt 模板 |
| `prompts/plan.md` | 改进计划的 prompt 模板 |
| `prompts/implement.md` | 代码实施的 prompt 模板 |

### `autodev run <项目路径> [选项]`

运行迭代循环。

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `-n, --rounds <N>` | 迭代轮数 | 5 |
| `-m, --model <model>` | AI 模型 | claude-sonnet-4 |
| `-s, --start <N>` | 从第 N 轮开始 | 1 |
| `--dry-run` | 只打印 prompt，不执行 | — |

### `autodev status <项目路径>`

查看项目的迭代历史和状态。

## 配置说明

### config.sh

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

### 自定义 Prompt

编辑 `.autodev/prompts/` 下的模板文件。支持以下占位符：

| 占位符 | 来源 |
|--------|------|
| `{{PRODUCT_NAME}}` | config.sh |
| `{{PRODUCT_DESC}}` | config.sh |
| `{{USER_PERSONA}}` | config.sh |
| `{{SOURCE_DIRS}}` | config.sh |
| `{{DOCS_DIR}}` | config.sh |
| `{{CODE_CONVENTIONS}}` | config.sh |
| `{{MAX_ITEMS}}` | config.sh |
| `{{FOCUS_AREAS}}` | config.sh |
| `{{FEEDBACK_FORMAT}}` | config.sh |
| `{{ROUND}}` | 当前轮次 |
| `{{TOTAL_ROUNDS}}` | 总轮次 |
| `{{FEEDBACK_FILE}}` | 当前轮反馈文件路径 |
| `{{PLAN_FILE}}` | 当前轮计划文件路径 |
| `{{COMMIT_PREFIX}}` | config.sh |

## 输出结构

```
your-project/
├── .autodev/
│   ├── config.sh
│   ├── prompts/
│   │   ├── feedback.md
│   │   ├── plan.md
│   │   └── implement.md
│   └── logs/                           ← 执行日志
│       ├── round_1_step1_feedback.log
│       ├── round_1_step2_plan.log
│       └── round_1_step3_implement.log
├── docs/
│   ├── feedback_round_1.md             ← AI 生成的反馈报告
│   ├── improvement_plan_round_1.md     ← AI 生成的改进计划
│   ├── feedback_round_2.md
│   └── ...
└── src/                                ← AI 直接修改的代码
```

## 方式二：Copilot Skill（推荐）

除了 shell 脚本，autodev 还提供 Copilot Skill 方式，**无需脚本、无需配置文件模板**，直接在 Copilot 会话中使用。

### 安装

```bash
# 复制 skill 到用户级目录（所有项目可用）
mkdir -p ~/.copilot/skills/autodev
cp skill/SKILL.md ~/.copilot/skills/autodev/SKILL.md
```

### 使用

在任何项目中启动 Copilot，直接说：

```
帮我自动迭代这个项目 5 轮
```

首次使用会交互式询问产品信息，之后自动循环执行。

### Skill vs Shell 脚本

| 特性 | Shell 脚本 | Copilot Skill |
|------|-----------|---------------|
| 上下文 | 每步冷启动 | 单一会话，持续记忆 |
| Prompt | 静态模板 | 动态推理，逐轮调整 |
| 多角色 | 需预定义 | 可中途添加角色 |
| 错误修复 | 下一轮才发现 | 当场验证并修复 |
| 交互控制 | 无（全自动） | 可随时暂停、调整方向 |
| 安装 | 复制脚本 + init | 复制一个 .md 文件 |

## License

MIT
