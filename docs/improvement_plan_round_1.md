# autodev 第1轮改进计划

**基于反馈文档**: `feedback_round_1.md`  
**制定时间**: 2026-03-01  
**目标版本**: v0.2.0  

---

## 改进概览

基于用户反馈，本轮改进聚焦于提升工具的稳定性和用户体验。选择了5个投入产出比最高的改进项，优先解决阻塞性问题和用户频繁遇到的痛点。

**改进价值**：预计解决这5个问题后，工具可用性评分从7.5/10提升至8.5/10，用户推荐意愿显著增强。

---

## 改进项列表

### P1-1: 增加前置条件检查机制
**优先级**: P1  
**问题描述**: 
- 引用反馈："缺少 copilot 依赖检查，工具启动后才发现 copilot 不可用，用户体验差"
- 引用反馈："copilot 不可用：没有检查 copilot CLI 是否安装；git 仓库检查：没有验证项目是否在 git 仓库中"

**解决方案**:
1. 修改文件：`autodev.sh`中的`cmd_run()`函数（约360行）
2. 在函数开头添加`check_prerequisites()`函数调用
3. 新增`check_prerequisites()`函数：
   - 检查`copilot`命令是否可用：`command -v copilot >/dev/null || die "Copilot CLI not found. Please install: https://github.com/github/copilot-cli"`
   - 检查当前目录是否为git仓库：`git rev-parse --git-dir >/dev/null 2>&1 || die "Not a git repository. Please run 'git init' first"`
   - 检查目标目录写入权限：`[[ -w "$PROJECT_DIR" ]] || die "No write permission to project directory"`

**预期效果**: 
- 在开始执行前提前发现环境问题，避免用户浪费时间
- 提供明确的解决指导，降低使用门槛
- 减少80%的环境相关支持问题

---

### P1-2: 实现增量执行恢复机制
**优先级**: P1  
**问题描述**: 
- 引用反馈："缺乏步骤级重试：如果步骤 2 失败，必须从步骤 1 重新开始"
- 引用反馈："缺少增量执行能力，步骤失败后无法从中途恢复，必须重头开始"

**解决方案**:
1. 修改文件：`autodev.sh`中的`cmd_run()`函数
2. 在LOG_DIR中增加状态文件：`.autodev/logs/round_N_status.json`
3. 记录每个步骤的完成状态：
   ```bash
   # 每步骤开始前记录状态
   echo "{\"round\":$CURRENT_ROUND,\"step\":1,\"status\":\"running\"}" > "${LOG_DIR}/round_${CURRENT_ROUND}_status.json"
   # 完成后更新状态  
   echo "{\"round\":$CURRENT_ROUND,\"step\":1,\"status\":\"completed\"}" > "${LOG_DIR}/round_${CURRENT_ROUND}_status.json"
   ```
4. 新增`--resume-from`参数：
   - `autodev run . --resume-from step2` - 跳过step1，从step2开始
   - `autodev run . --resume-from round2` - 从第2轮开始
5. 恢复前验证上一轮输出文件是否存在

**预期效果**: 
- 步骤失败后可精确恢复，节省60-90%重试时间
- 支持断点续传，适合长时间运行场景
- 减少用户挫败感，提升工具可靠性

---

### P1-3: 改进 copilot 错误处理和重试机制
**优先级**: P1  
**问题描述**: 
- 引用反馈："copilot 失败处理简陋：只是记录退出码，没有重试或降级机制"
- 网络异常、模型暂时不可用等临时性错误导致整轮失败

**解决方案**:
1. 修改文件：`autodev.sh`中的`run_copilot()`函数（89-108行）
2. 增加重试机制：
   ```bash
   run_copilot() {
     local prompt="$1" log_file="$2" max_retries=3 retry=0
     
     while [ $retry -lt $max_retries ]; do
       # 执行copilot调用
       if copilot_exec; then return 0; fi
       
       # 分析错误类型
       if [[ $exit_code -eq 1 && "$error_msg" =~ "network|timeout|rate_limit" ]]; then
         warn "网络错误，等待$((retry * 30 + 30))秒后重试 ($((retry+1))/$max_retries)"
         sleep $((retry * 30 + 30))
         retry=$((retry + 1))
       else
         break  # 非临时性错误，不重试
       fi
     done
   }
   ```
3. 增强错误信息解析，提供更友好的错误提示

**预期效果**: 
- 网络异常等临时问题自动重试，减少50%的失败率
- 更友好的错误提示，降低用户困扰
- 提升工具在不稳定网络环境下的可用性

---

### P1-4: 增加配置验证器
**优先级**: P1  
**问题描述**: 
- 引用反馈："缺少配置校验器，未检查必填项、文件路径有效性等"
- 引用反馈："用户可能忘记编辑配置文件，run 前检查是否还是默认占位符值"

**解决方案**:
1. 新增`validate_config()`函数，在`cmd_run()`加载配置后调用
2. 检查核心配置项：
   ```bash
   validate_config() {
     # 检查必填项
     [[ "$PRODUCT_NAME" != "我的产品" ]] || die "请编辑config.sh设置 PRODUCT_NAME"
     [[ "$PRODUCT_DESC" != "产品简介" ]] || die "请编辑config.sh设置 PRODUCT_DESC"  
     [[ "$USER_PERSONA" != "用户画像" ]] || die "请编辑config.sh设置 USER_PERSONA"
     
     # 检查路径有效性
     [[ -d "$PROJECT_DIR/$SOURCE_DIRS" ]] || warn "源码目录不存在: $SOURCE_DIRS"
     
     # 检查数值范围
     [[ "$MAX_ITEMS_PER_ROUND" -gt 0 && "$MAX_ITEMS_PER_ROUND" -le 20 ]] || die "MAX_ITEMS_PER_ROUND 应在1-20之间"
   }
   ```
3. 提供友好的修复指导

**预期效果**: 
- 100%避免因配置错误导致的执行失败
- 新用户配置错误率从70%降至10%  
- 更流畅的首次使用体验

---

### P2-1: 增强 status 命令功能
**优先级**: P2  
**问题描述**: 
- 引用反馈建议："改进 status 命令 - 显示每轮的执行状态（成功/失败/进行中），显示最后执行时间，提供失败轮次的错误信息摘要"

**解决方案**:
1. 修改文件：`autodev.sh`中的`cmd_status()`函数（304-351行）
2. 增强状态展示：
   ```bash
   cmd_status() {
     # 解析状态文件，展示详细状态
     echo "📊 项目迭代状态 (${PRODUCT_NAME})"
     echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
     
     for round in $(find_completed_rounds); do
       local status=$(get_round_status $round)  # success/failed/running
       local timestamp=$(get_round_timestamp $round)
       printf "  轮次 %-2d: %-8s [%s]\n" "$round" "$status" "$timestamp"
       
       if [[ "$status" == "failed" ]]; then
         printf "    ↳ 错误: %s\n" "$(get_failure_reason $round)"
       fi
     done
     
     # 显示下一轮建议
     echo ""
     echo "💡 建议: autodev run . --resume-from round$((last_round + 1))"
   }
   ```
3. 新增状态文件解析函数

**预期效果**: 
- 用户能快速了解项目迭代历史和状态
- 失败轮次的错误信息一目了然  
- 提供明确的下一步操作指导

---

## 实施计划

### 阶段1: 核心稳定性改进（P1优先级）
**时间**: 立即开始  
**任务**: P1-1, P1-2, P1-3, P1-4
**目标**: 解决所有阻塞性问题，确保工具基本可用

### 阶段2: 用户体验优化（P2优先级）  
**时间**: 阶段1完成后
**任务**: P2-1
**目标**: 提升用户满意度和工具易用性

### 验证方式
1. **自动化测试**: 针对每个改进项编写测试用例
2. **真实场景验证**: 在多个项目中测试改进效果  
3. **用户反馈收集**: 邀请原反馈用户复测并提供新反馈

---

## 预期收益

### 量化指标
- **可用性评分**: 7.5/10 → 8.5/10  
- **首次成功率**: 40% → 85%
- **重试时间节省**: 60-90%  
- **环境问题支持**: 减少80%

### 用户体验提升  
1. **稳定性**: 前置检查避免运行时失败
2. **效率**: 增量恢复大幅节省重试时间  
3. **友好性**: 更好的错误提示和配置验证
4. **透明性**: 清晰的状态展示和历史追踪

---

## 风险评估

### 低风险改进
- P1-1 (前置检查): 纯增量功能，无破坏性
- P1-4 (配置验证): 只是增加检查，不改变核心逻辑
- P2-1 (status增强): 只读功能，无副作用

### 中等风险改进  
- P1-2 (增量执行): 涉及核心执行流程，需谨慎测试
- P1-3 (错误处理): 可能改变失败行为，需确保向后兼容

### 缓解策略
1. 分步实施，每个改进独立测试
2. 保持向后兼容，添加功能开关
3. 详细记录变更，便于回滚

---

## 结论

本轮改进计划专注于解决用户反馈中的核心痛点，通过5个精心选择的改进项，在不增加复杂性的前提下显著提升工具的稳定性和易用性。

**成功标准**: 用户能在各种环境下顺利运行autodev，即使遇到问题也能快速定位和恢复，整体推荐意愿从4/5星提升至5/5星。