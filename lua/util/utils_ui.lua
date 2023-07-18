-- --------------------------------
-- UI工具类
-- --------------------------------
UtilsUI = UtilsUI or BaseClass()

-- ---------------------------------
-- 添加子对象到父容器，并做基础设置
-- ---------------------------------
function UtilsUI.AddUIChild(parentObj, childObj)
    local trans = childObj.transform
    trans:SetParent(parentObj.transform)
    trans.localScale = Vector3.one
    trans.localPosition = Vector3.zero
    trans.localRotation = Quaternion.identity

    local rect = childObj:GetComponent(typeof(RectTransform))
    rect.anchorMax = Vector2.one
    rect.anchorMin = Vector2.zero
    rect.offsetMin = Vector2.zero
    rect.offsetMax = Vector2.zero
    rect.localScale = Vector3.one
    rect.localPosition = Vector3.zero
    rect.anchoredPosition3D = Vector3.zero
    childObj:SetActive(true)
    local canvas = childObj:GetComponent(typeof(Canvas))
    if not UtilsBase.IsNull(canvas) then
        canvas.pixelPerfect = false;
        canvas.overrideSorting = true;
    end
end

function UtilsUI.AddBigbg(parentTransform, childObj)
    local childTransform = childObj.transform
    childTransform:SetParent(parentTransform)
    childTransform.localScale = Vector3.one
    childTransform.localPosition = Vector3.zero
    -- local rect = childObj:GetComponent(typeof(RectTransform))
    childTransform.anchoredPosition = Vector2.zero
end

--设置特效的层次
--@effectObj  (GameObject)特效对象
--@sortingOrder 设置的层次
function UtilsUI.SetEffectSortingOrder(effectObj, sortingOrder)
    local sortingOrder = sortingOrder or 1
    local particleSystems = effectObj:GetComponentsInChildren(typeof(ParticleSystemRenderer))
    for i = 0, particleSystems.Length  - 1 do
        if particleSystems[i] then
            particleSystems[i].sortingOrder = sortingOrder
        end

    end
    -- for k, v in pairs(particleSystems) do
    --     v.sortingOrder = sortingOrder
    -- end

    local meshRender = effectObj:GetComponentsInChildren(typeof(MeshRenderer))
    -- for k, v in pairs(meshRender) do
    --     v.sortingOrder = sortingOrder
    -- end
    for i = 0, meshRender.Length  - 1 do
        if meshRender[i] then
            meshRender[i].sortingOrder = sortingOrder
        end
    end
end

--使特效在parentTransform的裁剪区域内，要配合Xcqy/Particles/AdditiveMask使用
--@params parentTransform 父Transform
--@params effectTransform 特效
function UtilsUI:SetEffectMask(parentTransform, effectTransform)
    local rectTransform = parentTransform
    local min = rectTransform:TransformPoint(rectTransform.rect.min)
    local max = rectTransform:TransformPoint(rectTransform.rect.max)
    local minX = min.x
    local minY = min.y
    local maxX = max.x
    local maxY = max.y

    local aryParticleSystems = effectTransform:GetComponentsInChildren(typeof(ParticleSystemRenderer))
    for i, eachParticleSystem in ipairs(aryParticleSystems) do
        local material = eachParticleSystem:GetComponent(typeof(Renderer)).sharedMaterial
        material:SetFloat("_MinX", minX)
        material:SetFloat("_MinY", minY)
        material:SetFloat("_MaxX", maxX)
        material:SetFloat("_MaxY", maxY)
    end

    local aryMeshRender = effectTransform:GetComponentsInChildren(typeof(MeshRenderer))
    for k, eachMeshRender in ipairs(aryMeshRender) do
        local material = eachMeshRender:GetComponent(typeof(Renderer)).sharedMaterial
        material:SetFloat("_MinX", minX)
        material:SetFloat("_MinY", minY)
        material:SetFloat("_MaxX", maxX)
        material:SetFloat("_MaxY", maxY)
    end
end

--保证srcTransform在targetRectTransform的中间
--@param srcTransform 源transform
--@param targetRectTransform 最终指向的transform，注意，此参数必须要是一个RectTransform，如果确定是一个RectTransform，则不需要强制转型
--@param offsetPosition 手动的本地偏移量，可不填
function UtilsUI.SyncPosition(srcTransform, targetRectTransform, offsetPosition)
    local corners = {Vector3.zero, Vector3.zero, Vector3.zero, Vector3.zero}
    corners = Utils.GetWorldCorners(targetRectTransform, corners)
    --要获取的锚点
    local posz = srcTransform.position.z
    local pivot = Vector3(0.5, 0.5, posz)
    local finalX = corners[1].x * (1 - pivot.x) + corners[3].x * pivot.x
    local finalY = corners[1].y * (1 - pivot.y) + corners[3].y * pivot.y
    srcTransform.position = Vector3(finalX, finalY, posz)

    if offsetPosition then
        --加上手动的偏移量（如果存在，一般来说不需要）
        local offset = Vector3(offsetPosition.x, offsetPosition.y, 0)
        srcTransform.localPosition = offset + srcTransform.localPosition
    end
end