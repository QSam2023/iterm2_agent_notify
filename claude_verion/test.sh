#!/usr/bin/env bash
set -euo pipefail

# ===== 你现有通知脚本路径（改成你的实际文件名）=====
TARGET_SCRIPT="./iterm2_notify.sh"

# ===== 你现有脚本里的时间戳文件路径（必须一致）=====
TASK_START_FILE="/tmp/claude_task_start_time_iterm2"

# ===== 确保在 iTerm2 中运行 =====
if [[ "${TERM_PROGRAM:-}" != "iTerm.app" ]]; then
  echo "This test must run inside iTerm2."
  exit 0
fi

# ===== 伪造“第二次触发”条件：写入一个过去的 start_time =====
# 让 duration >= 20s（默认 MIN_DURATION=15 可通过）
NOW=$(date +%s)
echo $((NOW - 20)) > "$TASK_START_FILE"

# ===== 3 行通知内容（模拟截图效果）=====
NOTI_TEXT=$'✅ 任务完成\n✅ 点击查看结果\nClaude Code 任务完成'

# ===== 语音播报文本 =====
SPEAK_TEXT=${SPEAK_TEXT:-"Task Finish"}

# ===== 前台检测开关：1=检测, 0=跳过 =====
CHECK_FOREGROUND=${CHECK_FOREGROUND:-1}

# ===== 当前 iTerm2 前台状态（仅提示） =====
IS_FOREGROUND=$(osascript -e 'tell application "System Events" to get frontmost of process "iTerm2"' 2>/dev/null || echo "false")
echo "iTerm2 foreground: $IS_FOREGROUND (CHECK_FOREGROUND=$CHECK_FOREGROUND)"

# ===== 调用原脚本：传入事件类型 + 通知文本 + 语音文本 + 前台检测 =====
bash "$TARGET_SCRIPT" "Stop" "$NOTI_TEXT" "$SPEAK_TEXT" "$CHECK_FOREGROUND"
