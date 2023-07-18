--3d场景 controller
Scene3DController = Scene3DController or BaseClass()

function Scene3DController:__init()
    if Scene3DController.Instance then
        LogError("拒绝重复实例化单例" .. debug.traceback())
        return
    end
    Scene3DController.Instance = self
end

function Scene3DController:__delete()
end

function Scene3DController:Update()
end


function Scene3DController:MapClickHandler(pos)
end


function Scene3DController:Test()
end