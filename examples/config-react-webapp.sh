# autodev 项目配置示例 —— React Web 应用
#
# 使用方法:
#   1. autodev init ~/dev/my-react-app
#   2. 将此文件内容覆盖到 ~/dev/my-react-app/.autodev/config.sh
#   3. autodev run ~/dev/my-react-app -n 5

PRODUCT_NAME="TaskFlow"
PRODUCT_DESC="一个基于 React 的团队任务管理 Web 应用，支持看板视图、任务分配、截止日期提醒和团队协作"
USER_PERSONA="一名 30 岁的项目经理，管理 8 人开发团队，每天使用任务管理工具 2-3 小时，之前用过 Trello 和 Notion"
SOURCE_DIRS="src"
DOCS_DIR_REL="docs"
CODE_CONVENTIONS="TypeScript + React 18，使用 Tailwind CSS，组件遵循函数式写法，使用 React Query 管理服务端状态"
MAX_ITEMS_PER_ROUND=8
COMMIT_PREFIX="improve: iteration"
FOCUS_AREAS="任务创建流程、看板拖拽体验、响应式布局、加载性能"
FEEDBACK_FORMAT="包含：总体评分(1-10)、核心流程体验、UI/UX 问题、性能观察、与竞品对比、改进建议"
