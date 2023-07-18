-- 模型预览
PreviewManager = PreviewManager or BaseClass(BaseManager)

function PreviewManager:__init()
    if PreviewManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    PreviewManager.Instance = self;

    self.nextX = 100
    self.container = nil

    self:CreateContainer()
end

function PreviewManager:__delete()
end

function PreviewManager:NextX()
    self.nextX = self.nextX + 5
    return self.nextX
end

function PreviewManager:CreateContainer()
    self.container = GameObject("PreviewContainer")
    self.container.transform.position = Vector3(0, 0, 0)
    GameObject.DontDestroyOnLoad (self.container);
    Utils.ChangeLayersRecursively(self.container.transform, "ModelPreview")
end



