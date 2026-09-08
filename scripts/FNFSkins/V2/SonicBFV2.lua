local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local ASSET_ID = 137895615579863
local isScriptActive = false
local currentMdl = nil
local syncConn = nil

--Iconos FirstLife

local IconNormal = "rbxassetid://114228592450607" -- Expression.Regular
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
	"aah", "head new", "altedxport.005", "altedxport.006", "Cube",
	"muzzle new", "sdgdsagsd", "altedxport.001", "altedxport.003",
	"remodelSphere.010", "Cube.017", "Cube.008",
}

local sonicBasePartNames = {}
for _, partName in ipairs(sonicBaseRoots) do
	sonicBasePartNames[partName] = true
end

-- Cosmetics

local cosmetictoggle = true -- true to protect cosmetics from being hidden (Default: false)

local cosmeticRootNames = {
	Shadow = true,
	SHOVEL = true,
	Bodyy = true,
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

	local shirtModel = insertedModel:FindFirstChild("poleronmodel", true)
	local baseShirtModel = insertedModel:FindFirstChild("Camisa", true)
		or insertedModel:FindFirstChild("camisa", true)

	local function setShirtVisibility(model, visible)
		if not model then
			return
		end

		local objects = { model }
		for _, object in ipairs(model:GetDescendants()) do
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
	setShirtVisibility(baseShirtModel, hasShirtCosmetic)
end

local function updateInsertedHat(model, insertedModel)
	if not model or not insertedModel then
		return
	end

	local hasHatCosmetic = false
	for cosmeticName in pairs(HatsCosmetics) do
		if model:FindFirstChild(cosmeticName, true) then
			hasHatCosmetic = true
			break
		end
	end


	for _, object in ipairs(insertedModel:GetDescendants()) do
		if object:IsA("BasePart") and object.Name == "bhat" then
			object.Transparency = hasHatCosmetic and 1 or 0
			object.CanCollide = false
		end
	end
	for _, object in ipairs(insertedModel:GetDescendants()) do
		if object:IsA("BasePart") and object.Name == "hat" then
			object.Transparency = hasHatCosmetic and 1 or 0
			object.CanCollide = false
		end
	end
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

local function hideModelParts(model, exceptModel)
	if not model then
		return
	end

	for _, object in ipairs(model:GetDescendants()) do
		local isCosmeticPart = belongsToCosmeticRoot(object, model)
		local isBasePart = sonicBasePartNames[object.Name]
		local shouldHide = cosmetictoggle
			and isBasePart
			and not isCosmeticPart
			or not cosmetictoggle
			and (isBasePart or isCosmeticPart)

		if object:IsA("BasePart")
			and shouldHide
			and (not exceptModel or not object:IsDescendantOf(exceptModel)) then
			object.Transparency = 1
			object.CanCollide = false
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

local function loadModelSelection()
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

		return path:Clone()
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

	local mdl = loadModelSelection() or loadAsset(ASSET_ID)
	if not mdl then return end

	if oldVisual then
		mdl.Parent = oldVisual
	else
		mdl.Parent = char
	end

	if oldVisual then
		hideModelParts(oldVisual, mdl)
		if originalDefault and originalDefault ~= mdl then
			hideModelGeometry(originalDefault)
		end
	end
	updateInsertedHat(oldVisual or char, mdl)
	updateInsertedShirt(oldVisual or char, mdl)

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
			updateInsertedHat(oldVisual or char, mdl)
				updateInsertedShirt(oldVisual or char, mdl)
			if oldVisual and oldVisual.Parent then
				local defaultFolder = oldVisual:FindFirstChild("Default")
				if defaultFolder then
					local waist = defaultFolder:FindFirstChild("Waist")
					local hrpDef = defaultFolder:FindFirstChild("HumanoidRootPart")
					if waist and waist:IsA("BasePart") then waist.Transparency = 1 end
					if hrpDef and hrpDef:IsA("BasePart") then hrpDef.Transparency = 1 end
				end
			end
			task.wait(0.1)
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
		if stateObject and stateObject:IsA("BoolValue") and stateObject.Value then
			return true
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
					child.Size = layout and layout.size or UDim2.fromScale(0.47, 0.45)
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
	local isLastLife = getBooleanState(model, { "LastLife", "IsLastLife", "SecondLife" })
	local isDowned = getBooleanState(model, { "Downed", "IsDowned" })
	local isChased = getBooleanState(model, { "Chased", "IsChased", "InChase" })

	local eyesState = isChased and "Chased" or "Regular"
	local expressionState = "Regular"
	local eyesImage = isChased and ExpressionChased or ExpressionNormal
	local expressionImage = IconNormal

	if isLastLife then
		expressionState = "LastLife"
		eyesImage = ExpressionLastLife
	end
	if isDowned then
		expressionState = "Downed"
		eyesState = "Stunned"
		expressionImage = DownedIcon
	elseif isLastLife then
		expressionImage = IconLastLife
	end

	setFolderState(
		characterGui:FindFirstChild("Eyes"),
		eyesState,
		eyesImage,
		false,
		Color3.new(0, 0, 0),
		{
			position = UDim2.fromScale(0.16922964, 0.126643255),
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
			position = UDim2.fromScale(0.16922964, 0.126643255),
			size = UDim2.fromScale(0.47, 0.45),
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
