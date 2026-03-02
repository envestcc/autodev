# Contributing to autodev

感谢你对 autodev 项目的关注！欢迎各种形式的贡献。

Thank you for your interest in contributing to autodev!

## 如何贡献 / How to Contribute

### 报告 Bug / Report Bugs

请使用 [Bug Report](https://github.com/envestcc/autodev/issues/new?template=bug_report.md) 模板创建 Issue。

### 提议新功能 / Request Features

请使用 [Feature Request](https://github.com/envestcc/autodev/issues/new?template=feature_request.md) 模板创建 Issue。

### 提交代码 / Submit Code

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/my-feature`
3. 提交更改：`git commit -m 'feat: add my feature'`
4. 推送到分支：`git push origin feature/my-feature`
5. 创建 Pull Request

### PR 规范

- 每个 PR 聚焦一个改动
- 清晰描述改动内容和原因
- 如果修改了 `skill/SKILL.md`，请同时更新 README 中的相关说明

## 代码规范 / Code Standards

- **SKILL.md**：遵循 Claude Code / Copilot CLI Skill 文件规范
  - frontmatter 使用 YAML 格式
  - 指令使用 Markdown 格式
  - 保持中英文触发词同步
- **配置文件示例** (`examples/`)：使用标准 YAML，添加充分注释
- **文档**：README.md（中文）和 README.en.md（英文）保持同步

## 项目结构

```
autodev/
├── skill/SKILL.md       ← 核心 Skill 定义文件
├── README.md            ← 中文文档
├── README.en.md         ← English documentation
├── CONTRIBUTING.md      ← 贡献指南（本文件）
├── .github/             ← Issue/PR 模板
├── examples/            ← 配置示例
└── .autodev/            ← 自迭代配置
```

## 许可证 / License

贡献的代码将以 [MIT](LICENSE) 协议发布。
