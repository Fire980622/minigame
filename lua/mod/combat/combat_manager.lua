CombatManager = CombatManager or BaseClass(BaseManager)
function CombatManager:__init()
    if CombatManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

    CombatManager.Instance = self
   -- self.model = CombatModel.New()
    --self:InitHandler()
   
end

function CombatManager:__delete()
    
end
function CombatManager:OpenWindow()
    if self.window==nil then
         self.window=CombatWindow.New(self)
    end
    self.window:Show(args)
end





