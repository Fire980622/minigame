-- 全局事件
-- 模块内部事件可以使用EventLib类处理
event_name = event_name or {}

event_name.gamestart_before_init = "gamestart_before_init"
event_name.gamestart_end_init = "gamestart_end_init"
event_name.end_mgr_init = "end_mgr_init"

-- Socket事件
event_name.socket_connect = "socket_connect"

-- 场景事件
event_name.start_scene_load = "start_scene_load"
event_name.scene_load = "scene_load"
event_name.self_loaded = "self_loaded"


--开始控制player
event_name.start_player = "start_player"