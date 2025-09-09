#include <amxmodx>
#include <xs>
#include <reapi>

new enabled;
new cvar_enabled;

new HookChain:hook_PM_AirMove_pre;
new HookChain:hook_PM_AirMove_post;

enum PlayerState
{
    playerid,
    Float:fmove,
    Float:smove,
    Float:maxspeed
}; new oldstate[PlayerState];

public plugin_init()
{
    register_plugin(Fix FPS Limit", "1.0", "[O]MA(R));
    
    cvar_enabled = create_cvar("amx_fix_fps_limit", "1");

    bind_pcvar_num(cvar_enabled, enabled);
    hook_cvar_change(cvar_enabled, "on_cvar_changed");

    hook_PM_AirMove_pre  = RegisterHookChain(RG_PM_AirMove, "on_PM_AirMove_pre",  .post=false);
    hook_PM_AirMove_post = RegisterHookChain(RG_PM_AirMove, "on_PM_AirMove_post", .post=true);

    if (!enabled)
    {
        DisableHookChain(hook_PM_AirMove_pre);
        DisableHookChain(hook_PM_AirMove_post);
    }
}


public on_cvar_changed(pcvar, old_value[], new_value[])
{
    if ((pcvar != cvar_enabled) || equal(old_value, new_value))
    {
        return PLUGIN_CONTINUE;
    }

    new value = str_to_num(new_value);

    if (value)
    {
        EnableHookChain(hook_PM_AirMove_pre);
        EnableHookChain(hook_PM_AirMove_post);
    }
    else
    {
        DisableHookChain(hook_PM_AirMove_pre);
        DisableHookChain(hook_PM_AirMove_post);
    }

    return PLUGIN_CONTINUE;
}

public on_PM_AirMove_pre(id)
{
    oldstate[playerid] = id;

    new cmd = get_pmove(pm_cmd);
    new msec = get_ucmd(cmd, ucmd_msec);

    if (msec == 10)
    {
        oldstate[playerid] = 0;
        return HC_CONTINUE;
    }

    new Float:scale = xs_sqrt(float(msec) / 10.0);
    
    oldstate[fmove] = get_ucmd(cmd, ucmd_forwardmove);
    oldstate[smove] = get_ucmd(cmd, ucmd_sidemove);
    
    new Float:_fmove = oldstate[fmove] * scale;
    new Float:_smove = oldstate[smove] * scale;
    
    set_ucmd(cmd, ucmd_forwardmove, _fmove);
    set_ucmd(cmd, ucmd_sidemove,    _smove);

    oldstate[maxspeed] = get_pmove(pm_maxspeed);
    
    new Float:_maxspeed = oldstate[maxspeed] * scale;

    set_pmove(pm_maxspeed, _maxspeed);

    return HC_CONTINUE;
}

public on_PM_AirMove_post(id)
{
    if (oldstate[playerid] && (id == oldstate[playerid]))
    {
        new cmd = get_pmove(pm_cmd);
        
        set_ucmd(cmd, ucmd_forwardmove, oldstate[fmove]);
        set_ucmd(cmd, ucmd_sidemove,    oldstate[smove]);

        set_pmove(pm_maxspeed, oldstate[maxspeed]);
    }
}