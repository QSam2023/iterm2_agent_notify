#!/usr/bin/env bash
# iTerm2 Stop等事件通知脚本
# 功能: 时长过滤 + 语音播报 + iTerm2 原生通知
# 特点: 简洁实用，专注 iTerm2

set -euo pipefail

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 配置区域
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MIN_DURATION=15                        # 最小通知时长(秒), 低于此值不通知
STEAL_FOCUS=0                          # 是否抢焦点: 0=不抢, 1=抢焦点
CHECK_FOREGROUND_DEFAULT="${NOTIFY_CHECK_FOREGROUND:-1}"  # 默认前台检测: 1=检测, 0=跳过

# 语音配置
ENABLE_VOICE=true                      # 是否启用语音播报
VOICE_ENGLISH="${NOTIFY_VOICE_EN:-Samantha}"    # 英文语音 (从环境变量读取或使用默认)
VOICE_CHINESE="${NOTIFY_VOICE_ZH:-Ting-Ting}"  # 中文语音 (从环境变量读取或使用默认)
VOICE_RATE=200                         # 语速 (100-300)

# 参数解析
EVENT_TYPE="${1:-Unknown}"             # 事件类型 (SessionStart, Stop, Exit 等)
NOTIFICATION_TEXT="${2:-✅ Claude Code 任务完成}"  # 通知内容
SPEAK_TEXT="${3:-}"                    # 语音播报文本 (可为空)
CHECK_FOREGROUND="${4:-$CHECK_FOREGROUND_DEFAULT}"  # 是否检测 iTerm2 前台: 1=检测, 0=跳过

# 日志文件
LOG_FILE="/tmp/claude_iterm2_notify.log"

# 时间戳文件
TASK_START_FILE="/tmp/claude_task_start_time_iterm2"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 辅助函数
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 日志记录
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# 格式化时间显示 (秒 → "X分Y秒" 或 "Y秒")
format_time() {
    local duration=$1
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))

    if [ $minutes -gt 0 ]; then
        echo "${minutes}分${seconds}秒"
    else
        echo "${seconds}秒"
    fi
}

# 语音播报 (自动检测中英文)
speak_message() {
    local message="$1"

    # 如果禁用语音，直接返回
    [[ "$ENABLE_VOICE" != "true" ]] && return
    [[ -z "$message" ]] && return

    local voice="$VOICE_ENGLISH"  # 默认英文

    # 检测中文字符 (包含中文汉字)
    if echo "$message" | grep -q '[一-龥]' 2>/dev/null; then
        voice="$VOICE_CHINESE"
    fi

    # 后台播放语音 (不阻塞主流程)
    {
        say -v "$voice" -r "$VOICE_RATE" "$message" 2>/dev/null || say "$message"
    } </dev/null >/dev/null 2>&1 &

    log "Voice: $voice | Message: $message"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 主逻辑
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

log "======== Hook triggered: $EVENT_TYPE ========"

# ===== 1. iTerm2 检测 =====
if [[ "${TERM_PROGRAM:-}" != "iTerm.app" ]]; then
    log "Not iTerm2 environment (TERM_PROGRAM=${TERM_PROGRAM:-undefined}), skipped"
    exit 0
fi

log "iTerm2 detected ✓"

# ===== 2. 状态机: 时间戳处理 =====
CURRENT_TIME=$(date +%s)

if [ -f "$TASK_START_FILE" ]; then
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # 第二次触发: 计算时长并发送通知
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    START_TIME=$(cat "$TASK_START_FILE")
    DURATION=$((CURRENT_TIME - START_TIME))

    log "Task duration: ${DURATION}s (threshold: ${MIN_DURATION}s)"

    # ===== 3. 时长过滤 =====
    if [ $DURATION -lt $MIN_DURATION ]; then
        log "Duration too short (${DURATION}s < ${MIN_DURATION}s), skipped"
        rm -f "$TASK_START_FILE"
        exit 0
    fi

    log "Duration check passed ✓"

    # ===== 4. 前台检测 =====
    if [[ "$CHECK_FOREGROUND" == "1" ]]; then
        IS_FOREGROUND=$(osascript -e 'tell application "System Events" to get frontmost of process "iTerm2"' 2>/dev/null || echo "false")

        log "iTerm2 foreground: $IS_FOREGROUND"

        if [[ "$IS_FOREGROUND" == "true" ]]; then
            log "iTerm2 in foreground, notification skipped"
            rm -f "$TASK_START_FILE"
            exit 0
        fi

        log "Foreground check passed ✓"
    else
        log "Foreground check skipped (CHECK_FOREGROUND=$CHECK_FOREGROUND)"
    fi

    # ===== 5. 格式化时间 =====
    TIME_STR=$(format_time $DURATION)

    # 构建完整通知文本
    FULL_NOTIFICATION="$NOTIFICATION_TEXT (用时 $TIME_STR)"

    log "Notification: $FULL_NOTIFICATION"

    # ===== 6. 发送 iTerm2 通知 (OSC 9) =====
    printf "\e]9;%s\a" "$FULL_NOTIFICATION"
    log "iTerm2 notification sent ✓"

    # ===== 7. 设置标记点 (Cmd-Shift-J 跳转) =====
    printf "\e]1337;SetMark\a"
    log "Mark set ✓"

    # ===== 8. 可选: 抢焦点 =====
    if [[ "$STEAL_FOCUS" == "1" ]]; then
        printf "\e]1337;StealFocus\a"
        log "Focus stolen ✓"
    fi

    # ===== 9. 语音播报 =====
    if [[ -n "$SPEAK_TEXT" ]]; then
        speak_message "$SPEAK_TEXT"
    else
        speak_message "$FULL_NOTIFICATION"
    fi

    # ===== 10. 清理时间记录 =====
    rm -f "$TASK_START_FILE"
    log "Task completed, notification sequence finished [$EVENT_TYPE]"

else
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # 第一次触发: 记录开始时间
    # ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    echo "$CURRENT_TIME" > "$TASK_START_FILE"
    log "Task start time recorded: $CURRENT_TIME [$EVENT_TYPE]"
fi

log "======== Hook finished: $EVENT_TYPE ========"
