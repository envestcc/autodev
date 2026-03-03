[English](README.en.md) | 中文

<div align="center">

<h1>🤖 autodev</h1>

<p><strong>让 AI 替你做产品迭代 — 你睡觉，它改代码。</strong></p>

<p>
  <a href="https://github.com/envestcc/autodev/stargazers"><img src="https://img.shields.io/github/stars/envestcc/autodev?style=social" alt="GitHub stars"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
  <a href="https://github.com/envestcc/autodev/commits/main"><img src="https://img.shields.io/github/last-commit/envestcc/autodev" alt="Last commit"></a>
  <a href="https://github.com/envestcc/autodev/issues"><img src="https://img.shields.io/github/issues/envestcc/autodev" alt="Issues"></a>
  <a href="https://github.com/envestcc/autodev/network/members"><img src="https://img.shields.io/github/forks/envestcc/autodev?style=social" alt="Forks"></a>
</p>

<p>
  AI 扮演你的用户，自动发现问题 → 设计方案 → 写代码 → 提交 commit<br/>
  一行安装 · 零依赖 · 纯 Markdown · 兼容 <a href="https://docs.anthropic.com/en/docs/claude-code">Claude Code</a> & Copilot CLI
</p>

<br/>

```
"帮我自动迭代这个项目 5 轮"
```

```
🔄 第 1 轮 | 角色: 职场新人
   📋 模拟试用... 发现 5 个问题
   📐 设计改进... 4×P1 + 1×P2
   🔧 实施改进... 修改 3 个文件
✅ 提交: a1b2c3d

🔄 第 2 轮 | 角色: 职场新人
   📋 验证修复 + 深入测试... 3 个新问题
   📐 设计改进... 3 项
   🔧 实施改进... 修改 2 个文件
✅ 提交: d4e5f6g

✅ 全部完成！共实施 11 项改进。
```

</div>

---

## ✨ 特性

<table>
<tr>
<td>🤖 <b>全自动</b><br/>一句话启动，AI 读代码→找问题→写修复→提交 commit</td>
<td>🎭 <b>多角色</b><br/>不同用户画像轮换，多视角发现问题（<a href="personas/">预置模板</a>）</td>
</tr>
<tr>
<td>🔄 <b>N 轮递进</b><br/>每轮基于上一轮反馈，螺旋式改进</td>
<td>🪶 <b>零依赖</b><br/>一个 Markdown 文件，一行 curl 安装</td>
</tr>
<tr>
<td>🔍 <b>dry-run</b><br/>先分析不改代码，审阅后再实施</td>
<td>🎯 <b>聚焦模式</b><br/><code>focus_paths</code> 精准控制分析范围</td>
</tr>
</table>

## 💡 为什么选择 autodev

> **别的 AI 工具：** 你说改什么，它帮你改。<br/>
> **autodev：** AI 主动发现问题，自己决定改什么。

这是**唯一**从用户视角出发的 AI 编码工具 —— AI 扮演真实用户，而不是听指令的码农。

| | autodev | aider | OpenHands | Devin |
|---|---------|-------|-----------|-------|
| **核心思路** | 🎭 模拟用户发现问题 | 💬 对话改代码 | 🎫 自主解决 Issue | 🤖 自主工程师 |
| **用户画像模拟** | ✅ 多角色轮换 | ❌ | ❌ | ❌ |
| **自动多轮** | ✅ N 轮递进 | ❌ 单次对话 | ❌ 单 Issue | ❌ 单任务 |
| **安装** | `curl` 一行 | pip install | Docker 部署 | SaaS $500/月 |
| **依赖** | 零（纯 Markdown） | Python | Docker + 服务端 | 闭源云服务 |

## 两个版本

| | v1 (`SKILL.md`) | v2 (`SKILL-multi-agent.md`) |
|---|---|---|
| 架构 | 单 context 内联执行 | 多 Agent，每个 Step 独立 context |
| 模型 | 统一模型 | 每个角色可用不同模型 |
| Context 隔离 | ❌ 所有步骤共享 | ✅ 每步干净隔离 |
| 长轮次稳定性 | ⚠️ 3+ 轮后 context 可能过长 | ✅ 每步 context 都干净 |
| 兼容性 | 所有支持 Skill 的工具 | 需要支持 sub-agent（task 工具） |
| 复杂度 | 简单，220 行 | 更丰富，约 300 行 |

**推荐**：如果你的工具支持 sub-agent（Copilot CLI、Claude Code），使用 v2。否则使用 v1。

## 30 秒体验

```bash
# 1. 一键安装（Claude Code 用户）
mkdir -p ~/.claude/skills/autodev && curl -fsSL https://raw.githubusercontent.com/envestcc/autodev/main/skill/SKILL-multi-agent.md -o ~/.claude/skills/autodev/SKILL.md

# 2. 在任意项目中启动 Claude Code，说：
#    "帮我自动迭代这个项目 3 轮"

# 3. 看 AI 自动工作 ☕
```

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

**一键安装（推荐）：**

```bash
# v2 多 Agent 版（推荐，Claude Code 用户）
mkdir -p ~/.claude/skills/autodev && curl -fsSL https://raw.githubusercontent.com/envestcc/autodev/main/skill/SKILL-multi-agent.md -o ~/.claude/skills/autodev/SKILL.md

# v2 多 Agent 版（Copilot CLI 用户）
mkdir -p ~/.copilot/skills/autodev && curl -fsSL https://raw.githubusercontent.com/envestcc/autodev/main/skill/SKILL-multi-agent.md -o ~/.copilot/skills/autodev/SKILL.md

# v1 经典版（如果你的工具不支持 sub-agent）
# 将上面 URL 中的 SKILL-multi-agent.md 替换为 SKILL.md
```

**或从源码安装：**

```bash
git clone https://github.com/envestcc/autodev.git
# 推荐 v2（多 Agent 版）
cp autodev/skill/SKILL-multi-agent.md ~/.claude/skills/autodev/SKILL.md
# 如需 v1（经典版）：cp autodev/skill/SKILL.md ~/.claude/skills/autodev/SKILL.md
```

验证安装：`cat ~/.claude/skills/autodev/SKILL.md | head -3` 应输出 `---`。

### 前置条件

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 或 Copilot CLI 已安装
- 目标项目是一个 git 仓库

### 使用

在任何项目中启动 Claude Code，直接说：

```
帮我自动迭代这个项目 5 轮
```

首次使用会交互式询问产品信息（约 5 个问题），自动生成 `.autodev/config.yaml`，然后开始循环迭代。

### 配置（config.yaml）

首次运行时自动生成，也可手动编辑 `.autodev/config.yaml`：

```yaml
product:
  name: "个人记账本"
  description: "帮助年轻人轻松记录日常收支、分析消费习惯"

personas:
  - name: "职场新人"
    description: "月薪 8k，想养成记账习惯但总坚持不下来"
    focus: ["记账效率", "消费分析体验"]

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

> 💡 预置 Persona 模板见 [personas/](personas/) 目录，覆盖电商、SaaS、移动端、开发者工具等场景。

## 高级功能

### dry-run 模式

只分析不改代码，审阅反馈和计划后再决定是否实施：

```
先分析不要改代码，迭代 3 轮
```

或在 config.yaml 中设置 `iteration.dry_run: true`。

### 聚焦模式

大型项目中限制 AI 只关注特定模块：

```yaml
focus_paths: ["src/auth/", "src/api/"]
exclude_paths: ["src/vendor/", "dist/"]
```

### 生命周期 Hook

在特定节点自动执行自定义命令：

```yaml
hooks:
  before_step3: "npm run lint"
  after_each_item: "npm test"
  after_step3: "npm run build"
  after_round: "npm run e2e"
```

### 验证 Agent（v2）

开启后在代码实施后增加独立验证步骤，检查改进是否真正解决问题：

```yaml
iteration:
  enable_verification: true
```

## 中途控制

迭代过程中可以随时说：
- **"暂停"** → 完成当前 step 后暂停
- **"调整方向：更关注 XXX"** → 动态修改关注重点
- **"加一个角色：XXX"** → 添加新 persona
- **"看看目前的状态"** → 输出进度统计

## 贡献

请参阅 [CONTRIBUTING.md](CONTRIBUTING.md)。

## Star History

<a href="https://star-history.com/#envestcc/autodev&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=envestcc/autodev&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=envestcc/autodev&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=envestcc/autodev&type=Date" />
 </picture>
</a>

## 💪 Show Your Support

如果觉得有用，请给一个 ⭐ Star！这是对我最大的鼓励。

[![Star this repo](https://img.shields.io/github/stars/envestcc/autodev?style=social)](https://github.com/envestcc/autodev)

**分享给朋友：**

[![Share on Twitter](https://img.shields.io/badge/Share-Twitter-1DA1F2?logo=twitter&logoColor=white)](https://twitter.com/intent/tweet?text=🤖%20autodev%20—%20让AI替你做产品迭代：模拟用户→发现问题→写代码→提交commit。一行安装，零依赖！&url=https://github.com/envestcc/autodev)
[![Share on Reddit](https://img.shields.io/badge/Share-Reddit-FF4500?logo=reddit&logoColor=white)](https://www.reddit.com/submit?url=https://github.com/envestcc/autodev&title=autodev%20-%20AI-driven%20product%20auto-iteration%20engine)

## License

MIT
