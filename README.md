# Codex Token Cost

给 Codex++ 用的本地 token / 费用统计脚本。

主脚本会在 Codex 输入框上方显示本轮、会话和今日用量，也会在本地解锁官方 Profile 页面。helper 是可选的，不开也能用；开了以后可以补充 CC Switch、Codex SQLite 线程数、skill / plugin 统计。

## 文件

- `scripts/codex-live-token-cost.js`：主脚本。
- `scripts/codex-local-usage-helper.cjs`：可选 helper。
- `scripts/start-helper.ps1`：Windows helper 启动脚本。
- `scripts/start-helper.sh`：macOS / POSIX helper 启动脚本。

## 安装主脚本

Windows：

```powershell
Copy-Item .\scripts\codex-live-token-cost.js "$env:APPDATA\Codex++\user_scripts\market-codex-live-token-cost.js" -Force
```

macOS：

```sh
mkdir -p "$HOME/Library/Application Support/Codex++/user_scripts"
cp ./scripts/codex-live-token-cost.js "$HOME/Library/Application Support/Codex++/user_scripts/market-codex-live-token-cost.js"
```

然后重启 Codex，或重新加载 Codex++ 用户脚本。

## 启动 helper

Windows 手动启动：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\start-helper.ps1
```

macOS 手动启动：

```sh
sh ./scripts/start-helper.sh
```

检查是否启动成功：

Windows：

```powershell
Invoke-RestMethod http://127.0.0.1:17888/stats
```

macOS：

```sh
curl -fsS http://127.0.0.1:17888/stats
```

helper 没启动时，主 HUD 和本地 Profile 仍然可用。受影响的是 CC Switch 同步、Codex SQLite 线程数、skill / plugin 统计。

## 设置 helper 开机自启

Windows：

在仓库目录运行：

```powershell
$script = (Resolve-Path .\scripts\start-helper.ps1).Path
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName "CodexTokenCostHelper" -Action $action -Trigger $trigger -Settings $settings -Description "Start Codex Token Cost local helper" -Force
Start-ScheduledTask -TaskName "CodexTokenCostHelper"
```

取消自启：

```powershell
Unregister-ScheduledTask -TaskName "CodexTokenCostHelper" -Confirm:$false
```

macOS：

在仓库目录运行，命令会把当前路径写入 LaunchAgent：

```sh
mkdir -p "$HOME/Library/LaunchAgents"
cat > "$HOME/Library/LaunchAgents/com.tianzora.codex-token-cost-helper.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.tianzora.codex-token-cost-helper</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/sh</string>
    <string>REPO_PATH/scripts/start-helper.sh</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
  </dict>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <false/>
  <key>StandardOutPath</key>
  <string>/tmp/codex-token-cost-helper.launchd.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/codex-token-cost-helper.launchd.err</string>
</dict>
</plist>
PLIST
REPO_PATH="$(pwd)" perl -0pi -e 's|REPO_PATH|$ENV{REPO_PATH}|g' "$HOME/Library/LaunchAgents/com.tianzora.codex-token-cost-helper.plist"
launchctl bootstrap "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.tianzora.codex-token-cost-helper.plist"
launchctl kickstart -k "gui/$(id -u)/com.tianzora.codex-token-cost-helper"
```

取消自启：

```sh
launchctl bootout "gui/$(id -u)" "$HOME/Library/LaunchAgents/com.tianzora.codex-token-cost-helper.plist" 2>/dev/null || true
rm -f "$HOME/Library/LaunchAgents/com.tianzora.codex-token-cost-helper.plist"
```

## 要求

- Windows 或 macOS
- Codex 桌面端
- Codex++
- Node.js（只在使用 helper 时需要）
- Python 3 或可用的 `python`（只在 helper 读取 SQLite 统计时需要）

## 隐私

数据只保存在本机。主脚本写入浏览器 `localStorage`；helper 只读取本机 Codex session、Codex SQLite 和 CC Switch 数据。
