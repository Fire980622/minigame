-- ------------------------------
-- 窗口ID配置
-- ------------------------------
WindowConfig = WindowConfig or {}

-------------------------------------------------------------------------------
-- id命名规则: 前三位按照相应功能的协议前三位，后两位是具体的序号，方便分类
--------------------------------------------------------------------------------
WindowConfig.WinID = {
    -- ui_gm = 99001, --GM
    combat_panel=99999

}

WindowConfig.OpenFunc = {
    [WindowConfig.WinID.combat_panel] = function(args) CombatManager.Instance:OpenWindow(args) end,
    -- [WindowConfig.WinID.ui_gm] = function(args) HalloweenManager.Instance:OpenExchange(args) end,
}
