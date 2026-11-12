local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

if _G.AmyGFV2Loaded then
    return
end
_G.AmyGFV2Loaded = true

local player = Players.LocalPlayer
local GFCharacter = player.Character or player.CharacterAdded:Wait()
local GFAssetId = 136333819458978
local GFIsScriptActive = false
local GFCurrentModel = nil
local GFSyncConn = nil
local GFSetupInProgress = false
local GFSetupGeneration = 0
local GFLastEyesState = nil
local GFChasedVisible = false
local GFChasedLostAt = nil
local GFChasedReleaseDelay = 1.5
local GFChasedGeneration = 0
local HideJacketaswell = false
local GFJacketOriginalColors = setmetatable({}, { __mode = "k" })
local GFIconConnections = {}
local GFCosmeticConnections = {}
local GFModeConnections = {}
local GFStartPending = false

-- Amy Iconos
local IconNormalGF = "rbxassetid://73222561332765" -- Expression.Regular
local ExpressionNormalGF = "rbxassetid://79752501485749" -- Eyes.Regular
local ExpressionChasedGF = "rbxassetid://113659883065962" -- Eyes.Chased

-- LastLife Iconos Amy
local DownedIconGF = "rbxassetid://91117693958700" -- Expression.Downed
local IconLastLifeGF = "rbxassetid://119311173785729" -- Expression.LastLife
local ExpressionLastLifeGF = "rbxassetid://86029426878323" -- Reemplaza Eyes.Regular si estas en lastlife

local GFForceReload = false
local GFCosmeticToggle = true
local GFKeyDebounce = false

local shirtCosmetics = {
    TMOSTH = true,
    Cosmetic = true,
    AmyChristmasDress = true,
    coatthingy = true,
    Sleeve = true,
    lowerleg = true,
    upperleg = true,
}
shirtCosmetics["modern dress"] = true

local cosmeticRootNames = {
    TMOSTH = true,
}

local function GFBelongsToCosmeticRoot(object, model)
    if not GFCosmeticToggle then return end
    local current = object
    while current and current ~= model do
        if cosmeticRootNames[current.Name] or shirtCosmetics[current.Name] then
            return true
        end
        current = current.Parent
    end
    return false
end

local function GFRestoreCosmeticVisibility(model)
    if not GFCosmeticToggle or not model then return end

    for cosmeticName in pairs(shirtCosmetics) do
        local cosmetic = model:FindFirstChild(cosmeticName, true)
        if cosmetic then
            for _, object in ipairs(cosmetic:GetDescendants()) do
                if object:IsA("BasePart") then
                    object.Transparency = 0
                    object.CanCollide = false
                end
            end
        end
    end
end

-- ============================================================================
-- FUNCIONES DEL MARTILLO (HAMMER FIX & VISIBILITY)
-- ============================================================================

local GFHideThing = false
local GFTargetHammerState = {}

local function GFGetHammer(targetModel)
    if not targetModel then return nil end
    return targetModel:FindFirstChild("Hammer", true)
        or targetModel:FindFirstChild("Axe", true)
        or targetModel:FindFirstChild("MagicalAmy", true)
end

local function GFCacheHammerState(targetModel)
    local hammer = GFGetHammer(targetModel)
    if not hammer or GFTargetHammerState[targetModel] then return end

    local snapshot = {}
    local function collect(node)
        if not node then return end
        if node:IsA("BasePart") then
            table.insert(snapshot, {
                part = node,
                transparency = node.Transparency,
                canCollide = node.CanCollide,
                anchored = node.Anchored,
                massless = node.Massless,
            })
        end
        for _, child in ipairs(node:GetDescendants()) do
            collect(child)
        end
    end
    collect(hammer)
    GFTargetHammerState[targetModel] = snapshot
end

local function GFRestoreHammerState(targetModel)
    local snapshot = targetModel and GFTargetHammerState[targetModel]
    if not snapshot then return end

    for _, entry in ipairs(snapshot) do
        if entry and entry.part and entry.part.Parent then
            entry.part.Transparency = entry.transparency
            entry.part.CanCollide = entry.canCollide
            entry.part.Anchored = entry.anchored
            entry.part.Massless = entry.massless
        end
    end
    GFTargetHammerState[targetModel] = nil
end

local function GFHammerVisibilityFix(targetModel, visible)
    if GFHideThing or not targetModel then return end
    local hammer = GFGetHammer(targetModel)
    if not hammer then return end

    GFCacheHammerState(targetModel)
    local transparency = visible and 0 or 1
    if hammer:IsA("BasePart") then
        hammer.Transparency = transparency
    end
    for _, object in ipairs(hammer:GetDescendants()) do
        if object:IsA("BasePart") then
            object.Transparency = transparency
        end
    end
end

local function GFUpdateInsertedShirt(model, insertedModel)
    if not GFCosmeticToggle then
        for part, originalColor in pairs(GFJacketOriginalColors) do
            if part.Parent then
                part.Color = originalColor
            end
            GFJacketOriginalColors[part] = nil
        end
        return
    end
    if not model or not insertedModel then return end

    local hasShirtCosmetic = false
    for cosmeticName in pairs(shirtCosmetics) do
        if model:FindFirstChild(cosmeticName, true) then
            hasShirtCosmetic = true
            break
        end
    end

    local vestidoModel = insertedModel:FindFirstChild("Vestido", true)
    local chaquetaModel = insertedModel:FindFirstChild("Chaqueta", true)
    local white = Color3.fromRGB(255, 255, 255)
    local protectedSleeves = { LSleeve = true, RSleeve = true }

    local function isProtectedSleeve(object, root)
        local current = object
        while current and current ~= root do
            if protectedSleeves[current.Name] then return true end
            current = current.Parent
        end
        return false
    end

    local function setShirtVisibility(shirtGroup, visible)
        if not shirtGroup then return end
        for _, object in ipairs(shirtGroup:GetDescendants()) do
            if not isProtectedSleeve(object, shirtGroup) then
                if object:IsA("BasePart") then
                    object.Transparency = visible and 0 or 1
                    object.CanCollide = false
                elseif object:IsA("Decal") or object:IsA("Texture") then
                    object.Transparency = visible and 0 or 1
                end
            end
        end
    end

    local function setJacketRelatedColors()
        -- Forzamos la restauración o recolor blanco puro exacto del original
        if not HideJacketaswell then
            for part, originalColor in pairs(GFJacketOriginalColors) do
                if part.Parent then part.Color = originalColor end
                GFJacketOriginalColors[part] = nil
            end
        else
            local colorTargets = {}
            for _, name in ipairs({ "LSleeve", "RSleeve", "Arms" }) do
                local target = insertedModel:FindFirstChild(name, true)
                if target then table.insert(colorTargets, target) end
            end

            for _, target in ipairs(colorTargets) do
                for _, object in ipairs(target:GetDescendants()) do
                    if object:IsA("BasePart") then
                        if GFJacketOriginalColors[object] == nil then
                            GFJacketOriginalColors[object] = object.Color
                        end
                        object.Color = white
                    end
                end
            end
        end

        -- Aseguramos que las mangas protegidas mantengan visibilidad 0 y propiedades correctas
        for _, name in ipairs({ "LSleeve", "RSleeve" }) do
            local sleeve = insertedModel:FindFirstChild(name, true)
            if sleeve then
                for _, object in ipairs(sleeve:GetDescendants()) do
                    if object:IsA("BasePart") then
                        object.Transparency = 0
                        object.CanCollide = false
                    elseif object:IsA("Decal") or object:IsA("Texture") then
                        object.Transparency = 0
                    end
                end
            end
        end
    end

    setShirtVisibility(vestidoModel, not hasShirtCosmetic)
    setShirtVisibility(chaquetaModel, not (hasShirtCosmetic and HideJacketaswell))
    setJacketRelatedColors()
end

local function GFLoadAsset(id)
    local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
    if not ok or not objects or #objects == 0 then return nil end
    return objects[1]:Clone()
end

local function GFGetPlayerModel()
    local playersFolder = workspace:FindFirstChild("Players")
    return playersFolder and playersFolder:FindFirstChild(player.Name)
end

local function GFIsAmy()
	local model = GFGetPlayerModel()
	return model and model:GetAttribute("Character") == "Amy"
end

-- ============================================================================
-- SISTEMA DE ICONOS (RESTAURADO)
-- ============================================================================

local function GFGetBooleanState(root, names)
    if not root then
        return false
    end

    for _, name in ipairs(names) do
        local value = root:GetAttribute(name)
        if value == true or value == "true" or value == "True" then
            return true
        end

        local stateObject = root:FindFirstChild(name, true)
        if stateObject then
            if stateObject:IsA("BoolValue") and stateObject.Value then
                return true
            end
            if stateObject:IsA("ObjectValue") and stateObject.Value ~= nil then
                return true
            end
            if stateObject:IsA("StringValue") and (stateObject.Value == "true" or stateObject.Value == "True") then
                return true
            end
            if stateObject:IsA("IntValue") and stateObject.Value > 0 then
                return true
            end
        end
    end

    return false
end

local function GFSetFolderState(folder, activeName, imageId, fitToFrame, layout, zIndex)
    if not folder then
        return
    end

    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
            child.Visible = false
        end
    end

    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
            local isActive = child.Name == activeName
            if isActive then
                child.Visible = true
                child.Image = imageId
                child.ZIndex = zIndex
                if layout and layout.position then
                    child.Position = layout.position
                end
                if fitToFrame and layout and layout.size then
                    child.AnchorPoint = Vector2.new(0.5, 0.5)
                    child.Size = layout.size
                    child.ScaleType = Enum.ScaleType.Fit
                end
            end
        end
    end
end

local GFFunctionApplyIcon

GFFunctionApplyIcon = function()
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    local round = playerGui and playerGui:FindFirstChild("Round")
    local gameGui = round and round:FindFirstChild("Game")
    local teams = gameGui and gameGui:FindFirstChild("Teams")
    local playerFrame = teams and teams:FindFirstChild(player.Name)
    local frame = playerFrame and playerFrame:FindFirstChild("Frame")
    local characterGui = frame and frame:FindFirstChild("Character")

    if not characterGui then
        return
    end

    local model = GFGetPlayerModel() or player.Character
    local isDowned = GFGetBooleanState(model, { "Downed", "IsDowned", "BeingDowned" })
        or GFGetBooleanState(player.Character, { "Downed", "IsDowned", "BeingDowned" })
        or GFGetBooleanState(player, { "Downed", "IsDowned", "BeingDowned" })
    local isLastLife = GFGetBooleanState(model, { "LastLife", "IsLastLife", "SecondLife" })
        or GFGetBooleanState(player.Character, { "LastLife", "IsLastLife", "SecondLife" })
        or GFGetBooleanState(player, { "LastLife", "IsLastLife", "SecondLife" })
    local isChased = GFGetBooleanState(model, { "Chased", "IsChased", "InChase", "BeingChased" })
        or GFGetBooleanState(player.Character, { "Chased", "IsChased", "InChase", "BeingChased" })
        or GFGetBooleanState(player, { "Chased", "IsChased", "InChase", "BeingChased" })

    -- Chased con retardo de salida (GFChasedReleaseDelay)
    if isChased then
        if not GFChasedVisible or GFChasedLostAt then
            GFChasedVisible = true
            GFChasedLostAt = nil
            GFChasedGeneration += 1
        end
    elseif GFChasedVisible then
        if not GFChasedLostAt then
            GFChasedLostAt = os.clock()
            GFChasedGeneration += 1
            local generation = GFChasedGeneration
            task.delay(GFChasedReleaseDelay, function()
                if GFIsScriptActive and GFChasedGeneration == generation then
                    GFFunctionApplyIcon()
                end
            end)
        elseif os.clock() - GFChasedLostAt >= GFChasedReleaseDelay then
            GFChasedVisible = false
            GFChasedLostAt = nil
            GFChasedGeneration += 1
        end
    end

    local eyesState = "Regular"
    local expressionState = isLastLife and "LastLife" or "Regular"
    local eyesImage = ExpressionNormalGF
    local expressionImage = isLastLife and IconLastLifeGF or IconNormalGF

    if GFChasedVisible then
        eyesState = "Chased"
        eyesImage = ExpressionChasedGF
    end
    if isDowned then
        eyesState = "Stunned"
        expressionState = "Downed"
        expressionImage = DownedIconGF
    end
    if isLastLife and not GFChasedVisible then
        eyesImage = ExpressionLastLifeGF
    end

    if eyesState ~= GFLastEyesState then
        GFLastEyesState = eyesState
        warn("[AmyGFV2] Eyes state:", eyesState, "Chased:", isChased, "Downed:", isDowned)
    end

    local layout = {
        position = UDim2.fromScale(0.45, 0.39),
        size = UDim2.fromScale(0.60, 0.60),
    }
    GFSetFolderState(characterGui:FindFirstChild("Eyes"), isDowned and "" or eyesState, eyesImage, true, layout, 10)
    GFSetFolderState(characterGui:FindFirstChild("Expression"), expressionState, expressionImage, true, layout, 5)
end

local GFIconStateNames = {
    LastLife = true,
    IsLastLife = true,
    SecondLife = true,
    Downed = true,
    IsDowned = true,
    BeingDowned = true,
    Chased = true,
    IsChased = true,
    InChase = true,
    BeingChased = true,
}

local function GFDisconnectIconWatchers()
    for _, connection in ipairs(GFIconConnections) do
        connection:Disconnect()
    end
    table.clear(GFIconConnections)
end

local function GFWatchIconStateRoot(root, watchedRoots, watchedValues)
    if not root or watchedRoots[root] then
        return
    end
    watchedRoots[root] = true

    local function refresh()
        if GFIsScriptActive then
            GFFunctionApplyIcon()
        end
    end

    local function watchValue(object)
        if not GFIconStateNames[object.Name]
            or not object:IsA("ValueBase")
            or watchedValues[object] then
            return
        end
        watchedValues[object] = true
        table.insert(GFIconConnections, object.Changed:Connect(refresh))
    end

    for stateName in pairs(GFIconStateNames) do
        table.insert(
            GFIconConnections,
            root:GetAttributeChangedSignal(stateName):Connect(refresh)
        )
    end
    for _, descendant in ipairs(root:GetDescendants()) do
        watchValue(descendant)
    end
    table.insert(GFIconConnections, root.DescendantAdded:Connect(function(descendant)
        watchValue(descendant)
        if GFIconStateNames[descendant.Name] then
            refresh()
        end
    end))
    table.insert(GFIconConnections, root.DescendantRemoving:Connect(function(descendant)
        if GFIconStateNames[descendant.Name] then
            task.defer(refresh)
        end
    end))
end

local function GFSetupIconWatchers()
    GFDisconnectIconWatchers()
    local watchedRoots = setmetatable({}, { __mode = "k" })
    local watchedValues = setmetatable({}, { __mode = "k" })

    GFWatchIconStateRoot(player, watchedRoots, watchedValues)
    GFWatchIconStateRoot(player.Character, watchedRoots, watchedValues)
    GFWatchIconStateRoot(GFGetPlayerModel(), watchedRoots, watchedValues)

    local function watchPlayersFolder(folder)
        GFWatchIconStateRoot(folder:FindFirstChild(player.Name), watchedRoots, watchedValues)
        table.insert(GFIconConnections, folder.ChildAdded:Connect(function(child)
            if child.Name == player.Name then
                GFWatchIconStateRoot(child, watchedRoots, watchedValues)
                GFFunctionApplyIcon()
            end
        end))
    end

    local playersFolder = workspace:FindFirstChild("Players")
    if playersFolder then
        watchPlayersFolder(playersFolder)
    end
    table.insert(GFIconConnections, workspace.ChildAdded:Connect(function(child)
        if child.Name == "Players" then
            watchPlayersFolder(child)
        end
    end))

    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        table.insert(GFIconConnections, playerGui.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "Character"
                or descendant.Name == "Eyes"
                or descendant.Name == "Expression" then
                GFFunctionApplyIcon()
            end
        end))
    end
    GFFunctionApplyIcon()
end

-- ============================================================================
-- PARCHE CONDICIONAL DE REPLICATEDSTORAGE
-- ============================================================================

local ReplicatedReplacedModel = nil

local function GFSetupReplicatedStorageAsset()
    if ReplicatedReplacedModel and ReplicatedReplacedModel.Parent then return end
    
    task.spawn(function()
        local storage = game:GetService("ReplicatedStorage")
        local skinsFolder = storage:FindFirstChild("ClientAssets") 
            and storage.ClientAssets:FindFirstChild("Characters") 
            and storage.ClientAssets.Characters:FindFirstChild("Survivors") 
            and storage.ClientAssets.Characters.Survivors:FindFirstChild("Amy") 
            and storage.ClientAssets.Characters.Survivors.Amy:FindFirstChild("Skins")
        
        if not skinsFolder then return end
        local originalDefault = skinsFolder:FindFirstChild("Default")
        if not originalDefault then return end

        local replacement = GFLoadAsset(GFAssetId)
        if replacement then
            replacement.Name = "Default"
            if not replacement:FindFirstChild("Sphere.003") then
                local fallback = Instance.new("Part")
                fallback.Name = "Sphere.003"
                fallback.Size = Vector3.new(0.1, 0.1, 0.1)
                fallback.Transparency = 1
                fallback.CanCollide = false
                fallback.CanTouch = false
                fallback.CanQuery = false
                fallback.Anchored = true
                fallback.Parent = replacement
            end
            if not replacement:FindFirstChild("Sphere.007") then
                local fallback = Instance.new("Part")
                fallback.Name = "Sphere.007"
                fallback.Size = Vector3.new(0.1, 0.1, 0.1)
                fallback.Transparency = 1
                fallback.CanCollide = false
                fallback.CanTouch = false
                fallback.CanQuery = false
                fallback.Anchored = true
                fallback.Parent = replacement
            end
            replacement.Parent = skinsFolder
            ReplicatedReplacedModel = replacement
            originalDefault:Destroy()
        end
    end)
end

-- Head Sync Variables
local GFSyncToggle = true
local GFOriginalHeadBase, GFCustomMotorBase, GFOriginalBody, GFOriginalHead, GFCustomHead, GFCustomHeadMotor

local function GFFindOriginalHead(model)
    if not model then return nil end
    local head = model:FindFirstChild("MainHead", true) or model:FindFirstChild("Head", true)
    if head and head:IsA("BasePart") then return head end
    return nil
end

local function GFFindCustomHead(model)
    local mainHead = model:FindFirstChild("MainHead", true)
    if not mainHead then return nil end
    if mainHead:IsA("BasePart") then return mainHead end
    return mainHead:FindFirstChildWhichIsA("BasePart", true)
end

local function GFFindBody(model)
	if not model then return nil end
	local body = model:FindFirstChild("Body", true) or model:FindFirstChild("Torso", true) or model:FindFirstChild("UpperTorso", true) or model:FindFirstChild("HumanoidRootPart", true)
	if body and body:IsA("BasePart") then return body end
	return nil
end

local function GFFindHeadMotor(model, headPart)
    if not model or not headPart then return nil end
    local mainHead = model:FindFirstChild("MainHead", true)
    if not mainHead then return nil end
    return mainHead:FindFirstChild("Joint", true)
        or mainHead:FindFirstChildWhichIsA("Motor6D", true)
        or mainHead:FindFirstChildWhichIsA("Weld", true)
        or mainHead:FindFirstChildWhichIsA("WeldConstraint", true)
end

local function GFSetupHeadSync(originalModel, customModel, fallbackRoot)
	if not GFSyncToggle then return end
	GFOriginalHead = GFFindOriginalHead(originalModel)
	GFOriginalBody = GFFindBody(originalModel) or fallbackRoot
	GFCustomHead = GFFindCustomHead(customModel)
	GFCustomHeadMotor = GFFindHeadMotor(customModel, GFCustomHead)

	if not GFOriginalHead or not GFOriginalBody or not GFCustomHead or not GFCustomHeadMotor then return end
	GFOriginalHeadBase = GFOriginalBody.CFrame:ToObjectSpace(GFOriginalHead.CFrame)
	GFCustomMotorBase = GFCustomHeadMotor.C0
end

local GFSetupCharacter

GFSetupCharacter = function(char, forceReload)
    if not GFIsScriptActive and not forceReload then return end
    if GFSetupInProgress then return end
    GFSetupInProgress = true

    for _, connection in ipairs(GFCosmeticConnections) do
        connection:Disconnect()
    end
    table.clear(GFCosmeticConnections)

    GFSetupGeneration += 1
    local generation = GFSetupGeneration

    if forceReload then GFIsScriptActive = true end

    if GFSyncConn then GFSyncConn:Disconnect() GFSyncConn = nil end
    if GFCurrentModel and GFCurrentModel.Parent then GFCurrentModel:Destroy() GFCurrentModel = nil end

    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") and not GFBelongsToCosmeticRoot(v, char) then
            v.Transparency = 1
            v.CanCollide = (v.Name == "HumanoidRootPart")
        end
    end

    local playersFolder = workspace:FindFirstChild("Players")
    local oldVisual = playersFolder and playersFolder:FindFirstChild(player.Name)
    if oldVisual then
        for _, v in ipairs(oldVisual:GetDescendants()) do
            if v:IsA("BasePart") and not GFBelongsToCosmeticRoot(v, oldVisual) then
                v.Transparency = 1
            end
        end
        GFRestoreCosmeticVisibility(oldVisual)
    end

    GFHammerVisibilityFix(oldVisual or char, true)

    local mdl = GFLoadAsset(GFAssetId)
    if not mdl then
        GFSetupInProgress = false
        return
    end

    if generation ~= GFSetupGeneration or not GFIsScriptActive then
        mdl:Destroy()
        GFSetupInProgress = false
        return
    end

    mdl.Parent = char

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local newHrp = mdl:FindFirstChild("HumanoidRootPart", true)
    if not hrp or not newHrp then
        mdl:Destroy()
        GFSetupInProgress = false
        return
    end

    newHrp.Anchored = false
    newHrp.Transparency = 1
    newHrp.CanCollide = false
    newHrp.CanTouch = false
    newHrp.CanQuery = false

    local mdlHum = mdl:FindFirstChildOfClass("Humanoid")
    if mdlHum then mdlHum:Destroy() end
    local mdlAnim = mdl:FindFirstChildOfClass("Animator")
    if mdlAnim then mdlAnim:Destroy() end

    for _, v in ipairs(mdl:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
            v.CanTouch = false
            v.CanQuery = false
            v.Massless = true
            v.Anchored = false
            if v.Name == "HumanoidRootPart" or v.Name == "Waist" or v.Name == "Weld" then
                v.Transparency = 1
            end
        elseif v:IsA("Trail") or v:IsA("Beam") then
            v.Enabled = false
        end
    end

    newHrp.CFrame = hrp.CFrame
    GFCurrentModel = mdl
    GFUpdateInsertedShirt(oldVisual or char, mdl)
    GFSetupHeadSync(oldVisual or char, mdl, hrp)
    GFSetupInProgress = false

    local origHead = GFOriginalHead
    local origBody = GFOriginalBody
    local custMotor = GFCustomHeadMotor
    local custHead = GFCustomHead
    local custBase = GFCustomMotorBase
    local origBase = GFOriginalHeadBase

    GFSyncConn = RunService.RenderStepped:Connect(function()
        if not GFIsScriptActive or not hrp or not hrp.Parent then
            if GFSyncConn then GFSyncConn:Disconnect() GFSyncConn = nil end
            return
        end

        if not GFCurrentModel or not GFCurrentModel.Parent or not newHrp or not newHrp.Parent then
            if not GFSetupInProgress then
                task.spawn(function()
                    GFSetupCharacter(char, true)
                end)
            end
            return
        end

        newHrp.CFrame = hrp.CFrame

        if GFSyncToggle and origHead and origHead.Parent and origBody and origBody.Parent and custMotor and custMotor.Parent then
            local currentOriginalHead = origBody.CFrame:ToObjectSpace(origHead.CFrame)
            local rotationDelta = origBase.Rotation:Inverse() * currentOriginalHead.Rotation

            local targetC0 = custBase
            if custMotor.Part1 == custHead then
                targetC0 = custBase * rotationDelta
            elseif custMotor.Part0 == custHead then
                targetC0 = custBase * rotationDelta:Inverse()
            end

            custMotor.C0 = custMotor.C0:Lerp(targetC0, 0.35)
        end
    end)
end

local function GFStartScript()
    if GFIsScriptActive or GFStartPending then return end
    GFStartPending = true
    task.wait(1)
	if not GFIsAmy() then
		GFStartPending = false
		return
	end
    
    GFSetupReplicatedStorageAsset()

    GFChasedVisible = false
    GFChasedLostAt = nil
    GFChasedGeneration += 1
    GFLastEyesState = nil
    GFIsScriptActive = true
	GFStartPending = false
    GFSetupIconWatchers() -- RESTAURADO
    if GFCharacter then GFSetupCharacter(GFCharacter) end
end

local function GFStopScript()
    GFSetupGeneration += 1
    if not GFIsScriptActive then return end
    GFIsScriptActive = false
	GFStartPending = false
    GFDisconnectIconWatchers() -- RESTAURADO
	for _, connection in ipairs(GFCosmeticConnections) do connection:Disconnect() end
	table.clear(GFCosmeticConnections)
    if GFSyncConn then GFSyncConn:Disconnect() GFSyncConn = nil end
    if GFCurrentModel and GFCurrentModel.Parent then GFCurrentModel:Destroy() GFCurrentModel = nil end
    if GFCharacter then
        GFRestoreHammerState(GFCharacter)
        for _, v in ipairs(GFCharacter:GetDescendants()) do
            if v:IsA("BasePart") then v.Transparency = 0 end
        end
    end
end

player.CharacterAdded:Connect(function(newChar)
    GFCharacter = newChar
    if GFIsScriptActive then
        GFSetupIconWatchers() -- RESTAURADO
        task.wait(1)
        GFSetupCharacter(newChar)
    end
end)

local GFIsCurrentlyAmy = false
local function GFUpdateCharacterMode()
	local check = GFIsAmy() == true
	if check == GFIsCurrentlyAmy then return end
	GFIsCurrentlyAmy = check
	if check then GFStartScript() else GFStopScript() end
end

local function GFWatchAmyModel(model)
	if not model then return end
	table.insert(GFModeConnections, model:GetAttributeChangedSignal("Character"):Connect(function()
		task.defer(GFUpdateCharacterMode)
	end))
end

local function GFWatchPlayersFolder(folder)
	local visual = folder:FindFirstChild(player.Name)
	if visual then GFWatchAmyModel(visual) end
	table.insert(GFModeConnections, folder.ChildAdded:Connect(function(child)
		if child.Name == player.Name then
			GFWatchAmyModel(child)
			task.defer(GFUpdateCharacterMode)
		end
	end))
end

local playersFolder = workspace:FindFirstChild("Players")
if playersFolder then GFWatchPlayersFolder(playersFolder) end
workspace.ChildAdded:Connect(function(child)
	if child.Name == "Players" then GFWatchPlayersFolder(child) end
end)

GFUpdateCharacterMode()

-- Keybind para Force Reload (Tecla T)
local function GFTriggerForceReload()
	if not GFIsCurrentlyAmy then return end
    if GFForceReload then return end
    GFForceReload = true
    if player.Character and player.Character.Parent then
        GFRestoreHammerState(player.Character)
        GFSetupCharacter(player.Character, true)
    end
    task.defer(function()
        task.wait(0.2)
        GFForceReload = false
    end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.T then
        if GFKeyDebounce then return end
        GFKeyDebounce = true
        task.delay(0.25, function() GFKeyDebounce = false end)
        GFTriggerForceReload()
    end
end)

-- ============================================================================
-- INTERFAZ GRÁFICA
-- ============================================================================

local GFConfigOpen = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GFV2ConfigMenu"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = CoreGui

local GFButton = Instance.new("TextButton")
GFButton.Name = "GFv2"
GFButton.Size = UDim2.new(0, 70, 0, 42)
GFButton.Position = UDim2.new(0, 480, 0, 12)
GFButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
GFButton.BackgroundTransparency = 0.1
GFButton.Text = "GFv2"
GFButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GFButton.Font = Enum.Font.GothamBold
GFButton.TextSize = 15
GFButton.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0.5, 0)
btnCorner.Parent = GFButton

local GFPanel = Instance.new("Frame")
GFPanel.Name = "GFV2ConfigPanel"
GFPanel.Size = UDim2.new(0, 220, 0, 190)
GFPanel.Position = UDim2.new(0, 480, 0, 60)
GFPanel.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
GFPanel.BorderSizePixel = 0
GFPanel.Visible = false
GFPanel.Parent = screenGui

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 14)
panelCorner.Parent = GFPanel

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = Color3.fromRGB(255, 255, 255)
panelStroke.Thickness = 1
panelStroke.Transparency = 1
panelStroke.Parent = GFPanel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = GFPanel

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.Parent = GFPanel

local function createGFConfigRow(parent, labelText, valueRef, onToggle)
    local row = Instance.new("Frame")
    row.Name = labelText .. "Row"
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.6, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = labelText
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.GothamSemibold
    textLabel.TextSize = 14
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.Parent = row

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0.34, 0, 1, 0)
    toggleButton.Position = UDim2.new(0.64, 0, 0, 0)
    toggleButton.BackgroundColor3 = valueRef() and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(120, 120, 120)
    toggleButton.Text = tostring(valueRef())
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 12
    toggleButton.AutoButtonColor = false
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = row

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleButton

    toggleButton.MouseButton1Click:Connect(function()
        if onToggle then onToggle() end
        local nextValue = valueRef()
        toggleButton.Text = tostring(nextValue)
        toggleButton.BackgroundColor3 = nextValue and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(120, 120, 120)
    end)

    return row
end

local function makeGFConfigButton(label, callback)
    local button = Instance.new("TextButton")
    button.Name = label
    button.Size = UDim2.new(1, 0, 0, 30)
    button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    button.Text = label
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.AutoButtonColor = false
    button.BorderSizePixel = 0
    button.Parent = GFPanel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    button.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    return button
end

local function toggleGFCosmeticState()
    GFCosmeticToggle = not GFCosmeticToggle
    if player.Character and player.Character.Parent then
        GFSetupCharacter(player.Character, true)
    end
end

local function toggleGFSyncState()
    GFSyncToggle = not GFSyncToggle
end

local function toggleGFHideJacketState()
    HideJacketaswell = not HideJacketaswell
    if player.Character and player.Character.Parent then
        GFSetupCharacter(player.Character, true)
    end
end

createGFConfigRow(GFPanel, "Cosmetic Comp.", function() return GFCosmeticToggle end, toggleGFCosmeticState)
createGFConfigRow(GFPanel, "Head Sync", function() return GFSyncToggle end, toggleGFSyncState)
createGFConfigRow(GFPanel, "Hide Jacket", function() return HideJacketaswell end, toggleGFHideJacketState)

makeGFConfigButton("Force Reload", function()
    GFTriggerForceReload()
end)

GFButton.MouseButton1Click:Connect(function()
    GFConfigOpen = not GFConfigOpen
    GFPanel.Visible = GFConfigOpen
    GFButton.Text = GFConfigOpen and "Close" or "GFv2"
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/MisterSaiyan/cosas/refs/heads/main/scripts/FNFSkins/V2/gflms.lua"))()

-- ============================================================================
-- RECOLOR DEL MARTILLO / AXE (VALIDACIÓN ESTRICTA DE PARTES FÍSICAS)
-- ============================================================================

local function updateHammer(model)
    if not model then return end
    
    -- Verificamos de forma segura si el modelo tiene al menos una BasePart antes de iterar
    local hasValidParts = false
    if model:IsA("BasePart") then
        hasValidParts = true
    else
        for _, desc in ipairs(model:GetDescendants()) do
            if desc:IsA("BasePart") then
                hasValidParts = true
                break
            end
        end
    end
    
    if not hasValidParts then return end -- Si está vacío, salimos silenciosamente

    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            if v.Color == Color3.fromRGB(255, 217, 0) then v.Color = Color3.fromRGB(27, 42, 53) end
            if v.Color == Color3.fromRGB(255, 0, 102) then v.Color = Color3.fromRGB(86, 36, 36) end
            if v.Color == Color3.fromRGB(255, 0, 0) then v.Color = Color3.fromRGB(91, 93, 105) end
        end
    end
end

-- Función auxiliar para obtener el arma solo si tiene contenido real
local function getValidWeapon(parent)
    if not parent then return nil end
    local weapon = parent:FindFirstChild("Hammer") or parent:FindFirstChild("Axe")
    if not weapon then return nil end

    -- Verificamos si tiene partes adentro
    local hasParts = false
    if weapon:IsA("BasePart") then
        hasParts = true
    else
        for _, desc in ipairs(weapon:GetDescendants()) do
            if desc:IsA("BasePart") then
                hasParts = true
                break
            end
        end
    end

    if not hasParts then return nil end
    return weapon
end

pcall(function()
    local skinsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("ClientAssets")
        and game.ReplicatedStorage.ClientAssets:FindFirstChild("Characters")
        and game.ReplicatedStorage.ClientAssets.Characters:FindFirstChild("Survivors")
        and game.ReplicatedStorage.ClientAssets.Characters.Survivors:FindFirstChild("Amy")
        and game.ReplicatedStorage.ClientAssets.Characters.Survivors.Amy:FindFirstChild("Skins")
    
    if not skinsFolder then return end
    local defaultSkin = skinsFolder:FindFirstChild("Default")
    if not defaultSkin then return end

    local weapon = getValidWeapon(defaultSkin)
    if not weapon then return end

    updateHammer(weapon)
end)

if _G.AmyHammerUpd then _G.AmyHammerUpd:Disconnect() end
_G.AmyHammerUpd = workspace.Players.ChildAdded:Connect(function(child)
    if game.Players.LocalPlayer.Name ~= child.Name then return end
    task.delay(0.2, function()
        if not child or not child.Parent then return end
        local weapon = getValidWeapon(child)
        if not weapon then return end
        updateHammer(weapon)
    end)
end)
