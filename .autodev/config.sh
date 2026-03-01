# ┌──────────────────────────────────────────────────────┐
# │  autodev 自举配置 — 用 autodev 迭代 autodev 自身       │
# └──────────────────────────────────────────────────────┘

# 产品名称
PRODUCT_NAME="autodev"

# 产品简介（一两句话）
PRODUCT_DESC="一个 Bash CLI 工具，通过 Copilot CLI 驱动「模拟用户试用 → 改进计划 → 实施改进」的自动循环，实现产品无人值守迭代升级"

# 模拟用户画像（AI 将扮演此角色进行试用）
USER_PERSONA="一名独立开发者，有 3 年 shell 脚本经验，正在用 autodev 自动迭代自己的 React 项目。之前手动跟 Copilot 对话做迭代，现在想用 autodev 自动化这个过程。期望工具稳定可靠、配置简单、输出清晰"

# 源代码目录（相对于项目根目录，多个用空格分隔）
SOURCE_DIRS=". examples tests"

# 文档输出目录（相对于项目根目录）
DOCS_DIR_REL="docs"

# 代码规范（帮助 AI 保持风格一致）
CODE_CONVENTIONS="Bash (兼容 bash 3.2+/macOS 默认)，使用 set -euo pipefail，函数用 snake_case，shellcheck 无警告，保持脚本单文件可分发"

# 每轮最多改进项数量
MAX_ITEMS_PER_ROUND=5

# Git commit 前缀
COMMIT_PREFIX="feat(bootstrap): self-iteration"

# 重点关注领域（引导 AI 关注特定方面）
FOCUS_AREAS="CLI 易用性、错误处理健壮性、配置灵活性、文档完整性、跨平台兼容性(macOS/Linux)、自举能力(能否顺利迭代自身)"

# 反馈报告格式
FEEDBACK_FORMAT="包含：总体印象、安装与初始化体验、run 执行体验、config 配置体验、错误场景测试、与手动迭代的对比、Bug 列表、改进建议（按优先级排序）"
