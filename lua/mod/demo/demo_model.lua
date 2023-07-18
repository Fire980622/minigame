-- demo
-- @author huangyq
DemoModel = DemoModel or BaseClass(BaseModel)

function DemoModel:__init()
    self.demoWindow = nil
    self.demoGetSpriteWindow = nil
    self.demoScenceElement = nil
end

function DemoModel:__delete()
end

function DemoModel:OpenDemoWindow()
    if self.demoWindow == nil then
        self.demoWindow = DemoWindow.New(self)
        self.demoWindow:Open()
    else
        self.demoWindow:Open()
    end
end

function DemoModel:OpenDemoSpriteWindow()
    if self.demoGetSpriteWindow == nil then
        self.demoGetSpriteWindow = DemoGetSpriteWindow.New(self)
        self.demoGetSpriteWindow:Open()
    else
        self.demoGetSpriteWindow:Open()
    end
end

function DemoModel:CloseDemoSpriteWindow()
    WindowManager.Instance:CloseWindow(self.demoGetSpriteWindow)
end
-- function DemoModel:CloseDemoSpriteWindow()
--     if self.demoGetSpriteWindow ~= nil then
--         self.demoGetSpriteWindow:DeleteMe()
--         self.demoGetSpriteWindow = nil
--     end
-- end

function DemoModel:CloseDemoWindow()
    if self.demoWindow ~= nil then
        self.demoWindow:Hide()
    end
end


function DemoModel:InitSenceElement()
    if self.demoScenceElement == nil then
        self.demoScenceElement = DemoScenceElement.New()
        self.demoScenceElement:Init()
    end
end


function DemoModel:OpenUITestWindow()
    if self.uitestWindow == nil then
        self.uitestWindow = UITestWindow.New(self)
        self.uitestWindow:Open()
    else
        self.uitestWindow:Open()
    end
end

function DemoModel:CloseUITestWindow()
    if self.uitestWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.uitestWindow)
    end
end
