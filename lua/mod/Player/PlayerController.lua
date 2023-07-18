PlayerController = PlayerController or BaseClass(BasePanel)
local _Time = Time
function PlayerController:__init(bronPoint)
    self.resList = {
        {path=AssetConfig.player_anim,type = AssetType.asset},
        {path = AssetConfig.player, type = AssetType.Prefab}
    }
    if PlayerController.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    PlayerController.Instance = self
   self.gameObject=nil
    self.bronPoint=bronPoint
    self.timer=nil
     self:LoadAllAsset()
    self.start=false
    self.character=nil
    self.animationList={}
    self.animationData = {resId= "player", list = {"player_run", "player_idle"}}
    for _, animationId in ipairs(self.animationData.list) do
        table.insert(self.animationList, string.format("Unit/Npc/Animation/71006/%s/%s.anim", self.animationData.resId, animationId))
    end
    for _, path in ipairs(self.animationList) do
        table.insert(self.resList, {path = path, type = AssetType.Object})
    end
    self.assetLoader:LoadAll(self.resList)
end
function PlayerController:InitPanel()
    self.gameObject = self:GetGameObject(AssetConfig.player)
    self.transform=self.gameObject.transform
    self.rectTransform = self.gameObject:GetComponent(typeof(RectTransform))
    self.transform:SetParent(self.bronPoint)
   
    self.transform.localScale=Vector3.one

    self.transform.localPosition=Vector3.zero 
    self.transform.anchorMax=Vector2(1,1)
    self.transform.anchorMin=Vector2(1,1)
    --self.transform.pivot = Vector2(0.5, 0.5)
    self.Main=self.transform:Find("Main")
    self.body=self.Main:Find("Body")
    self.anim=self.body:GetComponent(typeof(Animator))
    self.rigidbody=self.transform:GetComponent(typeof(Rigidbody))
    self.character= self.transform:GetComponent(typeof(CharacterController))
    EventMgr.Instance:Fire(event_name.start_player) 
end
function PlayerController:Update()
    local moveSpeed=3
    local hSpeed = Input.GetAxis("Horizontal") * moveSpeed;
    local vSpeed = self.rigidbody.velocity.y;
    self.rigidbody.velocity = Vector2(hSpeed, vSpeed); 
--[[     self.anim:SetFloat("absHSpeed", math.abs(hSpeed));
    self.anim:SetFloat("vSpeed", vSpeed);
    print(math.abs(hSpeed))
    self.anim:Play("player_run") ]]


end

