local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local ASSET_ID = 73695760388601
local isScriptActive = false
local currentMdl = nil
local syncConn = nil

-- Amy Iconos

local IconNormal = "rbxassetid://71742134603425" -- Expression.Regular
local ExpressionNormal = "rbxassetid://84044297426855" -- Eyes.Regular
local ExpressionChased = "rbxassetid://129477061313180" -- Eyes.Chased

-- LastLife Iconos Amy

local DownedIcon = "rbxassetid://73290527991494" -- Expression.Downed

local IconLastLife = "rbxassetid://123405413536790" -- Expression.LastLife
local ExpressionLastLife = "rbxassetid://129477061313180" -- Reemplaza Eyes.Regular si estas en lastlife

-- force reload without a gui
local forceReload = false
local keyDebounce = false

local shirtCosmetics = {
    TMOSTH = true,
}

local cosmeticRootNames = {
    TMOSTH = true,
}

local function belongsToCosmeticRoot(object, model)
    local current = object
    while current and current ~= model do
        if cosmeticRootNames[current.Name] or shirtCosmetics[current.Name] then
            return true
        end
        current = current.Parent
    end
    return false
end

local function restoreCosmeticVisibility(model)
    if not model then
        return
    end

    for cosmeticName in pairs(shirtCosmetics) do
        local cosmetic = model:FindFirstChild(cosmeticName, true)
        if cosmetic then
            local objects = { cosmetic }
            for _, object in ipairs(cosmetic:GetDescendants()) do
                table.insert(objects, object)
            end

            for _, object in ipairs(objects) do
                if object:IsA("BasePart") then
                    object.Transparency = 0
                    object.CanCollide = false
                end
            end
        end
    end
end

local hidething = false -- Toggle Hammer visibility fix (don't change)

local function HammerVisiblityFix(targetModel, visible)
    if hidething or not targetModel then
        return
    end

    local hammer = targetModel:FindFirstChild("Hammer", true)
        or targetModel:FindFirstChild("Axe", true)
    if not hammer then
        return
    end

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

local function updateInsertedShirt(model, insertedModel)
    if not model or not insertedModel then
        return
    end

    local hasShirtCosmetic = false
    for cosmeticName in pairs(shirtCosmetics) do
        if model:FindFirstChild(cosmeticName, true) then
            hasShirtCosmetic = true
            break
        end
    end

    local shirtModel = insertedModel:FindFirstChild("Vestido", true)

    local function setShirtVisibility(shirtGroup, visible)
        if not shirtGroup then
            return
        end

        local objects = { shirtGroup }
        for _, object in ipairs(shirtGroup:GetDescendants()) do
            table.insert(objects, object)
        end

        for _, object in ipairs(objects) do
            if object:IsA("BasePart") then
                object.Transparency = visible and 0 or 1
                object.CanCollide = false
            elseif object:IsA("Decal") or object:IsA("Texture") then
                object.Transparency = visible and 0 or 1
            end
        end
    end

    setShirtVisibility(shirtModel, not hasShirtCosmetic)
end

local function loadAsset(id)
    local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
    if not ok or not objects or #objects == 0 then return nil end
    return objects[1]:Clone()
end

local function getPlayerModel()
    local playersFolder = workspace:FindFirstChild("Players")
    return playersFolder and playersFolder:FindFirstChild(player.Name)
end

local function getBooleanState(root, names)
    if not root then
        return false
    end

    for _, name in ipairs(names) do
        local value = root:GetAttribute(name)
        if value == true or value == "true" or value == "True" then
            return true
        end

        local stateObject = root:FindFirstChild(name, true)
        if stateObject and stateObject:IsA("BoolValue") and stateObject.Value then
            return true
        end
    end

    return false
end

local function setFolderState(folder, activeName, imageId, fitToFrame, layout, zIndex)
    if not folder then
        return
    end

    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("ImageLabel") or child:IsA("ImageButton") then
            local isActive = child.Name == activeName
            child.Visible = isActive
            if isActive then
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

local ApplyIcon

ApplyIcon = function()
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

    local model = getPlayerModel() or player.Character
    local isLastLife = getBooleanState(model, { "LastLife", "IsLastLife", "SecondLife" })
    local isDowned = getBooleanState(model, { "Downed", "IsDowned" })
    local isChased = getBooleanState(model, { "Chased", "IsChased", "InChase" })

    local eyesState = isChased and "Chased" or "Regular"
    local expressionState = isLastLife and "LastLife" or "Regular"
    local eyesImage = isChased and ExpressionChased or ExpressionNormal
    local expressionImage = isLastLife and IconLastLife or IconNormal

    if isLastLife then
        eyesImage = ExpressionLastLife
    end
    if isDowned then
        eyesState = "Stunned"
        expressionState = "Downed"
        expressionImage = DownedIcon
    end

    local layout = {
        position = UDim2.fromScale(0.47, 0.39),
        size = UDim2.fromScale(0.47, 0.45),
    }
    setFolderState(characterGui:FindFirstChild("Eyes"), eyesState, eyesImage, true, layout, 10)
    setFolderState(characterGui:FindFirstChild("Expression"), expressionState, expressionImage, true, layout, 5)
end

-- Head Sync

local synctoggle = true -- True to enable head sync, false to disable (Default: true)

local originalHeadBase, customMotorBase, originalBody, originalHead, customHead, customHeadMotor

local function findOriginalHead(model)
    if not model then return nil end

    local head = model:FindFirstChild("MainHead", true) or model:FindFirstChild("Head", true)
    if head and head:IsA("BasePart") then
        return head
    end

    return nil
end

-- Setup ViewPort (Cuz of cosmetic clipping the model)

local function setupAmyViewport()
	task.spawn(function()
		local viewportFrame = player.PlayerGui
			:WaitForChild("Round", 30)
			:WaitForChild("Game", 30)
			:WaitForChild("SurvivorHP", 30)
			:WaitForChild("ViewportFrame", 30)
		if not viewportFrame then return end
		local viewportModel = viewportFrame
			:WaitForChild("WorldModel", 30)
			:WaitForChild("Default", 30)
		if not viewportModel then return end

		local vpOverrideModel = nil
		local function replaceAViewportModel()
			local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. 73695760388601)
			if not ok or #objects == 0 then return end
			if vpOverrideModel and vpOverrideModel.Parent then
				vpOverrideModel:Destroy()
				vpOverrideModel = nil
			end
			local newModel = objects[1]:Clone()
			vpOverrideModel = newModel
			for _, part in ipairs(viewportModel:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.Transparency = 1
				end
			end
			local newHum = newModel:FindFirstChildOfClass("Humanoid")
			if newHum then newHum:Destroy() end
			for _, v in ipairs(newModel:GetDescendants()) do
				if v:IsA("BasePart") then v.CanCollide = false end
			end
			newModel.Parent = viewportModel
			local viewportHRP = viewportModel:FindFirstChild("HumanoidRootPart")
			local primaryPart = newModel.PrimaryPart or newModel:FindFirstChildWhichIsA("BasePart")
			if viewportHRP and primaryPart then
				newModel:PivotTo(viewportHRP.CFrame)
				primaryPart.Transparency = 1
				local weld = Instance.new("WeldConstraint")
				weld.Part0 = viewportHRP
				weld.Part1 = primaryPart
				weld.Parent = viewportHRP
			end
		end

		replaceAViewportModel()

		viewportModel.DescendantAdded:Connect(function()
			task.wait(0.1)
			if not vpOverrideModel or not vpOverrideModel.Parent then
				vpOverrideModel = nil
				replaceAViewportModel()
			end
		end)
	end)
end

local function findCustomHead(model)

    local mainHead = model:FindFirstChild("MainHead", true)
    if not mainHead then return nil end

    if mainHead:IsA("BasePart") then
        return mainHead
    end

    return mainHead:FindFirstChildWhichIsA("BasePart", true)
end

local function findBody(model)
	if not model then
		return nil
	end

	local body =
		model:FindFirstChild("Body", true)
		or model:FindFirstChild("Torso", true)
		or model:FindFirstChild("UpperTorso", true)
		or model:FindFirstChild("HumanoidRootPart", true)

	if body and body:IsA("BasePart") then
		return body
	end

	return nil
end

local function findHeadMotor(model, headPart)
    if not model or not headPart then
        return nil
    end

    local mainHead = model:FindFirstChild("MainHead", true)
    if not mainHead then return nil end

    return mainHead:FindFirstChild("Joint", true)
        or mainHead:FindFirstChildWhichIsA("Motor6D", true)
        or mainHead:FindFirstChildWhichIsA("Weld", true)
        or mainHead:FindFirstChildWhichIsA("WeldConstraint", true)
end

local function setupHeadSync(originalModel, customModel, fallbackRoot)
	if not synctoggle then
		return
	end

	if not originalModel or not customModel then
		warn(
			"[HeadSync] Faltan modelos",
			"OriginalModel:", originalModel,
			"CustomModel:", customModel
		)
		return
	end

	originalHead = findOriginalHead(originalModel)
	originalBody = findBody(originalModel) or fallbackRoot
	customHead = findCustomHead(customModel)
	customHeadMotor = findHeadMotor(customModel, customHead)

	if not originalHead then
		warn("[HeadSync] No se encontró el Head original")
		return
	end

	if not originalBody or not originalBody:IsA("BasePart") then
		warn("[HeadSync] No se encontró Body/Root original")
		return
	end

	if not customHead then
		warn("[HeadSync] No se encontró el Head custom")
		return
	end

	if not customHeadMotor then
		warn(
			"[HeadSync] No se encontró un Motor6D conectado al Head custom",
			customHead:GetFullName()
		)
		return
	end

	originalHeadBase = originalBody.CFrame:ToObjectSpace(originalHead.CFrame)
	customMotorBase = customHeadMotor.C0
end

local function isAmy()
	local model = getPlayerModel()
	return model and model:GetAttribute("Character") == "Amy"
end

-- Replace the replicatedstorage char (affects viewport, character selection and inventory)

task.spawn(function()
    local storage = game:GetService("ReplicatedStorage")
    local skins = storage
        :WaitForChild("ClientAssets")
        :WaitForChild("Characters")
        :WaitForChild("Survivors")
        :WaitForChild("Amy")
        :WaitForChild("Skins")

    local originalDefault = skins:WaitForChild("Default")
    local replacement = loadAsset(ASSET_ID)

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
        replacement.Parent = skins
        originalDefault:Destroy()
    end
end)

local function setupCharacter(char, forceReload)
    if not isScriptActive and not forceReload then return end

	if forceReload then
			isScriptActive = true
		end

    if syncConn then syncConn:Disconnect() syncConn = nil end
    if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end

    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") and not belongsToCosmeticRoot(v, char) then
            v.Transparency = 1
            if v.Name == "HumanoidRootPart" then
                v.CanCollide = true
            else
                v.CanCollide = false
            end
        end
    end

    local playersFolder = workspace:FindFirstChild("Players")
    local oldVisual = playersFolder and playersFolder:FindFirstChild(player.Name)
    if oldVisual then
        for _, v in ipairs(oldVisual:GetDescendants()) do
            if v:IsA("BasePart") and not belongsToCosmeticRoot(v, oldVisual) then
                v.Transparency = 1
            end
        end
        restoreCosmeticVisibility(oldVisual)
    end

    HammerVisiblityFix(oldVisual or char, true)

    local mdl = loadAsset(ASSET_ID)
    if not mdl then return end

    if oldVisual then
        mdl.Parent = oldVisual
    else
        mdl.Parent = char
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local newHrp = mdl:FindFirstChild("HumanoidRootPart", true)
    if not hrp or not newHrp then
        mdl:Destroy()
        return
    end

    newHrp.Anchored = false
    newHrp.Transparency = 1

    local mdlHum = mdl:FindFirstChildOfClass("Humanoid")
    if mdlHum then mdlHum:Destroy() end
    local mdlAnim = mdl:FindFirstChildOfClass("Animator")
    if mdlAnim then mdlAnim:Destroy() end

    for _, v in ipairs(mdl:GetDescendants()) do
        if v:IsA("BasePart") then
            if v.Name ~= "Sphere.002" and v.Name ~= "eye1" and v.Name ~= "eye2" then
                v.CanCollide = false
            end
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
    local physicalWeld = Instance.new("WeldConstraint")
    physicalWeld.Name = "SkinPhysicalAnchor"
    physicalWeld.Part0 = hrp
    physicalWeld.Part1 = newHrp
    physicalWeld.Parent = newHrp

    currentMdl = mdl
    updateInsertedShirt(oldVisual or char, mdl)
    setupHeadSync(oldVisual or char, mdl, hrp)

    task.spawn(function()
        while char and char.Parent and isScriptActive and currentMdl == mdl do
            restoreCosmeticVisibility(oldVisual or char)
            updateInsertedShirt(oldVisual or char, mdl)
            task.wait(0.1)
        end
    end)

    syncConn = RunService.RenderStepped:Connect(function()
        if not char or not char.Parent or not hrp or not hrp.Parent or not newHrp or not newHrp.Parent or not isScriptActive then
            if syncConn then syncConn:Disconnect() syncConn = nil end
            return
        end

        if synctoggle and originalHead and originalHead.Parent and originalBody and originalBody.Parent and customHeadMotor and customHeadMotor.Parent then
            local success, result = pcall(function()
                local currentOriginalHead = originalBody.CFrame:ToObjectSpace(originalHead.CFrame)
                local rotationDelta = originalHeadBase.Rotation:Inverse() * currentOriginalHead.Rotation

                local targetC0 = customMotorBase
                if customHeadMotor.Part1 == customHead then
                    targetC0 = customMotorBase * rotationDelta
                elseif customHeadMotor.Part0 == customHead then
                    targetC0 = customMotorBase * rotationDelta:Inverse()
                end

                customHeadMotor.C0 = customHeadMotor.C0:Lerp(targetC0, 0.35)
            end)
            if not success then
                warn("[HeadSync] Error during rotation calculation:", result)
            end
        end
    end)
end

local function startScript()
    if isScriptActive then return end
    task.wait(1.5) -- Reducido de 3 a 1 para agilizar la entrada
    setupAmyViewport()
    isScriptActive = true
    if character then setupCharacter(character) end

    task.spawn(function()
        while isScriptActive and isAmy() do
            ApplyIcon()
            task.wait(0.25)
        end
    end)
end

local function stopScript()
    if not isScriptActive then return end
    isScriptActive = false
    if syncConn then syncConn:Disconnect() syncConn = nil end
    if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end
    if character then
        for _, v in ipairs(character:GetDescendants()) do
            if v:IsA("BasePart") then v.Transparency = 0 end
        end
    end
end

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    if isScriptActive then
        task.wait(1.5)
        setupCharacter(newChar)
    end
end)

local isCurrentlyAmy = false
local isPlaying = false

RunService.Heartbeat:Connect(function()
    local check = isAmy()
    if check ~= isCurrentlyAmy then
        isCurrentlyAmy = check
        isPlaying = check
        if isPlaying then startScript() else stopScript() end
    end
end)

if isAmy() then
    isCurrentlyAmy = true
    isPlaying = true
    startScript()
end

-- Keybind para forcereload de debug

local function triggerForceReload()
	if not isCurrentlyAmy then
		game.StarterGui:SetCore("SendNotification", {
        Title = "GF Over Amy", 
        Text = "Force Reload doesn't work if you are not playing as amy.", 
        Icon = "rbxassetid://128451136697149", Duration = 10
    })
	return
	end

    if forceReload then
        return
    end

    forceReload = true

    if player.Character and player.Character.Parent then
        setupCharacter(player.Character, true)
    end

    task.defer(function()
        task.wait(0.2)
        forceReload = false
    end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode ~= Enum.KeyCode.T then
        return
    end

    if keyDebounce then
        return
    end

    keyDebounce = true
    task.delay(0.25, function()
        keyDebounce = false
    end)

    triggerForceReload()
end)

-- Loadstring para el tema lms

loadstring(game:HttpGet("https://raw.githubusercontent.com/MisterSaiyan/cosas/refs/heads/main/scripts/FNFSkins/V2/gflms.lua"))()
