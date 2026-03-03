# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [2.1.0] - 2026-03-03

### Added
- **验证 Agent（Step 4）**：可选的独立验证步骤，检查改进是否真正解决问题和回归（`enable_verification: true`）
- **dry-run 模式**：仅执行分析（Step 1 + 2），不修改代码（`dry_run: true` 或说"先分析不要改代码"）
- **生命周期 Hook**：`before_step3`、`after_each_item`、`after_step3`、`after_round` 自定义命令
- **聚焦模式**：`focus_paths` / `exclude_paths` 限制分析和修改范围，适合大型项目
- **并发锁**：`.autodev/.lock` 防止多实例同时运行
- **迭代总结报告**：全部轮次完成后输出累计统计、问题趋势、各轮概况
- **Persona 模板库**：`personas/` 目录预置电商、SaaS、移动端、开发者工具 4 套模板
- **关键代码索引**：feedback 报告新增章节，供后续 Agent 精准定位代码

### Changed
- **逐项 commit**：Step 3 改为每个改进项独立 commit，替代原来的批量 commit
- **config schema 校验**：启动前验证必填字段和格式，提前发现配置错误
- **严格输出校验**：v2 Orchestrator 检查 Agent 输出的必要章节和格式，失败自动重试一次

## [2.0.0] - 2026-02-26

### Added
- **v2 多 Agent 架构**：通过 sub-agent 实现 context 隔离和模型分工
- **Agent 模型选择指南**：详细的模型推荐和选型依据
- **v1 回退机制**：task 工具不可用时自动降级为单 Agent 模式

## [1.0.0] - 2026-02-20

### Added
- 初始版本：单 Agent 产品自动迭代引擎
- 模拟用户试用 → 设计改进计划 → 实施代码改进 三步循环
- 多 Persona 支持与轮换
- 动态策略表（10 轮不同关注点）
- 智能优先级调整
- 中途控制命令
- 迭代文档管理（保留/gitignore/删除）
