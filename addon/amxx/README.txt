FAPB Team Menu (AMX Mod X)
==========================

这是 FAPB 的独立队伍管理菜单，插件本身不改 FAPB/YAPB 的 AI，
只通过服务器命令调用 fapb add_t / fapb kick_t 等功能。

菜单使用经典数字界面（1-7 选择，0 退出），与 YAPB 菜单的操作方式一致。

安装（手动）
------------
1. 把 fapb_teams.amxx 复制到：
     cstrike/addons/amxmodx/plugins/fapb_teams.amxx
2. 在 cstrike/addons/amxmodx/configs/plugins.ini 末尾添加：
     fapb_teams.amxx
3. 重开地图或重启服务器。

命令
----
  fapb_teams        玩家控制台打开菜单
  fapb_bind [键]    绑定快捷键（默认 V），例如 fapb_bind v / fapb_bind =
  fapb_unbind [键]  解绑快捷键（默认 V）
  say /fapbteams    聊天打开菜单
  amx_fapb_teams    服务器控制台 / rcon（打印双方 Bot 列表）

Cvar
----
  fapb_teams_access 1
      1 = 只有 ADMIN_MENU 管理员可以打开（默认）
      0 = 所有玩家可以打开

菜单内容
--------
  T 队管理 / CT 队管理
    添加 1 个 Bot
    添加 5 个 Bot
    踢出 1 个 Bot
    踢出全部 Bot
    杀死全部 Bot
    查看 Bot 列表
    返回主菜单
  双方总览 / 刷新
  快速填充双方 (fapb fill)
  踢出全部 Bot (fapb kickall)
  交换 T/CT (fapb swap)
  快捷键设置 (Hotkey)
    绑定 V / N / = 键
    解绑 V / N / = 键

编译信息
--------
  AMX Mod X Compiler 1.8.1-300
  1.8.1 include 文件
  fapb_teams.sma 为 UTF-8 源码
