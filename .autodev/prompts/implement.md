请阅读改进计划: {{PLAN_FILE}}

**产品**：{{PRODUCT_NAME}}
**代码规范**：{{CODE_CONVENTIONS}}
**当前迭代**：第 {{ROUND}}/{{TOTAL_ROUNDS}} 轮

按照计划逐项实施改进。要求:

1. 严格按照优先级顺序实施
2. 每修改一个文件，确保：
   - 代码语法正确、不引入新 bug
   - 保持与现有代码风格一致（{{CODE_CONVENTIONS}}）
   - 最小化修改范围，不改动计划之外的代码
3. 所有改动完成后，做一次 git commit，message 格式:
   "{{COMMIT_PREFIX}} 第{{ROUND}}轮 - [本轮改进要点简述]"
4. 如果某项改进实施风险太大，跳过并在 commit message 中说明

开始实施。
