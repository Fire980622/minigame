-- 特效
-- @author huangyq
-- @date   160726
GoEffectPool = GoEffectPool or BaseClass(GoBasePool)

function GoEffectPool:__init(parent)
    self.name = "effect_node"
    self.maxSize = 30
    self.checkCount = 34
    self.parent = parent
    self.Type = GoPoolType.Effect

    self.ignoreList = {
        "Effect/Prefab/16036.prefab",
        "Effect/Prefab/13082.prefab",
        "Effect/Prefab/13083.prefab",
    }

    self:SetIgnoreFlag()
end

function GoEffectPool:__delete()
end

function GoEffectPool:Reset(poolObj, path)
    self:ResetModel(poolObj)
end

function GoEffectPool:ReturnEffect(poolObj, path)
    for _, data in ipairs(self.ignoreList) do
        if data == path then
            GameObject.DestroyImmediate(poolObj)
            return
        end
    end
    self:Return(poolObj, path)
end
