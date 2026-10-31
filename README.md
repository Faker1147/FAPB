# FAPB — Counter-Strike 1.6 第三方人机

> **FAPB** 是一个独立命名的 CS 1.6 Metamod Bot，核心来自 **YAPB 2.55b**。
> 枪法、瞄准系统、战术行为和经验系统完整保留；只重命名插件、命令、Cvar、
> 配置/航点路径和菜单文字，因此 FAPB 拥有完全独立的命令空间和菜单。

[![Release](https://img.shields.io/github/v/release/Faker1147/FAPB?include_prereleases&label=release)](https://github.com/Faker1147/FAPB/releases)
[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](LICENSE)

---

## 特性

- **原汁原味的枪法**：YAPB 2.55b 的 aim spring / damper / deviation 参数原样保留。
- **原汁原味的行为**：战术、经验、武器选择、航点系统、聊天逻辑未改动。
- **独立命令**：`fapb`（兼容短命令 `fb`）。
- **独立 Cvar**：全部为 `fb_*`，不会与 YAPB 的 `yb_*` 冲突。
- **独立菜单**：`fapb menu`、`fapb cmenu`、`fapb wp menu`，菜单文字与标题均为 FAPB。
- **独立配置/航点**：`addons/fapb/config/`、`addons/fapb/wptdefault/`。
- **原生队伍管理数字菜单**：`fapb menu` → `1`，由 fapb.dll 直接弹出，
  经典 1-0 数字界面；可选 T/CT 添加 Bot、随机踢出、全部踢出、指定 Bot 列表。
  支持 `bind v "fapb menu"`，完全不需要 AMXX。
- **可与 YAPB / SYPB 共存安装**：不覆盖对方文件，命令/Cvar 命名空间隔离。

> 运行层面同一时间只能启用一套 Bot 核心（FAPB、YAPB、SYPB 任选其一）。
> 原因见下方[兼容性](#兼容性重要)章节。

---

## 下载与安装

### 方式 A：完整包（推荐）

从 [Releases](https://github.com/Faker1147/FAPB/releases/latest) 下载 **FAPB_1.6.zip**，解压后把 `fapb` 文件夹放到：

```text
<游戏根目录>\cstrike\addons\fapb
```

编辑 `<游戏根目录>\cstrike\addons\metamod\plugins.ini`：

```ini
; 使用 FAPB 时注释掉 YAPB，避免两套 Bot 核心同时运行
; win32 addons/yapb/dlls/yapb.dll
win32 addons/fapb/dlls/fapb.dll
```

确认 `cstrike/liblist.gam` 中：

```text
gamedll "addons\metamod\dlls\metamod.dll"
```

启动游戏/服务器后，控制台执行：

```text
meta list
fapb version
```

### 方式 B：从本仓库克隆

本仓库的 `addon/` 不含完整航点数据（94 张地图的 `.pwf` 及配套文件，共 455 个，约 170 MB）。克隆后：

1. 把 `addon/` 复制为 `cstrike/addons/fapb/`；
2. 从 Release 包或已有 YAPB 安装中复制 `wptdefault/` 到 `cstrike/addons/fapb/wptdefault/`；
3. 按上面的 `plugins.ini` 配置加载。

也可以直接运行 `addon/install_fapb.ps1`（需要 PowerShell，脚本会备份 `plugins.ini`）。

---

## 命令与菜单

```text
fapb menu           打开 FAPB 主菜单（数字菜单，推荐）
fapb_menu           同上（fapb.cfg 中的别名）
fapb cmenu          打开 FAPB 控制菜单
fapb wp menu        航点主菜单
fapb help           显示全部命令
```

常用命令：

| 命令 | 作用 |
|---|---|
| `fapb add [skill] [team] [model]` | 添加一个 Bot |
| `fapb addbot ...` | 同上（兼容旧写法） |
| `fapb add_t` / `fapb add_ct` | 添加 T / CT Bot |
| `fapb fill` | 用 Bot 填满服务器 |
| `fapb kick` / `fapb kickall` | 踢一个 / 全部 Bot |
| `fapb killbots` | 杀死全部 Bot |
| `fapb list` | 列出当前 Bot |
| `fapb weaponmode` | 设置 Bot 武器模式 |
| `fapb version` / `fapb about` | 版本 / 关于 |
| `fapb wp on` / `fapb wp off` | 显示 / 隐藏航点 |
| `fapb path create` | 创建路径 |

完整命令和 Cvar 列表见 **[docs/COMMANDS.md](docs/COMMANDS.md)**。

默认菜单口令在 `fapb.cfg`：

```text
fb_password_key "_fbpw"
fb_password     "thebot"
```

聊天框输入 `_fbpw thebot` 获取菜单权限，或直接用 rcon 执行 `fapb menu`。

### 原生队伍管理菜单（无需 AMXX）

`fapb menu` 由 **fapb.dll 本身**弹出经典 1-0 数字主菜单，不需要 AMXX。
主菜单第 1 项已经改为“队伍管理”：

```text
FAPB 主菜单
1. 队伍管理      ← 进入队伍管理
2. 特性
3. 填充服务器
4. 结束本局
0. 退出
```

进入“队伍管理”后：

```text
FAPB 队伍管理
1. 快速添加 Bot（随机队伍）
2. 添加 Bot（选择 T/CT）  → 1 恐怖分子 / 2 反恐精英 / 5 自动
3. 随机踢出 1 个 Bot
4. 踢出全部 Bot
5. 踢出指定 Bot（列表）
0. 退出
```

绑定按键（客户端控制台执行一次）：

```text
bind v "fapb menu"
```

然后按 `V` → `1` 进入队伍管理。`fapb.cfg` 中也已经写入同样的
`bind "v" "fapb menu"`。

菜单本身仍受 FAPB 口令保护：

```text
fb_password_key "_fbpw"
fb_password     "thebot"
```

聊天框输入 `_fbpw thebot`，或用 rcon 执行 `fapb menu`。

> 这是 fapb.dll 自带的原生菜单（只改了中文标签/快捷键），不是新写的
> T/CT 仪表盘。新增独立 T/CT 子菜单需要重新编译 YAPB 源码。

---

## 兼容性（重要）

### 命令 / 文件层面

| 项目 | FAPB | YAPB |
|---|---|---|
| 主命令 | `fapb` / `fb` | `yapb` / `yb` |
| Cvar | `fb_*` | `yb_*` |
| 菜单 | `fapb menu` / `fapb cmenu` | `yapb menu` / `yapb cmenu` |
| 配置 | `addons/fapb/config/` | `addons/yapb/config/` |
| 航点 | `addons/fapb/wptdefault/` | `addons/yapb/wptdefault/` |

FAPB 读取 YAPB / PODBot 的 `.pwf` 航点格式，因此可以复用已有航点文件。
安装 FAPB 不会修改 YAPB 或 SYPB 的文件。

### 运行层面

YAPB、SYPB、FAPB 都属于“Bot 核心”，都会接管 Bot 管理、引擎回调、
`say` / `menuselect` 等事件。**同一时间只能启用一套 Bot 核心**：

- 用 FAPB：注释 `yapb.dll` / `sypb.dll`，只留 `fapb.dll`；
- 用 YAPB：注释 `fapb.dll`，恢复 `yapb.dll`；
- 用 SYPB：注释 `fapb.dll` / `yapb.dll`，只留 SYPB。

同时加载两套 Bot 核心会出现重复 Bot、抢 Hook、菜单错乱甚至崩溃。
这不是 FAPB 特有现象，YAPB 与 SYPB 混用也一样。

> 如果游戏目录里的“YAPB 对战/训练模式”启动器会重写 `plugins.ini`，
> 启动后请检查是否又把 `yapb.dll` 启用了。

### 闪退排查

如果 `hl.exe` 崩溃且 Windows 事件日志显示模块为 `fapb.dll`，
错误偏移为 `0x18173`、异常代码 `0xc0000005`，通常不是菜单本身，
而是**同时加载了多套 Bot 核心**：

- YAPB / SYPB / PODBot / EBot / CSBot Enabler
- AMXX 的 `amxmodx_mm.dll` 与 `amxmodx_bl_mm.dll` 同时加载

这会让 FAPB 的 Hook 链初始化不完整，运行时指针保持 NULL，按菜单时崩溃。
请只保留：

```ini
win32 addons/amxmodx/dlls/amxmodx_mm.dll
win32 addons/fapb/dlls/fapb.dll
```

FAPB 1.6 的 `install_fapb.ps1` 会自动注释其他 Bot 核心和重复的
`amxmodx_bl_mm.dll`。详细说明见
[docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)。

---

## 实测

环境：HLDS 1.1.2.5 (build 3262) + Metamod 1.19 + AMXX 1.8.1

```text
meta list
  [ 3] FAPB             RUN   -    fapb.dll          v2.55b    ini  Start Never

fapb version
  Name: FAPB
  Version: 2.55b (Build: 1966)
  Builded by: YaPB Dev Team

[FAPB] Connecting FAPB... (Skill 95~100)
```

`fapb menu` 与 `fapb help` 均已在 HLDS 控制台验证。

---

## 仓库结构

```text
addon/                 可直接安装的 FAPB 插件（不含 wptdefault）
  dlls/fapb.dll        已重命名/重建的 32 位 Metamod 插件
  config/              FAPB 配置（fb_* Cvar）
  install_fapb.ps1     安装脚本
  README_FAPB.txt      详细中文说明
  BUILD_INFO.txt       版本与哈希
tools/                 二进制级构建工具与原始 YAPB 样本
  artifacts/           原始 yapb.dll、两份内存 dump、原始配置
  make_dumpme.py       让 UPX 解包后跳过 DllMain
  dump32.ps1           32 位 PowerShell 内存 dump
  build_fapb.py        恢复重定位表、重命名、重建 PE
  make_configs.py      生成 FAPB 配置
docs/COMMANDS.md       命令 / Cvar 参考
```

完整航点包在 Release 的 `FAPB_1.6.zip` 中。

---

## 构建说明

`yapb.zip` 中只有 UPX 压缩后的 `yapb.dll`，没有源码。为了做到“保留原枪法、
瞄准和行为”，本项目采用**二进制级 FAPB 化**：

1. 修改 UPX stub，让解包完成后跳过 DllMain；
2. 分别在首选基址 `0x10000000` 和阻塞该基址的情况下 dump 内存镜像；
3. 对比两份镜像，恢复 UPX 破坏掉的全部重定位地址；
4. 只替换插件/命令/Cvar/路径字符串，重建 PE 和 `.reloc`；
5. 从原始 YAPB 配置生成 `fb_*` 配置。

AI 代码、瞄准参数、行为逻辑均未修改。构建脚本见 [tools/README.md](tools/README.md)。

原生队伍菜单使用 fapb.dll 内置的 `fapb menu`，只改了中文标签和
`fapb.cfg` 中的 V 键绑定，不需要 AMXX。

复现构建：

```powershell
# 需要 Windows + Python 3 + 32 位 PowerShell
python tools/make_dumpme.py
%WINDIR%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -File tools\dump32.ps1 `
  -Dll tools/artifacts/yapb_dumpme.dll -Out tools/artifacts/yapb_b1.bin -Block 0
%WINDIR%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -File tools\dump32.ps1 `
  -Dll tools/artifacts/yapb_dumpme.dll -Out tools/artifacts/yapb_b2.bin -Block 1
python tools/build_fapb.py
python tools/make_configs.py
```

`build_fapb.py` 输出的 DLL SHA256 应为：

```text
606e7a6ab8793553847bcbf2d5665d29edea0b3529eaca537d7e76de7b6e3553
```

---

## 致谢与许可

- 核心：**YAPB 2.55b**，作者 YaPB Dev Team，基于 PODBot 代码。
  上游：<https://github.com/yapb/yapb>（Unlicense）。
- FAPB 只是非官方重命名/重打包版本，与 YAPB 官方无关。
- 本仓库中的脚本、文档和 FAPB 构建产物采用 **Unlicense**（公共领域）。
  原始 YAPB 代码/二进制同样遵循其上游 Unlicense。
- 详细归属与变更说明见 [NOTICE.md](NOTICE.md)。

> FAPB 按“现状”提供，不提供任何担保；使用前请备份 `plugins.ini` 和服务器配置。
