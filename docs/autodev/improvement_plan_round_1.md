# 第 1 轮改进计划

## 基于反馈的改进项（6 项，max_items_per_round=6）

### 1. [P1] README 添加 badges 和语言切换
- **问题**：README 没有视觉标识，且纯中文限制国际用户
- **方案**：
  - README.md 顶部添加 License badge、GitHub stars badge
  - 添加语言切换链接 `[English](README.en.md) | 中文`
- **文件**：`README.md` 第 1 行前插入
- **预期效果**：提升专业感，方便国际用户切换语言

### 2. [P1] 创建英文 README
- **问题**：国际用户无法理解项目
- **方案**：创建 `README.en.md`，内容为 README.md 的英文翻译
- **文件**：新建 `README.en.md`
- **预期效果**：国际用户可理解项目并使用

### 3. [P1] 添加 CONTRIBUTING.md
- **问题**：贡献者不知道如何参与
- **方案**：创建 CONTRIBUTING.md，包含：如何提 Issue、PR 流程、代码规范、Skill 文件修改注意事项
- **文件**：新建 `CONTRIBUTING.md`
- **预期效果**：降低社区协作门槛

### 4. [P1] 添加 Issue 和 PR 模板
- **问题**：Issue/PR 格式随意，维护者处理成本高
- **方案**：
  - `.github/ISSUE_TEMPLATE/bug_report.md` — Bug 报告模板
  - `.github/ISSUE_TEMPLATE/feature_request.md` — 功能请求模板
  - `.github/PULL_REQUEST_TEMPLATE.md` — PR 检查清单
- **预期效果**：社区贡献有章可循

### 5. [P2] 完善 .gitignore
- **问题**：.gitignore 仅 2 行，缺少常见模式
- **方案**：添加 IDE 文件（.vscode、.idea）、OS 文件（Thumbs.db）、编辑器临时文件（*.swp）
- **文件**：编辑 `.gitignore`
- **预期效果**：避免无关文件提交

### 6. [P2] SKILL.md 添加版本号和英文触发词
- **问题**：用户无法判断 Skill 版本，英文触发覆盖不足
- **方案**：
  - frontmatter 添加 `version: 1.0.0`
  - 触发方式增加英文选项
- **文件**：`skill/SKILL.md` 第 1-8 行 frontmatter，第 16-19 行触发方式
- **预期效果**：版本可追踪，英文用户也能触发
