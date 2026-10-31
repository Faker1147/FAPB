# FAPB 故障排查

## 闪退：hl.exe 在 fapb.dll 0x18173 崩溃

典型 Windows 事件日志：

```text
出错应用程序: hl.exe
出错模块:     fapb.dll
异常代码:     0xc0000005
错误偏移:     0x00018173
```

### 原因

该偏移处代码读取 FAPB 的运行时全局指针（RVA `0xB3548`）。
正常 FAPB-only 环境中该指针会在初始化阶段被赋值；如果同时加载多套
Bot 核心，Metamod Hook 链/初始化顺序被破坏，指针保持 NULL，打开菜单
或执行相关逻辑时就会访问冲突。

常见冲突项：

```text
yapb/bin/yapb.dll
sypb/dlls/sypb.dll
podbot/podbot_mm.dll
ebot/dlls/ebot.dll
csbot_enabler/csbot_enabler_mm.dll
amxmodx_bl_mm.dll（与 amxmodx_mm.dll 同时加载）
```

### 修复

`cstrike/addons/metamod/plugins.ini` 只保留一套 Bot 核心：

```ini
win32 addons/amxmodx/dlls/amxmodx_mm.dll
win32 addons/fapb/dlls/fapb.dll
```

其余 Bot 核心行前加 `;`。不要同时启用 YAPB、SYPB、PODBot、EBot、
CSBot Enabler 中的任何两个。

FAPB 1.6 的 `install_fapb.ps1` 会自动完成这一步，并备份原
`plugins.ini`：

```powershell
powershell -ExecutionPolicy Bypass -File .\install_fapb.ps1 -GameDir "D:\Counter Strike 8684(多BOT版)"
```

如果确实要保留其他 Bot，使用 `-KeepOtherBots`，但 FAPB 与其他 Bot
同时运行不受支持，闪退是预期结果。

### 切换 Bot

- 用 FAPB：只启用 `addons/fapb/dlls/fapb.dll`
- 用 YAPB：注释 FAPB，只启用 `addons/yapb/bin/yapb.dll`
- 用 SYPB：注释 FAPB/YAPB，只启用 `addons/sypb/dlls/sypb.dll`

改完 `plugins.ini` 后重启服务器/游戏。

## 菜单按键无效

确认客户端使用的是 `fapb menu`，并且没有残留 YAPB 绑定：

```text
bind "v" "fapb menu"
setinfo "_fbpw" "thebot"
```

中文模式还要检查 `cstrike_schinese/config.cfg` / `userconfig.cfg`。

## 菜单打不开

菜单受 FAPB 口令保护：

```text
fb_password_key "_fbpw"
fb_password     "thebot"
```

在聊天框输入 `_fbpw thebot`，或用 rcon 执行 `fapb menu`。
