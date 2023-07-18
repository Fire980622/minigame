LoginModel = LoginModel or BaseClass(BaseModel)

function LoginModel:__init()
    self.window = nil

    self.login_visable = false
end

function LoginModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
        self.login_visable = false
    end
end

function LoginModel:InitMainUI()
    if self.window == nil then
        self.window = LoginView.New(self)
        self.window:Open()
        self.login_visable = true
        --SoundManager.Instance:PlayBGM(SoundEumn.Background_MainCity)
    else
        self.window:Open()
    end
end

function LoginModel:CloseMainUI()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
        self.login_visable = false
    end
end

function LoginModel:clear_account_input()
    if self.window ~= nil then
        self.window:clear_account_input()
    end
end

function LoginModel:SetAccountByCookie()
    if self.window ~= nil then
        self.window:SetAccountByCookie()
    end
end
