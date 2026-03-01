# 第 2 轮用户体验反馈

> **角色**：独立开发者 — 有自己的副业/开源项目，希望自动化产品迭代过程，减少重复工作
> **关注重点**：验证第 1 轮改进效果，深入测试核心流程细节

## 总体印象

第 1 轮的 6 项改进全部落地，效果显著。README 现在以 Skill 为主推方式，新用户阅读体验大幅提升；初始化从 8 步减到 5 步更加流畅；yaml 示例的加入让配置有据可依。**评分从 7/10 提升到 8/10。**

但深入测试核心流程后，我发现了一些细节问题：SKILL.md 中的 config.yaml 模板与自动推断逻辑存在矛盾，README 首段描述未更新以反映多平台兼容，且 Skill 对已有 config.sh 项目的迁移路径不明确。

## 功能逐项评测

### 功能 1: SKILL.md 初始化流程（已改进）

- **✅ 改进验证**：问题数从 8 减到 5，体验更流畅（skill/SKILL.md:25-31）
- **✅ 自动推断说明清晰**：明确列出了哪些项会自动推断（skill/SKILL.md:33-36）
- **问题 1**：config.yaml 模板仍包含 `code_conventions: "用户回答"`（skill/SKILL.md:52），但上文说代码规范会"自动检测"。模板应改为 `code_conventions: "auto"` 或添加注释说明此项可选
- **问题 2**：模板中 `iteration.max_rounds: 5` 是硬编码的（skill/SKILL.md:55），但迭代轮数应从用户触发语句提取。应标注此项会被运行时参数覆盖

### 功能 2: README 结构（已改进）

- **✅ 改进验证**：Skill 方式现在是"快速开始"首选（README.md:29），Shell 降为"方式二"（README.md:110）
- **✅ 对比表上移**：Skill vs Shell 表更易被看到（README.md:98-108）
- **✅ Claude Code 说明**：安装和前置条件都已提及（README.md:41, README.md:45）
- **问题 1**：README.md:5 首段仍只提"通过 Copilot CLI 驱动"，未体现 Claude Code 兼容性。建议改为"通过 Copilot CLI / Claude Code 驱动"
- **问题 2**：README.md:117 shell 安装仍使用 `<your-user>` 占位符，真实用户会困惑。应提供实际仓库地址或说明需要替换

### 功能 3: 动态策略（已改进）

- **✅ 改进验证**：策略扩展到 10 轮，每轮有明确方向（skill/SKILL.md:89-99）
- **优点**：第 6-10 轮的视角选择合理（国际化→压力测试→安全→开发者体验→回归测试）
- **问题**：第 10 轮"回归测试"与第 2 轮"验证上一轮问题"有部分重叠。建议第 10 轮描述更具体——如"全量回归 + 产出质量评估总结报告"

### 功能 4: config.yaml 示例（新增）

- **✅ 改进验证**：新增的两个 yaml 示例（examples/config-miniprogram.yaml, examples/config-react-webapp.yaml）格式规范、注释清晰
- **问题**：示例文件顶部使用 `#` 注释说明"使用方法"，但没有提到可以通过编辑已有的 config.yaml 来自定义，只说"首次运行时自动生成"。建议补充"也可手动创建或编辑"

### 功能 5: Skill 与 Shell 共存场景

- **问题**：如果一个项目已经用 shell 方式运行过（有 .autodev/config.sh），再用 Skill 方式会创建 config.yaml 并行存在。SKILL.md 没有说明如何处理这种情况——是忽略 config.sh？自动迁移？还是提示用户？
- **建议**：在 SKILL.md 初始化部分添加：如果检测到 config.sh 存在，询问用户是否基于 config.sh 迁移生成 config.yaml

## 发现的 Bug

1. [P1] **config.yaml 模板与自动推断矛盾** — skill/SKILL.md:52 模板写 `code_conventions: "用户回答"` 但文档说会自动推断
2. [P2] **README 首段未更新** — README.md:5 仅提 Copilot CLI，未提 Claude Code
3. [P2] **Shell 安装地址占位符** — README.md:117 `<your-user>` 不是有效的 git 地址

## 与上一轮对比

- ✅ 已解决：README 以 Skill 为主推（P1-1）
- ✅ 已解决：初始化流程精简至 5 步（P1-2）
- ✅ 已解决：config.yaml 示例已添加（P1-3）
- ✅ 已解决：动态策略扩展至 10 轮（P2-1）
- ✅ 已解决：Claude Code 兼容性说明（P2-2）
- ✅ 已解决：Skill 产出结构示例（P2-3）
- 🆕 新发现：config.yaml 模板与自动推断逻辑矛盾
- 🆕 新发现：README 首段未更新
- 🆕 新发现：Skill 与 Shell 共存迁移路径不明确

## 改进建议（按优先级）

1. **[P1] 修正 config.yaml 模板** — 将 `code_conventions` 改为可选项并添加注释，`max_rounds` 标注会被运行时覆盖
2. **[P1] 添加 config.sh → config.yaml 迁移说明** — 在 SKILL.md 初始化部分处理已有 config.sh 的场景
3. **[P2] 更新 README 首段** — 体现多平台兼容
4. **[P2] 修正 shell 安装地址** — 移除占位符或给出更通用的说明
5. **[P2] 细化第 10 轮策略** — 区分于第 2 轮验证
