# 第 1 轮用户体验反馈

> **角色**：独立开发者 — 有自己的副业/开源项目，希望自动化产品迭代过程，减少重复工作
> **关注重点**：全面体验，覆盖所有功能，建立基线（用户体验、易用性、上手引导、文档质量）

## 总体印象

autodev 的 Copilot Skill 方式是一个极具创新性的理念——让 AI 自动迭代改进产品代码，形成闭环。SKILL.md 的设计逻辑清晰，三步循环（反馈→计划→实施）合理可行，动态调整策略和多 Persona 轮换是亮点。**评分：7/10**

但作为一个想快速上手的独立开发者，我遇到了以下主要摩擦点：README 仍以 shell 脚本方式为主要推荐，Skill 方式被放在"方式二"且缺乏详细说明；SKILL.md 中的初始化流程需要回答 8 个问题过于冗长；config.yaml 与 config.sh 两套配置格式并存造成混乱；缺少实际运行效果的示例让我无法预判产出质量。

## 功能逐项评测

### 功能 1: SKILL.md 定义（skill/SKILL.md）

- **优点**：frontmatter 格式规范，触发关键词覆盖中英文；迭代流程三步骤划分清晰；动态调整策略（第1-5轮各有侧重）设计精巧
- **问题 1**：初始化流程要求依次回答 8 个问题（skill/SKILL.md:24-33），其中"迭代轮数"(问题6)与用户触发时说的"N轮"重复，且有些问题对新用户来说过于细节化（如"代码规范"、"反馈报告格式"）
- **问题 2**：config.yaml 模板（skill/SKILL.md:37-58）缺少 `feedback_format` 字段，而 config.sh 有此字段。两套配置系统不统一
- **问题 3**：Step 1 的动态调整策略只预设了 5 轮（skill/SKILL.md:84-91），第 N>5 轮描述为"随机选择一个新视角"，策略过于模糊
- **问题 4**：中途控制功能（skill/SKILL.md:188-193）如"暂停"、"调整方向"等，仅有文字描述，没有说明 AI 如何检测这些指令（依赖自然语言理解，但未给出使用示例）

### 功能 2: README 文档（README.md）

- **问题 1**：README.md:29-58 "快速开始"完全是 shell 脚本方式，Skill 方式在 README.md:148 才出现，标题为"方式二"。但用户说 Skill 是推荐方式，文档与实际推荐不一致
- **问题 2**：README.md:60-83 命令参考、README.md:89-125 配置说明都是 shell 方式的详细文档，Skill 方式只有 5 行安装说明和 1 行使用示例（README.md:153-165）
- **问题 3**：README.md:127-146 的"输出结构"示例使用 `docs/` 目录，但 SKILL.md 默认使用 `docs/autodev/`，不一致
- **问题 4**：README.md 的 Skill vs Shell 对比表（README.md:172-180）信息有价值，但位置太靠后，新用户可能看不到就已经选择了 shell 方式

### 功能 3: Shell 脚本（autodev.sh）

- **优点**：代码质量高，有完善的错误处理、重试机制、配置验证、增量执行等（第1轮改进已实施）
- **观察**：autodev.sh 有 686 行，功能完备，但用户说这不是推荐方式了。如果 Skill 是主推方向，shell 脚本的定位需要重新考虑

### 功能 4: 测试（tests/test_basic.sh）

- **优点**：测试结构清晰，覆盖了 init/run/status/错误处理等场景
- **问题**：仅测试 shell 脚本方式，对 Skill 方式无任何测试或验证机制
- **问题**：tests/test_basic.sh:66 使用 `sed -i.bak` 然后删除 .bak 文件，虽然兼容 macOS 但不够优雅

### 功能 5: 示例配置（examples/）

- **优点**：提供了小程序和 React 两种场景的配置示例，注释清晰
- **问题**：示例全部是 config.sh 格式，没有 config.yaml（Skill 方式）的示例

## 发现的 Bug

1. [P1] **配置格式不统一** — SKILL.md 使用 config.yaml，其余所有文件使用 config.sh，两者字段不完全对应。skill/SKILL.md:37-58 vs .autodev/config.sh
2. [P1] **README 推荐方式与实际不符** — README 主推 shell 方式，但用户认为 Skill 是推荐方式。README.md:29-58 vs README.md:148-165
3. [P2] **Skill 初始化问题 6 冗余** — "迭代轮数"在用户触发时已指定（如"迭代 3 轮"），初始化再问一次是冗余的。skill/SKILL.md:31
4. [P2] **示例缺失** — examples/ 目录无 config.yaml 示例，无 Skill 方式产出的示例文档

## 与上一轮对比

- ✅ 已解决：前置条件检查（autodev.sh 已添加 check_prerequisites）
- ✅ 已解决：增量执行恢复（autodev.sh 已添加 --resume-from）
- ✅ 已解决：copilot 重试机制（autodev.sh 已添加 run_copilot 重试）
- ✅ 已解决：配置验证器（autodev.sh 已添加 validate_config）
- ✅ 已解决：status 命令增强（autodev.sh 已增强 cmd_status）
- 🆕 新发现：Skill 方式与 Shell 方式文档/配置不统一
- 🆕 新发现：README 结构未跟上产品重心转移（Skill 为主）
- 🆕 新发现：缺少 Skill 方式的示例和产出样例

## 改进建议（按优先级）

1. **[P1] 重构 README，以 Skill 为主推方式** — 将"快速开始"改为 Skill 方式，shell 脚本降级为"高级用法/替代方案"
2. **[P1] 统一配置格式** — 为 Skill 方式补充 config.yaml 示例，或在 SKILL.md 中说明与 config.sh 的关系
3. **[P1] 精简 Skill 初始化流程** — 减少必问问题（合并或设置智能默认值），删除冗余的"迭代轮数"问题
4. **[P2] 添加 Skill 产出示例** — 在 examples/ 或 README 中展示一个完整的 Skill 迭代产出（feedback + plan 文件样例）
5. **[P2] 增强 SKILL.md 动态策略** — 为 N>5 轮提供更具体的策略列表，而非"随机选择"
6. **[P2] 添加 claude code 兼容说明** — 用户提到需要兼容 claude code skill，但当前文档中没有提及
