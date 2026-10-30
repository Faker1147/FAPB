/*
 * FAPB Team Menu (classic numeric menu)
 * -------------------------------------
 * A standalone AMX Mod X companion menu for FAPB.
 * Uses the old-style numbered menu (1-0), like YAPB's in-game menus.
 *
 * Commands:
 *   fapb_teams            client console
 *   fapb_team             alias
 *   fapb_bind [key]       bind a key (default V)
 *   fapb_unbind [key]     unbind a key (default V)
 *   say /fapbteams        chat
 *   amx_fapb_teams        server console / rcon overview
 *
 * Cvar:
 *   fapb_teams_access 1   1 = ADMIN_MENU only (default), 0 = everyone
 */

#include <amxmodx>
#include <amxmisc>

#define PLUGIN  "FAPB Team Menu"
#define VERSION "1.3"
#define AUTHOR  "FAPB"

#define TEAM_T  1
#define TEAM_CT 2

// 1,2,3,4,5,6,7 and 0
#define MENU_KEYS 639

new g_access;
new g_menu_main;
new g_menu_team_t;
new g_menu_team_ct;
new g_menu_hotkey;
new const g_team_names[][] = { "", "T", "CT" };

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    g_access = register_cvar("fapb_teams_access", "1");

    register_clcmd("fapb_teams", "cmd_teams");
    register_clcmd("fapb_team", "cmd_teams");
    register_clcmd("fapb_bind", "cmd_bind");
    register_clcmd("fapb_unbind", "cmd_unbind");
    register_clcmd("amx_fapb_teams", "cmd_teams");
    register_srvcmd("fapb_teams", "cmd_srv_teams");
    register_srvcmd("fapb_team", "cmd_srv_teams");
    register_srvcmd("amx_fapb_teams", "cmd_srv_teams");
    register_clcmd("say /fapbteams", "cmd_say_teams");
    register_clcmd("say_team /fapbteams", "cmd_say_teams");

    g_menu_main = register_menuid("FAPB Team Menu");
    register_menucmd(g_menu_main, 1023, "menu_main");

    g_menu_team_t = register_menuid("FAPB Team Menu: T");
    register_menucmd(g_menu_team_t, 1023, "menu_team_t");

    g_menu_team_ct = register_menuid("FAPB Team Menu: CT");
    register_menucmd(g_menu_team_ct, 1023, "menu_team_ct");

    g_menu_hotkey = register_menuid("FAPB Team Menu: Hotkey");
    register_menucmd(g_menu_hotkey, 1023, "menu_hotkey");
}

public plugin_cfg()
{
    server_print("[FAPB] Team menu loaded. Use: fapb_teams | fapb_bind v | say /fapbteams");
}

public cmd_say_teams(id)
{
    cmd_teams(id);
    return PLUGIN_HANDLED;
}

public cmd_teams(id)
{
    if (id == 0)
    {
        print_overview(0);
        return PLUGIN_HANDLED;
    }

    if (get_pcvar_num(g_access) && !(get_user_flags(id) & ADMIN_MENU))
    {
        client_print(id, print_chat, "[FAPB] 你没有权限使用队伍管理菜单（需要 ADMIN_MENU）。");
        client_print(id, print_console, "[FAPB] 服务器可将 fapb_teams_access 设为 0 开放给所有玩家。");
        return PLUGIN_HANDLED;
    }

    show_main(id);
    return PLUGIN_HANDLED;
}

public cmd_srv_teams()
{
    print_overview(0);
    return PLUGIN_HANDLED;
}

public cmd_bind(id)
{
    if (!id)
    {
        server_print("[FAPB] fapb_bind is a player command. Use: fapb_bind v");
        return PLUGIN_HANDLED;
    }

    new key[16];
    read_argv(1, key, charsmax(key));
    if (!key[0])
        copy(key, charsmax(key), "v");

    if (!valid_key(key))
    {
        client_print(id, print_chat, "[FAPB] 快捷键名无效：%s（示例：v、n、=、F1、MOUSE3）", key);
        return PLUGIN_HANDLED;
    }

    client_cmd(id, "bind %s fapb_teams", key);
    client_print(id, print_chat, "[FAPB] 已绑定快捷键 %s -> 队伍管理菜单。", key);
    client_print(id, print_console, "[FAPB] bind %s fapb_teams", key);
    return PLUGIN_HANDLED;
}

public cmd_unbind(id)
{
    if (!id)
    {
        server_print("[FAPB] fapb_unbind is a player command. Use: fapb_unbind v");
        return PLUGIN_HANDLED;
    }

    new key[16];
    read_argv(1, key, charsmax(key));
    if (!key[0])
        copy(key, charsmax(key), "v");

    if (!valid_key(key))
    {
        client_print(id, print_chat, "[FAPB] 快捷键名无效：%s", key);
        return PLUGIN_HANDLED;
    }

    client_cmd(id, "unbind %s", key);
    client_print(id, print_chat, "[FAPB] 已解绑快捷键 %s。", key);
    return PLUGIN_HANDLED;
}

valid_key(const key[])
{
    new len = strlen(key);
    if (len < 1 || len > 15)
        return 0;

    for (new i = 0; i < len; i++)
    {
        new c = key[i];
        if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9'))
            continue;
        if (c == '_' || c == '-' || c == '=' || c == '[' || c == ']')
            continue;
        return 0;
    }
    return 1;
}

show_main(id)
{
    new tcount = count_bots(TEAM_T);
    new ctcount = count_bots(TEAM_CT);
    new text[512];

    formatex(text, charsmax(text),
        "\yFAPB 队伍管理\w   T:%d  CT:%d^n^n\
        \w1. T 队管理^n\
        \w2. CT 队管理^n\
        \w3. 双方总览 / 刷新^n\
        \w4. 快速填充双方 (fapb fill)^n\
        \w5. 踢出全部 Bot (fapb kickall)^n\
        \w6. 交换 T/CT (fapb swap)^n\
        \w7. 快捷键设置^n^n\
        \w0. 退出",
        tcount, ctcount);

    show_menu(id, MENU_KEYS, text, -1, "FAPB Team Menu");
}

public menu_main(id, key)
{
    switch (key)
    {
        case 0: show_team(id, TEAM_T);
        case 1: show_team(id, TEAM_CT);
        case 2:
        {
            print_overview(id);
            show_main(id);
        }
        case 3:
        {
            server_cmd("fapb fill");
            client_print(id, print_chat, "[FAPB] 已执行 fapb fill。");
            show_main(id);
        }
        case 4:
        {
            server_cmd("fapb kickall");
            client_print(id, print_chat, "[FAPB] 已踢出全部 Bot。");
            show_main(id);
        }
        case 5:
        {
            server_cmd("fapb swap");
            client_print(id, print_chat, "[FAPB] 已执行队伍交换。");
            show_main(id);
        }
        case 6: show_hotkey(id);
        case 9: return PLUGIN_HANDLED;
        default: show_main(id);
    }
    return PLUGIN_HANDLED;
}

show_team(id, team)
{
    new count = count_bots(team);
    new text[512];

    formatex(text, charsmax(text),
        "\y%s 队管理\w   当前 %d 个 Bot^n^n\
        \w1. 添加 1 个 Bot^n\
        \w2. 添加 5 个 Bot^n\
        \w3. 踢出 1 个 Bot^n\
        \w4. 踢出全部 Bot^n\
        \w5. 杀死全部 Bot^n\
        \w6. 查看 Bot 列表^n\
        \w7. 返回主菜单^n^n\
        \w0. 退出",
        g_team_names[team], count);

    if (team == TEAM_T)
        show_menu(id, MENU_KEYS, text, -1, "FAPB Team Menu: T");
    else
        show_menu(id, MENU_KEYS, text, -1, "FAPB Team Menu: CT");
}

public menu_team_t(id, key)
{
    handle_team(id, key, TEAM_T);
}

public menu_team_ct(id, key)
{
    handle_team(id, key, TEAM_CT);
}

handle_team(id, key, team)
{
    switch (key)
    {
        case 0:
        {
            add_bots(team, 1);
            show_team(id, team);
        }
        case 1:
        {
            add_bots(team, 5);
            show_team(id, team);
        }
        case 2:
        {
            kick_bots(team, 1);
            show_team(id, team);
        }
        case 3:
        {
            kick_bots(team, 0);
            show_team(id, team);
        }
        case 4:
        {
            kill_bots(team);
            show_team(id, team);
        }
        case 5:
        {
            print_team_bots(id, team);
            show_team(id, team);
        }
        case 6: show_main(id);
        case 9: return PLUGIN_HANDLED;
        default: show_team(id, team);
    }
    return PLUGIN_HANDLED;
}

show_hotkey(id)
{
    new text[512];

    formatex(text, charsmax(text),
        "\yFAPB 快捷键设置\w^n^n\
        \w1. 绑定 V 键^n\
        \w2. 绑定 N 键^n\
        \w3. 绑定 = 键^n\
        \w4. 解绑 V 键^n\
        \w5. 解绑 N 键^n\
        \w6. 解绑 = 键^n\
        \w7. 返回主菜单^n^n\
        \w0. 退出");

    show_menu(id, MENU_KEYS, text, -1, "FAPB Team Menu: Hotkey");
}

public menu_hotkey(id, key)
{
    switch (key)
    {
        case 0:
        {
            client_cmd(id, "bind v fapb_teams");
            client_print(id, print_chat, "[FAPB] 已绑定 V 键 -> 队伍管理菜单。");
        }
        case 1:
        {
            client_cmd(id, "bind n fapb_teams");
            client_print(id, print_chat, "[FAPB] 已绑定 N 键 -> 队伍管理菜单。");
        }
        case 2:
        {
            client_cmd(id, "bind = fapb_teams");
            client_print(id, print_chat, "[FAPB] 已绑定 = 键 -> 队伍管理菜单。");
        }
        case 3:
        {
            client_cmd(id, "unbind v");
            client_print(id, print_chat, "[FAPB] 已解绑 V 键。");
        }
        case 4:
        {
            client_cmd(id, "unbind n");
            client_print(id, print_chat, "[FAPB] 已解绑 N 键。");
        }
        case 5:
        {
            client_cmd(id, "unbind =");
            client_print(id, print_chat, "[FAPB] 已解绑 = 键。");
        }
        case 6: show_main(id);
        case 9: return PLUGIN_HANDLED;
        default: show_hotkey(id);
    }
    return PLUGIN_HANDLED;
}

add_bots(team, amount)
{
    for (new i = 0; i < amount; i++)
    {
        if (team == TEAM_T)
            server_cmd("fapb add_t");
        else
            server_cmd("fapb add_ct");
    }
}

kick_bots(team, amount)
{
    new count = count_bots(team);
    if (amount <= 0 || amount > count)
        amount = count;

    for (new i = 0; i < amount; i++)
    {
        if (team == TEAM_T)
            server_cmd("fapb kick_t");
        else
            server_cmd("fapb kick_ct");
    }
}

kill_bots(team)
{
    if (team == TEAM_T)
        server_cmd("fapb kill_t");
    else
        server_cmd("fapb kill_ct");
}

count_bots(team)
{
    new count = 0;
    for (new i = 1; i <= get_maxplayers(); i++)
    {
        if (!is_user_connected(i) || !is_user_bot(i))
            continue;
        if (get_user_team(i) == team)
            count++;
    }
    return count;
}

print_overview(id)
{
    new tcount = count_bots(TEAM_T);
    new ctcount = count_bots(TEAM_CT);
    new msg[128];

    formatex(msg, charsmax(msg), "[FAPB] 当前 Bot: T=%d  CT=%d", tcount, ctcount);
    if (id)
        client_print(id, print_chat, msg);
    else
        server_print(msg);

    print_team_bots(id, TEAM_T);
    print_team_bots(id, TEAM_CT);
}

print_team_bots(id, team)
{
    new name[32];
    new count = 0;
    new header[64];

    formatex(header, charsmax(header), "[FAPB] %s 队 Bot:", g_team_names[team]);
    if (id)
        client_print(id, print_console, header);
    else
        server_print(header);

    for (new i = 1; i <= get_maxplayers(); i++)
    {
        if (!is_user_connected(i) || !is_user_bot(i))
            continue;
        if (get_user_team(i) != team)
            continue;

        get_user_name(i, name, charsmax(name));
        if (id)
            client_print(id, print_console, "  %s", name);
        else
            server_print("  %s", name);
        count++;
    }

    if (count == 0)
    {
        if (id)
            client_print(id, print_console, "  (无)");
        else
            server_print("  (无)");
    }
}
