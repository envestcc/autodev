# Persona 模板库 / Persona Templates

预置的用户画像模板，覆盖常见产品场景。直接复制到你的 `.autodev/config.yaml` 中使用。

Pre-built user persona templates for common product types. Copy into your `.autodev/config.yaml`.

| 模板 / Template | 适用场景 / Use Case | Personas |
|---|---|---|
| [ecommerce.yaml](ecommerce.yaml) | 电商平台、在线商城 | 普通买家、高频买家、卖家、客服 |
| [saas.yaml](saas.yaml) | B2B SaaS、企业工具 | 免费试用用户、付费用户、企业管理员 |
| [mobile-app.yaml](mobile-app.yaml) | 移动端 App、小程序 | 年轻用户、中年用户、无障碍用户、弱网用户 |
| [developer-tool.yaml](developer-tool.yaml) | CLI、SDK、API、DevOps | 初级/资深开发者、CI/CD 集成者、开源贡献者 |

## 使用方法 / Usage

```yaml
# 在 .autodev/config.yaml 中，从模板复制需要的 persona：
personas:
  - name: "初级开发者"
    description: "1-2年经验，熟悉基本命令行，不熟悉高级配置和底层原理"
    focus: ["安装流程", "Quick Start", "错误提示可读性", "文档准确性"]
```

## 贡献模板 / Contributing

欢迎提交新的 persona 模板！请遵循现有格式，每个文件对应一个产品场景。
