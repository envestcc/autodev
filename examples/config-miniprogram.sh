# autodev 项目配置示例 —— 微信小程序（数学错题本）
#
# 使用方法:
#   1. autodev init ~/dev/edu-x
#   2. 将此文件内容覆盖到 ~/dev/edu-x/.autodev/config.sh
#   3. autodev run ~/dev/edu-x -n 5

PRODUCT_NAME="数学错题本"
PRODUCT_DESC="一个微信小程序，帮助高中生通过拍照快速录入数学错题，并通过闪卡复习、知识点统计等功能提升复习效率"
USER_PERSONA="一名正在备战高考的高三理科生，数学成绩约100-110分（满分150），弱项为解析几何和三角函数，曾经用过实体错题本但因为太费时间而放弃"
SOURCE_DIRS="miniprogram"
DOCS_DIR_REL="docs"
CODE_CONVENTIONS="微信小程序规范（WXML/WXSS/JS），使用微信云开发，遵循项目现有代码风格"
MAX_ITEMS_PER_ROUND=6
COMMIT_PREFIX="feat: 迭代改进"
FOCUS_AREAS="错题录入效率、复习体验、数据统计准确性、新用户上手体验"
FEEDBACK_FORMAT="包含：总体印象、各功能点评（录入/复习/统计/列表）、Bug 列表、改进建议（按 P0/P1/P2 优先级排序）"
