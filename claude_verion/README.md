# iTerm2 通知脚本（Claude Hook） / iTerm2 Notification Script (Claude Hook)

一个用于 iTerm2 的通知脚本，支持时长过滤、前台检测、语音播报与 iTerm2 原生通知（OSC 9）。
An iTerm2 notification script with duration filtering, foreground checks, voice
playback, and native iTerm2 notifications (OSC 9).

## 文件说明 / Files

- `iterm2_notify.sh`：核心通知脚本 / Core notification script
- `test.sh`：模拟“任务结束”场景的测试脚本 / Test script simulating a task finish
- `claude_setting.json`：Claude hooks 的配置示例 / Example Claude hooks config

## 环境要求 / Requirements

- macOS
- iTerm2
- 可用的 `osascript` 与 `say` / `osascript` and `say` must be available

## 使用方法 / Usage

### 1. 放置脚本 / Place the script

将 `iterm2_notify.sh` 复制到 `~/.claude/scripts/iterm2_notify.sh`，并赋予执行权限：
Copy `iterm2_notify.sh` to `~/.claude/scripts/iterm2_notify.sh` and make it
executable:

```bash
chmod +x ~/.claude/scripts/iterm2_notify.sh
```

### 2. 配置 Claude hooks / Configure Claude hooks

参考 `claude_setting.json` 的内容，将命令挂到 `Stop` / `Notification` /
`PostToolUse` 等 hook 中：
Use `claude_setting.json` as a reference and wire the command to hooks such as
`Stop`, `Notification`, or `PostToolUse`:

```json
"command": "~/.claude/scripts/iterm2_notify.sh 'Stop' '✅ 任务完成\nClaude Code 任务完成' 'Claude Finish' 1"
```

### 3. 脚本参数 / Script arguments

```bash
iterm2_notify.sh <EVENT_TYPE> <NOTIFICATION_TEXT> <SPEAK_TEXT> <CHECK_FOREGROUND>
```

- `EVENT_TYPE`：事件类型（如 `Stop` / `Input` / `Error`）
  Event type (e.g. `Stop`, `Input`, `Error`)
- `NOTIFICATION_TEXT`：通知文本（支持 `\n` 换行）
  Notification text (supports `\n` newlines)
- `SPEAK_TEXT`：语音播报文本（可留空）
  Voice text (can be empty)
- `CHECK_FOREGROUND`：是否检测 iTerm2 前台（`1` 检测，`0` 跳过）
  Whether to check iTerm2 foreground (`1` check, `0` skip)

## 配置项（脚本内）/ Script config

可在 `iterm2_notify.sh` 顶部调整：
Configure the following near the top of `iterm2_notify.sh`:

- `MIN_DURATION`：最短时长（秒） / Minimum duration (seconds)
- `STEAL_FOCUS`：是否抢焦点（`0/1`） / Steal focus (`0/1`)
- `ENABLE_VOICE`：是否语音播报（`true/false`） / Enable voice (`true/false`)
- `VOICE_ENGLISH` / `VOICE_CHINESE`：中英文语音 / English & Chinese voices
- `VOICE_RATE`：语速（100-300） / Voice rate (100-300)

支持的环境变量：
Environment variables:

- `NOTIFY_CHECK_FOREGROUND`：默认是否前台检测
  Default foreground check
- `NOTIFY_VOICE_EN` / `NOTIFY_VOICE_ZH`：覆盖默认语音
  Override default voices

## 日志与状态文件 / Logs & state

- 日志：`/tmp/claude_iterm2_notify.log`
  Log file: `/tmp/claude_iterm2_notify.log`
- 任务起始时间：`/tmp/claude_task_start_time_iterm2`
  Task start time: `/tmp/claude_task_start_time_iterm2`

## 测试脚本 / Test script

在 iTerm2 中运行：
Run inside iTerm2:

```bash
./test.sh
```

该脚本会伪造一个“已运行 20 秒”的任务，触发一次通知流程。
The script fakes a 20-second task to trigger the notification flow.
