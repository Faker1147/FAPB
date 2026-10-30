/*
 * FAPB Team Menu
 * ---------------
 * An independent AMX Mod X menu for FAPB (not part of the YAPB core).
 * It calls FAPB console commands, so the bot AI remains untouched.
 *
 * Commands:
 *   fapb_teams            client console
 *   fapb_team             alias
 *   say /fapbteams        chat
 *   amx_fapb_teams        server console / rcon
 *
 * Cvar:
 *   fapb_teams_access 1  1 = ADMIN_MENU only (default), 0 = everyone
 */

#include <amxmodx>
#include <amxmisc>

#define PLUGIN  "FAPB Team Menu"
#define VERSION "1.1"
#define AUTHOR  "FAPB"

#define TEAM_T  1
#define TEAM_CT 2

new g_access;
new const g_team_names[][] = { "", "T", "CT" };

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    g_access = register_cvar("fapb_teams_access", "1");

    register_clcmd("fapb_teams", "cmd_teams");
    register_clcmd("fapb_team", "cmd_teams");
    register_clcmd("amx_fapb_teams", "cmd_teams");
    register_srvcmd("fapb_teams", "cmd_srv_teams");
    register_srvcmd("fapb_team", "cmd_srv_teams");
    register_srvcmd("amx_fapb_teams", "cmd_srv_teams");
    register_clcmd("say /fapbteams", "cmd_say_teams");
    register_clcmd("say_team /fapbteams", "cmd_say_teams");
}

public plugin_cfg()
{
    server_print("[FAPB] Team menu loaded. Use: fapb_teams | say /fapbteams");
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

show_main(id)
{
    new tcount = count_bots(TEAM_T);
    new ctcount = count_bots(TEAM_CT);
    new title[128];

    formatex(title, charsmax(title), "\yFAPB 队伍管理\w   T:%d  CT:%d", tcount, ctcount);

    new menu = menu_create(title, "menu_main");
    menu_additem(menu, "\wT 队管理 (T Team)", "t");
    menu_additem(menu, "\wCT 队管理 (CT Team)", "ct");
    menu_additem(menu, "\w双方总览 / 刷新", "overview");
    menu_additem(menu, "\w快速填充双方 (fapb fill)", "fill");
    menu_additem(menu, "\w踢出全部 Bot (fapb kickall)", "kickall");
    menu_additem(menu, "\w交换 T/CT (fapb swap)", "swap");

    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_setprop(menu, MPROP_EXITNAME, "退出");
    menu_setprop(menu, MPROP_BACKNAME, "返回");
    menu_setprop(menu, MPROP_NEXTNAME, "下一页");
    menu_display(id, menu, 0);
}

public menu_main(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new data[16], name[64], access, callback;
    menu_item_getinfo(menu, item, access, data, charsmax(data), name, charsmax(name), callback);
    menu_destroy(menu);

    if (equal(data, "t"))
    {
        show_team(id, TEAM_T);
    }
    else if (equal(data, "ct"))
    {
        show_team(id, TEAM_CT);
    }
    else if (equal(data, "overview"))
    {
        print_overview(id);
        show_main(id);
    }
    else if (equal(data, "fill"))
    {
        server_cmd("fapb fill");
        client_print(id, print_chat, "[FAPB] 已执行 fapb fill。");
        show_main(id);
    }
    else if (equal(data, "kickall"))
    {
        server_cmd("fapb kickall");
        client_print(id, print_chat, "[FAPB] 已踢出全部 Bot。");
        show_main(id);
    }
    else if (equal(data, "swap"))
    {
        server_cmd("fapb swap");
        client_print(id, print_chat, "[FAPB] 已执行队伍交换。");
        show_main(id);
    }

    return PLUGIN_HANDLED;
}

show_team(id, team)
{
    new count = count_bots(team);
    new title[128];
    new info[16];

    formatex(title, charsmax(title), "\y%s 队管理\w   当前 %d 个 Bot", g_team_names[team], count);
    new menu = menu_create(title, "menu_team");

    formatex(info, charsmax(info), "%s_add1", team == TEAM_T ? "t" : "ct");
    menu_additem(menu, "\w添加 1 个 Bot (Add 1)", info);

    formatex(info, charsmax(info), "%s_add5", team == TEAM_T ? "t" : "ct");
    menu_additem(menu, "\w添加 5 个 Bot (Add 5)", info);

    formatex(info, charsmax(info), "%s_kick1", team == TEAM_T ? "t" : "ct");
    menu_additem(menu, "\w踢出 1 个 Bot (Kick 1)", info);

    formatex(info, charsmax(info), "%s_kickall", team == TEAM_T ? "t" : "ct");
    menu_additem(menu, "\w踢出全部 Bot (Kick All)", info);

    formatex(info, charsmax(info), "%s_kill", team == TEAM_T ? "t" : "ct");
    menu_additem(menu, "\w杀死全部 Bot (Kill All)", info);

    formatex(info, charsmax(info), "%s_list", team == TEAM_T ? "t" : "ct");
    menu_additem(menu, "\w查看 Bot 列表 (List)", info);

    formatex(info, charsmax(info), "%s_back", team == TEAM_T ? "t" : "ct");
    menu_additem(menu, "\w返回主菜单 (Back)", info);

    menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
    menu_setprop(menu, MPROP_EXITNAME, "退出");
    menu_setprop(menu, MPROP_BACKNAME, "返回");
    menu_setprop(menu, MPROP_NEXTNAME, "下一页");
    menu_display(id, menu, 0);
}

public menu_team(id, menu, item)
{
    if (item == MENU_EXIT)
    {
        menu_destroy(menu);
        return PLUGIN_HANDLED;
    }

    new data[16], name[64], access, callback;
    menu_item_getinfo(menu, item, access, data, charsmax(data), name, charsmax(name), callback);
    menu_destroy(menu);

    new team = (data[0] == 't') ? TEAM_T : TEAM_CT;

    if (contain(data, "add1") != -1)
    {
        add_bots(team, 1);
    }
    else if (contain(data, "add5") != -1)
    {
        add_bots(team, 5);
    }
    else if (contain(data, "kick1") != -1)
    {
        kick_bots(team, 1);
    }
    else if (contain(data, "kickall") != -1)
    {
        kick_bots(team, 0);
    }
    else if (contain(data, "kill") != -1)
    {
        kill_bots(team);
    }
    else if (contain(data, "list") != -1)
    {
        print_team_bots(id, team);
    }
    else if (contain(data, "back") != -1)
    {
        show_main(id);
        return PLUGIN_HANDLED;
    }

    show_team(id, team);
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
