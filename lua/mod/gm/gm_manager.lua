GmManager = GmManager or BaseClass(BaseManager)

function GmManager:__init()
    if GmManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    GmManager.Instance = self

    self.list = {}
    self:InitData()

    self.model = GmModel.New()
    self.cmd = GmCmd.New()
end

function GmManager:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

function GmManager:InitData()
    -- local originData = DataGm.data_data
    -- for _, data in ipairs(originData) do
    --     if self.list[data.type] ~= nil then
    --         table.insert(self.list[data.type], data)
    --     else
    --         self.list[data.type] = {data}
    --     end
    -- end
end

function GmManager:OpenGmWindow()
    self.model:OpenGmWindow()
end

function GmManager:CloseGmWindow()
    self.model:CloseGmWindow()
end

