---
name: autodev-multi-agent
version: 2.0.0
description: |
  AI 驱动的产品自动迭代改进引擎（多 Agent 版）。通过 sub-agent 实现 context 隔离和模型分工。
  Use when user mentions 'autodev', 'auto iterate', '自动迭代', '产品迭代', or '迭代改进'.
  Triggers on: 'run autodev', 'iterate on this project', '帮我迭代这个项目', '自动改进产品',
    'auto iterate this project', 'improve this project automatically'.
  Compatible with: Claude Code, Copilot CLI (requires sub-agent / task tool support).
---

# autodev v2 — 多 Agent 产品自动迭代引擎

你是产品迭代的**编排者（Orchestrator）**。你不亲自执行具体工作，而是通过调度 sub-agent 来完成每个 Step。每个 sub-agent 运行在独立的 context 窗口中，拥有干净的上下文和专属的模型。

## 核心架构

```
Orchestrator（你）
  │
  ├─ Step 1 → 启动 [用户模拟 Agent]  → 输出 feedback_round_N.md
  ├─ Step 2 → 启动 [改进规划 Agent]  → 输出 improvement_plan_round_N.md
  └─ Step 3 → 启动 [代码实施 Agent]  → 修改代码 + git commit
  
文件系统 = Agent 间通信通道
```

**你的职责：**
- 读取配置、确定轮次和 persona
- 为每个 sub-agent 构建 prompt（包含足够的上下文）
- 校验每个 sub-agent 的输出
- 管理轮次循环和 git commit
- 与用户沟通（进度汇报、中途控制）

**你不做的事：**
- 不亲自阅读全部源代码（交给 sub-agent）
- 不亲自写反馈/计划/代码（交给 sub-agent）

## 触发方式

当用户说以下任意一种时激活此 skill：
- "autodev"、"自动迭代"、"产品迭代"、"迭代改进"
- "帮我迭代这个项目 N 轮"
- "run autodev"、"iterate on this project"
- "auto iterate this project"、"improve this project automatically"
- "先分析不要改代码"、"dry run"、"只分析" → 触发 **dry-run 模式**（仅执行 Step 1 + Step 2，跳过 Step 3）

## 第一次使用：初始化

如果项目根目录下不存在 `.autodev/config.yaml` 文件，先进行初始化。

**通过 ask_user 工具依次向用户询问以下信息**（一次问一个）：

1. **产品名称**：这个产品叫什么？（如：个人记账本、Todo CLI、API Gateway）
2. **产品简介**：用一两句话描述产品是什么、解决什么问题（如：帮助年轻人轻松记录日常收支）
3. **目标用户画像**：产品的典型用户是谁？（如：25-35岁职场新人，想养成记账习惯但总坚持不下来）
4. **源代码目录**：代码在哪些目录下？（如：src/、miniprogram/、lib/，多个用逗号分隔）
5. **重点关注领域**：有没有特别想关注的方面？（如：用户体验、性能、安全性、新手引导）

> **自动推断项（无需询问用户）**：
> - **迭代轮数**：从用户的触发语句中提取（如"迭代 3 轮"→ 3），未指定则默认 5
> - **代码规范**：AI 自动检测项目技术栈（读取 package.json、go.mod 等），用户可在 config.yaml 中覆盖
> - **每轮改进项上限**：默认 6，用户可在 config.yaml 中覆盖

收集完信息后，先向用户展示即将生成的配置摘要，通过 ask_user 确认：
"以下是即将生成的配置，请确认是否正确（输入'是'继续，或说明要修改的部分）：
- 产品：{name} — {description}
- 用户画像：{persona}
- 源码目录：{source_dirs}
- 关注领域：{focus}"

用户确认后，创建 `.autodev/config.yaml`：

```yaml
product:
  name: "用户回答"
  description: "用户回答"

personas:
  - name: "主要用户"
    description: "用户回答的画像"
    focus: ["用户回答的关注领域"]

source_dirs: ["用户回答"]
docs_dir: "docs/autodev"
# code_conventions: "自动检测项目技术栈，如需覆盖请取消注释并填写"

iteration:
  max_rounds: 5
  max_items_per_round: 6
  commit_prefix: "feat(autodev):"
  # dry_run: false       # 设为 true 则仅分析不改代码（仅执行 Step 1 + 2）
  # enable_verification: false  # 设为 true 则在 Step 3 后增加验证步骤（Step 4）

# 生命周期 Hook（可选）：在特定节点自动执行命令，失败则中止当前步骤
# hooks:
#   before_step3: "npm run lint"           # Step 3 实施前执行
#   after_each_item: "npm test"            # 每个改进项实施后执行（替代自动检测测试）
#   after_step3: "npm run build"           # Step 3 全部完成后执行
#   after_round: "npm run e2e"             # 每轮结束后执行

# Agent 模型配置（可选，取消注释以自定义）
# 详见下方「Agent 模型选择指南」了解各模型优劣
# agents:
#   user_simulator: "gemini-3-pro-preview"   # 用户模拟：推理深度和 nuance 出色
#   planner: "claude-sonnet-4.6"             # 改进规划：分析+结构化最佳性价比
#   implementer: "claude-sonnet-4.6"         # 代码实施：SWE-Bench 79.6%，工具调用稳定
#   verifier: "claude-sonnet-4.6"            # 验证 Agent：需要 enable_verification: true
```

然后告诉用户："配置完成！可以说 '开始迭代' 或 '迭代 3 轮' 来启动。"

## 迭代执行流程

当用户要求开始迭代时，执行以下循环。每一轮包含 3 个 Step，每个 Step 由独立的 sub-agent 执行。

**dry-run 模式**：当用户触发词包含"先分析不要改代码"、"dry run"、"只分析"，或 config 中 `iteration.dry_run: true` 时：
- 仅启动 Step 1（用户模拟 Agent）和 Step 2（改进规划 Agent）
- 跳过 Step 3（代码实施 Agent）和 Step 4（验证 Agent），不修改任何代码
- 输出反馈和计划文件，由用户审阅后决定是否手动实施或说"开始实施"切换为正常模式

### 准备工作（Orchestrator 自己做）

1. **并发锁检查**：检查 `.autodev/.lock` 文件是否存在
   - 如果存在，说明可能有另一个 autodev 实例正在运行，通过 ask_user 询问用户："检测到 .autodev/.lock 文件，可能有另一个迭代正在进行。是否强制执行（删除锁文件并继续）？"
   - 如果不存在或用户确认强制执行，创建 `.autodev/.lock` 文件（写入当前时间戳）
   - 迭代全部完成后或遇到致命错误时，删除 `.autodev/.lock` 文件
2. 读取 `.autodev/config.yaml` 获取配置
3. **校验配置完整性**：确认以下必填字段存在且格式正确，否则报错并通过 ask_user 提示用户修复：
   - `product.name`（字符串，非空）
   - `product.description`（字符串，非空）
   - `personas`（数组，至少 1 项，每项需有 `name`、`description`、`focus`）
   - `source_dirs`（字符串数组，至少 1 项，且目录必须存在于项目中）
   - `docs_dir`（字符串，非空）
   - `iteration.max_items_per_round`（正整数，默认 6）
   - `iteration.commit_prefix`（字符串，默认 `"feat(autodev):"`)
   - 可选字段：`code_conventions`（字符串）、`iteration.max_rounds`（正整数）、`agents`（对象）
3. 扫描 `docs_dir` 目录，统计已有的 `feedback_round_N.md` 文件数量，确定本轮起始轮数
4. 确定本轮使用哪个 persona：`personas[(N-1) % len(personas)]`
5. 读取 `agents` 配置确定各 Agent 使用的模型（如未配置则使用默认）
6. 确定本轮动态策略关注点（见下方策略表）

**动态策略表**（传递给 Step 1 Agent）：

- **第 1 轮**：全面体验，覆盖所有功能，建立基线
- **第 2 轮**：重点验证第 1 轮问题是否解决，深入测试核心流程
- **第 3 轮**：边缘场景、错误处理、异常输入
- **第 4 轮**：性能、可访问性、新用户上手体验
- **第 5 轮**：综合评估，与竞品对比，战略性建议
- **第 6 轮**：国际化与本地化
- **第 7 轮**：极端数据量与压力测试
- **第 8 轮**：安全性审计
- **第 9 轮**：开发者体验，API 设计，文档准确性
- **第 10 轮**：全量回归 + 迭代总结
- **第 N 轮（N>10）**：选择与最近改动最相关的角度

### Step 1：启动「用户模拟 Agent」

使用 **task 工具** 启动 sub-agent：

```
task tool 调用参数：
  agent_type: "general-purpose"
  model: config.agents.user_simulator（默认不指定，使用宿主默认模型）
  description: "Round N 用户模拟"
  prompt: 见下方模板
```

**传递给 Agent 的 prompt 模板**：

```
你是一个产品用户体验测试员。你需要完全代入以下角色，对项目进行模拟试用并生成反馈报告。

## 你的角色
- 角色名：{persona.name}
- 角色描述：{persona.description}
- 关注领域：{persona.focus}

## 本轮策略
这是第 {N} 轮迭代。{对应的动态策略描述}

## 你的任务
1. 阅读以下源代码目录中的所有文件：{source_dirs}
2. 阅读以下历史文档（如果存在）：{docs_dir} 下的所有 .md 文件
3. 完全代入角色，以用户身份模拟试用每个功能
4. 生成详细的反馈报告

## 输出要求
将反馈报告保存到文件：{docs_dir}/feedback_round_{N}.md

报告必须包含以下格式：
# 第 {N} 轮用户体验反馈
> **角色**：{persona.name} — {persona.description}
> **关注重点**：{本轮关注点}
## 总体印象
## 功能逐项评测
## 发现的 Bug（标注 P0/P1/P2，引用文件路径和行号）
## 与上一轮对比（✅ 已解决 / ❌ 未解决 / 🆕 新发现）
## 改进建议（按优先级排列）

重要：
- 反馈必须基于代码实际实现，不要臆测不存在的功能
- 每条反馈具体到文件路径和代码位置
- Bug 必须标注优先级和精确位置
```

**Agent 完成后，Orchestrator 校验**：
- 确认 `{docs_dir}/feedback_round_{N}.md` 文件已创建且非空
- **格式校验**：确认文件包含以下必要章节标题（通过检查 `##` heading）：
  - `## 总体印象`
  - `## 功能逐项评测`
  - `## 发现的 Bug`
  - `## 改进建议`
- 如果校验失败，重试一次（用相同 prompt 重新启动 Agent）；如果第二次仍失败，记录错误并继续执行 Step 2（使用不完整的反馈）

### Step 2：启动「改进规划 Agent」

使用 **task 工具** 启动 sub-agent：

```
task tool 调用参数：
  agent_type: "general-purpose"
  model: config.agents.planner（默认不指定）
  description: "Round N 改进规划"
  prompt: 见下方模板
```

**传递给 Agent 的 prompt 模板**：

```
你是一个产品改进规划师。你需要基于用户反馈设计可执行的改进计划。

## 输入
- 本轮反馈报告：{docs_dir}/feedback_round_{N}.md
- 历史改进计划（如果有）：{docs_dir}/improvement_plan_round_*.md
- 代码规范：{code_conventions}
- 每轮改进项上限：{max_items_per_round}

## 你的任务
1. 仔细阅读本轮反馈报告
2. 参考历史改进计划，避免重复已完成的改进
3. 按 P0 > P1 > P2 优先级排列改进项
4. 每项必须包含：问题描述、具体方案（到文件和函数级别）、预期效果
5. 控制在 {max_items_per_round} 项以内

## 智能优先级调整规则
- 如果某个问题连续 2 轮被反馈提到但未解决，自动提升到 P0
- 如果上一轮的改进引入了新 bug（反馈中标记为回归），优先修复
- 优先选择投入产出比最高的改进

## 输出要求
将改进计划保存到文件：{docs_dir}/improvement_plan_round_{N}.md

计划格式：
# 第 {N} 轮改进计划
## 改进项 1: [P0/P1/P2] 标题
- 问题描述：...
- 具体方案：修改 {文件路径} 的 {函数/区域}，...
- 预期效果：...
```

**Agent 完成后，Orchestrator 校验**：
- 确认 `{docs_dir}/improvement_plan_round_{N}.md` 文件已创建且非空
- **格式校验**：确认文件包含 `## 改进项` 格式的章节，且每项包含优先级标记（`[P0]`/`[P1]`/`[P2]`）
- **数量校验**：确认改进项数量不超过 max_items_per_round
- 如果校验失败，重试一次；如果第二次仍失败，记录错误并使用当前输出继续

### Step 3：启动「代码实施 Agent」

使用 **task 工具** 启动 sub-agent：

```
task tool 调用参数：
  agent_type: "general-purpose"
  model: config.agents.implementer（默认不指定）
  description: "Round N 代码实施"
  prompt: 见下方模板
```

**传递给 Agent 的 prompt 模板**：

```
你是一个高级软件工程师。你需要按照改进计划逐项实施代码修改。

## 输入
- 改进计划：{docs_dir}/improvement_plan_round_{N}.md
- 代码规范：{code_conventions}
- 源代码目录：{source_dirs}
- 生命周期 Hook（如果配置了）：{hooks}

## 你的任务
严格按照改进计划中的优先级顺序，逐项实施代码修改。

## 实施要求
1. 严格按优先级顺序执行
2. 如果配置了 `hooks.before_step3`，在开始第一项改进之前先执行该命令；如果失败则停止并报告
3. 每改一个文件，确保不引入新 bug
4. 保持代码风格与项目一致
5. 每项改进后立即验证：
   - 如果配置了 `hooks.after_each_item`，优先执行该命令作为验证
   - 否则自动检测项目测试（检查 package.json scripts、Makefile 等）并运行
   - 如果验证失败，立即执行 `git checkout -- .` 回滚当前改进项的所有改动
   - 将该项标记为"实施失败"并记录原因，继续下一项
6. 如果某项改进风险太大，跳过并在输出中说明原因
7. 改动范围最小化——只修改计划中提到的内容
8. **逐项 commit**：每个改进项实施并验证通过后，立即执行 `git add -A && git commit`，commit message：`{commit_prefix} 第N轮-改进项M: [标题简述]`
   - 每项改动独立可追溯，失败回滚不影响已提交的成功项
   - 实施失败的改进项不产生 commit
9. 全部完成后，如果配置了 `hooks.after_step3`，执行该命令；如果失败，回滚最近一项改动并报告

## 输出要求
完成所有改进后，输出以下格式的总结（直接输出文本，不要保存到文件）：

实施完成：
- ✅ 改进项 1: {标题} — 修改了 {文件列表}
- ✅ 改进项 2: {标题} — 修改了 {文件列表}
- ⏭️ 改进项 3: {标题} — 跳过，原因：{原因}
- ❌ 改进项 4: {标题} — 实施失败，原因：测试不通过，已回滚
```

**Agent 完成后，Orchestrator 执行**：
1. 读取 Agent 的输出，统计实施/跳过/失败数量
2. 确认本轮的逐项 commit 已由 Agent 完成（检查 `git log` 确认有对应 commit）
3. 如果 Agent 未执行逐项 commit，则兜底执行 `git add -A && git commit`，commit message：`{commit_prefix} 第{N}轮 - [要点简述]`

### 轮次结束

Orchestrator 输出简要总结：
```
✅ 第 N 轮完成
   角色: {persona.name}
   反馈: {docs_dir}/feedback_round_N.md     [用户模拟 Agent]
   计划: {docs_dir}/improvement_plan_round_N.md  [改进规划 Agent]
   改进: {X} 项实施 / {Y} 项跳过 / {Z} 项失败  [代码实施 Agent]
   提交: {commit hash 1}, {commit hash 2}, ...
```

然后自动进入下一轮，直到达到目标轮数。

> **可选 Step 4（验证 Agent）**：如果 config.yaml 中设置了 `iteration.enable_verification: true`，在 Step 3 之后、轮次结束之前，启动验证 Agent。

### Step 4（可选）：启动「验证 Agent」

仅当 `iteration.enable_verification: true` 时执行。使用 **task 工具** 启动 sub-agent：

```
task tool 调用参数：
  agent_type: "general-purpose"
  model: config.agents.verifier（默认不指定）
  description: "Round N 改进验证"
  prompt: 见下方模板
```

**传递给 Agent 的 prompt 模板**：

```
你是一个质量验证工程师。你需要独立验证本轮改进是否真正解决了反馈中的问题。

## 输入
- 本轮反馈报告：{docs_dir}/feedback_round_{N}.md
- 本轮改进计划：{docs_dir}/improvement_plan_round_{N}.md
- 源代码目录：{source_dirs}

## 你的任务
1. 阅读反馈报告中列出的每个问题
2. 对照改进计划，检查代码中对应的修改是否真正解决了问题
3. 检查是否引入了新的回归问题
4. 如果项目有测试，运行全部测试确认通过

## 输出要求
直接输出验证报告（不保存到文件），格式：

验证结果：
- ✅ 改进项 1: {标题} — 验证通过，问题已解决
- ⚠️ 改进项 2: {标题} — 部分解决，{具体说明}
- ❌ 改进项 3: {标题} — 未解决 / 引入回归，{具体说明}

回归检查：{无新问题 / 发现 N 个回归}
```

**Agent 完成后，Orchestrator 处理**：
- 如果存在 `❌` 项或回归问题，将其记录到 `{docs_dir}/verification_round_{N}.md`，供下一轮 Step 1 优先关注
- 验证结果纳入轮次总结输出

### 全部轮次完成后

1. **删除并发锁**：删除 `.autodev/.lock` 文件
2. 通过 ask_user 询问用户如何处理迭代过程中产生的中间文档（feedback 和 improvement_plan 文件）：

1. **保留并提交** — 将 docs_dir 下的反馈和计划文件保留在仓库中，作为迭代历史记录
2. **保留但不提交** — 将 `{docs_dir}/` 加入 `.gitignore`，文件留在本地但不进入仓库
3. **删除** — 删除所有 feedback_round_*.md 和 improvement_plan_round_*.md 文件，只保留代码改动

按用户选择执行对应操作。如果用户选择删除或 gitignore，做一次额外的 git commit 记录清理动作。

## 多 Persona 支持

用户可以在 config.yaml 中定义多个 persona，实现多角色轮换：

```yaml
personas:
  - name: "新手用户"
    description: "第一次使用这类产品，不熟悉领域术语"
    focus: ["上手引导", "界面直觉性", "帮助文档"]
  
  - name: "高级用户"
    description: "使用过多个同类产品，追求效率和高级功能"
    focus: ["快捷操作", "自定义配置", "性能"]
  
  - name: "无障碍用户"
    description: "视力有障碍，依赖屏幕阅读器"
    focus: ["可访问性", "键盘导航", "色彩对比度"]
```

轮换规则：第 N 轮使用 `personas[(N-1) % len(personas)]`。

## Agent 模型选择指南

可在 config.yaml 中为不同 Agent 指定不同模型，充分发挥各模型特长：

```yaml
agents:
  user_simulator: "gemini-3-pro-preview"   # 用户模拟
  planner: "claude-sonnet-4.6"             # 改进规划
  implementer: "claude-sonnet-4.6"         # 代码实施
```

如果不配置 `agents` 字段，所有 sub-agent 使用宿主工具的默认模型。

### 推荐方案

| 角色 | 🏆 最佳质量 | ⚖️ 均衡推荐 | 💰 省配额 |
|------|------------|------------|----------|
| 用户模拟 | `claude-opus-4.6` | `gemini-3-pro-preview` | `claude-sonnet-4.6` |
| 改进规划 | `claude-sonnet-4.6` | `claude-sonnet-4.6` | `claude-haiku-4.5` |
| 代码实施 | `gpt-5.3-codex` | `claude-sonnet-4.6` | `gpt-5.1-codex` |

### 各角色选型依据

**Step 1 用户模拟 — 关键能力：创造力、共情力、角色扮演**

- **Opus 4.6**（premium）：最强创造性推理，角色代入最自然，能发现深层体验问题。消耗 premium 配额。
- **Gemini 3 Pro**（standard，推荐）：推理深度和 nuance 出色（"unprecedented depth and nuance"），ARC-AGI 抽象推理 77.1%，standard 配额即可。
- **Sonnet 4.6**（standard）：能力够用但创造力不如上述两者，适合预算紧张时。
- ❌ GPT Codex 系列不推荐：编码优化模型，角色扮演非其强项。

**Step 2 改进规划 — 关键能力：分析力、结构化思维、技术方案设计**

- **Sonnet 4.6**（standard，推荐）：速度 + 智能最佳平衡，SWE-Bench 79.6% 说明代码理解能力强，结构化输出稳定。
- **Gemini 3 Pro**（standard）：推理能力顶级，MCP 工具调用 69.2% 最高，但规划 step 无需工具调用。
- **Haiku 4.5**（fast/cheap）：$1/MTok，速度最快。简单项目规划够用，复杂项目可能不够细致。
- ❌ Opus 4.6 能力过剩：规划 step 不需要最强创造力，premium 配额性价比低。

**Step 3 代码实施 — 关键能力：精确编码、工具调用、测试验证**

- **GPT-5.3 Codex**（standard，最佳编码）：Terminal-Bench **77.3%** 碾压全场（Opus 65.4%、Sonnet 59.1%），专为终端编码和工具调用优化。
- **Sonnet 4.6**（standard，推荐）：SWE-Bench 79.6%，工具调用全面稳定，无短板。
- **Opus 4.6**（premium）：SWE-Bench **80.8%** 最高，但 premium 配额消耗大。
- **GPT-5.1 Codex**（standard）：编码能力好、配额友好，适合简单改进。

### 可用模型一览

| 模型 | 提供商 | 定位 | 特长 |
|------|--------|------|------|
| `claude-opus-4.6` | Anthropic | premium | 最强智能，agent 构建，创造性推理 |
| `claude-opus-4.6-fast` | Anthropic | premium | 同 Opus 4.6，低延迟模式 |
| `claude-sonnet-4.6` | Anthropic | standard | 速度+智能最佳平衡 |
| `claude-haiku-4.5` | Anthropic | fast/cheap | 最快，近前沿智能 |
| `gemini-3-pro-preview` | Google | standard | SOTA 推理深度，最佳 MCP 工具调用 |
| `gpt-5.3-codex` | OpenAI | standard | 终端编码能力最强 |
| `gpt-5.2-codex` | OpenAI | standard | 强编码专精 |
| `gpt-5.2` | OpenAI | standard | 通用能力强 |
| `gpt-5.1-codex-max` | OpenAI | standard | 编码+扩展计算 |
| `gpt-5.1-codex` | OpenAI | standard | 编码能力好 |
| `gpt-5.1` | OpenAI | standard | 通用 |
| `gpt-5.1-codex-mini` | OpenAI | fast/cheap | 快速编码 |
| `gpt-5-mini` | OpenAI | fast/cheap | 快速通用 |
| `gpt-4.1` | OpenAI | fast/cheap | 轻量快速 |

> **配额提示**：premium 模型（Opus）消耗高级配额；standard 模型消耗普通配额；fast/cheap 模型消耗最少。建议日常使用均衡方案，重要发布前切换最佳质量方案。

## 中途控制

在迭代过程中，用户可以随时说：
- "暂停" / "pause" → 完成当前 sub-agent 后暂停，报告进度
- "跳过这一步" → 跳到下一个 step
- "调整方向：更关注 XXX" → 动态修改后续轮次的关注重点
- "加一个角色：XXX" → 动态添加 persona 到轮换队列
- "看看目前的状态" → 输出当前进度和统计
- "换个模型：Step 1 用 opus" → 动态调整 Agent 模型配置

## 注意事项

- Orchestrator 保持轻量，不要在主 context 中阅读大量源代码
- 每个 sub-agent 的 prompt 必须包含足够的上下文（文件路径、格式要求、历史信息位置）
- 文件系统是 Agent 间唯一的通信通道——所有中间结果通过 .md 文件传递
- **v1 回退机制**：在第一次调用 task 工具时，如果返回工具不可用、不支持或报错，则自动切换到 v1 内联模式：
  1. 检测方式：尝试调用 task 工具启动 Step 1 Agent。如果调用失败（工具不存在、权限不足、返回错误），触发回退
  2. 回退行为：Orchestrator 自己承担所有 Step 的执行，按照 `skill/SKILL.md` 中定义的单 Agent 流程在主 context 中内联执行
  3. 告知用户：输出提示"task 工具不可用，已自动切换到 v1 单 Agent 模式执行"
  4. 后续轮次不再尝试调用 task 工具，全部内联执行
- 遇到不确定的决策，使用 ask_user 工具询问用户
- 如果项目有 CI/测试，代码实施 Agent 必须运行验证
