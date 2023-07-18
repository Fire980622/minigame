
-- 初始化映射表
require "clz_mapping_lua"
require "clz_mapping_data"

require "base/common"
require "base/baseclass"

require "base/base_view"
require "base/base_panel"
require "base/base_window"

require "base/base_manager"
require "base/base_model"

-- require "base/base_layout"
require "util/I18N"
require "util/socket"

require "mod/connect/connection_enum"
require "mod/connect/protocal_helper"
require "mod/connect/protoc"

-- 使用c# LuaTableProxy类及接口
require "base/game_lua_start"
require "mod/connect/connection"

-- 放在最后
require "base/lua_preload"
