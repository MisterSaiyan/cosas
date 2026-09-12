local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local ASSET_ID = 137895615579863
local isScriptActive = false
local currentMdl = nil
local syncConn = nil

--Iconos FirstLife

local IconNormal = "rbxassetid://88534919957810" -- Expression.Regular
local ExpressionNormal = "rbxassetid://105224083812202" -- Eyes.Regular
local ExpressionChased = "rbxassetid://134712413253361" -- Eyes.Chased

-- LastLife Iconos

local DownedIcon = "rbxassetid://97120638843605" -- Expression.Downed

local IconLastLife = "rbxassetid://91850457535074" -- Expression.LastLife
local ExpressionLastLife = "rbxassetid://80325412154894" -- Reemplaza Eyes.Regular si estas en lastlife

-- force reload without a gui
local forceReload = false
local keyDebounce = false

local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

-- Silly SSonic Base Parts (Reused from previous script)

local sonicBaseRoots = {
	"hed", "Cube.001", "Cube.002", "Cube.003", "Cube.004",
	"Ear1", "Ear2", "Sphere.017", "Sphere.030", "eye1", "eye2",
	"eyes", "joy1", "joy2", "muzzl", "normal", "nose", "Body",
	"RIndex1", "RIndex2", "RMiddle1", "RMiddle2", "RPinky1", "RPinky2",
	"RThumb1", "RThumb2", "Right Hand", "LIndex1", "LIndex2",
	"LMiddle1", "LMiddle2", "LPinky1", "LPinky2", "LThumb1", "LThumb2",
	"Left Hand", "LArm1", "LArm2", "LArm3", "LArm4", "LArm5",
	"RArm1", "RArm2", "RArm3", "RArm4", "RArm5", "LFoot",
	"RFoot", "LFoot1", "LFoot2", "LFoot3", "LFoot4", "LFoot5",
	"RLeg1", "RLeg2", "RLeg3", "RLeg4", "RLeg5", "RSleeve",
	"LSleeve", "tail", "belly", "Sphere.003", "Sphere.006",
	"Sphere.007", "Sphere.010", "left backspike", "right backspike",
	-- remodel parts
	"Cube.015", "Cube.016", "burger", 
	"Cube.009", "Cube.014", "exportme", "Cube.011",
	"ears", "ears.001", "ears.002", "ears.003", "replace",
	"aah", "head new", "headnewFocus", "altedxport.005", "altedxport.006", "Cube",
	"muzzle new", "sdgdsagsd", "altedxport.001", "altedxport.003",
	"remodelSphere.010", "Cube.017", "Cube.008",
}

local sonicBasePartNames = {}
for _, partName in ipairs(sonicBaseRoots) do
	sonicBasePartNames[partName] = true
end

-- Cosmetics

local cosmetictoggle = true -- true to protect cosmetics from being hidden (Default: true)

local cosmeticRootNames = {
	Shadow = true,
	SHOVEL = true,
	Bodyy = true,
}

local cosmeticrootnamesHIDE = -- Cosmetics that are forced to hide
{
 superMoist_shoes = true,
    ["head new"] = true,
    headnewFocus = true,
}

local shirtCosmetics = 
{
	HyperCape = true,
	RedCape = true,
	PacedCape = true,
	EnergyCape = true,
	DevilHunter = true,
	PostMortemCape = true,
	superMoist_cape = true,
	BrownScarg = true,
}

local HatsCosmetics =
	{
	Hair = true,
	Hat = true,
	Bowtie = true,
	PaceHat = true,
	StrawCowboy = true,
	AnniFlowers = true,
	AnniversaryCombo = true,
	AnniDoll = true,
	AnniNo1Hat = true,
	AnniHat = true,
	OvaHat = true,
	BrokenCrown = true,
	SANTA_HAT = true,
	TrevorsHat = true,
	Crown = true,
	ScoutHat = true,
	}

local function setProtectedCosmeticVisibility(model)
	if not model then
		return
	end

	local function applyToObject(obj, visible)
		if not obj then
			return
		end

		local objects = { obj }
		for _, child in ipairs(obj:GetDescendants()) do
			table.insert(objects, child)
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

	local protectedNames = {}
	for name in pairs(shirtCosmetics) do
		protectedNames[name] = true
	end
	for name in pairs(HatsCosmetics) do
		protectedNames[name] = true
	end
	for name in pairs(cosmeticRootNames) do
		protectedNames[name] = true
	end
	for name in pairs(cosmeticrootnamesHIDE) do
		protectedNames[name] = true
	end

	for _, object in ipairs(model:GetDescendants()) do
		local name = object.Name
		if protectedNames[name] then
			if object:IsA("Model") or object:IsA("Folder") or object:IsA("BasePart") then
				applyToObject(object, cosmetictoggle)
			end
		end
	end
end

local function updateInsertedShirt(model, insertedModel)
	if not model or not insertedModel then
		return
	end

	local shirtModel = insertedModel:FindFirstChild("poleronmodel", true)
	local baseShirtModel = insertedModel:FindFirstChild("Camisa", true)
		or insertedModel:FindFirstChild("camisa", true)

	local function setShirtVisibility(group, visible)
		if not group then
			return
		end

		local objects = { group }
		for _, object in ipairs(group:GetDescendants()) do
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

	if not cosmetictoggle then
		setShirtVisibility(shirtModel, true)
		setShirtVisibility(baseShirtModel, false)
		return
	end

	local hasShirtCosmetic = false
	for cosmeticName in pairs(shirtCosmetics) do
		if model:FindFirstChild(cosmeticName, true) then
			hasShirtCosmetic = true
			break
		end
	end

	setShirtVisibility(shirtModel, not hasShirtCosmetic)
	setShirtVisibility(baseShirtModel, hasShirtCosmetic)
end

local function updateInsertedHat(model, insertedModel)
	if not model or not insertedModel then
		return
	end

	local function setHatVisibility(name, visible)
		for _, object in ipairs(insertedModel:GetDescendants()) do
			if object:IsA("BasePart") and object.Name == name then
				object.Transparency = visible and 0 or 1
				object.CanCollide = false
			end
		end
	end

	if not cosmetictoggle then
		setHatVisibility("bhat", true)
		setHatVisibility("hat", true)
		return
	end

	local hasHatCosmetic = false
	for cosmeticName in pairs(HatsCosmetics) do
		if model:FindFirstChild(cosmeticName, true) then
			hasHatCosmetic = true
			break
		end
	end

	setHatVisibility("bhat", not hasHatCosmetic)
	setHatVisibility("hat", not hasHatCosmetic)
end

local function belongsToCosmeticRoot(object, model)
	local current = object
	while current and current ~= model do
		if cosmeticRootNames[current.Name] then
			return true
		end
		current = current.Parent
	end
	return false
end

local function belongsToForcedHideCosmetic(object, model)
	local current = object
	while current and current ~= model do
		if cosmeticrootnamesHIDE[current.Name] then
			return true
		end
		current = current.Parent
	end
	return false
end

local function hideModelParts(model, exceptModel)
	if not model then
		return
	end

	for _, object in ipairs(model:GetDescendants()) do
		local isCosmeticPart = belongsToCosmeticRoot(object, model)
		local isForcedHiddenCosmetic = belongsToForcedHideCosmetic(object, model)
		local isBasePart = sonicBasePartNames[object.Name]
		local shouldHide = isForcedHiddenCosmetic
			or (cosmetictoggle and isBasePart and not isCosmeticPart)
			or (not cosmetictoggle and (isBasePart or isCosmeticPart))

		if object:IsA("BasePart")
			and shouldHide
			and (not exceptModel or not object:IsDescendantOf(exceptModel)) then
			object.Transparency = 1
			object.CanCollide = false
		end
	end
end

local function isForcedHiddenHeadPart(name)
	if type(name) ~= "string" then
		return false
	end
	local lowered = string.lower(name)
	return lowered == "head new" or lowered == "headnewfocus"
end

local function forceHideProblemHeadParts(model)
	if not model then
		return
	end

	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("BasePart") and isForcedHiddenHeadPart(object.Name) then
			if object.Transparency < 1 then
				object.Transparency = 1
				object.CanCollide = false
				object:Destroy()
			end
		end
	end
end

local function hideModelGeometry(model)
	if not model then
		return
	end

	if model:IsA("BasePart") then
		model.Transparency = 1
		model.CanCollide = false
	end

	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("BasePart") then
			object.Transparency = 1
			object.CanCollide = false
		end
	end
end

-- Replace the replicatedstorage char (affects viewport, character selection and inventory)

task.spawn(function()
    local storage = game:GetService("ReplicatedStorage")
    local skins = storage
        :WaitForChild("ClientAssets")
        :WaitForChild("Characters")
        :WaitForChild("Survivors")
        :WaitForChild("Sonic")
        :WaitForChild("Skins")

    local originalDefault = skins:WaitForChild("Default")
    local replacement = loadAsset(ASSET_ID)

    if replacement then
        replacement.Name = "Default"
		local replacementRoot = replacement:FindFirstChild("HumanoidRootPart", true)
		if replacementRoot and replacement:IsA("Model") then
			local rootCFrame = replacementRoot.CFrame
			local pivotCFrame = replacement:GetPivot()
			replacement.PrimaryPart = replacementRoot
			replacement:PivotTo(rootCFrame:ToObjectSpace(pivotCFrame))
		end
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

local function getPlayerModel()
	local playersFolder = workspace:FindFirstChild("Players")
	return playersFolder and playersFolder:FindFirstChild(player.Name)
end

-- Head Sync

local synctoggle = true -- False to disable head sync (Default: true)

local originalHeadBase, customMotorBase, originalBody, originalHead, customHead, customHeadMotor

local function findOriginalHead(model)
	if not model then
		return nil
	end

	local head = model:FindFirstChild("Head", true)
	if head and head:IsA("BasePart") then
		return head
	end

	return nil
end

local function findCustomHead(model)
	if not model then
		return nil
	end

	for _, child in ipairs(model:GetChildren()) do
		if child.Name == "Head" and child:IsA("BasePart") then
			return child
		end
	end

	return nil
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

local function findHeadMotor(model, head)
	if not model or not head then
		return nil
	end

	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("Motor6D") and object.Part1 == head then
			return object
		end
	end

	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("Motor6D") and object.Part0 == head then
			return object
		end
	end

	return nil
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

local function isSonic()
	local model = getPlayerModel()
	return model and model:GetAttribute("Character") == "Sonic"
end

local function applyLoadedModelRules(sourceModel, model)
	if not model then
		return
	end

	if sourceModel then
		hideModelParts(sourceModel, model)
		updateInsertedHat(sourceModel, model)
		updateInsertedShirt(sourceModel, model)
	end

	forceHideProblemHeadParts(model)

	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("BasePart") and cosmeticrootnamesHIDE[object.Name] then
			object.Transparency = 1
			object.CanCollide = false
		end
	end
end

local function loadModelSelection(sourceModel)
	local storage = game:GetService("ReplicatedStorage")
	local path = storage:FindFirstChild("ClientAssets")
		and storage.ClientAssets:FindFirstChild("Characters")
		and storage.ClientAssets.Characters:FindFirstChild("Survivors")
		and storage.ClientAssets.Characters.Survivors:FindFirstChild("Sonic")
		and storage.ClientAssets.Characters.Survivors.Sonic:FindFirstChild("Skins")
		and storage.ClientAssets.Characters.Survivors.Sonic.Skins:FindFirstChild("Default")

	if not path then
		warn("No se encontró la ruta de los modelos de personajes")
		return
	end

	local model = path:Clone()
	applyLoadedModelRules(sourceModel, model)
	return model
end

local function setupCharacter(char, forceReload)
	if not isScriptActive and not forceReload then
			return
	end

	if forceReload then
			isScriptActive = true
		end

	if syncConn then syncConn:Disconnect() syncConn = nil end
	if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end

	local playersFolder = workspace:FindFirstChild("Players")
	local oldVisual = playersFolder and playersFolder:FindFirstChild(player.Name)
	local originalDefault = oldVisual and oldVisual:FindFirstChild("Default")

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") and (not oldVisual or not v:IsDescendantOf(oldVisual)) then
			v.Transparency = 1
			if v.Name == "HumanoidRootPart" then
				v.CanCollide = true
			else
				v.CanCollide = false
			end
		end
	end

	local mdl = loadModelSelection(oldVisual or char) or loadAsset(ASSET_ID)
	if not mdl then return end
	if not mdl.Parent then
		applyLoadedModelRules(oldVisual or char, mdl)
	end

	if oldVisual then
		mdl.Parent = oldVisual
	else
		mdl.Parent = char
	end

	if oldVisual then
		if originalDefault and originalDefault ~= mdl then
			hideModelGeometry(originalDefault)
		end
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
			v.CanCollide = false
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
	setupHeadSync(oldVisual or char, mdl, hrp)

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

	task.spawn(function()
		while char and char.Parent and isScriptActive do
			local sourceForLoop = oldVisual or char
			setProtectedCosmeticVisibility(sourceForLoop)
			setProtectedCosmeticVisibility(mdl)
			updateInsertedHat(sourceForLoop, mdl)
			updateInsertedShirt(sourceForLoop, mdl)
			forceHideProblemHeadParts(mdl)
			forceHideProblemHeadParts(sourceForLoop)
			if oldVisual and oldVisual.Parent then
				local defaultFolder = oldVisual:FindFirstChild("Default")
				if defaultFolder then
					local waist = defaultFolder:FindFirstChild("Waist")
					local hrpDef = defaultFolder:FindFirstChild("HumanoidRootPart")
					if waist and waist:IsA("BasePart") then waist.Transparency = 1 end
					if hrpDef and hrpDef:IsA("BasePart") then hrpDef.Transparency = 1 end
				end
			end
			task.wait(0.3)
		end
	end)
end

local ApplyIcon

local function startScript()
	if isScriptActive then return end
	task.wait(3)
	isScriptActive = true
	if character then setupCharacter(character) end

	task.spawn(function()
		while isScriptActive and isSonic() do
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
		task.wait(1)
		setupCharacter(newChar)
	end
end)

local isCurrentlySonic = false
RunService.Heartbeat:Connect(function()
	local check = isSonic()
	if check ~= isCurrentlySonic then
		isCurrentlySonic = check
		if isCurrentlySonic then startScript() else stopScript() end
	end
end)

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

local function setFolderState(folder, activeName, imageId, fitToFrame, imageColor, layout, zIndex, position)
	if not folder then
		return
	end

	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("ImageLabel") or child:IsA("ImageButton") then
			local isActive = child.Name == activeName
			child.Visible = isActive
			if isActive then
				if zIndex then
					child.ZIndex = zIndex
				end
			end
			if isActive and imageId then
				child.Image = imageId
				if imageColor then
					child.ImageColor3 = imageColor
				end
				if layout and layout.position then
					child.Position = layout.position
				end
				if fitToFrame and folder:IsA("GuiObject") then
					child.AnchorPoint = Vector2.new(0.5, 0.5)
					child.Size = layout and layout.size or UDim2.fromScale(0.46, 0.44)
					child.ScaleType = Enum.ScaleType.Fit
				end
			end
		end
	end
end

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
		local isDowned = getBooleanState(model, { "Downed", "IsDowned", "BeingDowned" })
		or getBooleanState(player, { "Downed", "IsDowned", "BeingDowned" })
	local isLastLife = getBooleanState(model, { "LastLife", "IsLastLife", "SecondLife" })
		or getBooleanState(player, { "LastLife", "IsLastLife", "SecondLife" })
	local isChased = getBooleanState(model, { "Chased", "IsChased", "InChase", "BeingChased" })
		or getBooleanState(player, { "Chased", "IsChased", "InChase", "BeingChased" })

	local eyesState = "Regular"
	local expressionState = "Regular"
	local eyesImage = ExpressionNormal
	local expressionImage = IconNormal

	if isDowned then
		expressionState = "Downed"
		eyesState = "Stunned"
		expressionImage = DownedIcon
	elseif isLastLife then
		expressionState = "LastLife"
		eyesImage = ExpressionLastLife
		expressionImage = IconLastLife
	elseif isChased then
		eyesState = "Chased"
		eyesImage = ExpressionChased
	end

	setFolderState(
		characterGui:FindFirstChild("Eyes"),
		eyesState,
		eyesImage,
		false,
		Color3.new(0, 0, 0),
		{
			position = UDim2.fromScale(0.171, 0.126643255),
		},
		10
	)
	setFolderState(
		characterGui:FindFirstChild("Expression"),
		expressionState,
		expressionImage,
		true,
		nil,
		{
			position = UDim2.fromScale(0.168, 0.126643255),
			size = UDim2.fromScale(0.57, 0.55),
		},
		5
	)
end

if isSonic() then
	isCurrentlySonic = true
	startScript()
end

-- Keybind para forcereload de debug

local function triggerForceReload()
	if not isCurrentlySonic then
		game.StarterGui:SetCore("SendNotification", {
        Title = "BF Over Sonic", 
        Text = "Force Reload doesn't work if you are not playing as sonic.", 
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

    if input.KeyCode ~= Enum.KeyCode.R then
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

loadstring(game:HttpGet("https://raw.githubusercontent.com/MisterSaiyan/cosas/refs/heads/main/scripts/FNFSkins/V2/bflms.lua"))()

-- Configuracion BFV2

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ConfiguracionesBF"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local success = pcall(function()
    screenGui.Parent = CoreGui
end)
if not success then
    screenGui.Parent = player:WaitForChild("PlayerGui")
end

local gui = Instance.new("Frame")
gui.Name = "ContenedorHorizontal"
gui.Size = UDim2.new(0, 0, 0, 42)
gui.AutomaticSize = Enum.AutomaticSize.X 
gui.Position = UDim2.new(0, 300, 0, 12) 
gui.BackgroundTransparency = 1
gui.Parent = screenGui

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = gui
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.Padding = UDim.new(0, 12)
listLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local function crearBotonVisual(texto, orden)
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

local btnBFV2 = crearBotonVisual("BFv2", 1)
btnBFV2.Parent = gui

local bfConfigOpen = false

local existingBFPanel = rawget(_G, "BFV2ConfigPanel")
local bfConfigPanel = existingBFPanel or (function()
    local panel = Instance.new("Frame")
    panel.Name = "BFV2ConfigPanel"
    panel.Size = UDim2.new(0, 220, 0, 190)
    panel.Position = UDim2.new(0, 300, 0, 60)
    panel.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = screenGui

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 14)
    panelCorner.Parent = panel

    local panelStroke = Instance.new("UIStroke")
    panelStroke.Color = Color3.fromRGB(255, 255, 255)
    panelStroke.Thickness = 1
    panelStroke.Transparency = 1
    panelStroke.LineJoinMode = Enum.LineJoinMode.Miter
    panelStroke.Parent = panel

    return panel
end)()

_G.BFV2ConfigPanel = bfConfigPanel

local bfConfigLayout = Instance.new("UIListLayout")
bfConfigLayout.Parent = bfConfigPanel
bfConfigLayout.Padding = UDim.new(0, 8)
bfConfigLayout.FillDirection = Enum.FillDirection.Vertical
bfConfigLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
bfConfigLayout.SortOrder = Enum.SortOrder.LayoutOrder

local bfPadding = Instance.new("UIPadding")
bfPadding.Parent = bfConfigPanel
bfPadding.PaddingLeft = UDim.new(0, 10)
bfPadding.PaddingRight = UDim.new(0, 10)
bfPadding.PaddingTop = UDim.new(0, 10)
bfPadding.PaddingBottom = UDim.new(0, 10)

local function createToggleRow(parent, labelText, valueRef, onToggle)
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

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = Color3.fromRGB(0, 0, 0)
    toggleStroke.Thickness = 1
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

local function toggleCosmeticState()
    cosmetictoggle = not cosmetictoggle
    if player.Character and player.Character.Parent then
        setupCharacter(player.Character, true)
    end
end

local function toggleSyncState()
    synctoggle = not synctoggle
end

local function makeConfigButton(label, callback)
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
    button.Parent = bfConfigPanel

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

createToggleRow(bfConfigPanel, "Cosmetic Comp.", function() return cosmetictoggle end, toggleCosmeticState)
createToggleRow(bfConfigPanel, "Head Sync", function() return synctoggle end, toggleSyncState)

local forceReloadButton = makeConfigButton("Force Reload", function()
    triggerForceReload()
end)

local function setBFConfigVisible(visible)
    bfConfigOpen = visible
    bfConfigPanel.Visible = visible
    btnBFV2.Text = visible and "Close" or "BFv2"
end

btnBFV2.MouseButton1Click:Connect(function()
    setBFConfigVisible(not bfConfigOpen)
end)

setBFConfigVisible(false)
