-- Shader的Manager
-- ljh 2016.11.08
ShaderManager = ShaderManager or BaseClass()

function ShaderManager:__init()
    ShaderManager.Instance = self

    self:Init()
end

function ShaderManager:__delete()
end

function ShaderManager:Init()
    -- local shaderManager = Game.Logic.CSShaderManager:GetInstance()
    -- shaderManager:InitShader("Shaders/UnlitTextureNpc.shader", "UnlitTexture", function() 
    --         print("shaderManager:InitShader") 
    --         shaderManager:GetShader("UnlitTexture")
    --     end)

    
	CS.Game.Logic.CSShaderManager:GetInstance():TempInitShader()
end