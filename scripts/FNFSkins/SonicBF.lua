local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local ASSET_ID = 123956260066489
local isScriptActive = false
local currentMdl = nil
local syncConn = nil

local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

local function getPlayerModel()
	local playersFolder = workspace:FindFirstChild("Players")
	return playersFolder and playersFolder:FindFirstChild(player.Name)
end

local synctoggle = true
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

local function setupViewport()
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
		local function replaceViewportModel()
			local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. 123956260066489)
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

		replaceViewportModel()

		viewportModel.DescendantAdded:Connect(function()
			task.wait(0.1)
			if not vpOverrideModel or not vpOverrideModel.Parent then
				vpOverrideModel = nil
				replaceViewportModel()
			end
		end)
	end)
end

local function setupCharacter(char)
	if not isScriptActive then return end
	if syncConn then syncConn:Disconnect() syncConn = nil end
	if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
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
			if v:IsA("BasePart") then v.Transparency = 1 end
		end
	end

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

local function startScript()
	if isScriptActive then return end
	task.wait(3)
	isScriptActive = true
	setupViewport()
	if character then setupCharacter(character) end
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
		setupViewport()
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

if isSonic() then
	isCurrentlySonic = true
	startScript()
end

local function loadCustomAsset(url, filename)
	if not isfile(filename) then
		writefile(filename, game:HttpGet(url))
	end
	return getcustomasset(filename)
end

local CUSTOM_MUSIC = loadCustomAsset(
	"https://github.com/monicagalindo-wq/RECUP/raw/refs/heads/main/Break%20Free.mp3",
	"breakfree.mp3"
)

task.spawn(function()
	local theme = game:GetService("ReplicatedStorage")
		:FindFirstChild("ClientAssets")
		and game.ReplicatedStorage.ClientAssets:FindFirstChild("Sounds")
		and game.ReplicatedStorage.ClientAssets.Sounds:FindFirstChild("mus")
		and game.ReplicatedStorage.ClientAssets.Sounds.mus:FindFirstChild("Game")
		and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game:FindFirstChild("Round")
		and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game.Round:FindFirstChild("SoloTheme")
		and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game.Round.SoloTheme:FindFirstChild("SonicSolo")
	if not theme then return end
	theme.SoundId = CUSTOM_MUSIC
	theme.Volume = 1.5
	theme.Looped = false
end)
