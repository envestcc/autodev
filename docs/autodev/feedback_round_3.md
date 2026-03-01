# 第 3 轮用户体验反馈

> **角色**：独立开发者 — 有自己的副业/开源项目，希望自动化产品迭代过程，减少重复工作
> **关注重点**：废弃 Shell 脚本方向评估，清理遗留物，确保 Skill-only 体验干净一致

## 总体印象

经过前 2 轮迭代，autodev 的 Skill 方式已经成为事实上的主推方式，README 和 SKILL.md 都已就绪。但项目仓库中仍然存在大量 Shell 脚本时代的遗留物，给新用户造成困惑。**评分：8/10，但存在"身份分裂"问题。**

作为一个新用户 clone 这个仓库，我会看到：一个 686 行的 `autodev.sh`、shell 格式的示例配置、一个测试 shell 脚本的测试文件、shell 时代的反馈文档——然后 README 告诉我"推荐使用 Skill 方式"。这种混乱信号需要彻底清理。

## 功能逐项评测

### 功能 1: 仓库根目录第一印象

- **问题 1（P0）**：`autodev.sh` 仍是仓库中最显眼的文件之一，686 行代码。新用户会以为这就是产品本体，而不是已废弃的旧方式
- **问题 2**：`tests/test_basic.sh` 仅测试 shell 脚本，与 Skill 无关。给人错误印象——以为产品有测试覆盖
- **问题 3**：`examples/` 目录中 .sh 和 .yaml 文件混杂，2 种格式各 2 个，新用户不知道该看哪个

### 功能 2: .autodev/ 本项目配置

- **问题 1**：`.autodev/config.sh`（shell 格式）和 `.autodev/config.yaml`（Skill 格式）并存。两个配置文件讲的是不同格式的同一件事
- **问题 2**：`.autodev/prompts/` 目录（feedback.md, plan.md, implement.md）是 shell 脚本方式的模板系统，Skill 方式完全不需要这些文件
- **问题 3**：`.autodev/logs/` 是 shell 脚本的执行日志，与 Skill 无关

### 功能 3: docs/ 目录

- **问题**：`docs/feedback_round_1.md` 和 `docs/improvement_plan_round_1.md` 是 shell 时代的产物（存放在 `docs/` 而非 `docs/autodev/`），与当前 Skill 方式的 `docs/autodev/` 路径不一致

### 功能 4: README 内容

- **问题 1**：README.md:98-108 的 "Skill vs Shell 脚本" 对比表——如果 Shell 已废弃，这个对比表就不需要了
- **问题 2**：README.md:110-178 整个"方式二：Shell 脚本"章节应该移除
- **问题 3**：README 引言仍说"通过 Copilot CLI / Claude Code 驱动"——既然只有 Skill 了，应该说清楚是通过 Skill 驱动

### 功能 5: SKILL.md 中的 Shell 遗留引用

- **问题 1**：skill/SKILL.md:66-71 "已有 config.sh 的项目迁移" 章节——如果 shell 方式已废弃，迁移说明也可以简化或作为历史兼容注释
- **问题 2**：skill/SKILL.md:94 "这是比 shell 脚本强大之处"——废弃后不需要与自己比较

## 发现的 Bug

1. [P0] **仓库身份分裂** — autodev.sh（686行）、shell 测试、shell 配置、shell 示例仍存在于仓库中，与 Skill-only 方向严重冲突
2. [P1] **README 包含已废弃内容** — "方式二：Shell 脚本" 整章 + 对比表需移除
3. [P1] **本项目 .autodev/ 有 shell 遗留** — config.sh、prompts/、logs/ 均为 shell 时代产物
4. [P2] **docs/ 有 shell 时代文档** — docs/feedback_round_1.md、docs/improvement_plan_round_1.md 路径与当前规范不一致
5. [P2] **SKILL.md 残留 shell 比较措辞** — "这是比 shell 脚本强大之处"等

## 与上一轮对比

- ✅ 已解决：config.yaml 模板与自动推断矛盾（P1-1 第2轮修复）
- ✅ 已解决：config.sh 迁移说明（P1-2 第2轮添加）
- ✅ 已解决：README 首段已更新（P2-1 第2轮修复）
- ✅ 已解决：Shell 安装地址占位符（P2-2 第2轮修复）
- ✅ 已解决：第10轮策略已细化（P2-3 第2轮修复）
- 🆕 新方向：全面废弃 Shell 脚本，清理所有遗留物

## 改进建议（按优先级）

1. **[P0] 删除 autodev.sh** — 移除 shell 脚本主体
2. **[P0] 删除 shell 相关示例和测试** — 移除 examples/*.sh、tests/test_basic.sh
3. **[P1] 清理 .autodev/ 中的 shell 遗留** — 移除 config.sh、prompts/、logs/
4. **[P1] 重写 README 为 Skill-only** — 移除所有 shell 章节和对比表
5. **[P2] 移动/归档 shell 时代文档** — 处理 docs/ 下的旧反馈文件
6. **[P2] 清理 SKILL.md 中的 shell 引用** — 移除比较措辞和不再需要的迁移章节
