======================================================================
 FAPB 1.5 —— Counter-Strike 1.6 第三方人机
 核心：YAPB 2.55b（枪法 / 瞄准 / 行为逻辑完整保留）
======================================================================

一、FAPB 是什么？
----------------------------------------------------------------------
FAPB 是把 yapb.zip 中的 YAPB 2.55b 核心完整保留下来，重新命名而成的
第三方 Bot。它不是重新写的一套 AI，而是对原 YAPB 核心做“换名”：

  * 枪法、瞄准系统（aim spring / damper / deviation 等）原样保留；
  * 战术行为、经验系统、武器选择、菜单逻辑原样保留；
  * 只修改了：插件名、控制台命令、Cvar 前缀、配置/航点路径、显示文字；
  * 因此 FAPB 的 Bot 表现与 YAPB 2.55b 一致，但拥有完全独立的命令空间。

独立命名空间：
  主命令        fapb         （兼容旧短命令 fb）
  主菜单        fapb menu    （快捷别名 fapb_menu）
  控制菜单      fapb cmenu
  所有 Cvar     fb_*         （例如 fb_quota、fb_minskill）
  配置目录      addons/fapb/config/
  航点目录      addons/fapb/wptdefault/

二、文件结构
----------------------------------------------------------------------
cstrike/addons/fapb/
  dlls/fapb.dll                 FAPB 核心（32 位 Metamod 插件）
  config/fapb.cfg               主配置（Bot 数量、技能、聊天、菜单口令等）
  config/fapb_against.cfg       “对战模式”配置（quota=9）
  config/general.cfg            性格、经济、技能参数
  config/chatter.cfg            Bot 聊天语句
  config/language/*.cfg         中/英/德文菜单与聊天语言
  wptdefault/                   YAPB 格式航点（.pwf，455 个文件）
  README_FAPB.txt               本说明
  plugins.ini.example           Metamod 加载示例
  install_fapb.ps1              一键安装脚本（可选）

三、安装（手动）
----------------------------------------------------------------------
1. 关闭 CS 1.6 / HLDS。
2. 把整个 fapb 文件夹复制到：
      <游戏根目录>\cstrike\addons\fapb
   最终应存在：
      <游戏根目录>\cstrike\addons\fapb\dlls\fapb.dll
3. 编辑 <游戏根目录>\cstrike\addons\metamod\plugins.ini：
      ; win32 addons/yapb/dlls/yapb.dll
      win32 addons/fapb/dlls/fapb.dll
   注意：使用 FAPB 时请把 YAPB 那一行注释掉（行首加 ;）。
4. 确认 <游戏根目录>\cstrike\liblist.gam 中：
      gamedll "addons\metamod\dlls\metamod.dll"
5. 启动游戏/服务器，控制台执行：
      meta list
      fapb version
   能看到 FAPB 即加载成功。

也可以运行 install_fapb.ps1 自动复制并修改 plugins.ini（会先备份）。

四、独立命令菜单
----------------------------------------------------------------------
  fapb menu         打开 FAPB 主菜单（推荐，数字菜单）
  fapb_menu         同上（fapb.cfg 中定义的别名）
  fapb cmenu        打开 FAPB 控制菜单
  fapb wp menu      打开航点主菜单
  fapb help         显示全部子命令帮助

默认情况下菜单受口令保护，相关配置在 fapb.cfg：
  fb_password_key "_fbpw"
  fb_password     "thebot"
聊天框输入口令（默认 _fbpw thebot）可获得菜单权限；也可以直接用
rcon 执行 fapb menu。修改口令后记得同步修改 fb_password。

  【原生队伍管理菜单（无需 AMXX）】
  bind "v" "fapb menu"

  按 V 打开 FAPB 主菜单，再按 1 进入【队伍管理】：
    1. 快速添加 Bot（随机队伍）
    2. 添加 Bot（选择 T/CT） -> 1 恐怖分子 / 2 反恐精英 / 5 自动
    3. 随机踢出 1 个 Bot
    4. 踢出全部 Bot
    5. 踢出指定 Bot（列表）
    0. 退出

  fapb.cfg 中已经写入 bind "v" "fapb menu"。
  该菜单由 fapb.dll 自己弹出，完全不需要 AMXX。

五、常用命令
----------------------------------------------------------------------
  fapb add [skill] [team] [model]   添加一个 Bot
  fapb addbot ...                   同上（兼容旧写法）
  fapb add_t / fapb add_ct          添加 T / CT Bot
  fapb fill                         把服务器填满 Bot
  fapb kick                         随机踢一个 Bot
  fapb kickall                      踢出全部 Bot
  fapb kick_t / fapb kick_ct        踢 T / CT 的一个 Bot
  fapb killbots                     杀死全部 Bot
  fapb list                         列出当前 Bot
  fapb weaponmode                   设置 Bot 武器模式
  fapb order <bot> <command>        对指定 Bot 下命令
  fapb version                      显示版本
  fapb about                        显示关于信息
  fapb wp on / off                  显示/隐藏航点
  fapb wp menu                      航点主菜单
  fapb path create                  创建双向路径
  fapb path create_both             创建双向连接
  fapb path create_in / create_out  创建单向连接
  fapb exp save                     保存经验数据

完整列表以控制台 `fapb help` 为准。

六、常用 Cvar（全部为 fb_ 前缀）
----------------------------------------------------------------------
  fb_quota            自动添加的 Bot 数量（fapb.cfg 默认 10）
  fb_autovacate       玩家进入时自动移出 Bot（默认 1）
  fb_minskill         随机 Bot 最低技能（默认 95）
  fb_maxskill         随机 Bot 最高技能（默认 100）
  fb_aimtype          瞄准类型（默认 3）
  fb_chat             Bot 是否聊天（默认 0）
  fb_language         语言：chs / en / de（默认 chs）
  fb_password         菜单口令
  fb_password_key     聊天口令关键字
  fb_restrictweapons  限制 Bot 使用的武器
  fb_wptsubfolder     航点子目录
  fb_thinkfps         Bot 思考频率（1-50）
  fb_aim_*            高级瞄准参数（弹簧/阻尼/偏差，非必要不要改）

主配置：addons/fapb/config/fapb.cfg
对战配置：addons/fapb/config/fapb_against.cfg
修改后重开地图或重启服务器生效。

七、与 YAPB / SYPB 等第三方人机的兼容性
----------------------------------------------------------------------
1. 命令/Cvar 不冲突
   FAPB 使用 fapb / fb / fb_*；YAPB 使用 yapb / yb / yb_*。
   两者可以同时“安装”在同一台服务器上，互不覆盖配置文件、航点和命令。

2. 航点格式兼容
   FAPB 读取 YAPB/PODBot 的 .pwf 航点；wptdefault 已随包复制一份。
   也可以把已有 .pwf 放进 addons/fapb/wptdefault/ 或地图对应的
   maps/ 配置目录。

3. 运行时的限制（重要）
   YAPB、SYPB、FAPB 都属于“Bot 核心”，都会接管 Bot 管理、引擎回调、
   say/menuselect 等事件。同一时间只能启用一套 Bot 核心：
     - 用 FAPB：注释 yapb.dll / sypb.dll，只留 fapb.dll；
     - 用 YAPB：注释 fapb.dll，恢复 yapb.dll；
     - 用 SYPB：注释 fapb.dll / yapb.dll，只留 SYPB。
   同时加载两套 Bot 核心会出现重复 Bot、抢 Hook、菜单错乱甚至崩溃，
   这不是 FAPB 特有现象，YAPB 与 SYPB 混用也一样。

4. 与 AMX Mod X 共存
   FAPB 是 Metamod 插件，不依赖 AMXX，也不会修改 AMXX 配置；
   可以与 AMXX 一起加载。FAPB 的菜单是插件内置菜单，不是 AMXX 菜单。

八、常见问题
----------------------------------------------------------------------
Q: `meta list` 里没有 FAPB？
A: 检查 plugins.ini 路径是否为 addons/fapb/dlls/fapb.dll；
   检查 fapb.dll 是否为 32 位；查看 HLDS 控制台报错。

Q: 进游戏没有 Bot？
A: 执行 `fapb fill`，或把 fapb.cfg 的 fb_quota 改为 10 后重开地图。

Q: 菜单没反应？
A: 菜单默认需要口令/RCON。用 rcon 执行 `fapb menu`，
   或在聊天框输入 `_fbpw thebot` 后再试。

Q: 想恢复 YAPB？
A: 在 plugins.ini 中注释 fapb.dll，取消注释 yapb.dll，重开服务器。
   FAPB 没有覆盖 YAPB 的文件。

Q: 修改 fb_aim_* 会影响枪法吗？
A: 会。默认值就是 YAPB 2.55b 的原始瞄准参数；除非明确知道含义，
   否则不要修改，以保持原汁原味的枪法。

九、版本与来源
----------------------------------------------------------------------
FAPB 1.5
核心版本：YAPB 2.55b（YaPB Dev Team，基于 PODBot 代码）
制作方式：从 yapb.zip 的 yapb.dll 解包，重命名插件/命令/Cvar/路径，
          重建 PE 与重定位表；未改动 AI、瞄准、行为代码。
版权：YAPB 为 GPL 开源项目；再分发时请遵守其许可证并保留原作者署名。
======================================================================
