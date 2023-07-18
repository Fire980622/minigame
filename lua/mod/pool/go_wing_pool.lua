-- 仙翼
-- @author huangyq
-- @date   160726
GoWingPool = GoWingPool or BaseClass(GoBasePool)

function GoWingPool:__init(parent)
    self.name = "wing_node"
    self.maxSize = 30
    self.checkCount = 44
    self.parent = parent
    self.Type = GoPoolType.Wing
    self:SetIgnoreFlag()
end

function GoWingPool:__delete()
end

function GoWingPool:Reset(poolObj, path)
    local node = poolObj.transform:Find("wing_tpose/bp_wing")
    if node ~= nil then
        local count = node.transform.childCount
        if count > 0 then
            local list = {}
            for i = 1, count do
                local child = node.transform:GetChild(i-1)
                table.insert(list, child)
            end
            for _, data in ipairs(list) do
                GameObject.Destroy(data.gameObject)
            end
        end
    end
    self:ClearMesh(poolObj)
    self:ClearAnimatorController(poolObj)
    self:ResetModel(poolObj)
end
