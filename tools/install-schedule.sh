#!/usr/bin/env bash
# 定时自动整理（macOS launchd）。默认不启用，手动执行才装上。
#
#   tools/install-schedule.sh install [小时]   # 安装，默认每天 21:00 触发
#   tools/install-schedule.sh status           # 查看状态
#   tools/install-schedule.sh remove           # 卸载
#
# 触发时会运行： <仓库>/tools/kb process --run
# 你可以用环境变量 KB_AGENT_CMD 指定 AI CLI，默认 "opencode run"。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LABEL="com.knowleger.organize"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
HOUR="${2:-21}"
KB="$ROOT/tools/kb"
LOG="$ROOT/.kb-schedule.log"

case "${1:-status}" in
  install)
    mkdir -p "$HOME/Library/LaunchAgents"
    cat > "$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string><string>-lc</string>
    <string>cd "$ROOT" && python3 "$KB" process --run >> "$LOG" 2>&1</string>
  </array>
  <key>StartCalendarInterval</key><dict><key>Hour</key><integer>$HOUR</integer><key>Minute</key><integer>0</integer></dict>
  <key>StandardOutPath</key><string>$LOG</string>
  <key>StandardErrorPath</key><string>$LOG</string>
</dict></plist>
PLISTEOF
    launchctl unload "$PLIST" 2>/dev/null || true
    launchctl load "$PLIST"
    echo "✓ 已安装：每天 $HOUR:00 自动整理，日志：$LOG"
    echo "  首次可能需要在「系统设置 → 隐私与安全性」授权。"
    ;;
  remove)
    launchctl unload "$PLIST" 2>/dev/null || true
    rm -f "$PLIST"
    echo "✓ 已卸载定时任务"
    ;;
  status)
    if launchctl list | grep -q "$LABEL"; then echo "● 已启用"; launchctl list | grep "$LABEL"
    else echo "○ 未启用（运行 tools/install-schedule.sh install 开启）"; fi
    ;;
  *)
    echo "用法：tools/install-schedule.sh {install|status|remove} [小时]"; exit 1;;
esac
