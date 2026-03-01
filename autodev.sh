#!/usr/bin/env bash
#
# autodev — AI 驱动的产品自动迭代改进引擎
#
# 通过 Copilot CLI 驱动「模拟用户试用 → 设计改进计划 → 实施代码改进」循环。
# 适用于任何类型的产品项目。
#

set -euo pipefail

VERSION="0.1.0"
PROG_NAME="autodev"
CONFIG_DIR_NAME=".autodev"

# ── 颜色 ──────────────────────────────────────────────
if [[ -t 1 ]]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
  BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; BOLD=''; RESET=''
fi

# ── 默认值 ────────────────────────────────────────────
TOTAL_ROUNDS=5
START_ROUND=1
MODEL="claude-sonnet-4"
DRY_RUN=false
RESUME_FROM=""

# ── 辅助函数 ──────────────────────────────────────────
timestamp() { date '+%Y-%m-%d %H:%M:%S'; }

info()  { echo -e "${BLUE}[INFO]${RESET}  $1"; }
ok()    { echo -e "${GREEN}[OK]${RESET}    $1"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET}  $1"; }
err()   { echo -e "${RED}[ERROR]${RESET} $1" >&2; }
die()   { err "$1"; exit 1; }

banner() {
  echo -e "${CYAN}${BOLD}"
  cat <<'EOF'
   ╔═══════════════════════════════════════════╗
   ║         autodev · AI 自动迭代引擎         ║
   ╚═══════════════════════════════════════════╝
EOF
  echo -e "${RESET}"
}

log_step() {
  echo ""
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "  ${BOLD}[$(timestamp)]${RESET} $1"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
}

resolve_path() {
  cd "$1" 2>/dev/null && pwd || { err "目录不存在: $1"; exit 1; }
}

check_prerequisites() {
  local project_dir="$1"
  
  # 检查copilot命令是否可用
  command -v copilot >/dev/null || die "Copilot CLI not found. Please install: https://github.com/github/copilot-cli"
  
  # 检查当前目录是否为git仓库
  cd "$project_dir" 2>/dev/null || die "目录不存在: $project_dir"
  git rev-parse --git-dir >/dev/null 2>&1 || die "Not a git repository. Please run 'git init' first"
  
  # 检查目标目录写入权限
  [[ -w "$project_dir" ]] || die "No write permission to project directory"
  
  info "前置条件检查通过 ✓"
}

validate_config() {
  # 检查必填项
  [[ "$PRODUCT_NAME" != "我的产品" ]] || die "请编辑config.sh设置 PRODUCT_NAME"
  [[ "$PRODUCT_DESC" != "产品简介" ]] || die "请编辑config.sh设置 PRODUCT_DESC"  
  [[ "$USER_PERSONA" != "用户画像" ]] || die "请编辑config.sh设置 USER_PERSONA"
  
  # 检查路径有效性
  [[ -d "$PROJECT_DIR/$SOURCE_DIRS" ]] || warn "源码目录不存在: $SOURCE_DIRS"
  
  # 检查数值范围
  [[ "$MAX_ITEMS_PER_ROUND" -gt 0 && "$MAX_ITEMS_PER_ROUND" -le 20 ]] || die "MAX_ITEMS_PER_ROUND 应在1-20之间"
  
  info "配置验证通过 ✓"
}

save_step_status() {
  local round="$1" step="$2" status="$3"
  local status_file="${LOG_DIR}/round_${round}_status.json"
  echo "{\"round\":$round,\"step\":$step,\"status\":\"$status\",\"timestamp\":\"$(timestamp)\"}" > "$status_file"
}

get_last_completed_step() {
  local round="$1"
  local status_file="${LOG_DIR}/round_${round}_status.json"
  if [[ -f "$status_file" ]]; then
    local status
    status=$(grep -o '"status":"[^"]*"' "$status_file" | cut -d'"' -f4)
    local step
    step=$(grep -o '"step":[0-9]*' "$status_file" | cut -d':' -f2)
    if [[ "$status" == "completed" ]]; then
      echo "$step"
    else
      echo "0"
    fi
  else
    echo "0"
  fi
}

get_round_status() {
  local round="$1"
  local logs_dir="$2"
  local status_file="${logs_dir}/round_${round}_status.json"
  
  if [[ -f "$status_file" ]]; then
    local status
    status=$(grep -o '"status":"[^"]*"' "$status_file" | cut -d'"' -f4)
    case "$status" in
      completed) echo "success" ;;
      failed) echo "failed" ;;
      running) echo "running" ;;
      *) echo "unknown" ;;
    esac
  else
    echo "not_started"
  fi
}

get_round_timestamp() {
  local round="$1"
  local logs_dir="$2"
  local status_file="${logs_dir}/round_${round}_status.json"
  
  if [[ -f "$status_file" ]]; then
    grep -o '"timestamp":"[^"]*"' "$status_file" | cut -d'"' -f4
  else
    echo "未运行"
  fi
}

get_failure_reason() {
  local round="$1"
  local logs_dir="$2"
  local status_file="${logs_dir}/round_${round}_status.json"
  
  if [[ -f "$status_file" ]]; then
    local step
    step=$(grep -o '"step":[0-9]*' "$status_file" | cut -d':' -f2)
    case "$step" in
      1) echo "模拟用户试用失败" ;;
      2) echo "设计改进计划失败" ;;
      3) echo "实施代码改进失败" ;;
      *) echo "未知错误" ;;
    esac
  else
    echo "状态文件不存在"
  fi
}

# ── 用法 ──────────────────────────────────────────────
usage() {
  cat <<USAGE
${PROG_NAME} v${VERSION} — AI 驱动的产品自动迭代改进引擎

用法:
  ${PROG_NAME} init   <项目路径>                  初始化配置
  ${PROG_NAME} run    <项目路径> [选项]            运行迭代
  ${PROG_NAME} status <项目路径>                  查看迭代状态
  ${PROG_NAME} --help                            显示帮助
  ${PROG_NAME} --version                         显示版本

run 选项:
  -n, --rounds <N>      迭代轮数 (默认: 5)
  -m, --model <model>   AI 模型 (默认: claude-sonnet-4)
  -s, --start <N>       从第 N 轮开始 (默认: 1)
  --resume-from <step>  从指定步骤恢复 (round<N>/step<N>)
  --dry-run             只打印 prompt，不实际执行

示例:
  ${PROG_NAME} init ~/dev/my-app
  ${PROG_NAME} run ~/dev/my-app -n 3
  ${PROG_NAME} run ~/dev/my-app -n 5 -m claude-opus-4.6
  ${PROG_NAME} run ~/dev/my-app --start 3
  ${PROG_NAME} run ~/dev/my-app --resume-from step2
  ${PROG_NAME} run ~/dev/my-app --resume-from round2
  ${PROG_NAME} status ~/dev/my-app
USAGE
}

# ══════════════════════════════════════════════════════
#  Copilot 调用
# ══════════════════════════════════════════════════════
run_copilot() {
  local prompt="$1"
  local log_file="$2"
  local max_retries=3
  local retry=0

  if $DRY_RUN; then
    echo -e "${CYAN}──── PROMPT ────${RESET}"
    echo "$prompt"
    echo -e "${CYAN}──── END ────${RESET}"
    echo "(dry-run: 跳过执行)"
    return 0
  fi

  while [ $retry -lt $max_retries ]; do
    cd "$PROJECT_DIR"
    copilot "${COPILOT_FLAGS[@]}" -p "$prompt" 2>&1 | tee "$log_file"
    local exit_code=${PIPESTATUS[0]}
    
    if [ $exit_code -eq 0 ]; then
      return 0
    fi
    
    # 分析错误类型
    local error_msg
    error_msg=$(tail -10 "$log_file" | grep -i "network\|timeout\|rate.limit\|connection" || true)
    
    if [[ -n "$error_msg" && $retry -lt $((max_retries - 1)) ]]; then
      local wait_time=$((retry * 30 + 30))
      warn "网络错误，等待${wait_time}秒后重试 ($((retry+1))/$max_retries)"
      sleep $wait_time
      retry=$((retry + 1))
    else
      err "copilot 退出码: $exit_code (详情见 $log_file)"
      return $exit_code
    fi
  done
  
  err "copilot 重试次数已达上限"
  return 1
}

# ══════════════════════════════════════════════════════
#  Prompt 模板引擎
# ══════════════════════════════════════════════════════
load_prompt_template() {
  local step_name="$1"
  local custom_file="${AUTODEV_DIR}/prompts/${step_name}.md"
  if [ -f "$custom_file" ]; then
    cat "$custom_file"
  else
    err "Prompt 模板不存在: ${custom_file}"
    exit 1
  fi
}

render_prompt() {
  local template="$1"
  # 使用 awk 替代多次 sed 调用，一次性完成所有变量替换
  echo "$template" | awk \
    -v product_name="$PRODUCT_NAME" \
    -v product_desc="$PRODUCT_DESC" \
    -v user_persona="$USER_PERSONA" \
    -v source_dirs="$SOURCE_DIRS" \
    -v docs_dir_rel="$DOCS_DIR_REL" \
    -v code_conv="$CODE_CONVENTIONS" \
    -v max_items="$MAX_ITEMS_PER_ROUND" \
    -v round="$CURRENT_ROUND" \
    -v total="$TOTAL_ROUNDS" \
    -v fb_file="$CURRENT_FEEDBACK_FILE" \
    -v plan_file="$CURRENT_PLAN_FILE" \
    -v commit_pfx="$COMMIT_PREFIX" \
    -v focus="$FOCUS_AREAS" \
    -v fb_fmt="$FEEDBACK_FORMAT" \
    '{
      gsub(/\{\{PRODUCT_NAME\}\}/, product_name)
      gsub(/\{\{PRODUCT_DESC\}\}/, product_desc)
      gsub(/\{\{USER_PERSONA\}\}/, user_persona)
      gsub(/\{\{SOURCE_DIRS\}\}/, source_dirs)
      gsub(/\{\{DOCS_DIR\}\}/, docs_dir_rel)
      gsub(/\{\{CODE_CONVENTIONS\}\}/, code_conv)
      gsub(/\{\{MAX_ITEMS\}\}/, max_items)
      gsub(/\{\{ROUND\}\}/, round)
      gsub(/\{\{TOTAL_ROUNDS\}\}/, total)
      gsub(/\{\{FEEDBACK_FILE\}\}/, fb_file)
      gsub(/\{\{PLAN_FILE\}\}/, plan_file)
      gsub(/\{\{COMMIT_PREFIX\}\}/, commit_pfx)
      gsub(/\{\{FOCUS_AREAS\}\}/, focus)
      gsub(/\{\{FEEDBACK_FORMAT\}\}/, fb_fmt)
      print
    }'
}

# ══════════════════════════════════════════════════════
#  子命令: init
# ══════════════════════════════════════════════════════
cmd_init() {
  local target="$1"
  local ad_dir="${target}/${CONFIG_DIR_NAME}"

  if [ -f "${ad_dir}/config.sh" ]; then
    warn "${ad_dir}/config.sh 已存在。如需重新初始化，请先删除 ${CONFIG_DIR_NAME}/ 目录。"
    exit 1
  fi

  mkdir -p "${ad_dir}/prompts"

  # ── config.sh ──
  cat > "${ad_dir}/config.sh" <<'CONFIG'
# ┌──────────────────────────────────────────────────────┐
# │  autodev 项目配置                                     │
# │  编辑以下变量以适配你的产品                              │
# └──────────────────────────────────────────────────────┘

# 产品名称
PRODUCT_NAME="我的产品"

# 产品简介（一两句话）
PRODUCT_DESC="一个 XXX 应用，帮助用户 XXX"

# 模拟用户画像（AI 将扮演此角色进行试用）
USER_PERSONA="一名 25 岁的白领用户，每天使用手机约 4 小时，对科技产品有一定了解但非专业人士"

# 源代码目录（相对于项目根目录，多个用空格分隔）
SOURCE_DIRS="src"

# 文档输出目录（相对于项目根目录）
DOCS_DIR_REL="docs"

# 代码规范（帮助 AI 保持风格一致）
CODE_CONVENTIONS="遵循项目现有代码风格"

# 每轮最多改进项数量
MAX_ITEMS_PER_ROUND=6

# Git commit 前缀
COMMIT_PREFIX="feat: 迭代改进"

# 重点关注领域（引导 AI 关注特定方面）
FOCUS_AREAS="用户体验、功能完整性、代码质量"

# 反馈报告格式
FEEDBACK_FORMAT="包含：总体印象、各功能点评、Bug 列表、改进建议（按优先级排序）"
CONFIG

  # ── prompts/feedback.md ──
  cat > "${ad_dir}/prompts/feedback.md" <<'PROMPT'
你现在要扮演以下用户角色来试用一个产品：

**产品**：{{PRODUCT_NAME}} — {{PRODUCT_DESC}}
**你的身份**：{{USER_PERSONA}}
**当前迭代**：第 {{ROUND}}/{{TOTAL_ROUNDS}} 轮

请完成以下任务:

1. 仔细阅读项目源代码（{{SOURCE_DIRS}} 目录），理解当前所有已实现的功能
2. 阅读之前已有的反馈文档和改进计划（{{DOCS_DIR}} 目录），了解已经发现过的问题和已做的改进
3. 以你的用户身份，模拟使用每个功能，给出真实、具体、可操作的体验反馈
4. 重点关注：{{FOCUS_AREAS}}
5. 特别注意：
   - 之前提出的问题是否已被解决
   - 是否有新发现的 bug 或体验问题
   - 对比之前版本，哪些变好了，哪些还没改善
   - 新的改进建议（按优先级排序）

将完整报告保存到: {{FEEDBACK_FILE}}

报告格式要求：{{FEEDBACK_FORMAT}}

注意：反馈必须基于代码实际实现的功能，不要臆测不存在的功能。每条反馈要具体说明在哪个页面/模块、什么操作中遇到的。
PROMPT

  # ── prompts/plan.md ──
  cat > "${ad_dir}/prompts/plan.md" <<'PROMPT'
请阅读最新的用户体验反馈报告: {{FEEDBACK_FILE}}
同时参考之前的改进计划和反馈（{{DOCS_DIR}} 目录下的所有文档），了解改进历史。

**产品**：{{PRODUCT_NAME}} — {{PRODUCT_DESC}}
**当前迭代**：第 {{ROUND}}/{{TOTAL_ROUNDS}} 轮

基于反馈，设计一个具体的改进计划，要求:

1. 按优先级排列（P0 紧急修复 > P1 重要改进 > P2 体验优化）
2. 每个改进项必须包含：
   - 问题描述（引用反馈中的具体内容）
   - 解决方案（具体到修改哪个文件、怎么改）
   - 预期效果
3. 控制范围：本轮最多 {{MAX_ITEMS}} 个改进项，确保质量
4. 优先选择投入产出比高的改进
5. 不要重复已经在之前轮次中解决的问题

将改进计划保存到: {{PLAN_FILE}}
PROMPT

  # ── prompts/implement.md ──
  cat > "${ad_dir}/prompts/implement.md" <<'PROMPT'
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
PROMPT

  # ── .gitignore ──
  cat > "${ad_dir}/.gitignore" <<'GI'
logs/
GI

  ok "配置已初始化: ${ad_dir}/"
  echo ""
  echo "  📁 生成的文件:"
  echo "     ${CONFIG_DIR_NAME}/config.sh             ← 主配置 (必须编辑)"
  echo "     ${CONFIG_DIR_NAME}/prompts/feedback.md   ← 试用反馈 prompt"
  echo "     ${CONFIG_DIR_NAME}/prompts/plan.md       ← 改进计划 prompt"
  echo "     ${CONFIG_DIR_NAME}/prompts/implement.md  ← 代码实施 prompt"
  echo ""
  echo "  📝 下一步:"
  echo "     1. 编辑 ${ad_dir}/config.sh 填入你的产品信息"
  echo "     2. (可选) 编辑 prompts/*.md 自定义 prompt"
  echo "     3. 运行: ${PROG_NAME} run ${target} -n 5"
}

# ══════════════════════════════════════════════════════
#  子命令: status
# ══════════════════════════════════════════════════════
cmd_status() {
  local target="$1"
  local ad_dir="${target}/${CONFIG_DIR_NAME}"
  local docs_dir
  local logs_dir="${ad_dir}/logs"

  if [ ! -f "${ad_dir}/config.sh" ]; then
    err "未找到配置: ${ad_dir}/config.sh"
    echo "   运行 '${PROG_NAME} init ${target}' 初始化"
    exit 1
  fi

  # shellcheck source=/dev/null
  source "${ad_dir}/config.sh"
  docs_dir="${target}/${DOCS_DIR_REL}"

  banner
  echo -e "📊 ${BOLD}项目迭代状态${RESET} (${PRODUCT_NAME})"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "  ${BOLD}路径:${RESET} ${target}"
  echo ""

  # 统计已完成的轮次
  local max_round=0
  for f in "${docs_dir}"/feedback_round_*.md; do
    [ -f "$f" ] || continue
    local n
    n=$(basename "$f" | sed 's/feedback_round_\([0-9]*\)\.md/\1/')
    [ "$n" -gt "$max_round" ] && max_round=$n
  done

  if [ "$max_round" -eq 0 ]; then
    info "尚未运行任何迭代"
    echo ""
    echo "💡 ${BOLD}建议:${RESET} ${PROG_NAME} run ${target}"
    return
  fi

  echo -e "  ${BOLD}迭代历史:${RESET}"
  for r in $(seq 1 "$max_round"); do
    local status
    status=$(get_round_status "$r" "$logs_dir")
    local timestamp
    timestamp=$(get_round_timestamp "$r" "$logs_dir")
    
    case "$status" in
      success)
        printf "    轮次 %-2d: ${GREEN}%-8s${RESET} [%s]\n" "$r" "success" "$timestamp"
        ;;
      failed)
        printf "    轮次 %-2d: ${RED}%-8s${RESET} [%s]\n" "$r" "failed" "$timestamp"
        printf "      ${YELLOW}↳ 错误:${RESET} %s\n" "$(get_failure_reason "$r" "$logs_dir")"
        ;;
      running)
        printf "    轮次 %-2d: ${YELLOW}%-8s${RESET} [%s]\n" "$r" "running" "$timestamp"
        ;;
      *)
        printf "    轮次 %-2d: ${CYAN}%-8s${RESET} [%s]\n" "$r" "unknown" "$timestamp"
        ;;
    esac
  done

  echo ""
  echo "💡 ${BOLD}建议:${RESET} ${PROG_NAME} run ${target} --start $((max_round + 1))"
}

# ══════════════════════════════════════════════════════
#  子命令: run
# ══════════════════════════════════════════════════════
cmd_run() {
  # 前置条件检查
  check_prerequisites "$PROJECT_DIR"
  
  # 加载配置
  local ad_dir="${PROJECT_DIR}/${CONFIG_DIR_NAME}"
  AUTODEV_DIR="$ad_dir"
  local config_file="${ad_dir}/config.sh"

  if [ ! -f "$config_file" ]; then
    err "未找到配置: ${config_file}"
    echo "   运行 '${PROG_NAME} init ${PROJECT_DIR}' 初始化"
    exit 1
  fi

  # shellcheck source=/dev/null
  source "$config_file"
  
  # 配置验证
  validate_config

  DOCS_DIR="${PROJECT_DIR}/${DOCS_DIR_REL}"
  LOG_DIR="${ad_dir}/logs"

  COPILOT_FLAGS=(
    --allow-all
    --model "$MODEL"
    --add-dir "$PROJECT_DIR"
  )

  mkdir -p "$DOCS_DIR" "$LOG_DIR"

  banner
  log_step "🚀 ${PRODUCT_NAME} — 自动迭代 (第${START_ROUND}~${TOTAL_ROUNDS}轮, 模型: ${MODEL})"

  for CURRENT_ROUND in $(seq "$START_ROUND" "$TOTAL_ROUNDS"); do
    CURRENT_FEEDBACK_FILE="${DOCS_DIR}/feedback_round_${CURRENT_ROUND}.md"
    CURRENT_PLAN_FILE="${DOCS_DIR}/improvement_plan_round_${CURRENT_ROUND}.md"

    # 处理恢复逻辑
    local start_step=1
    if [[ -n "$RESUME_FROM" ]]; then
      if [[ "$RESUME_FROM" =~ ^round([0-9]+)$ ]]; then
        local resume_round=${BASH_REMATCH[1]}
        if [[ $CURRENT_ROUND -lt $resume_round ]]; then
          continue
        elif [[ $CURRENT_ROUND -eq $resume_round ]]; then
          start_step=1
        fi
      elif [[ "$RESUME_FROM" =~ ^step([0-9]+)$ ]] && [[ $CURRENT_ROUND -eq $START_ROUND ]]; then
        start_step=${BASH_REMATCH[1]}
      fi
    fi

    # ── Step 1: 模拟用户试用 ──
    if [[ $start_step -le 1 ]]; then
      save_step_status "$CURRENT_ROUND" 1 "running"
      log_step "📝 第 ${CURRENT_ROUND}/${TOTAL_ROUNDS} 轮 — Step 1/3: 模拟用户试用"
      local template prompt
      template=$(load_prompt_template "feedback")
      prompt=$(render_prompt "$template")
      if run_copilot "$prompt" "${LOG_DIR}/round_${CURRENT_ROUND}_step1_feedback.log"; then
        save_step_status "$CURRENT_ROUND" 1 "completed"
      else
        save_step_status "$CURRENT_ROUND" 1 "failed"
        continue
      fi

      if [ ! -f "$CURRENT_FEEDBACK_FILE" ] && ! $DRY_RUN; then
        warn "反馈文档未生成 (${CURRENT_FEEDBACK_FILE})，继续..."
      fi
    fi

    # ── Step 2: 设计改进计划 ──
    if [[ $start_step -le 2 ]]; then
      save_step_status "$CURRENT_ROUND" 2 "running"
      log_step "📋 第 ${CURRENT_ROUND}/${TOTAL_ROUNDS} 轮 — Step 2/3: 设计改进计划"
      template=$(load_prompt_template "plan")
      prompt=$(render_prompt "$template")
      if run_copilot "$prompt" "${LOG_DIR}/round_${CURRENT_ROUND}_step2_plan.log"; then
        save_step_status "$CURRENT_ROUND" 2 "completed"
      else
        save_step_status "$CURRENT_ROUND" 2 "failed"
        continue
      fi

      if [ ! -f "$CURRENT_PLAN_FILE" ] && ! $DRY_RUN; then
        warn "计划文档未生成 (${CURRENT_PLAN_FILE})，跳过实施..."
        continue
      fi
    fi

    # ── Step 3: 实施改进 ──
    if [[ $start_step -le 3 ]]; then
      save_step_status "$CURRENT_ROUND" 3 "running"
      log_step "🔧 第 ${CURRENT_ROUND}/${TOTAL_ROUNDS} 轮 — Step 3/3: 实施代码改进"
      template=$(load_prompt_template "implement")
      prompt=$(render_prompt "$template")
      if run_copilot "$prompt" "${LOG_DIR}/round_${CURRENT_ROUND}_step3_implement.log"; then
        save_step_status "$CURRENT_ROUND" 3 "completed"
      else
        save_step_status "$CURRENT_ROUND" 3 "failed"
        continue
      fi
    fi

    log_step "✅ 第 ${CURRENT_ROUND}/${TOTAL_ROUNDS} 轮完成"
  done

  # ── 总结 ──
  log_step "🎉 ${PRODUCT_NAME} — 全部迭代完成！"
  echo "  📁 文档输出: ${DOCS_DIR_REL}/"
  for r in $(seq "$START_ROUND" "$TOTAL_ROUNDS"); do
    [ -f "${DOCS_DIR}/feedback_round_${r}.md" ] && echo "     ✓ feedback_round_${r}.md"
    [ -f "${DOCS_DIR}/improvement_plan_round_${r}.md" ] && echo "     ✓ improvement_plan_round_${r}.md"
  done
  echo ""
  echo "  📁 日志: ${CONFIG_DIR_NAME}/logs/"
  echo "  📊 提交: cd ${PROJECT_DIR} && git --no-pager log --oneline -20"
}

# ══════════════════════════════════════════════════════
#  主入口：解析子命令
# ══════════════════════════════════════════════════════
if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

SUBCOMMAND=""
PROJECT_DIR=""

case "$1" in
  init|run|status)
    SUBCOMMAND="$1"; shift
    ;;
  -h|--help)
    usage; exit 0
    ;;
  -v|--version)
    echo "${PROG_NAME} v${VERSION}"; exit 0
    ;;
  *)
    err "未知子命令: $1"
    usage; exit 1
    ;;
esac

# 解析子命令后续参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n|--rounds)     TOTAL_ROUNDS="$2"; shift 2 ;;
    -m|--model)      MODEL="$2"; shift 2 ;;
    -s|--start)      START_ROUND="$2"; shift 2 ;;
    --resume-from)   RESUME_FROM="$2"; shift 2 ;;
    --dry-run)       DRY_RUN=true; shift ;;
    -*)              err "未知选项: $1"; usage; exit 1 ;;
    *)
      if [ -z "$PROJECT_DIR" ]; then
        PROJECT_DIR="$1"; shift
      else
        err "多余参数: $1"; usage; exit 1
      fi
      ;;
  esac
done

if [ -z "$PROJECT_DIR" ]; then
  err "请指定项目路径"
  usage
  exit 1
fi

PROJECT_DIR=$(resolve_path "$PROJECT_DIR")

case "$SUBCOMMAND" in
  init)   cmd_init "$PROJECT_DIR" ;;
  run)    cmd_run ;;
  status) cmd_status "$PROJECT_DIR" ;;
esac
