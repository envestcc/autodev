#!/usr/bin/env bash
#
# autodev 基础测试
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AUTODEV="${SCRIPT_DIR}/../autodev.sh"
TEST_DIR=$(mktemp -d)

trap 'rm -rf "$TEST_DIR"' EXIT

pass=0
fail=0

assert() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    echo "  ✅ ${desc}"
    pass=$((pass + 1))
  else
    echo "  ❌ ${desc}"
    fail=$((fail + 1))
  fi
}

assert_fail() {
  local desc="$1"; shift
  if ! "$@" >/dev/null 2>&1; then
    echo "  ✅ ${desc}"
    pass=$((pass + 1))
  else
    echo "  ❌ ${desc} (期望失败但成功了)"
    fail=$((fail + 1))
  fi
}

echo ""
echo "🧪 autodev 测试"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── --version ──
echo ""
echo "📦 版本和帮助:"
assert "--version 输出版本号" bash "$AUTODEV" --version
assert "--help 输出帮助信息" bash "$AUTODEV" --help

# ── init ──
echo ""
echo "📂 init 子命令:"
mkdir -p "${TEST_DIR}/project/src"
assert "init 创建配置目录" bash "$AUTODEV" init "${TEST_DIR}/project"
assert "config.sh 已生成" test -f "${TEST_DIR}/project/.autodev/config.sh"
assert "feedback.md 已生成" test -f "${TEST_DIR}/project/.autodev/prompts/feedback.md"
assert "plan.md 已生成" test -f "${TEST_DIR}/project/.autodev/prompts/plan.md"
assert "implement.md 已生成" test -f "${TEST_DIR}/project/.autodev/prompts/implement.md"
assert_fail "重复 init 应失败" bash "$AUTODEV" init "${TEST_DIR}/project"

# ── run --dry-run ──
echo ""
echo "🏃 run --dry-run 子命令:"
# 需要创建 docs 目录和 git 仓库
cd "${TEST_DIR}/project" && git init -q
assert "dry-run 正常执行" bash "$AUTODEV" run "${TEST_DIR}/project" -n 1 --dry-run

# ── status ──
echo ""
echo "📊 status 子命令:"
assert "status 正常执行" bash "$AUTODEV" status "${TEST_DIR}/project"

# ── 错误处理 ──
echo ""
echo "🚫 错误处理:"
assert_fail "无参数应失败" bash "$AUTODEV" run
assert_fail "不存在的路径应失败" bash "$AUTODEV" run /nonexistent/path
assert_fail "无配置的项目应失败" bash "$AUTODEV" run "${TEST_DIR}"

# ── 总结 ──
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  结果: ${pass} 通过, ${fail} 失败"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

[ "$fail" -eq 0 ] && exit 0 || exit 1
