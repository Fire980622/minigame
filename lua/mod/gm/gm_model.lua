GmModel = GmModel or BaseClass(BaseModel)

function GmModel:__init()
    self.gmWindow = nil
end

function GmModel:__delete()
end

function GmModel:OpenGmWindow()
    if self.gmWindow == nil then
        self.gmWindow = GmWindow.New(self)
        self.gmWindow:Open()
    else
        self.gmWindow:Open()
    end
end

function GmModel:CloseGmWindow()
    if self.gmWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.gmWindow)
    end
end
