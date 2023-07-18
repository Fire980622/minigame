-- ICon的使用
DemoIconSlot = DemoIconSlot or BaseClass()

function DemoIconSlot:__init(gameObject, itemId)
    self.gameObject = gameObject
    self.itemId = itemId
end

function DemoIconSlot:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end
