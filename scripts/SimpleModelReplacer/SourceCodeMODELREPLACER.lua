-- Saiyan's Outcome Memories Model Replacer
-- MAKE SURE THE MODEL RIG IS IDENTICAL OR IT WILL PUT YOU ON THE REST POSE

-- My version of the model replacer thing that has the used methods
-- that are in the silly super sonic skin

-- Features:
-- Experimental Head Sync using c0/c1 to sync custom model with the default model
-- Fully customizable functions for your own model ids and which character to target
-- Custom Model viewable in viewport

-- I DO NOT OWN OR TAKE CREDITS FOR THE CODE OR METHODS, I SIMPLY MADE THIS TEMPLATE 
-- FOR FUN, IF YOU WANNA IMPROVE OR ADD SOMETHING, FEEL FREE TO DO SO

-- CONTACT ME VIA MY DISCORD IF YOU HAVE AN INQUIRE OR WANNA BE CREDITED IN ANYTHING

-- ==========================================
-- LOCALS & SERVICES
-- ==========================================

-- We start with getting the services we need
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- We define the bases for synching the heads
local originalHeadBase
local customMotorBase
local originalBody
local originalHead
local customHead
local customHeadMotor

local synctoggle = true -- Set to false if you want to disable the head sync

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local MODEL_ID = 76242789522318 -- The model you wish to use
local KILLER_ID = nil -- Killer model
local isScriptActive = false -- Set to true if you want to enable the whole script
local currentMdl = nil -- used to manage current mdl from MODEL_ID
local currentKillerMdl = nil -- used to manage current killer mdl from KILLER_ID
local syncConn = nil -- For Head Syncing
local killerSyncConn = nil -- For Killer Head Syncing

local forceReload = false

-- ==========================================
-- FUNCTIONS
-- ==========================================

-- Loads the asset from the giving ID
local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

-- Lets get the player model too
local function getPlayerModel()
    local playersFolder = workspace:FindFirstChild("Players")
    return playersFolder and playersFolder:FindFirstChild(player.Name)
end

-- Selected character from the dropdown (default: Sonic)
local selectedCharacter = "Sonic"

-- (WIP) Killer Selection
local selectedKiller = "2011x"

-- Checks if the player model is the one we want to replace
local function isCharacter()
	local model = getPlayerModel()
	return model and model:GetAttribute("Character") == selectedCharacter -- Char list: "Sonic", "Tails", "Knuckles", "Amy", "Cream","Silver", "MetalSonic", "Blaze", "Shadow", "Eggman"
end

-- Replaces the model, but highely depends on the rig of the model
local function IsKiller()
	local model = getPlayerModel()
	return model and model:GetAttribute("Character") == selectedKiller -- Char List: "2011x", "Kolossos", "Tripware", "Fleetway"
end

-- Sets up the viewport model to show the custom model in the UI
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
			local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. MODEL_ID)
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

-- ==========================================
-- Head Sync (EXPERIMENTAL AND CAN BREAK EASILY)
-- ==========================================

-- We need to target the original head so it works
local function findOriginalHead(model)
    -- If no model, shuts the rest of the function down and returns nil
	if not model then
		return nil
	end

	local head = model:FindFirstChild("Head", true) -- Tries to locate the head (should be motor6d for the best)

    -- If it finds the head and it's a BasePart, it returns it. Otherwise, it returns nil.
	if head and head:IsA("BasePart") then
		return head
	end

	return nil
end

-- The same function, but adapted to find it on your custom model
local function findCustomHead(model)
if not model then return nil end

	-- GetChildren() Doesn't go through the descendants, so we can ignore any models or folders named "Head"
    -- and should focus in the root (thats where the motor6d is usually located in om)
	for _, child in ipairs(model:GetChildren()) do
		
		-- We check the child and if its a basepart
		if child.Name == "Head" and child:IsA("BasePart") then
			-- If child is a basepart, we return it
			return child
		end
		
	end

	return nil
end

-- Time to find the body, which is used to measure the head rotation
local function findBody(model)
	if not model then
		return nil
	end

    -- Grouping the parts that must be usedas the body, in case the model uses a different naming convention
	local body =
		model:FindFirstChild("Body", true)
		or model:FindFirstChild("Torso", true)
		or model:FindFirstChild("UpperTorso", true)
		or model:FindFirstChild("HumanoidRootPart", true)

        -- Returns if its a basepart, otherwise returns nil
	if body and body:IsA("BasePart") then
		return body
	end

	return nil
end

-- Time to find the motor that connects the thing
local function findHeadMotor(model, head)
	if not model or not head then
		return nil
	end

	-- First check if the head has a motor6d as a child, which is the most common case.
	-- This should be the most common case
	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("Motor6D")
			and object.Part1 == head then

			return object
		end
	end

	-- If its a motor 6d that connects the head to the body, we can also check if the head is Part0, which is less common but still possible 
	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("Motor6D")
			and object.Part0 == head then

			return object
		end
	end

	return nil
end
-- Main Function to setup the whole syncing process, it will find the original head, body, custom head and motor6d and store them in the local variables
local function setupHeadSync(originalModel, customModel, fallbackRoot)
	if not originalModel or not customModel then
		warn(
			"[HeadSync] Faltan modelos",
			"OriginalModel:", originalModel,
			"CustomModel:", customModel
		)
		return
	end

	-- La head que reacciona y se mueve con la cámara.
	originalHead = findOriginalHead(originalModel)

	-- Referencia del cuerpo.
	originalBody = findBody(originalModel) or fallbackRoot

	-- Head invisible/armature del modelo custom.
	customHead = findCustomHead(customModel)

	-- Articulación que permite mover solo la cabeza custom.
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

	-- Pose inicial del Head original respecto al cuerpo original.
	originalHeadBase =
		originalBody.CFrame:ToObjectSpace(originalHead.CFrame)

	-- Transform inicial del Motor6D custom.
	customMotorBase =
		customHeadMotor.C0

	print(
		"[HeadSync]",
		originalHead:GetFullName(),
		"->",
		customHeadMotor:GetFullName(),
		"Part0:",
		customHeadMotor.Part0 and customHeadMotor.Part0.Name,
		"Part1:",
		customHeadMotor.Part1 and customHeadMotor.Part1.Name
	)
end

-- ==========================================
-- Character
-- ==========================================

local function setupCharacter(char, forceReload)
	if not isCharacter() and not forceReload then
		return
	end

	if not isScriptActive and not forceReload then
		return
	end

	if forceReload then
		isScriptActive = true
	end

	task.wait(0.05)

	-- Detener sincronizaciones anteriores antes de reemplazar el modelo.
	if syncConn then
		syncConn:Disconnect()
		syncConn = nil
	end

    -- We begin checking the current model and their childrens, if a model is found, it's destroyed
	if currentMdl and currentMdl.Parent then
		currentMdl:Destroy()
		currentMdl = nil
	end

	    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("BasePart") then
            v.Transparency = 1
            if v.Name == "HumanoidRootPart" then
                v.CanCollide = true
            else
                v.CanCollide = false
            end
        elseif v:IsA("Model") then
            for _, part in ipairs(v:GetDescendants()) do
                if part:IsA("BasePart") then part.Transparency = 1 end
            end
        end
    end

	local oldVisual = getPlayerModel()
	    if oldVisual then
        for _, v in ipairs(oldVisual:GetDescendants()) do
            if v:IsA("BasePart") then v.Transparency = 1 end
        end
    end

	-- Elegir modelo desde el id
	local ID_A_CARGAR = MODEL_ID

	local mdl = loadAsset(ID_A_CARGAR)

	if not mdl then
		warn("[Model] No se pudo cargar el asset:", ID_A_CARGAR)
		return
	end

	if oldVisual then
		mdl.Parent = oldVisual
	else
		mdl.Parent = char
	end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local newHrp =
		mdl:FindFirstChild("HumanoidRootPart", true)

	if not hrp or not newHrp then
		warn(
			"[Model] Falta HumanoidRootPart",
			"Original:", hrp,
			"Custom:", newHrp
		)

		mdl:Destroy()
		return
	end

	newHrp.Anchored = false
	newHrp.Transparency = 1

    newHrp.CFrame = hrp.CFrame

    local physicalWeld = Instance.new("WeldConstraint")
	physicalWeld.Name = "SkinPhysicalAnchor"
	physicalWeld.Part0 = hrp
	physicalWeld.Part1 = newHrp
	physicalWeld.Parent = newHrp

	-- El modelo custom no necesita su propio Humanoid/Animator.
	local mdlHum = mdl:FindFirstChildOfClass("Humanoid")

	if mdlHum then
		mdlHum:Destroy()
	end

	local mdlAnim = mdl:FindFirstChildOfClass("Animator")

	if mdlAnim then
		mdlAnim:Destroy()
	end

    task.wait(0.05)

	-- Preparación de las piezas custom.
	for _, object in ipairs(mdl:GetDescendants()) do
		if object:IsA("BasePart") then
			object.CanCollide = false

			object.Massless = true
			object.Anchored = false

			if object.Name == "HumanoidRootPart"
				or object.Name == "Waist" 
				or object.Name == "Weld" then

				object.Transparency = 1
			end

		elseif object:IsA("Trail")
			or object:IsA("Beam") then
		end
	end

	-- Colocar el modelo custom sobre el personaje.
	newHrp.CFrame = hrp.CFrame
	currentMdl = mdl

	setupHeadSync(oldVisual, mdl, hrp)

	-- hola lerp
	local lerpVelocity = 0.35

	-- Head Sync Stuff
syncConn = RunService.RenderStepped:Connect(function() 
		-- Attempt logic so it doesn't drop nil
		if not char or not char.Parent or not hrp or not hrp.Parent or not newHrp or not newHrp.Parent or not isScriptActive then
			if syncConn then
				syncConn:Disconnect()
				syncConn = nil
			end
			return
		end

		-- All the necessary parts must be valid and present in the hierarchy
		if not (originalHead and originalHead.Parent and originalBody and originalBody.Parent and customHeadMotor and customHeadMotor.Parent) then
			return
		end

		-- Same check for the motor6d parts, ensuring they are connected to valid parts
		if not (customHeadMotor.Part0 and customHeadMotor.Part1 and customHeadMotor.Part0.Parent and customHeadMotor.Part1.Parent) then
			warn("[HeadSync] Motor6D corrupted or disconnected")
			return
		end

		-- Main logic for syncing the head rotation
		if synctoggle and originalHeadBase and customMotorBase then
			local success, result = pcall(function()
				local currentOriginalHead = originalBody.CFrame:ToObjectSpace(originalHead.CFrame)
				local rotationDelta = originalHeadBase.Rotation:Inverse() * currentOriginalHead.Rotation

				local targetC0 = customMotorBase
				if customHeadMotor.Part1 == customHead then
					targetC0 = customMotorBase * rotationDelta
				elseif customHeadMotor.Part0 == customHead then
					targetC0 = customMotorBase * rotationDelta:Inverse()
				end

				customHeadMotor.C0 = customHeadMotor.C0:Lerp(targetC0, lerpVelocity)
			end)
			-- No success equals printing the error to warn, so we can see what went wrong
			if not success then
				warn("[HeadSync] Error during rotation calculation:", result)
			end
			
		-- Do not do stuff if toggle is off, but still ensure the C0 is set to the base value to avoid drift
		elseif not synctoggle and customMotorBase and customHeadMotor.Parent then
			customHeadMotor.C0 = customMotorBase
		end
	end)

	-- Mantener ocultos Waist y HumanoidRootPart originales.
	task.spawn(function()
		while char
			and char.Parent
			and isScriptActive do

			if oldVisual and oldVisual.Parent then
				local defaultFolder =
					oldVisual:FindFirstChild("Default")

				if defaultFolder then
					local waist =
						defaultFolder:FindFirstChild("Waist")

					local hrpDef =
						defaultFolder:FindFirstChild(
							"HumanoidRootPart"
						)

					if waist and waist:IsA("BasePart") then
						waist.Transparency = 1
					end

					if hrpDef and hrpDef:IsA("BasePart") then
						hrpDef.Transparency = 1
					end
				end
			end

			task.wait(0.1)
		end
	end)

end

local function setupKiller(char, forceReload)
	if not IsKiller() and not forceReload then
		return
	end

	if not isScriptActive and not forceReload then
		return
	end

	if forceReload then
		isScriptActive = true
	end

	task.wait(0.05)

	if killerSyncConn then
		killerSyncConn:Disconnect()
		killerSyncConn = nil
	end

	if currentKillerMdl and currentKillerMdl.Parent then
		currentKillerMdl:Destroy()
		currentKillerMdl = nil
	end

	for _, v in ipairs(char:GetChildren()) do
		if v:IsA("BasePart") then
			v.Transparency = 1
			if v.Name == "HumanoidRootPart" then
				v.CanCollide = true
			else
				v.CanCollide = false
			end
		elseif v:IsA("Model") then
			for _, part in ipairs(v:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end
		end
	end

	local oldVisual = getPlayerModel()
	if oldVisual then
		for _, v in ipairs(oldVisual:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Transparency = 1
			end
		end
	end

	local ID_A_CARGAR = KILLER_ID

	if not ID_A_CARGAR then
		warn("[Killer] Falta KILLER_ID")
		return
	end

	local mdl = loadAsset(ID_A_CARGAR)

	if not mdl then
		warn("[Killer] No se pudo cargar el asset:", ID_A_CARGAR)
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
		warn(
			"[Killer] Falta HumanoidRootPart",
			"Original:", hrp,
			"Custom:", newHrp
		)

		mdl:Destroy()
		return
	end

	newHrp.Anchored = false
	newHrp.Transparency = 1

	newHrp.CFrame = hrp.CFrame

	local physicalWeld = Instance.new("WeldConstraint")
	physicalWeld.Name = "SkinPhysicalAnchor"
	physicalWeld.Part0 = hrp
	physicalWeld.Part1 = newHrp
	physicalWeld.Parent = newHrp

	local mdlHum = mdl:FindFirstChildOfClass("Humanoid")

	if mdlHum then
		mdlHum:Destroy()
	end

	local mdlAnim = mdl:FindFirstChildOfClass("Animator")

	if mdlAnim then
		mdlAnim:Destroy()
	end

	task.wait(0.05)

	for _, object in ipairs(mdl:GetDescendants()) do
		if object:IsA("BasePart") then
			object.CanCollide = false
			object.Massless = true
			object.Anchored = false

			if object.Name == "HumanoidRootPart"
				or object.Name == "Waist"
				or object.Name == "Weld" then

				object.Transparency = 1
			end

		elseif object:IsA("Trail")
			or object:IsA("Beam") then
		end
	end

	newHrp.CFrame = hrp.CFrame
	currentKillerMdl = mdl

	setupHeadSync(oldVisual, mdl, hrp)

	local lerpVelocity = 0.35

	killerSyncConn = RunService.RenderStepped:Connect(function()
		if not char or not char.Parent or not hrp or not hrp.Parent or not newHrp or not newHrp.Parent or not isScriptActive then
			if killerSyncConn then
				killerSyncConn:Disconnect()
				killerSyncConn = nil
			end
			return
		end

		if not (originalHead and originalHead.Parent and originalBody and originalBody.Parent and customHeadMotor and customHeadMotor.Parent) then
			return
		end

		if not (customHeadMotor.Part0 and customHeadMotor.Part1 and customHeadMotor.Part0.Parent and customHeadMotor.Part1.Parent) then
			warn("[HeadSync] Motor6D corrupted or disconnected")
			return
		end

		if synctoggle and originalHeadBase and customMotorBase then
			local success, result = pcall(function()
				local currentOriginalHead = originalBody.CFrame:ToObjectSpace(originalHead.CFrame)
				local rotationDelta = originalHeadBase.Rotation:Inverse() * currentOriginalHead.Rotation

				local targetC0 = customMotorBase
				if customHeadMotor.Part1 == customHead then
					targetC0 = customMotorBase * rotationDelta
				elseif customHeadMotor.Part0 == customHead then
					targetC0 = customMotorBase * rotationDelta:Inverse()
				end

				customHeadMotor.C0 = customHeadMotor.C0:Lerp(targetC0, lerpVelocity)
			end)
			if not success then
				warn("[HeadSync] Error during rotation calculation:", result)
			end
		elseif not synctoggle and customMotorBase and customHeadMotor.Parent then
			customHeadMotor.C0 = customMotorBase
		end
	end)

	task.spawn(function()
		while char
			and char.Parent
			and isScriptActive do

			if oldVisual and oldVisual.Parent then
				local defaultFolder =
					oldVisual:FindFirstChild("Default")

				if defaultFolder then
					local waist =
						defaultFolder:FindFirstChild("Waist")

					local hrpDef =
						defaultFolder:FindFirstChild(
							"HumanoidRootPart"
						)

					if waist and waist:IsA("BasePart") then
						waist.Transparency = 1
					end

					if hrpDef and hrpDef:IsA("BasePart") then
						hrpDef.Transparency = 1
					end
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
	if character then
		if IsKiller() then
			setupKiller(character)
		elseif isCharacter() then
			setupCharacter(character)
		end
	end
end

local function stopScript()
	if not isScriptActive then return end
	isScriptActive = false
	if syncConn then syncConn:Disconnect() syncConn = nil end
	if killerSyncConn then killerSyncConn:Disconnect() killerSyncConn = nil end
	if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end
	if currentKillerMdl and currentKillerMdl.Parent then currentKillerMdl:Destroy() currentKillerMdl = nil end
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
		if IsKiller() then
			setupKiller(newChar)
		elseif isCharacter() then
			setupCharacter(newChar)
		end
		setupViewport()
	end
end)

local isCurrentlyTargetCharacter = false
local isCurrentlyTargetKiller = false
RunService.Heartbeat:Connect(function()
	local checkCharacter = isCharacter()
	local checkKiller = IsKiller()
	if checkCharacter ~= isCurrentlyTargetCharacter or checkKiller ~= isCurrentlyTargetKiller then
		isCurrentlyTargetCharacter = checkCharacter
		isCurrentlyTargetKiller = checkKiller
		if isCurrentlyTargetCharacter or isCurrentlyTargetKiller then
			startScript()
		else
			stopScript()
		end
	end
end)

if isCharacter() or IsKiller() then
	isCurrentlyTargetCharacter = isCharacter()
	isCurrentlyTargetKiller = IsKiller()
	startScript()
end

-- ==========================================
-- Rayfield
-- ==========================================

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local window = Rayfield:CreateWindow({
    name = "Saiyan's OM Model Replacer",
    subtitle = "Rayfield Gen2",
	showName = "Simple OM Replacer",
})

local tab = window:CreateTab({ name = "Home", icon = 93364949241311 })

tab:CreateInput({
    name = "ModelID",
    numeric = true,
    value = "",
    placeholder = "Enter a valid assetid",
    callback = function(text)
	local id = tonumber(text)

        if id then
            MODEL_ID = id
		end
    end,
})

tab:CreateInput({
    name = "Kiler AssetID",
    numeric = true,
    value = "",
    placeholder = "Enter a valid assetid",
    callback = function(text)
	local idk = tonumber(text)

        if idk then
            KILLER_ID = idk
		end
    end,
})

tab:CreateDropdown({
    name = "Survivor",
    multiSelect = false,
    options = { "Sonic", "Tails", "Knuckles", "MetalSonic", "Amy", "Eggman", "Cream", "Silver", "Blaze", "Shadow" },
    value = { "Sonic" },
    callback = function(selected)
        local characterChoice = selected
        if type(selected) == "table" then
            characterChoice = selected[1]
        end
        selectedCharacter = characterChoice
    end,
})

tab:CreateDropdown({
    name = "Killer",
    multiSelect = false,
    options = { "2011x", "Kolossos", "Tripware", "Fleetway"},
    value = { "2011x" },
    callback = function(selected)
        local characterChoiceK = selected
        if type(selected) == "table" then
            characterChoiceK = selected[1]
        end
        selectedKiller = characterChoiceK
    end,
})

window:Notify({
    title = "DISCLAIMER #1",
    content = "KILLER REPLACER IS A WIP ATM, USE A MODEL EDIT OR MANUALLY EDIT THE RIG",
    duration = 10,
})

window:Notify({
    title = "DISCLAIMER #2",
    content = "DOUBLE CHECK THE CHARACTER AND CUSTOM MODEL RIGS BEFORE APPLYING ANY CUSTOM MODEL",
    duration = 10,
})
