# 第 3 轮改进计划

**基于反馈**: `docs/autodev/feedback_round_3.md`
**角色**: 独立开发者
**方向**: 废弃 Shell 脚本，全面拥抱 Skill
**本轮改进上限**: 6 项

---

## 改进项列表

### P0-1: 删除 autodev.sh 及 shell 测试

**问题描述**: 686 行的 autodev.sh 仍是仓库最显眼的文件，新用户误以为这是产品本体。tests/test_basic.sh 仅测试 shell 脚本。

**解决方案**:
1. 删除 `autodev.sh`
2. 删除 `tests/test_basic.sh`
3. 删除 `tests/` 目录（如果变空）

**预期效果**: 仓库根目录干净，新用户一眼看到 `skill/SKILL.md` 是核心

---

### P0-2: 删除 shell 格式示例

**问题描述**: examples/ 中 .sh 和 .yaml 混杂，造成困惑。

**解决方案**:
1. 删除 `examples/config-miniprogram.sh`
2. 删除 `examples/config-react-webapp.sh`
3. 仅保留 .yaml 示例

**预期效果**: examples/ 目录只有 yaml 文件，与 Skill 方式一致

---

### P1-1: 清理 .autodev/ 中的 shell 遗留

**问题描述**: .autodev/ 中 config.sh、prompts/、logs/ 均为 shell 时代产物，与 config.yaml 并存造成混乱。

**解决方案**:
1. 删除 `.autodev/config.sh`
2. 删除 `.autodev/prompts/` 整个目录
3. 删除 `.autodev/logs/` 整个目录（已在 .gitignore 中）
4. 更新 `.autodev/.gitignore`（如存在）

**预期效果**: .autodev/ 只剩 config.yaml 和 .gitignore

---

### P1-2: 重写 README 为 Skill-only

**问题描述**: README 仍有"方式二：Shell 脚本"整章（README.md:110-178）和 Skill vs Shell 对比表。

**解决方案**:
1. 移除 README.md:98-178（对比表 + 整个 Shell 章节）
2. "快速开始" 标题简化为"快速开始"（去掉"Copilot Skill 方式，推荐"后缀）
3. 各处 "Skill 方式" 措辞简化（已是唯一方式，不需要区分）

**预期效果**: README 简洁聚焦，只讲一种方式

---

### P2-1: 归档 shell 时代文档

**问题描述**: docs/feedback_round_1.md 和 docs/improvement_plan_round_1.md 是 shell 时代产物，路径与当前 docs/autodev/ 不一致。

**解决方案**:
1. 删除 `docs/feedback_round_1.md`
2. 删除 `docs/improvement_plan_round_1.md`
3. 它们的历史贡献已记录在 git 历史中

**预期效果**: docs/ 目录结构干净，只有 docs/autodev/ 子目录

---

### P2-2: 清理 SKILL.md 中的 shell 引用

**问题描述**: SKILL.md 中有"已有 config.sh 的项目迁移"章节和"这是比 shell 脚本强大之处"等比较措辞。

**解决方案**:
1. 移除 `skill/SKILL.md` 中的"已有 config.sh 的项目迁移"章节（第 66-71 行）
2. 移除"（这是比 shell 脚本强大之处）"措辞（第 94 行）
3. 保持 SKILL.md 自信、独立，不再与废弃方式比较

**预期效果**: SKILL.md 是独立完整的产品定义，无历史包袱
