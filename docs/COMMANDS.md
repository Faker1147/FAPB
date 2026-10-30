# FAPB 命令与 Cvar 参考

主命令：

```text
fapb <subcommand> [args]
fb   <subcommand> [args]
```

`fb` 是 FAPB 保留的短命令别名。所有 Cvar 使用 `fb_` 前缀。

---

## 1. Bot 管理

| 命令 | 别名 | 说明 |
|---|---|---|
| `fapb add [skill] [team] [model]` | `addbot` | 添加一个 Bot |
| `fapb add_t` | `addbot_t` | 添加一个 T Bot |
| `fapb add_ct` | `addbot_ct` | 添加一个 CT Bot |
| `fapb addhs` | `addbot_hs` | 添加一个使用刀/手枪的 Bot（按原版行为） |
| `fapb fill` | `fillserver` | 用 Bot 填满服务器 |
| `fapb kick` | `kickone` | 随机踢出一个 Bot |
| `fapb kick_t` | `kickbot_t` | 踢出一个 T Bot |
| `fapb kick_ct` | `kickbot_ct` | 踢出一个 CT Bot |
| `fapb kickall` | `kickbots` | 踢出全部 Bot |
| `fapb killbots` | `killall` | 杀死全部 Bot |
| `fapb kill_t` | `killbots_t` | 杀死全部 T Bot |
| `fapb kill_ct` | `killbots_ct` | 杀死全部 CT Bot |
| `fapb list` | `listbots` | 列出当前 Bot |
| `fapb swap` | `swaptteams` | 交换 Bot 队伍 |
| `fapb weaponmode` | `wmode` | 设置 Bot 武器模式 |
| `fapb order <bot> <command>` | `sendcmd` | 对指定 Bot 下命令 |
| `fapb votemap` | — | 让死亡的 Bot 投票选图 |

## 2. 菜单

| 命令 | 别名 | 说明 |
|---|---|---|
| `fapb cmenu` | `cmdmenu` / `menu` / `botmenu` | 打开 FAPB 控制菜单 |
| `fapb help` | `?` | 显示命令帮助 |
| `fapb version` | `ver` | 版本信息 |
| `fapb about` | `about_bot` | 关于信息 |
| `fapb time` | `ctime` | 显示服务器时间 |

菜单受口令保护，默认配置：

```text
fb_password_key "_fbpw"
fb_password     "thebot"
```

聊天框输入 `_fbpw thebot`，或使用 rcon 执行 `fapb cmenu`。

`fapb.cfg` 中还提供了 `fapb_menu` 别名，可直接绑定：

```text
bind "=" "fapb_menu"
```

### 2.1 队伍管理菜单（AMXX 伴侣插件）

需要 AMXX，并加载 `fapb_teams.amxx`（安装脚本会自动处理）。

| 命令 | 说明 |
|---|---|
| `fapb_teams` | 玩家控制台打开队伍管理菜单 |
| `fapb_team` | 同上（别名） |
| `fapb_bind [键]` | 绑定快捷键到 `fapb_teams`，默认 `v`；例如 `fapb_bind v`、`fapb_bind =` |
| `fapb_unbind [键]` | 解绑快捷键，默认 `v` |
| `say /fapbteams` | 聊天打开菜单 |
| `amx_fapb_teams` | 服务器控制台 / rcon，打印双方 Bot 列表 |

权限 Cvar：

```text
fapb_teams_access 1   ; 1 = ADMIN_MENU 管理员（默认），0 = 所有玩家
```

菜单项：

- T 队管理 / CT 队管理
  - 添加 1 个 Bot
  - 添加 5 个 Bot
  - 踢出 1 个 Bot
  - 踢出全部 Bot
  - 杀死全部 Bot
  - 查看 Bot 列表
  - 返回主菜单
- 双方总览 / 刷新
- 快速填充双方（`fapb fill`）
- 踢出全部 Bot（`fapb kickall`）
- 交换 T/CT（`fapb swap`）
- 快捷键设置（绑定/解绑 V、N、= 键）

快捷键绑定只影响执行命令的玩家本人，不会改服务器或其他玩家的
`config.cfg`。也可以直接在客户端控制台执行：

```text
bind v fapb_teams
```

> 该插件只调用 `fapb` 服务器命令，不修改 FAPB 的 AI 或瞄准参数。

## 3. 航点 / 路径

| 命令 | 说明 |
|---|---|
| `fapb wp` | 切换航点显示 |
| `fapb wp on` / `fapb wp off` | 显示 / 隐藏航点 |
| `fapb wp menu` | 航点主菜单 |
| `fapb wp add` | 打开航点创建菜单 |
| `fapb wp addbasic` | 在地图上生成基础航点 |
| `fapb wp cache` | 缓存最近航点 |
| `fapb wp check` | 检查航点连接 |
| `fapb wp find` | 显示到指定航点的方向 |
| `fapb wp load` | 从硬盘加载航点 |
| `fapb wp save [nocheck]` | 保存航点 |
| `fapb wp setradius` | 设置航点半径 |
| `fapb wp teleport` | 传送到指定航点 |
| `fapb wp mdl on/off` | 显示 / 隐藏航点模型 |
| `fapb autowp` | 切换自动航点 |
| `fapb deletewp` | 删除当前地图航点文件 |
| `fapb path create` | 打开路径创建菜单 |
| `fapb path create_both` | 创建双向连接 |
| `fapb path create_in` | 创建入向连接 |
| `fapb path create_out` | 创建出向连接 |
| `fapb path delete` | 删除到最近航点的路径 |
| `fapb path cache` | 缓存最近航点 |
| `fapb path autodistance` | 设置自动路径最大距离 |

`waypoint` / `wpt` / `pwp` 等是 `wp` 的旧别名；`pathwaypoint` 是 `path` 的别名。

## 4. 其他

| 命令 | 说明 |
|---|---|
| `fapb exp save` | 保存 Bot 经验数据 |
| `fapb wp on noclip` | 开启 noclip 辅助 (航点编辑) |

---

## Cvar（全部为 `fb_*`）

### Bot 管理

```text
fb_quota             自动添加的 Bot 数量（默认 10）
fb_autovacate        玩家进入时自动移出 Bot
fb_followpercent     跟随玩家的 Bot 比例
fb_followuser        跟随玩家的 Bot 数量
fb_minskill          随机 Bot 最低技能
fb_maxskill          随机 Bot 最高技能
fb_dangerfactor      经验系统的危险系数
fb_skilltags         是否在 Bot 名字后显示技能值
fb_stopbots          暂停所有 Bot
fb_forceteam         强制 Bot 加入的队伍
fb_nameprefix        Bot 名字前缀
fb_botbuy            Bot 是否自动购买
fb_restrictweapons   限制 Bot 使用的武器
fb_thruwalls         Bot 是否穿墙射击
fb_noshots           禁止 Bot 开枪（调试用）
fb_hardmode          困难模式
fb_ecorounds         经济回合
fb_knifemode         刀战模式
fb_tkpunish          团队杀手惩罚
fb_walkallow         允许 Bot 慢走
fb_spraypaints       允许 Bot 喷图
fb_chat              Bot 是否聊天
fb_synth             是否使用引擎语音
fb_csdmplay          CSDM 模式
fb_commtype          通讯类型
fb_msectype          毫秒类型
fb_aimtype           瞄准类型
fb_language          语言：chs / en / de
fb_chatterpath       聊天语音路径
fb_wptsubfolder      航点子目录
fb_loglevel          日志等级
fb_debug             调试模式
fb_debuggoal         调试目标
fb_thinkfps          Bot 思考频率（1-50）
fb_password          菜单口令
fb_password_key      聊天口令关键字
fb_version           版本 Cvar
```

### 瞄准 / 枪法参数

> 这些默认值就是 YAPB 2.55b 的原始参数。除非明确知道含义，否则不要修改，
> 以保持原版枪法。

```text
fb_aim_damper_coefficient_x
fb_aim_damper_coefficient_y
fb_aim_deviation_x
fb_aim_deviation_y
fb_aim_influence_x_on_y
fb_aim_influence_y_on_x
fb_aim_notarget_slowdown_ratio
fb_aim_offset_delay
fb_aim_spring_stiffness_x
fb_aim_spring_stiffness_y
fb_aim_target_anticipation_ratio
```

配置位置：

```text
cstrike/addons/fapb/config/fapb.cfg
cstrike/addons/fapb/config/fapb_against.cfg
```

修改后重开地图或重启服务器生效。
