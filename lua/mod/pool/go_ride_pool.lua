-- 坐骑
-- @author ljh
-- @date   160809
GoRidePool = GoRidePool or BaseClass(GoBasePool)

function GoRidePool:__init(parent)
    self.name = "ride_tpose"
    self.maxSize = 20
    self.timeout = 72
    self.parent = parent
    self.Type = GoPoolType.Ride
    self:SetIgnoreFlag()
end

function GoRidePool:__delete()
end

function GoRidePool:Reset(poolObj)
	self:ClearMesh(poolObj)
    self:ClearAnimatorController(poolObj)
    self:ResetModel(poolObj)
    self:ClearBpObj(poolObj, 1)
end
