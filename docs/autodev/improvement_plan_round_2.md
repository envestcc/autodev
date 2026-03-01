# 第 2 轮改进计划

**基于反馈**: `docs/autodev/feedback_round_2.md`
**角色**: 独立开发者
**本轮改进上限**: 6 项

---

## 改进项列表

### P1-1: 修正 SKILL.md config.yaml 模板

**问题描述**: 模板中 `code_conventions: "用户回答"` 与文档声明的"自动推断"矛盾；`max_rounds` 硬编码但文档说从触发语句提取。

**解决方案**:
1. 修改 `skill/SKILL.md` 第 40-62 行的 config.yaml 模板
2. `code_conventions` 改为注释说明可选：`# code_conventions: "自动检测，如需覆盖请取消注释"`
3. `max_rounds` 添加注释：`# 运行时通过 "迭代 N 轮" 覆盖`
4. 清理模板使其与自动推断逻辑一致

**预期效果**: 模板与文档逻辑一致，用户不会困惑

---

### P1-2: 添加 config.sh 迁移说明

**问题描述**: Skill 与 Shell 共存时，已有 config.sh 的项目如何迁移到 config.yaml 不明确。

**解决方案**:
1. 在 `skill/SKILL.md` 初始化部分（"第一次使用"之后）添加迁移说明段落
2. 内容：如果检测到 `.autodev/config.sh` 已存在，提示用户选择是否基于现有配置生成 config.yaml

**预期效果**: 已有 shell 方式用户能平滑迁移到 Skill 方式

---

### P2-1: 更新 README 首段

**问题描述**: README.md:5 首段仅提 Copilot CLI，未体现已支持的 Claude Code 兼容性。

**解决方案**:
1. 修改 `README.md` 第 5 行
2. "通过 Copilot CLI 驱动" → "通过 Copilot CLI / Claude Code 驱动"

**预期效果**: 首段准确反映产品能力

---

### P2-2: 修正 shell 安装地址

**问题描述**: README.md:117 的 `<your-user>` 占位符让用户困惑。

**解决方案**:
1. 修改 `README.md` shell 安装部分
2. 改为通用说明：`git clone <本仓库地址>`，或使用 GitHub 风格的相对引用

**预期效果**: 安装说明直接可用

---

### P2-3: 细化第 10 轮策略

**问题描述**: 第 10 轮"回归测试"与第 2 轮"验证上一轮问题"部分重叠。

**解决方案**:
1. 修改 `skill/SKILL.md` 第 10 轮策略描述
2. 改为"全量回归测试 + 产出迭代总结报告，评估整体改进效果和剩余技术债"

**预期效果**: 各轮策略无重叠，第 10 轮有总结性价值
