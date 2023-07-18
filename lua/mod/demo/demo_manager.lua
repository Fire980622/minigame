-- demo
DemoManager = DemoManager or BaseClass(BaseManager)

function DemoManager:__init()
    if DemoManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    DemoManager.Instance = self;

    self.model = DemoModel.New()

    self:InitHandler()
end

function DemoManager:__delete()
end

function DemoManager:InitHandler()
    self:AddNetHandler(90010, self.On90010)
    self:AddNetHandler(90020, self.On90020)
end

function DemoManager:On90010(data)
    -- 做点别的
end

function DemoManager:On90020(data)
    -- 做点别的
end

function DemoManager:OpenDemoWindow()
    self.model:OpenDemoWindow()
end

function DemoManager:OpenDemoSpriteWindow()
    self.model:OpenDemoSpriteWindow()
end
