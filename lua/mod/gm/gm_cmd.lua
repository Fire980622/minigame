GmCmd = GmCmd or BaseClass()

function GmCmd:__init()
    Connection.Instance:AddHandler(9900, self.On9900)

    -- 自定义控制台命令添加到gm_cmd.commands中
    -- 其中desc和func项为必须，args可选
    -- args参数格式说明:
    -- desc: 参数说明文字(必须项)
    -- type: string|number 参数类型(必须项)
    -- optional: true|false 该参数是否可选(不填的话默认为false)
    -- range: 格式{max, min}，类型为数字时表示一个数字范围，类型为字符串时表示一个长度范围(可选项)
    self.commands = {
        speedup = {
            desc = "客户端加速运行",
            args = {
                {desc = "比例，有效范围0.1~10之间", type = "number", range = {0.1, 10}},
            },
            func = function(ratio)
                Time.timeScale = tonumber(ratio)
                print(string.format("客户端%s倍运行速度", ratio))
            end
        },
        help = {
            desc = "显示帮助信息",
            args = {
                {desc = "关键字", type = "string", optional = true},
            },
            func = function(keyword)
                self:Help(keyword)
            end
        },
        CreateSomeRole = {
            desc = "测试，创建N个玩家",
            args = {
                {desc = "玩家个数，有效范围1~100之间", type = "number", range = {1, 100}},
            },
            func = function(num)
                SceneManager.Instance:TestCreateSomeRole(num)
            end
        },
        CreateSomeNpc = {
            desc = "测试，创建N个Npc",
            args = {
                {desc = "Npc个数，有效范围1~100之间", type = "number", range = {1, 100}},
            },
            func = function(num)
                SceneManager.Instance:TestCreateSomeNpc(num)
            end
        },
    }

end

-- 检查参数错误
function GmCmd:CheckArgs(args_info, args)
    local err = {}
    for k, v in pairs(args_info) do
        if v.optional == true and args[k] == nil then
            -- 参数是一个可选项且为空，跳过
        elseif v.type == 'number' then
            local num = tonumber(args[k])
            if args[k] == nil then
                table.insert(err, string.format("缺少参数: %s\n", v.desc))
            elseif num == nil then
                table.insert(err, string.format("参数 %s 无效: 非数字\n", args[k]))
            elseif v.range ~= nil and (num < v.range[1] or num > v.range[2]) then
                table.insert(err, string.format("参数 %s 无效: 超出有效范围 %d ~ %d\n", args[k], v.range[1], v.range[2]))
            end
        elseif v.type == 'string' then
            local str = tostring(args[k])
            local len = string.len(str)
            if args[k] == nil then
                table.insert(err, string.format("缺少参数: %s\n", v.desc))
            elseif v.range ~= nil and (len < v.range[1] or len > v.range[2]) then
                table.insert(err, string.format("参数 %s 无效: 长度超出有效范围 %d ~ %d\n", args[k], v.range[1], v.range[2]))
            end
        end
    end
    return table.concat(err)
end

-- 处理帮助信息
function GmCmd:Help(keyword)
    if keyword == nil then
        print("调用lua版控制台指令:[命令] [参数1] [参数2] ...")
        print("设用C#控制台指令:[类名].[方法名] [参数1] [参数2] ...")
        print("快捷键:F1显示/隐藏 F2改变尺寸 ctrl+n和ctrl+p浏览历史命令 ctrl+a和ctrl+e移动光标 ctrl+w和ctrl+k删除当前输入的内容")
    end
    for cmd, info in pairs(self.commands) do
        if keyword ~= nil and string.find(cmd, keyword) == nil and string.find(info.desc, keyword) == nil then
            -- 查找不到指定关键词相关的命令
        else
            local text = {}
            table.insert(text, "<color=#393>" .. cmd .. "</color>")
            if info.args ~= nil then
                for _, v in pairs(info.args) do
                    local opt = ""
                    if v.optional then
                        opt = "(可选)"
                    end
                    table.insert(text, "[<color=#393>" .. v.desc .. opt .. "</color>]")
                end
            end
            table.insert(text, info.desc)
            print(table.concat(text))
        end
    end
end

-- 执行命令
function GmCmd:Run(str)
    local cmd = nil
    local args = {}
    for token in string.gmatch(str, "%S+") do
        if cmd == nil then
            cmd = token
        else
            table.insert(args, token)
        end
    end

    -- gm命令特殊处理
    if cmd == "gm" then
        Connection.Instance:Send(9900, {cmd = table.concat(args, " ")})
        return
    end
    -- 代码调试特殊处理
    if cmd == "run" then
        if #args > 0 then
            assert(loadstring(" return "..args[1]))()
        end
        return
    end

    -- 热更模块
    if cmd == "hot" then
        if #args > 0 then
            if package.loaded[args[1]] ~= nil then
                package.loaded[args[1]] = nil
                require(args[1])
            else
                print("<color='#ffff00'>找不到该文件</color>")
            end
        end
        return
    end

    local info = self.commands[cmd]
    if info == nil then
        print("无效的命令")
        return
    end

    if info.args == nil then
        info.func()
    else
        local err = self:CheckArgs(info.args, args)
        if string.len(err) > 0 then
            print(err)
        else
            info.func(unpack(args))
        end
    end
end

-- 处理gm命令执行结果
function GmCmd:On9900(data)
    print(data.msg)
    -- 刷新控制台显示
    -- GameContext.GetInstance().GameConsole:Reload()
end
