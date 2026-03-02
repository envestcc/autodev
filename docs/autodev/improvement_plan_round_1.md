# 第 1 轮改进计划

## 改进项 1: [P0] 补充测试失败时的回滚处理策略

- **问题描述**：v1（`skill/SKILL.md:154-158`）和 v2（`skill/SKILL-multi-agent.md:248-256`）的 Step 3 实施要求中，均提到"如果项目有测试，运行测试确保不破坏现有功能"，但完全没有定义测试失败后应如何处理——是回滚改动、跳过当前项、还是继续下一项。缺少回滚策略会导致一次失败的改动污染项目状态，后续轮次都基于错误的基础运行。
- **具体方案**：
  1. 修改 `skill/SKILL.md` 第 154-158 行的 Step 3 实施要求区域，在第 4 条（运行测试）后追加回滚规则：
     ```
     4. **实施后立即验证**：如果项目有测试，运行测试确保不破坏现有功能
        - 如果测试失败，立即执行 `git checkout -- .` 回滚当前改进项的所有改动
        - 将该项标记为"实施失败"，记录失败原因，继续下一项
        - 如果连续 2 项实施失败，暂停并通过 ask_user 询问用户是否继续
     ```
  2. 修改 `skill/SKILL-multi-agent.md` 第 250-255 行的 Step 3 代码实施 Agent prompt 模板，在实施要求第 4 条后追加相同的回滚规则：
     ```
     4. 如果项目有测试（检查 package.json scripts、Makefile 等），每项改进后运行测试确保不破坏现有功能
        - 如果测试失败，立即执行 `git checkout -- .` 回滚当前改进项的所有改动
        - 将该项标记为"实施失败"并记录原因，继续下一项
     ```
  3. 同步修改两个文件的输出格式模板，新增 `❌` 失败状态标记（与已有的 `✅` 和 `⏭️` 并列）：
     ```
     - ❌ 改进项 N: {标题} — 实施失败，原因：测试不通过，已回滚
     ```
- **预期效果**：AI 在实施代码改进时，遇到测试失败有明确的处理路径，不会让错误改动累积到后续轮次。

## 改进项 2: [P1] 修复源码安装指引与推荐版本不一致

- **问题描述**：`README.md:100-101` 和 `README.en.md:100-101` 的源码安装示例 `cp autodev/skill/SKILL.md ~/.claude/skills/autodev/SKILL.md` 复制的是 v1 文件，但文档上方（第 44 行、第 84-88 行）明确推荐使用 v2（`SKILL-multi-agent.md`）。新用户按指引操作会安装到非推荐版本。
- **具体方案**：
  1. 修改 `README.md` 第 100-101 行，将源码安装命令改为：
     ```bash
     git clone https://github.com/envestcc/autodev.git
     # 推荐 v2（多 Agent 版）
     cp autodev/skill/SKILL-multi-agent.md ~/.claude/skills/autodev/SKILL.md
     # 如需 v1（经典版）：cp autodev/skill/SKILL.md ~/.claude/skills/autodev/SKILL.md
     ```
  2. 同步修改 `README.en.md` 第 99-101 行，内容一致（英文注释）：
     ```bash
     git clone https://github.com/envestcc/autodev.git
     # Recommended: v2 (multi-agent)
     cp autodev/skill/SKILL-multi-agent.md ~/.claude/skills/autodev/SKILL.md
     # For v1 (classic): cp autodev/skill/SKILL.md ~/.claude/skills/autodev/SKILL.md
     ```
- **预期效果**：源码安装默认安装推荐的 v2 版本，与一键安装和文档推荐保持一致。

## 改进项 3: [P1] 完善 v2 的 v1 回退机制

- **问题描述**：`skill/SKILL-multi-agent.md:396` 仅用一句话提到"如果 task 工具不可用，回退到 v1 模式"，但没有提供检测逻辑、回退步骤或回退后的行为说明。AI 在实际执行时缺乏可操作的指令，可能直接报错。
- **具体方案**：
  修改 `skill/SKILL-multi-agent.md` 第 396 行，将单行注意事项扩展为一个完整的回退机制说明段落（在"注意事项"部分内展开）：
  ```markdown
  - **v1 回退机制**：在第一次调用 task 工具时，如果返回工具不可用、不支持或报错，则自动切换到 v1 内联模式：
    1. 检测方式：尝试调用 task 工具启动 Step 1 Agent。如果调用失败（工具不存在、权限不足、返回错误），触发回退
    2. 回退行为：Orchestrator 自己承担所有 Step 的执行，按照 `skill/SKILL.md` 中定义的单 Agent 流程在主 context 中内联执行
    3. 告知用户：输出提示"task 工具不可用，已自动切换到 v1 单 Agent 模式执行"
    4. 后续轮次不再尝试调用 task 工具，全部内联执行
  ```
- **预期效果**：AI 在不支持 sub-agent 的环境中能自动检测并优雅降级，用户无需手动切换版本。

## 改进项 4: [P1] 更新 CONTRIBUTING.md 项目结构和 PR 规范

- **问题描述**：`CONTRIBUTING.md:44` 项目结构只列出了 `skill/SKILL.md`，遗漏了 v2 的 `skill/SKILL-multi-agent.md`。`CONTRIBUTING.md:29` PR 规范只提到修改 `skill/SKILL.md` 需同步 README，未提及 v2 文件的同步要求。两个 SKILL 文件有大量重叠逻辑，贡献者可能只更新一个而遗漏另一个。
- **具体方案**：
  1. 修改 `CONTRIBUTING.md` 第 29 行的 PR 规范，替换为：
     ```markdown
     - 如果修改了 `skill/SKILL.md` 或 `skill/SKILL-multi-agent.md`，请同时检查另一个文件是否需要同步修改，并更新 README 中的相关说明
     ```
  2. 修改 `CONTRIBUTING.md` 第 42-50 行的项目结构，补充 v2 文件：
     ```
     autodev/
     ├── skill/
     │   ├── SKILL.md                ← v1 核心 Skill 定义（单 Agent）
     │   └── SKILL-multi-agent.md    ← v2 核心 Skill 定义（多 Agent，推荐）
     ├── README.md            ← 中文文档
     ├── README.en.md         ← English documentation
     ├── CONTRIBUTING.md      ← 贡献指南（本文件）
     ├── .github/             ← Issue/PR 模板
     ├── examples/            ← 配置示例
     └── .autodev/            ← 自迭代配置
     ```
- **预期效果**：贡献者能完整了解项目结构，提交 PR 时不会遗漏 v2 文件的同步更新。

## 改进项 5: [P1] 初始化流程增加输入示例和确认步骤

- **问题描述**：`skill/SKILL.md:28-35` 和 `skill/SKILL-multi-agent.md:51-57` 的初始化问题缺少输入示例，新用户不知道该怎么回答（如"源代码目录"该填什么）。生成 config.yaml 后没有确认步骤，配置错误需手动编辑文件。`examples/` 下有优秀的配置示例但初始化流程中完全未提及。
- **具体方案**：
  1. 修改 `skill/SKILL.md` 第 28-35 行的 ask_user 问题列表，为每个问题追加示例值：
     ```markdown
     1. **产品名称**：这个产品叫什么？（如：个人记账本、Todo CLI、API Gateway）
     2. **产品简介**：用一两句话描述产品是什么、解决什么问题（如：帮助年轻人轻松记录日常收支）
     3. **目标用户画像**：产品的典型用户是谁？（如：25-35岁职场新人，想养成记账习惯但总坚持不下来）
     4. **源代码目录**：代码在哪些目录下？（如：src/、miniprogram/、lib/，多个用逗号分隔）
     5. **重点关注领域**：有没有特别想关注的方面？（如：用户体验、性能、安全性、新手引导）
     ```
  2. 修改 `skill/SKILL.md` 第 41 行（"收集完信息后"）之后、生成 config.yaml 之前，插入确认步骤：
     ```markdown
     收集完信息后，先向用户展示即将生成的配置摘要，通过 ask_user 确认：
     "以下是即将生成的配置，请确认是否正确（输入'是'继续，或说明要修改的部分）：
     - 产品：{name} — {description}
     - 用户画像：{persona}
     - 源码目录：{source_dirs}
     - 关注领域：{focus}"
     
     用户确认后，创建 `.autodev/config.yaml`：
     ```
  3. 对 `skill/SKILL-multi-agent.md` 第 51-64 行做同样的修改（追加示例值和确认步骤）。
- **预期效果**：新用户初始化时有清晰的参考，减少配置错误；确认步骤提供纠错机会，避免生成后手动编辑。

## 改进项 6: [P2] 添加面向开发者工具的配置示例

- **问题描述**：`examples/` 目录下只有面向 C 端产品的示例（记账小程序、React 任务管理），缺少面向开发者工具、CLI、API 服务等 B 端/开发者场景的配置参考。独立开发者做的项目很多是开发者工具类的。
- **具体方案**：
  在 `examples/` 目录下新增 `config-cli-tool.yaml` 文件，内容示例：
  ```yaml
  # 示例：CLI 开发者工具项目配置
  # 适用于：命令行工具、开发者库、API 服务等面向开发者的项目

  product:
    name: "my-cli-tool"
    description: "一个帮助开发者快速生成项目脚手架的 CLI 工具"

  personas:
    - name: "初级开发者"
      description: "刚入行1-2年的开发者，熟悉基本命令行操作，但不熟悉高级配置"
      focus: ["安装流程", "帮助信息", "错误提示可读性", "文档准确性"]

    - name: "资深开发者"
      description: "5年+经验，使用过多个同类工具，追求效率和可定制性"
      focus: ["命令设计合理性", "配置灵活性", "性能", "可编程扩展"]

    - name: "CI/CD 集成者"
      description: "负责将工具集成到自动化流水线中，关注非交互模式和退出码"
      focus: ["非交互模式", "退出码规范", "日志输出格式", "环境变量支持"]

  source_dirs: ["src", "bin"]
  docs_dir: "docs/autodev"
  code_conventions: "TypeScript/Node.js CLI，使用 commander.js"

  iteration:
    max_rounds: 5
    max_items_per_round: 6
    commit_prefix: "feat(autodev):"
  ```
- **预期效果**：开发者工具类项目的用户有直接可参考的配置模板，包含 CLI 特有的 persona 视角（如 CI/CD 集成者），降低配置门槛。
