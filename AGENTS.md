# AGENTS.md

## Project summary 项目摘要
- This repo hosts iTerm2 notification scripts for Claude hooks. / 本仓库存放用于 Claude hooks 的 iTerm2 通知脚本。
- Core logic lives in `claude_verion/iterm2_notify.sh`. / 核心逻辑在 `claude_verion/iterm2_notify.sh`。
- Example hook config in `claude_verion/claude_setting.json`. / Hook 配置示例在 `claude_verion/claude_setting.json`。
- Documentation lives under `docs/`. / 文档位于 `docs/`。
- There is no compiled build step. / 无编译构建步骤。

## Repository layout 仓库结构
- `claude_verion/` contains the bash scripts and example config. / `claude_verion/` 包含脚本与示例配置。
- `docs/` contains plugin tutorials and examples. / `docs/` 包含插件教程与示例。
- `opencode_version/` currently empty placeholder. / `opencode_version/` 当前为空占位。
- No package manager or language toolchain files are present. / 未提供包管理或语言工具链文件。

## Build / lint / test 构建/检查/测试
- Build: none. / 构建：无。
- Lint: none configured. / Lint：未配置。
- Tests: `claude_verion/test.sh` exercises the notification flow. / 测试：`claude_verion/test.sh` 触发通知流程。
- Single test run: `bash claude_verion/test.sh`. / 单测执行：`bash claude_verion/test.sh`。
- The test script must run inside iTerm2 (`TERM_PROGRAM=iTerm.app`). / 测试需在 iTerm2 中运行（`TERM_PROGRAM=iTerm.app`）。
- If you only need the main script, run `bash claude_verion/iterm2_notify.sh ...`. / 只跑主脚本时使用 `bash claude_verion/iterm2_notify.sh ...`。
- Optional linting: `shellcheck claude_verion/*.sh` if available. / 可选 lint：安装 `shellcheck` 后运行 `shellcheck claude_verion/*.sh`。

## Local prerequisites 本地前置条件
- macOS is required (scripts call `osascript` and `say`). / 需要 macOS（依赖 `osascript` 与 `say`）。
- iTerm2 must be installed and running. / 必须安装并运行 iTerm2。
- Scripts assume a POSIX shell with bash. / 脚本基于 POSIX shell 与 bash。
- OSC escape sequences are sent to iTerm2. / 通过 OSC 转义序列向 iTerm2 发送通知。

## Script entry points 脚本入口
- `claude_verion/iterm2_notify.sh` is the primary entry point. / 主入口脚本：`claude_verion/iterm2_notify.sh`。
- `claude_verion/test.sh` fakes a 20s task duration and triggers a notification. / `claude_verion/test.sh` 模拟 20 秒任务并触发通知。
- `claude_verion/claude_setting.json` shows a hook configuration. / `claude_verion/claude_setting.json` 提供 hook 配置示例。

## Bash style guide Bash 风格规范
- Use `#!/usr/bin/env bash` shebang. / 使用 `#!/usr/bin/env bash`。
- Always set `set -euo pipefail` near the top. / 顶部设置 `set -euo pipefail`。
- Keep functions small and focused. / 函数保持小而专注。
- Prefer `local` variables inside functions. / 函数内优先使用 `local` 变量。
- Use `snake_case` for variables and functions. / 变量与函数使用 `snake_case`。
- Use ALL_CAPS for configuration constants. / 配置常量使用全大写。
- Quote all variable expansions unless intentional word splitting. / 除非需要拆分，变量展开都加引号。
- Use `[[ ... ]]` for conditional expressions. / 条件判断使用 `[[ ... ]]`。
- Use `case` for multi-branch string matching. / 多分支匹配使用 `case`。
- Keep indentation at two spaces. / 缩进使用两个空格。
- Use `printf` instead of `echo` for escape sequences. / 输出转义序列用 `printf`。
- Guard optional commands with `||` fallbacks when needed. / 可选命令加 `||` 兜底。

## Error handling 错误处理
- Exit early when environment checks fail (e.g., non-iTerm2). / 环境检查失败时提前退出。
- Log errors to `/tmp/claude_iterm2_notify.log`. / 错误写入 `/tmp/claude_iterm2_notify.log`。
- Avoid silent failures; log before exiting. / 不要静默失败，退出前记录日志。
- Use `rm -f` for cleanup to avoid errors. / 清理使用 `rm -f`。
- Ensure temporary files are deleted on completion. / 完成后删除临时文件。
- Prefer explicit exit codes for failure cases. / 失败场景使用明确退出码。

## Logging practices 日志规范
- Use the `log()` helper for all log entries. / 所有日志通过 `log()`。
- Include timestamps in log output. / 日志包含时间戳。
- Log decision points (duration checks, foreground checks). / 记录关键分支（时长/前台检测）。
- Keep log messages concise and descriptive. / 日志简洁清晰。

## Timing and state handling 时间与状态处理
- Task start time is tracked via `/tmp/claude_task_start_time_iterm2`. / 任务起始时间写入 `/tmp/claude_task_start_time_iterm2`。
- Only send notifications when duration >= `MIN_DURATION`. / 仅当时长 >= `MIN_DURATION` 才通知。
- Reset state file after notification to avoid duplicates. / 通知后清理状态文件。
- Avoid multiple concurrent runs writing the same state file. / 避免并发写同一状态文件。

## Notification behavior 通知行为
- OSC 9 is used for iTerm2 native notifications. / 使用 OSC 9 原生通知。
- `SetMark` is used to create a jump point in iTerm2. / 使用 `SetMark` 建立跳转点。
- `StealFocus` is optional and controlled by config. / `StealFocus` 由配置控制。
- Foreground detection uses `System Events` via `osascript`. / 前台检测通过 `osascript` 的 `System Events`。
- Voice playback uses `say` and switches voices by language. / 语音播报通过 `say` 并按语言切换。

## Configuration conventions 配置约定
- Configuration is defined near the top of the script. / 配置集中在脚本顶部。
- Read environment variable overrides using `${VAR:-default}`. / 环境变量覆盖使用 `${VAR:-default}`。
- Keep defaults documented in comments if needed. / 默认值必要时注释说明。
- Add new config options alongside existing ones. / 新配置与现有配置并列。

## JSON style guide JSON 规范
- Use two-space indentation. / 使用 2 空格缩进。
- Keep keys in a stable order (permissions, hooks, enabledPlugins, model). / key 顺序固定（permissions, hooks, enabledPlugins, model）。
- Use double quotes for all keys and strings. / 所有 key 与字符串使用双引号。
- Keep long shell commands on a single line. / 长命令保持单行。
- Avoid trailing commas. / 避免尾逗号。

## Markdown style guide Markdown 规范
- Keep headings short and descriptive. / 标题简短且明确。
- Use fenced code blocks with language identifiers. / 代码块使用语言标识。
- Wrap lines at readable lengths (~80-100 chars). / 行宽保持可读（约 80-100 字符）。
- Prefer numbered steps for procedures. / 步骤用编号列表。
- Keep bilingual content consistent in tone. / 中英表述风格保持一致。

## Naming conventions 命名规范
- Script files use `snake_case` and `.sh` extension. / 脚本文件用 `snake_case` + `.sh`。
- Config files use descriptive nouns (e.g., `claude_setting.json`). / 配置文件用描述性名词。
- Temporary files live under `/tmp/` with clear prefixes. / 临时文件放在 `/tmp/` 并带前缀。

## Dependencies and external calls 依赖与外部调用
- `osascript` is required for notifications and foreground checks. / `osascript` 用于通知与前台检测。
- `say` is required for voice playback. / `say` 用于语音播报。
- `date` and `printf` are standard macOS utilities. / `date` 与 `printf` 为标准工具。
- Avoid adding dependencies unless absolutely necessary. / 非必要不新增依赖。

## Adding new scripts 新增脚本
- Place new scripts under `claude_verion/`. / 新脚本放入 `claude_verion/`。
- Provide a short README update when adding user-facing features. / 增加用户功能时更新 README。
- Include a small test or example invocation. / 提供简短测试或示例命令。
- Keep scripts compatible with macOS default bash. / 兼容 macOS 默认 bash。

## Testing guidance 测试建议
- Run `bash claude_verion/test.sh` in iTerm2 for smoke testing. / 在 iTerm2 运行 `bash claude_verion/test.sh` 进行冒烟测试。
- Ensure notifications are skipped if iTerm2 is foreground (when enabled). / 启用前台检测时应跳过前台通知。
- Validate voice output when `ENABLE_VOICE=true`. / `ENABLE_VOICE=true` 时验证语音。
- Verify `MIN_DURATION` filtering by adjusting the fake start time. / 调整伪造时间验证 `MIN_DURATION`。

## Release/checklist 发布检查
- Confirm permissions for scripts (`chmod +x`). / 确认脚本权限（`chmod +x`）。
- Confirm docs match the script arguments. / 文档与脚本参数保持一致。
- Verify example hook commands still work. / 示例 hook 命令可用。
- Avoid committing `/tmp` artifacts. / 不提交 `/tmp` 产物。

## Cursor/Copilot rules Cursor/Copilot 规则
- No `.cursor/rules`, `.cursorrules`, or Copilot instruction files found. / 未发现 Cursor 或 Copilot 规则文件。
- If such rules are added, update this section accordingly. / 若新增规则文件，请更新本节。

## Notes for agents 给代理的说明
- This repository is not a git repo; avoid git commands. / 本仓库不是 git repo，避免 git 命令。
- Keep modifications minimal and focused on the scripts. / 改动保持小而聚焦。
- Avoid introducing emojis unless requested. / 未要求时不要添加表情。
- Prefer edits over rewrites to preserve intent. / 优先编辑而非重写。
- Ask before changing behavior or defaults. / 更改行为或默认值前先询问。

## Example command cheatsheet 示例命令
- Run main script: `bash claude_verion/iterm2_notify.sh "Stop" "Done" "Done" 1` / 运行主脚本。
- Run test script: `bash claude_verion/test.sh` / 运行测试脚本。
- Make scripts executable: `chmod +x claude_verion/iterm2_notify.sh claude_verion/test.sh` / 设置可执行。
- Tail log: `tail -f /tmp/claude_iterm2_notify.log` / 查看日志。

## Single-test focus 单测重点
- Only one test script exists; treat `claude_verion/test.sh` as the single test. / 唯一测试脚本是 `claude_verion/test.sh`。
- For manual checks, open iTerm2 and run the test script there. / 手动检查请在 iTerm2 运行。

## Future extensions 未来扩展
- If a lint tool is added, document its single-file invocation. / 新增 lint 工具时补充单文件命令。
- If a test framework is added, document how to run one test. / 新增测试框架时补充单测命令。
- Keep this file updated with new commands and conventions. / 变更后保持本文件更新。
