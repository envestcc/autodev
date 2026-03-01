# 第 2 轮改进计划（聚焦 GitHub 曝光和获星）

## 核心目标：让路过的开发者 3 秒内理解价值，10 秒内想 star

### 1. [P0] README 添加 "Why autodev" 价值主张区块
- **问题**：当前 README 直接跳到 "工作原理"，没有 hook — 路过的开发者不知道为什么要 star
- **方案**：在标题下方添加一句精炼 tagline + 3 个核心卖点 bullet（用 emoji 增加视觉吸引力）
- **文件**：`README.md` 第 9-11 行、`README.en.md` 同步
- **预期效果**：3 秒理解价值，提升 star 转化率

### 2. [P0] 设置 GitHub repo topics + description
- **问题**：repo 没有 topics，在 GitHub Explore/搜索中不可见
- **方案**：`gh repo edit` 设置 description 和 topics（ai, copilot, automation, developer-tools, claude, productivity, iteration, code-review）
- **预期效果**：出现在 topic 页面，搜索排名提升

### 3. [P0] README 添加一键安装命令（零门槛试用）
- **问题**：当前安装需先 clone 再 cp — 摩擦太大，路过用户不会试
- **方案**：添加 `curl` 一行命令直接从 GitHub raw 下载到目标目录
- **文件**：`README.md` 安装区、`README.en.md` 同步
- **预期效果**：30 秒内完成安装，降低试用门槛

### 4. [P1] README 添加效果演示区块
- **问题**：没有展示 autodev 实际运行效果，用户无法想象使用场景
- **方案**：添加一个"实际运行效果"区块，展示一轮迭代的输出摘要（文字版 demo）
- **文件**：`README.md`、`README.en.md`
- **预期效果**：用户看到实际输出后更有信心 star 和试用

### 5. [P1] 同步 SKILL.md 触发词 + 正文英文触发
- **问题**：frontmatter 有英文触发词但正文列表没同步
- **方案**：skill/SKILL.md:18-21 补齐英文触发词
- **预期效果**：英文用户也能顺利触发，扩大用户群

### 6. [P2] examples/ 添加英文注释
- **问题**：示例文件纯中文注释，英文用户无法参考
- **方案**：每个 YAML 添加双语注释
- **预期效果**：国际用户可直接复制使用
