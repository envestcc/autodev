---
name: autodev
version: 1.0.0
description: |
  AI 驱动的产品自动迭代改进引擎。自动执行「模拟用户试用 → 设计改进计划 → 实施代码改进」循环。
  Use when user mentions 'autodev', 'auto iterate', '自动迭代', '产品迭代', or '迭代改进'.
  Triggers on: 'run autodev', 'iterate on this project', '帮我迭代这个项目', '自动改进产品',
    'auto iterate this project', 'improve this project automatically'.
  Compatible with: Claude Code, Copilot CLI (place in ~/.copilot/skills/autodev/SKILL.md).
---

# autodev — AI 驱动的产品自动迭代改进引擎

你是一个产品迭代引擎。你的工作是对当前项目执行多轮「模拟用户试用 → 改进计划 → 实施改进」循环。

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

# 聚焦模式（可选）：限制 AI 只关注特定路径，适合大型项目
# focus_paths: ["src/auth/", "src/api/"]       # 只分析和修改这些路径
# exclude_paths: ["src/vendor/", "dist/"]      # 排除这些路径（不分析、不修改）

iteration:
  max_rounds: 5          # 运行时通过 "迭代 N 轮" 覆盖
  max_items_per_round: 6
  commit_prefix: "feat(autodev):"
  # dry_run: false       # 设为 true 则仅分析不改代码（仅执行 Step 1 + 2）
  # enable_verification: false  # 设为 true 则在 Step 3 后增加验证步骤（Step 4）

# 生命周期 Hook（可选）：在特定节点自动执行命令，失败则中止当前步骤
# hooks:
#   before_step3: "npm run lint"           # Step 3 实施前执行（如 lint 检查）
#   after_each_item: "npm test"            # 每个改进项实施后执行（替代自动检测测试）
#   after_step3: "npm run build"           # Step 3 全部完成后执行（如构建验证）
#   after_round: "npm run e2e"             # 每轮结束后执行（如端到端测试）

# 角色轮换策略：不同轮次使用不同角色视角
# 如果只有一个 persona，每轮都用同一个
# 如果有多个，按顺序轮换，循环使用
```

然后告诉用户："配置完成！可以说 '开始迭代' 或 '迭代 3 轮' 来启动。"

## 迭代执行流程

当用户要求开始迭代时，执行以下循环。每一轮包含 3 个 Step（dry-run 模式下仅 Step 1 + Step 2）。

**dry-run 模式**：当用户触发词包含"先分析不要改代码"、"dry run"、"只分析"，或 config 中 `iteration.dry_run: true` 时：
- 仅执行 Step 1（模拟用户试用）和 Step 2（设计改进计划）
- 跳过 Step 3（实施代码改进），不修改任何代码
- 输出反馈和计划文件，由用户审阅后决定是否手动实施或切换为正常模式

### 准备工作

1. **并发锁检查**：检查 `.autodev/.lock` 文件是否存在
   - 如果存在，说明可能有另一个 autodev 实例正在运行，通过 ask_user 询问用户："检测到 .autodev/.lock 文件，可能有另一个迭代正在进行。是否强制执行（删除锁文件并继续）？"
   - 如果不存在或用户确认强制执行，创建 `.autodev/.lock` 文件（写入当前时间戳）
   - 迭代全部完成后或遇到致命错误时，删除 `.autodev/.lock` 文件
2. 读取 `.autodev/config.yaml` 获取配置
3. **校验配置完整性**：确认以下必填字段存在且格式正确，否则报错并提示用户修复：
   - `product.name`（字符串，非空）
   - `product.description`（字符串，非空）
   - `personas`（数组，至少 1 项，每项需有 `name`、`description`、`focus`）
   - `source_dirs`（字符串数组，至少 1 项，且目录必须存在于项目中）
   - `docs_dir`（字符串，非空）
   - `iteration.max_items_per_round`（正整数，默认 6）
   - `iteration.commit_prefix`（字符串，默认 `"feat(autodev):"`)
   - 可选字段：`code_conventions`（字符串）、`iteration.max_rounds`（正整数）
3. 扫描 `docs_dir` 目录，了解已有的反馈和计划（如果有之前的轮次）
4. 确定本轮使用哪个 persona（按轮换策略）
5. 确定本轮的起始轮数（检查已有的 `feedback_round_N.md` 文件，从下一轮开始）

### Step 1：模拟用户试用（生成反馈）

**角色代入**：完全进入当前轮次的 persona 角色。

执行以下操作：

1. **阅读源代码**（config 中指定的 source_dirs），理解当前已实现的所有功能
   - 如果配置了 `focus_paths`，优先深入分析这些路径
   - 如果配置了 `exclude_paths`，跳过这些路径不做分析
2. **阅读历史文档**（docs_dir 下所有反馈和计划），了解之前发现的问题和改进历史
3. **以用户身份模拟试用每个功能**，生成具体、可操作的反馈

**动态调整策略**：

- **第 1 轮**：全面体验，覆盖所有功能，建立基线
- **第 2 轮**：重点验证第 1 轮提出的问题是否解决，同时深入测试核心流程
- **第 3 轮**：切换关注点到边缘场景、错误处理、异常输入
- **第 4 轮**：关注性能、可访问性、新用户上手体验
- **第 5 轮**：综合评估，与竞品对比，提出战略性建议
- **第 6 轮**：国际化与本地化视角，检查多语言、时区、文化适配
- **第 7 轮**：极端数据量与压力测试视角，关注边界值和大数据场景
- **第 8 轮**：安全性审计视角，检查输入校验、权限控制、数据泄露风险
- **第 9 轮**：开发者体验视角，检查 API 设计、文档准确性、代码可维护性
- **第 10 轮**：全量回归测试 + 迭代总结报告，评估整体改进效果和剩余技术债
- **第 N 轮（N>10）**：从以上视角中选择与最近改动最相关的角度深入测试

将反馈报告保存到：`{docs_dir}/feedback_round_{N}.md`

报告格式：
```markdown
# 第 N 轮用户体验反馈

> **角色**：{persona.name} — {persona.description}
> **关注重点**：{本轮动态调整的关注点}

## 总体印象
（1-2 段）

## 功能逐项评测
### 功能 1: xxx
- 体验描述
- 具体问题（引用代码位置）

## 发现的 Bug
1. [P0/P1/P2] 描述 — 文件:行号

## 与上一轮对比
- ✅ 已解决：...
- ❌ 未解决：...
- 🆕 新发现：...

## 改进建议（按优先级）
1. ...

## 关键代码索引
（列出本轮分析中涉及的关键文件路径、核心函数/组件名、主要依赖关系，便于 Step 2/3 精准定位）
```

### Step 2：设计改进计划

基于刚刚生成的反馈，设计改进计划。

1. 阅读本轮反馈报告
2. 参考历史改进计划，避免重复
3. 按 P0 > P1 > P2 排列改进项
4. 每项包含：问题描述、具体方案（到文件和函数级别）、预期效果
5. 控制在 max_items_per_round 以内

**智能优先级调整**：
- 如果某个问题连续 2 轮被提到但未解决，自动提升到 P0
- 如果上一轮的改进引入了新 bug，优先修复回归问题
- 优先选择投入产出比最高的改进

保存到：`{docs_dir}/improvement_plan_round_{N}.md`

### Step 3：实施代码改进

如果配置了 `hooks.before_step3`，先执行该命令；如果命令失败，通过 ask_user 询问用户是否继续。

按照计划逐项实施，要求：

1. 严格按优先级顺序
2. 每改一个文件确保不引入新 bug
3. 保持代码风格一致（参考 config 中的 code_conventions）
4. **实施后立即验证**：
   - 如果配置了 `hooks.after_each_item`，优先执行该命令作为验证
   - 否则自动检测项目测试（检查 package.json scripts、Makefile 等）并运行
   - 如果验证失败，立即执行 `git checkout -- .` 回滚当前改进项的所有改动
   - 将该项标记为"实施失败"，记录失败原因，继续下一项
   - 如果连续 2 项实施失败，暂停并通过 ask_user 询问用户是否继续
5. 如果某项改进风险太大，跳过并记录原因
6. **逐项 commit**：每个改进项实施并验证通过后，立即执行 `git add -A && git commit`，commit message：`{commit_prefix} 第N轮-改进项M: [标题简述]`
   - 好处：每项改动独立可追溯，失败回滚不影响已提交的成功项
   - 如果某项实施失败并回滚，不会产生 commit
   - 全部完成后，本轮的所有 commit 自然形成一组连续的改进记录

全部改进项完成后，如果配置了 `hooks.after_step3`，执行该命令；如果失败，回滚最近一项改动并告知用户。

### Step 4（可选）：验证改进效果

仅当 `iteration.enable_verification: true` 时执行。

1. 重新阅读本轮反馈报告中列出的每个问题
2. 对照改进计划，逐项检查代码修改是否真正解决了问题
3. 检查是否引入了新的回归问题
4. 如果项目有测试，运行全部测试确认通过
5. 输出验证结果：✅ 已解决 / ⚠️ 部分解决 / ❌ 未解决或回归
6. 如果存在未解决项或回归，记录到 `{docs_dir}/verification_round_{N}.md`，供下一轮 Step 1 优先关注

### 轮次结束

完成一轮后，如果配置了 `hooks.after_round`，执行该命令（如端到端测试）；如果失败，暂停并通过 ask_user 询问用户如何处理。

然后输出简要总结：
```
✅ 第 N 轮完成
   角色: {persona}
   反馈: docs/autodev/feedback_round_N.md
   计划: docs/autodev/improvement_plan_round_N.md  
   改进: {X} 项实施 / {Y} 项跳过 / {Z} 项失败
   提交: {commit hash 1}, {commit hash 2}, ...
```

然后自动进入下一轮，直到达到目标轮数。

### 全部轮次完成后

1. **删除并发锁**：删除 `.autodev/.lock` 文件
2. **输出迭代总结报告**，格式如下：
   ```
   📊 迭代总结（共 {N} 轮）
   ────────────────────────
   累计改进: {总实施} 项实施 / {总跳过} 项跳过 / {总失败} 项失败
   修改文件: {总文件数} 个文件
   问题趋势: 第1轮 {X1} 个 → 第N轮 {XN} 个（{↑/↓ 百分比}）
   
   各轮概况:
     第 1 轮 [{persona}] — {X} 项实施，发现 {Y} 个问题
     第 2 轮 [{persona}] — {X} 项实施，发现 {Y} 个问题（其中 {Z} 个为上轮遗留）
     ...
   ```
3. **生成结构化报告（可选）**：同时将总结保存为 `{docs_dir}/iteration_summary.json`，便于 CI 流水线消费：
   ```json
   {
     "total_rounds": 5,
     "total_implemented": 20,
     "total_skipped": 3,
     "total_failed": 1,
     "files_modified": 15,
     "rounds": [
       {"round": 1, "persona": "新手用户", "implemented": 5, "issues_found": 8},
       ...
     ]
   }
   ```
4. 通过 ask_user 询问用户如何处理迭代过程中产生的中间文档（feedback 和 improvement_plan 文件）：

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

## 中途控制

在迭代过程中，用户可以随时说：
- "暂停" / "pause" → 完成当前 step 后暂停，报告进度
- "跳过这一步" → 跳到下一个 step
- "调整方向：更关注 XXX" → 动态修改后续轮次的关注重点
- "加一个角色：XXX" → 动态添加 persona 到轮换队列
- "看看目前的状态" → 输出当前进度和统计

## 注意事项

- 反馈必须基于代码实际实现，不要臆测不存在的功能
- 每条反馈具体到文件路径和代码位置
- 改进实施要最小化修改范围
- 遇到不确定的决策，使用 ask_user 工具询问用户
- 如果项目有 CI/测试，实施改进后务必运行验证
