-- ----------------------------------------------------------
-- UI - 游戏登录
-- ----------------------------------------------------------
LoginView = LoginView or BaseClass(BaseWindow)

function LoginView:__init(model)
    self.model = model
    self.name = "LoginView"
    --self.winLinkType = WinLinkType.Single

    self.resList = {
        {path = AssetConfig.login_window_prefab, type = AssetType.Prefab}
        , {path = AssetConfig.loading_page_bg, type = AssetType.Prefab}
        , {path = AssetConfig.loading_logo, type = AssetType.Prefab}
    }

    self.gameObject = nil
    self.transform = nil


    self.onEndEditCallback = function(data)
        self:OnEndEdit(data)
    end
end

function LoginView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    ------------------------------------------------
    self.inputField.onEndEdit:RemoveListener(self.onEndEditCallback)
end

function LoginView:InitPanel()
    ctx.LoadingPage:Hide()

    self.gameObject = self:GetGameObject(AssetConfig.login_window_prefab)
    self.gameObject.name = self.name
    UtilsUI.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform


    local project_name = self.transform:Find("ImgProjectName")
    local ImgBg = self.transform:Find("ImgBg")
    local logoGameObject = self:GetGameObject(AssetConfig.loading_logo)
    local bgGameObject = self:GetGameObject(AssetConfig.loading_page_bg)
    UtilsUI.AddBigbg(project_name, logoGameObject)
    UtilsUI.AddBigbg(ImgBg, bgGameObject)


    self.inputField = self.transform:Find("InputCon"):Find("InputField"):GetComponent(typeof(InputField))
    self.inputField.textComponent = self.transform:Find("InputCon/InputField/Text"):GetComponent(typeof(Text))
    self.inputField.onEndEdit:AddListener(self.onEndEditCallback)

    self.zoneCon = self.transform:Find("ZoneCon").gameObject
    self.txtCurZoneName = self.zoneCon.transform:Find("TxtCurZoneName"):GetComponent(typeof(Text))
    self.txtCurZoneName.text = TI18N("开发服")

    self.btnEnterGame = self.transform:Find("BtnEnterGame"):GetComponent(typeof(Button))
    self.btnEnterGame.onClick:AddListener(function() self:on_submit() end)

    self.tipsTxt = self.transform:Find("Tips/Text"):GetComponent(typeof(Text))
    self.tipsTxt.text = TI18N("抵制不良游戏，拒绝盗版游戏。注意自我保护，谨防受骗上当。适度游戏益脑，沉迷游戏伤身。合理安排时间，享受健康生活。")

    self.lastAccount = self:GetPlayerPrefs("last_account")
    if self.lastAccount ~= "" then
        self.inputField.text = self.lastAccount
    else
        self.inputField.text = TI18N("请输入帐号123")
    end

    local versionTxt = self.transform:Find("Version/VerionText"):GetComponent(typeof(Text))
    versionTxt.text = TI18N("版本号:") .. CSVersion.GameName .. "1.0.0.000" .. TI18N("\n新广出审[2016]955号")
end

function LoginView:OnEndEdit(temp)
    if temp == "" then
        self.inputField.text = TI18N("请输入帐号")
        self.inputField.textComponent.color = Color(199/255,249/255,1)
        self.hasInputSelfName = false
    else
        self.hasInputSelfName = true
    end
end

function LoginView:SetAccountByCookie()
    local lastAccount = self:GetPlayerPrefs("last_account")
    if lastAccount ~= "" and self.inputField ~= nil then
        self.inputField.text = lastAccount
    end
end

--点击登录按钮
function LoginView:on_submit()
    self:Hide()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.combat_panel, {})
    LoginManager.Instance:DoLogin()
    if CS.CSSubpackageManager.isSubpackage then
        CS.CSSubpackageManager.GetInstance():StartDownload();
    end
end

-- 清除账号
function LoginView:clear_account_input()
    if self.inputField then
        self.inputField.text = ""
    end
    self:SavePlayerPrefs("last_account", "")
end

function LoginView:SavePlayerPrefs(key, val)
    --local origin = WWW.EscapeURL(tostring(val))
    --PlayerPrefs.SetString(key, origin)
end

function LoginView:GetPlayerPrefs(key)
    --local str = PlayerPrefs.GetString(key)
    --return WWW.UnEscapeURL(str)
    return ""
end
