# 第 1 轮改进计划

**基于反馈**: `docs/autodev/feedback_round_1.md`
**角色**: 独立开发者
**本轮改进上限**: 6 项

---

## 改进项列表

### P1-1: 重构 README，以 Skill 为主推方式

**问题描述**: README "快速开始" 完全是 shell 方式（README.md:29-58），Skill 方式在 148 行才出现且只有极简说明。产品重心已转向 Skill，文档应反映这一点。

**解决方案**:
1. 修改 `README.md`：
   - 将"快速开始"改为 Skill 方式（安装 + 使用）
   - 将 shell 脚本降级为"方式二：Shell 脚本（高级用法）"
   - 将 Skill vs Shell 对比表上移到更显眼位置
   - 补充 Skill 方式的配置说明和输出结构

**预期效果**: 新用户直接看到推荐方式，减少选择困惑，5 分钟内上手

---

### P1-2: 精简 Skill 初始化流程

**问题描述**: 初始化需回答 8 个问题（skill/SKILL.md:24-33），其中"迭代轮数"与触发命令重复，"代码规范"等对新用户太技术化。

**解决方案**:
1. 修改 `skill/SKILL.md` 初始化部分：
   - 删除"迭代轮数"问题（从用户触发语句中提取）
   - 将 8 个问题精简为 5 个核心问题：产品名称、产品简介、目标用户画像、源代码目录、重点关注领域
   - "代码规范"和"每轮改进项上限"改为自动推断 + 可选覆盖
   - 说明 AI 会自动检测技术栈

**预期效果**: 初始化从 8 步降为 5 步，降低 40% 上手摩擦

---

### P1-3: 添加 config.yaml 示例

**问题描述**: examples/ 只有 config.sh 示例，没有 Skill 方式使用的 config.yaml 示例。新用户无法参考。

**解决方案**:
1. 新增 `examples/config-miniprogram.yaml` — 基于现有 config-miniprogram.sh 转换
2. 新增 `examples/config-react-webapp.yaml` — 基于现有 config-react-webapp.sh 转换
3. 在 README 中引用这些示例

**预期效果**: 用户有清晰的 config.yaml 参考，减少配置出错

---

### P2-1: 增强动态策略描述

**问题描述**: SKILL.md 第 N>5 轮的策略为"随机选择一个新视角或极端用户场景"（skill/SKILL.md:91），过于模糊。

**解决方案**:
1. 修改 `skill/SKILL.md` Step 1 动态调整策略：
   - 为第 6-10 轮提供具体策略列表（如：第 6 轮-国际化/多语言、第 7 轮-极端数据量、第 8 轮-安全性审计等）
   - 保留"随机"作为 N>10 的兜底

**预期效果**: 长期迭代时每轮有明确方向，不会陷入重复

---

### P2-2: 添加 Claude Code 兼容性说明

**问题描述**: 用户要求兼容 Claude Code Skill，但 SKILL.md 和 README 均未提及兼容性。

**解决方案**:
1. 在 `skill/SKILL.md` 顶部 frontmatter 注释中添加兼容性说明
2. 在 `README.md` 安装部分添加 Claude Code 的安装路径说明（`~/.claude/skills/`）

**预期效果**: 用户知道如何在两种环境中使用

---

### P2-3: 补充 Skill 方式产出示例

**问题描述**: 用户无法预知 Skill 方式迭代后会产出什么样的文件。

**解决方案**:
1. 在 `README.md` 中添加"Skill 方式输出结构"示例
2. 引用现有的 `docs/autodev/` 产出作为真实示例

**预期效果**: 用户对产出有预期，增强使用信心
