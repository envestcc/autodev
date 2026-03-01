# 第 1 轮用户体验反馈

> **角色**：独立开发者 — 想在 GitHub 上发现并使用 autodev 来自动迭代自己的项目
> **关注重点**：GitHub 公开仓库最佳实践 + Copilot/Claude Code Skill 最佳实践

## 总体印象

从 GitHub 搜索发现 autodev 仓库后，第一印象是：README 清晰、核心文件 (`skill/SKILL.md`) 定位明确、仓库结构干净。但作为一个 public repo，缺少社区协作必备文件（CONTRIBUTING、Issue 模板等），README 没有视觉标识（badges），且纯中文内容限制了国际用户发现和使用。Skill 文件本身质量不错，但缺少版本标识和英文触发词覆盖。**评分：7.5/10**

## 功能逐项评测

### 功能 1: GitHub 仓库规范性

- **[P1] 无 CONTRIBUTING.md** — 开源协作标配，贡献者不知道如何参与
- **[P1] 无 `.github/ISSUE_TEMPLATE/`** — 没有 Issue 模板，维护者处理成本高
- **[P2] 无 `.github/PULL_REQUEST_TEMPLATE.md`** — PR 缺少检查清单
- **[P1] README 无 badges** — 缺乏专业度视觉信号（License、Stars 等）
- **[P2] .gitignore 过于简陋** — 仅 2 行，缺少常见 IDE/OS 文件模式
- **[P2] 无 CHANGELOG.md** — 用户不知道版本变更历史

### 功能 2: README 国际化

- **[P1] 纯中文 README** — GitHub 国际用户无法理解项目，搜索可见度低
- 建议：README.md 顶部添加语言切换，新增 README.en.md

### 功能 3: SKILL.md 最佳实践

- **[P2] 无版本号** — frontmatter 缺少 version 字段，用户无法判断是否需要更新
- **[P2] 英文触发词不足** — 缺少 "auto iterate"、"improve this project" 等常见表达
- **优点**：格式规范，兼容性声明清晰，指令结构化好

### 功能 4: 项目元数据

- **[P2] GitHub repo 缺少 topics** — 影响搜索发现
- **[P2] repo description 可优化** — 可添加英文摘要

## 发现的 Bug

1. [P1] 无 CONTRIBUTING.md — 开源协作门槛高
2. [P1] README 纯中文 — 国际用户无法发现和使用
3. [P1] README 无 badges — 缺乏专业度视觉信号
4. [P1] 无 Issue/PR 模板 — 社区协作效率低
5. [P2] .gitignore 不完整 — 容易提交垃圾文件
6. [P2] SKILL.md 无版本号 — 用户无法追踪更新

## 与上一轮对比

（首轮，无历史对比）

## 改进建议（按优先级）

1. **[P1] 添加 README badges** — License、Stars、最近提交等
2. **[P1] 创建英文 README** — README.md 顶部语言切换 + README.en.md
3. **[P1] 添加 CONTRIBUTING.md** — 贡献指南
4. **[P1] 添加 Issue/PR 模板** — .github/ 目录
5. **[P2] 完善 .gitignore** — 覆盖常见编辑器和 OS 文件
6. **[P2] SKILL.md 添加版本号和更多英文触发词**
