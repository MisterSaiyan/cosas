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
local GFAssetId = 73695760388601
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

-- force reload without a gui
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
    if not GFCosmeticToggle then return end
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

local GFHideThing = false -- Toggle Hammer visibility fix (don't change)
local GFTargetHammerState = {}

local function GFGetHammer(targetModel)
    if not targetModel then
        return nil
    end

    return targetModel:FindFirstChild("Hammer", true)
        or targetModel:FindFirstChild("Axe", true)
        or targetModel:FindFirstChild("MagicalAmy", true)
end

local function GFCacheHammerState(targetModel)
    local hammer = GFGetHammer(targetModel)
    if not hammer or GFTargetHammerState[targetModel] then
        return
    end

    local snapshot = {}
    local function collect(node)
        if not node then
            return
        end

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
    if not snapshot then
        return
    end

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
    if GFHideThing or not targetModel then
        return
    end

    local hammer = GFGetHammer(targetModel)
    if not hammer then
        return
    end

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

    local vestidoModel = insertedModel:FindFirstChild("Vestido", true)
    local chaquetaModel = insertedModel:FindFirstChild("Chaqueta", true)
    local white = Color3.fromRGB(255, 255, 255)
    local protectedSleeves = {
        LSleeve = true,
        RSleeve = true,
    }

    local function isProtectedSleeve(object, root)
        local current = object
        while current and current ~= root do
            if protectedSleeves[current.Name] then
                return true
            end
            current = current.Parent
        end
        return false
    end

    local function setShirtVisibility(shirtGroup, visible)
        if not shirtGroup then
            return
        end

        local objects = { shirtGroup }
        for _, object in ipairs(shirtGroup:GetDescendants()) do
            table.insert(objects, object)
        end

        for _, object in ipairs(objects) do
            if not isProtectedSleeve(object, shirtGroup) and object:IsA("BasePart") then
                object.Transparency = visible and 0 or 1
                object.CanCollide = false
            elseif not isProtectedSleeve(object, shirtGroup)
                and (object:IsA("Decal") or object:IsA("Texture")) then
                object.Transparency = visible and 0 or 1
            end
        end
    end

    local function setJacketRelatedColors()
        if not HideJacketaswell then
            for part, originalColor in pairs(GFJacketOriginalColors) do
                if part.Parent then
                    part.Color = originalColor
                end
                GFJacketOriginalColors[part] = nil
            end
        else
            local colorTargets = {}
            for _, name in ipairs({ "LSleeve", "RSleeve", "Arms" }) do
                local target = insertedModel:FindFirstChild(name, true)
                if target then
                    table.insert(colorTargets, target)
                end
            end

            for _, target in ipairs(colorTargets) do
                local objects = { target }
                for _, object in ipairs(target:GetDescendants()) do
                    table.insert(objects, object)
                end

                for _, object in ipairs(objects) do
                    if object:IsA("BasePart") then
                        if GFJacketOriginalColors[object] == nil then
                            GFJacketOriginalColors[object] = object.Color
                        end
                        object.Color = white
                    end
                end
            end
        end

        for _, name in ipairs({ "LSleeve", "RSleeve" }) do
            local sleeve = insertedModel:FindFirstChild(name, true)
            if sleeve then
                local objects = { sleeve }
                for _, object in ipairs(sleeve:GetDescendants()) do
                    table.insert(objects, object)
                end

                for _, object in ipairs(objects) do
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
            local isActive = child.Name == activeName
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

-- Head Sync

local GFSyncToggle = false -- True to enable head sync, false to disable (Default: true)

local GFOriginalHeadBase, GFCustomMotorBase, GFOriginalBody, GFOriginalHead, GFCustomHead, GFCustomHeadMotor

local function GFFindOriginalHead(model)
    if not model then return nil end

    local head = model:FindFirstChild("MainHead", true) or model:FindFirstChild("Head", true)
    if head and head:IsA("BasePart") then
        return head
    end

    return nil
end

-- Setup ViewPort (Cuz of cosmetic clipping the model)

local function GFSetupAmyViewport()
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
			local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. GFAssetId)
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

		local viewportRefreshPending = false
		viewportModel.DescendantAdded:Connect(function()
			if viewportRefreshPending then return end
			viewportRefreshPending = true
			task.delay(0.1, function()
				viewportRefreshPending = false
				if viewportModel.Parent and (not vpOverrideModel or not vpOverrideModel.Parent) then
					vpOverrideModel = nil
					replaceAViewportModel()
				end
			end)
		end)
	end)
end

local function GFFindCustomHead(model)

    local mainHead = model:FindFirstChild("MainHead", true)
    if not mainHead then return nil end

    if mainHead:IsA("BasePart") then
        return mainHead
    end

    return mainHead:FindFirstChildWhichIsA("BasePart", true)
end

local function GFFindBody(model)
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

local function GFFindHeadMotor(model, headPart)
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

local function GFSetupHeadSync(originalModel, customModel, fallbackRoot)
	if not GFSyncToggle then
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

	GFOriginalHead = GFFindOriginalHead(originalModel)
	GFOriginalBody = GFFindBody(originalModel) or fallbackRoot
	GFCustomHead = GFFindCustomHead(customModel)
	GFCustomHeadMotor = GFFindHeadMotor(customModel, GFCustomHead)

	if not GFOriginalHead then
		warn("[HeadSync] No se encontró el Head original")
		return
	end

	if not GFOriginalBody or not GFOriginalBody:IsA("BasePart") then
		warn("[HeadSync] No se encontró Body/Root original")
		return
	end

	if not GFCustomHead then
		warn("[HeadSync] No se encontró el Head custom")
		return
	end

	if not GFCustomHeadMotor then
		warn(
			"[HeadSync] No se encontró un Motor6D conectado al Head custom",
			GFCustomHead:GetFullName()
		)
		return
	end

	GFOriginalHeadBase = GFOriginalBody.CFrame:ToObjectSpace(GFOriginalHead.CFrame)
	GFCustomMotorBase = GFCustomHeadMotor.C0
end

local function GFIsAmy()
	local model = GFGetPlayerModel()
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
        replacement.Parent = skins
        originalDefault:Destroy()
    end
end)

local function GFSetupCharacter(char, forceReload)
    if not GFIsScriptActive and not forceReload then return end
    if GFSetupInProgress then return end
    GFSetupInProgress = true
	for _, connection in ipairs(GFCosmeticConnections) do
		connection:Disconnect()
	end
	table.clear(GFCosmeticConnections)
    GFSetupGeneration += 1
    local generation = GFSetupGeneration

	if forceReload then
			GFIsScriptActive = true
		end

    if GFSyncConn then GFSyncConn:Disconnect() GFSyncConn = nil end
    if GFCurrentModel and GFCurrentModel.Parent then GFCurrentModel:Destroy() GFCurrentModel = nil end

    for _, v in ipairs(char:GetDescendants()) do
        if v:IsA("BasePart") and not GFBelongsToCosmeticRoot(v, char) then
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

    if oldVisual then
        mdl.Parent = oldVisual
    else
        mdl.Parent = char
    end

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
    local physicalWeld = Instance.new("WeldConstraint")
    physicalWeld.Name = "SkinPhysicalAnchor"
    physicalWeld.Part0 = hrp
    physicalWeld.Part1 = newHrp
    physicalWeld.Parent = newHrp

    GFCurrentModel = mdl
    GFUpdateInsertedShirt(oldVisual or char, mdl)
    GFSetupHeadSync(oldVisual or char, mdl, hrp)
	GFSetupInProgress = false

	local cosmeticSource = oldVisual or char
	local cosmeticUpdatePending = false
	local function queueCosmeticUpdate(object)
		local current = object
		local isCosmetic = false
		while current and current ~= cosmeticSource do
			if cosmeticRootNames[current.Name] or shirtCosmetics[current.Name] then
				isCosmetic = true
				break
			end
			current = current.Parent
		end
		if not isCosmetic or cosmeticUpdatePending then
			return
		end

		cosmeticUpdatePending = true
		task.defer(function()
			cosmeticUpdatePending = false
			if not GFIsScriptActive or GFSetupGeneration ~= generation
				or GFCurrentModel ~= mdl or not cosmeticSource.Parent then
				return
			end
			GFRestoreCosmeticVisibility(cosmeticSource)
			GFUpdateInsertedShirt(cosmeticSource, mdl)
		end)
	end
	table.insert(GFCosmeticConnections, cosmeticSource.DescendantAdded:Connect(queueCosmeticUpdate))
	table.insert(GFCosmeticConnections, cosmeticSource.DescendantRemoving:Connect(queueCosmeticUpdate))

    if GFSyncToggle then
        GFSyncConn = RunService.RenderStepped:Connect(function()
        if not char or not char.Parent or not hrp or not hrp.Parent or not newHrp or not newHrp.Parent or not GFIsScriptActive then
            if GFSyncConn then GFSyncConn:Disconnect() GFSyncConn = nil end
            return
        end

        if GFSyncToggle and GFOriginalHead and GFOriginalHead.Parent and GFOriginalBody and GFOriginalBody.Parent and GFCustomHeadMotor and GFCustomHeadMotor.Parent then
            local success, result = pcall(function()
                local currentOriginalHead = GFOriginalBody.CFrame:ToObjectSpace(GFOriginalHead.CFrame)
                local rotationDelta = GFOriginalHeadBase.Rotation:Inverse() * currentOriginalHead.Rotation

                local targetC0 = GFCustomMotorBase
                if GFCustomHeadMotor.Part1 == GFCustomHead then
                    targetC0 = GFCustomMotorBase * rotationDelta
                elseif GFCustomHeadMotor.Part0 == GFCustomHead then
                    targetC0 = GFCustomMotorBase * rotationDelta:Inverse()
                end

                GFCustomHeadMotor.C0 = GFCustomHeadMotor.C0:Lerp(targetC0, 0.35)
            end)
            if not success then
                warn("[HeadSync] Error during rotation calculation:", result)
            end
        end
        end)
    end
end

local function GFStartScript()
    if GFIsScriptActive or GFStartPending then return end
    GFStartPending = true
    task.wait(1.5) -- Reducido de 3 a 1 para agilizar la entrada
	if not GFIsAmy() then
		GFStartPending = false
		return
	end
    GFSetupAmyViewport()
    GFChasedVisible = false
    GFChasedLostAt = nil
    GFChasedGeneration += 1
    GFLastEyesState = nil
    GFIsScriptActive = true
	GFStartPending = false
	GFSetupIconWatchers()
    if GFCharacter then GFSetupCharacter(GFCharacter) end
end

local function GFStopScript()
    GFSetupGeneration += 1
    if not GFIsScriptActive then return end
    GFIsScriptActive = false
	GFStartPending = false
	GFDisconnectIconWatchers()
	for _, connection in ipairs(GFCosmeticConnections) do
		connection:Disconnect()
	end
	table.clear(GFCosmeticConnections)
    if GFSyncConn then GFSyncConn:Disconnect() GFSyncConn = nil end
    if GFCurrentModel and GFCurrentModel.Parent then GFCurrentModel:Destroy() GFCurrentModel = nil end
    if GFCharacter then
        GFRestoreHammerState(GFCharacter)
        for _, v in ipairs(GFCharacter:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 0
            end
        end
    end
end

player.CharacterAdded:Connect(function(newChar)
    GFCharacter = newChar
	if GFIsScriptActive then
		GFSetupIconWatchers()
	end
    if GFIsScriptActive then
        task.wait(1.5)
        GFSetupCharacter(newChar)
    end
end)

local GFIsCurrentlyAmy = false
local GFIsPlaying = false

local watchedAmyModels = setmetatable({}, { __mode = "k" })
local function GFUpdateCharacterMode()
	local check = GFIsAmy() == true
	if check == GFIsCurrentlyAmy then
		return
	end

	GFIsCurrentlyAmy = check
	GFIsPlaying = check
	if check then
		GFStartScript()
	else
		GFStopScript()
	end
end

local function GFWatchAmyModel(model)
	if not model or watchedAmyModels[model] then
		return
	end
	watchedAmyModels[model] = true
	table.insert(GFModeConnections, model:GetAttributeChangedSignal("Character"):Connect(function()
		task.defer(GFUpdateCharacterMode)
	end))
end

local function GFWatchPlayersFolder(folder)
	local visual = folder:FindFirstChild(player.Name)
	if visual then
		GFWatchAmyModel(visual)
	end
	table.insert(GFModeConnections, folder.ChildAdded:Connect(function(child)
		if child.Name == player.Name then
			GFWatchAmyModel(child)
			task.defer(GFUpdateCharacterMode)
		end
	end))
end

local playersFolder = workspace:FindFirstChild("Players")
if playersFolder then
	GFWatchPlayersFolder(playersFolder)
end
table.insert(GFModeConnections, workspace.ChildAdded:Connect(function(child)
	if child.Name == "Players" then
		GFWatchPlayersFolder(child)
	end
end))

GFUpdateCharacterMode()

-- Keybind para forcereload de debug

local function GFTriggerForceReload()
	if not GFIsCurrentlyAmy then
		game.StarterGui:SetCore("SendNotification", {
        Title = "GF Over Amy", 
        Text = "Force Reload doesn't work if you are not playing as amy.", 
        Icon = "rbxassetid://128451136697149", Duration = 10
    })
	return
	end

    if GFForceReload then
        return
    end

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
    if gameProcessed then
        return
    end

    if input.KeyCode ~= Enum.KeyCode.T then
        return
    end

    if GFKeyDebounce then
        return
    end

    GFKeyDebounce = true
    task.delay(0.25, function()
        GFKeyDebounce = false
    end)

    GFTriggerForceReload()
end)

-- Configuracion GFV2

local function crearBotonVisualGF(texto, orden)
    local boton = Instance.new("TextButton")
    boton.Name = "Panel_" .. (texto:gsub("%s+", ""))
    boton.Size = UDim2.new(0, 0, 0, 42)
    boton.AutomaticSize = Enum.AutomaticSize.X
    boton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    boton.BackgroundTransparency = 0.1
    boton.AutoButtonColor = true
    boton.LayoutOrder = orden

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0.5, 0)
    corner.Parent = boton

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 22)
    padding.PaddingRight = UDim.new(0, 22)
    padding.Parent = boton

    boton.Text = texto
    boton.TextColor3 = Color3.fromRGB(255, 255, 255)
    boton.Font = Enum.Font.GothamBold
    boton.TextSize = 15

    return boton
end

local function getSharedGFTopBar()
    local bfGui = CoreGui:FindFirstChild("ConfiguracionesBF")
    if bfGui then
        local bar = bfGui:FindFirstChild("ContenedorHorizontal")
        if bar then
            return bar
        end
    end
    return nil
end

local GFSharedBar = getSharedGFTopBar()
local GFConfigOpen = false

local function ensureGFButton()
    if GFSharedBar and GFSharedBar:FindFirstChild("GFv2") then
        return GFSharedBar:FindFirstChild("GFv2")
    end

    local bar = GFSharedBar or (function()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ConfiguracionesGF"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = CoreGui

        local topBar = Instance.new("Frame")
        topBar.Name = "ContenedorHorizontal"
        topBar.Size = UDim2.new(0, 0, 0, 42)
        topBar.AutomaticSize = Enum.AutomaticSize.X
        topBar.Position = UDim2.new(0, 400, 0, 12)
        topBar.BackgroundTransparency = 1
        topBar.Parent = screenGui

        local listLayout = Instance.new("UIListLayout")
        listLayout.Parent = topBar
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder
        listLayout.FillDirection = Enum.FillDirection.Horizontal
        listLayout.Padding = UDim.new(0, 12)
        listLayout.VerticalAlignment = Enum.VerticalAlignment.Center

        return topBar
    end)()

    local existingButton = bar:FindFirstChild("GFv2")
    if existingButton then
        return existingButton
    end

    local gfButton = crearBotonVisualGF("GFv2", 2)
    gfButton.Name = "GFv2"
    gfButton.Parent = bar

    return gfButton
end

local GFButton = ensureGFButton()

local function ensureGFPanel()
    local panel = rawget(_G, "GFV2ConfigPanel")
    if panel and panel.Parent then
        return panel
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GFV2ConfigMenu"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = CoreGui

    local panel = Instance.new("Frame")
    panel.Name = "GFV2ConfigPanel"
    panel.Size = UDim2.new(0, 220, 0, 182)
    panel.Position = UDim2.new(0, 400, 0, 60)
    panel.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = panel

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 1
    stroke.LineJoinMode = Enum.LineJoinMode.Miter
    stroke.Parent = panel

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = panel

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.Parent = panel

    _G.GFV2ConfigPanel = panel
    return panel
end

local GFPanel = ensureGFPanel()

local function createGFConfigRow(parent, labelText, valueRef, onToggle)
    local row = Instance.new("Frame")
    row.Name = labelText .. "Row"
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    row.Parent = parent

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 8)
    rowCorner.Parent = row

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0.6, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = labelText
    textLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
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

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(0, 0, 0)
    toggleStroke.Thickness = 1
    toggleStroke.Transparency = 1
    toggleStroke.Parent = toggleButton

    toggleButton.MouseButton1Click:Connect(function()
        if onToggle then
            onToggle()
        end
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

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 1
    stroke.Parent = button

    button.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
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

local function setGFConfigVisible(visible)
    GFConfigOpen = visible
    GFPanel.Visible = visible
    GFButton.Text = visible and "Close" or "GFv2"
end

createGFConfigRow(GFPanel, "Cosmetic Comp.", function() return GFCosmeticToggle end, toggleGFCosmeticState)
createGFConfigRow(GFPanel, "Head Sync", function() return GFSyncToggle end, toggleGFSyncState)
createGFConfigRow(GFPanel, "Hide Jacket", function() return HideJacketaswell end, function()
    HideJacketaswell = not HideJacketaswell
end)

makeGFConfigButton("Force Reload", function()
    GFTriggerForceReload()
end)

GFButton.MouseButton1Click:Connect(function()
    setGFConfigVisible(not GFConfigOpen)
end)

setGFConfigVisible(false)

-- Loadstring para el tema lms

loadstring(game:HttpGet("https://raw.githubusercontent.com/MisterSaiyan/cosas/refs/heads/main/scripts/FNFSkins/V2/gflms.lua"))()

-- Colores del martillo (creditos a lil2kki)

local function updateHammer(model)
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            if v.Color == Color3.fromRGB(255, 217, 0) then v.Color = Color3.fromRGB(27, 42, 53) end
            if v.Color == Color3.fromRGB(255, 0, 102) then v.Color = Color3.fromRGB(86, 36, 36) end
            if v.Color == Color3.fromRGB(255, 0, 0) then v.Color = Color3.fromRGB(91, 93, 105) end
        end
    end
end

updateHammer(game:GetService("ReplicatedStorage").ClientAssets.Characters.Survivors.Amy.Skins.Default.Hammer)

if _G.AmyHammerUpd then _G.AmyHammerUpd:Disconnect() end
_G.AmyHammerUpd = workspace.Players.ChildAdded:Connect(function(child)
    print("ChildAdded:", child.ClassName, child:GetFullName())
    if game.Players.LocalPlayer.Name ~= child.Name then return end

    local cameraConnection
    local currentCameraConnection
    local initialCFrame
    local finished = false

    local function applyHammer()
        if finished then return end
        finished = true
        if cameraConnection then cameraConnection:Disconnect() end
        if currentCameraConnection then currentCameraConnection:Disconnect() end

        local Hammer = child:FindFirstChild("Hammer", true)
        if not Hammer then return end
        print(Hammer:GetFullName())
        updateHammer(Hammer)
    end

    local function watchCamera()
        if cameraConnection then
            cameraConnection:Disconnect()
            cameraConnection = nil
        end
        local camera = workspace.CurrentCamera
        if not camera then return end
        if not initialCFrame then initialCFrame = camera.CFrame end
        if camera.CFrame ~= initialCFrame then
            applyHammer()
            return
        end
        cameraConnection = camera:GetPropertyChangedSignal("CFrame"):Connect(function()
            if camera.CFrame ~= initialCFrame then applyHammer() end
        end)
        if camera.CFrame ~= initialCFrame then applyHammer() end
    end

    currentCameraConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)
    watchCamera()
end)

print("hammer recolor comes!")
