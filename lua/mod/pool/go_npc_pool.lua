-- NPC模型对象池
-- @author huangyq
-- @date   160726
GoNpcPool = GoNpcPool or BaseClass(GoBasePool)

function GoNpcPool:__init(parent)
    self.name = "npc_tpose"
    self.maxSize = 10
    self.parent = parent
    self.Type = GoPoolType.Npc

    self.checkerList = {
        -- 宠物
        -- GoNodeChecker.New(GoPoolType.Npc, 30027, {"Bip_R_Hand"})
        -- ,GoNodeChecker.New(GoPoolType.Npc, 30029, {"Bip_R_Hand"})
        -- ,GoNodeChecker.New(GoPoolType.Npc, 30037, {"Bip_R_Hand"})
        -- ,GoNodeChecker.New(GoPoolType.Npc, 30127, {"Bip_R_Hand"})
        -- ,GoNodeChecker.New(GoPoolType.Npc, 30227, {"Bip_R_Hand"})
        -- ,GoNodeChecker.New(GoPoolType.Npc, 30129, {"Bip_R_Hand"})
        -- ,GoNodeChecker.New(GoPoolType.Npc, 30229, {"Bip_R_Hand"})
        -- ,GoNodeChecker.New(GoPoolType.Npc, 30137, {"Bip_R_Hand"})
        -- ,GoNodeChecker.New(GoPoolType.Npc, 30237, {"Bip_R_Hand"})
        GoNodeChecker.New(GoPoolType.Npc, 30046, {"bp_R_Ear", "bp_L_Ear", "bp_Tail"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30146, {"bp_R_Ear", "bp_L_Ear", "bp_Tail"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30246, {"bp_R_Ear", "bp_L_Ear", "bp_Tail"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30247, {"Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30747 , {"Bip_R_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30050, {"Bone_Tail_03"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30150, {"Bone_Tail_03"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30250, {"Bone_Tail_03"})
        ,GoNodeChecker.New(GoPoolType.Npc, 10031 , {"Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 10032, {"Bone_M_Hair_01"})

        ,GoNodeChecker.New(GoPoolType.Npc, 30427, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30429, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30837, {"Bip_R_Hand"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30446, {"bp_L_Ear", "bp_R_Ear", "bp_Tail"})
        ,GoNodeChecker.New(GoPoolType.Npc, 30450, {"Bone_Tail_03"})

        -- 其他
        ,GoNodeChecker.New(GoPoolType.Npc, 11025, {"Bip_L_Weapon"})
        ,GoNodeChecker.New(GoPoolType.Npc, 70138, {"bp_star_01", "bp_star_02", "bp_star_03", "bp_star_04", "bp_star_05"})
    }
    self:SetIgnoreFlag()
end

function GoNpcPool:__delete()
end

function GoNpcPool:Reset(poolObj, path)
    for _, checker in ipairs(self.checkerList) do
        checker:Check(path, poolObj)
    end
    self:ClearMesh(poolObj)
    self:ClearAnimatorController(poolObj)
    self:ClearBpObj(poolObj, 2)
    self:ResetModel(poolObj)
end
