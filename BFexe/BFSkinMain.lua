local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local AssetId = 97163073527228

local selectPreview    = nil
local selectSyncConn   = nil

local Enabled = true

local SELECT_MODEL_ID = AssetId
local SELECT_ANIM_ID  = ""
local DISPLAY_NAME    = "2022x"
local CHAR_NAME       = "2022x"

local ChaseThemeUrl      = "https://github.com/MisterSaiyan/cosas/raw/refs/heads/main/MJX.mp3"
local LastLifeThemeUrl   = "https://github.com/MisterSaiyan/cosas/raw/refs/heads/main/BFlastlifeFIX.mp3"
local RageThemeUrl        = "https://github.com/MisterSaiyan/cosas/raw/refs/heads/main/xbfrage.mp3"
local ChaseFileName      = "XBFChase.mp3"
local LastLifeFileName   = "XBFLastLife.mp3"
local RageFileName	     = "xbfrage.mp3"
local ModelOffset        = CFrame.new(0, 0, 0)
local State = {
	model                  = nil,
	connections            = {},
	hiddenOriginalModifiers = {},
	rageActive             = false,
}


if isfile(LastLifeFileName) then
	delfile(LastLifeFileName)
	end
	
if isfile(RageFileName) then
	delfile(RageFileName)
end

local function GetAsset(url, filename)
	if not isfile(filename) then
		writefile(filename, game:HttpGet(url))
	end
	return getcustomasset(filename)
end

local function FindChaseSounds()
	local assets = workspace:FindFirstChild("Assets")
	local songs  = assets and assets:FindFirstChild("Songs")
	if songs then
		local normal   = songs:FindFirstChild("NormalChase")
		local lastLife = songs:FindFirstChild("LastLifeChase")
		if normal and lastLife then return normal, lastLife end
	end
	return nil, nil
end

local function IsKolo()
	if not Enabled then return false end
	local playersFolder = workspace:FindFirstChild("Players")
	local charFolder    = playersFolder and playersFolder:FindFirstChild(LocalPlayer.Name)
	if not charFolder then return false end
	return tostring(charFolder:GetAttribute("Character")) == "2011x"
end

local function ClearConnections()
	if not Enabled then return end
	for _, conn in ipairs(State.connections) do
		conn:Disconnect()
	end
	State.connections = {}
end

local function CleanModel(character)
	if not Enabled then return false end
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("LocalScript") then obj:Destroy() end
	end
end

local function SyncOriginalInvisibility(character, model)
	if not Enabled then return false end
	local bfParts = model:FindFirstChild("BFPARTS", true)
	local ForcedInvis = model:FindFirstChild("ForcedInvisibility", true)
	local skinParts = {}
	local trackedSkinParts = {}
	local trackedOriginals = {}
	local visibilitySource

	local function addSkinPart(obj)
		if not obj:IsA("BasePart") or trackedSkinParts[obj] then
			return
		end
		trackedSkinParts[obj] = true
		table.insert(skinParts, obj)

		if visibilitySource then
			local modifier = visibilitySource.Transparency
			if obj.LocalTransparencyModifier ~= modifier then
				obj.LocalTransparencyModifier = modifier
			end
		end
	end

	local function forceInvisible(obj)
		if not Enabled then return false end
		if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture") then
			if obj.Transparency ~= 1 then
				obj.Transparency = 1
			end
			table.insert(State.connections, obj:GetPropertyChangedSignal("Transparency"):Connect(function()
				if obj.Parent and obj.Transparency ~= 1 then
					obj.Transparency = 1
				end
			end))
		end
	end

	local function syncSkinVisibility()
		if not Enabled then return false end
		if not visibilitySource then return end
		local modifier = visibilitySource.Transparency
		for _, part in ipairs(skinParts) do
			if part.Parent and part.LocalTransparencyModifier ~= modifier then
				part.LocalTransparencyModifier = modifier
			end
		end
	end

	local function setVisibilitySource(obj)
		if visibilitySource or obj.Name ~= "Sphere.185" or not obj:IsA("BasePart")
			or obj:IsDescendantOf(model) then
			return
		end

		visibilitySource = obj
		table.insert(State.connections, obj:GetPropertyChangedSignal("Transparency"):Connect(syncSkinVisibility))
		syncSkinVisibility()
	end

	local function trackOriginalPart(obj)
		if not obj:IsA("BasePart") or obj:IsDescendantOf(model) then return end

		setVisibilitySource(obj)
		if not obj:IsA("MeshPart") or trackedOriginals[obj] then return end
		trackedOriginals[obj] = true

		State.hiddenOriginalModifiers[obj] = obj.LocalTransparencyModifier
		obj.LocalTransparencyModifier = 1
	end

	if bfParts then
		for _, obj in ipairs(bfParts:GetDescendants()) do
			addSkinPart(obj)
		end
	else
		warn("Could not sync skin invisibility: BFPARTS was not found in the custom model")
	end

	if ForcedInvis then
		forceInvisible(ForcedInvis)
		for _, obj in ipairs(ForcedInvis:GetDescendants()) do
			forceInvisible(obj)
		end
		table.insert(State.connections, ForcedInvis.DescendantAdded:Connect(forceInvisible))
	else
		warn("Could not force invisibility: ForcedInvisibility was not found in the custom model")
	end
	for _, obj in ipairs(character:GetDescendants()) do
		trackOriginalPart(obj)
	end

	table.insert(State.connections, model.DescendantAdded:Connect(function(obj)
		if bfParts and obj:IsDescendantOf(bfParts) then
			addSkinPart(obj)
		end
	end))
	table.insert(State.connections, character.DescendantAdded:Connect(trackOriginalPart))
end

-- ==========================================
-- FUNCIONES DE LIMPIEZA OPTIMIZADAS
-- ==========================================

local function destroySelectPreview()
	if selectSyncConn then 
		selectSyncConn:Disconnect() 
		selectSyncConn = nil 
	end
	if selectPreview and selectPreview.Parent then 
		selectPreview:Destroy() 
	end
	selectPreview = nil
end

local function CleanupVictoryScreen()
	local resScreen = workspace:FindFirstChild("RES_Screen")
	if not resScreen then return end
	for _, child in ipairs(resScreen:GetChildren()) do
		if child:IsA("Model") and child.Name == "" then
			for _, p in ipairs(child:GetDescendants()) do
				if p:IsA("BasePart") and p.Transparency == 1 then
					p.Transparency = 0
				end
			end
		end
	end
end

local function CleanupCharacter(character)
	if not character then return end
	local kolo = character:FindFirstChild("Kolo")
	if kolo then kolo:Destroy() end
end


local function CleanupAll()
	CleanupVictoryScreen()
	destroySelectPreview()
	if LocalPlayer.Character then
		CleanupCharacter(LocalPlayer.Character)
	end
	ClearConnections()
	
	-- Restaurar transparencias originales guardadas
	for part, transparencyModifier in pairs(State.hiddenOriginalModifiers) do
		if part.Parent then
			part.LocalTransparencyModifier = transparencyModifier
		end
	end
	State.hiddenOriginalModifiers = {}
	if State.model then
		State.model:Destroy()
		State.model = nil
	end
end

local function ResetState()
	ClearConnections()
	for part, transparencyModifier in pairs(State.hiddenOriginalModifiers) do
		if part.Parent then
			part.LocalTransparencyModifier = transparencyModifier
		end
	end
	State.hiddenOriginalModifiers = {}
	if State.model then
		State.model:Destroy()
		State.model = nil
	end
end

-- ==========================================
-- SETUP DE KOLO Y CARACTERES
-- ==========================================

local function setupKolo(character)
	if not IsKolo() or not character or character:FindFirstChild("Kolo") then return end

	local hrp = character:WaitForChild("HumanoidRootPart", 5)
	if not hrp then return end

	task.spawn(function()
		local success, objects = pcall(game.GetObjects, game, "rbxassetid://" .. AssetId)
		if not success or #objects == 0 then return end
		if LocalPlayer.Character ~= character or character:FindFirstChild("Kolo") then return end

		local model   = objects[1]:Clone()
		model.Name    = "Kolo"

		local primary = model:FindFirstChild("HumanoidRootPart")
			or model:FindFirstChild("Torso")
			or model:FindFirstChildWhichIsA("BasePart")
		if not primary then model:Destroy() return end

		model.PrimaryPart = primary
		CleanModel(model)

		local hum = model:FindFirstChildOfClass("Humanoid")
		if hum then hum:Destroy() end

		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored    = false
				part.CanCollide  = false
				part.Massless    = true
			end
		end

		model.Parent = character
		State.model  = model
		SyncOriginalInvisibility(character, model)

		if model:FindFirstChild("HumanoidRootPart") then
			model.HumanoidRootPart.Transparency = 1
		end

		local weld      = Instance.new("Motor6D")
		weld.Name       = "RootJoint"
		weld.Part0      = hrp
		weld.Part1      = primary
		weld.C0         = ModelOffset
		weld.Parent     = hrp
	end)
end

local function OnCharacterAdded(character)
	CleanupAll() -- Limpia antes de asignar la skin de nuevo para evitar conflictos
	ResetState() -- Reinici el estado antes de configurarlo

	-- Esperar brevemente (hasta 2 segundos) por si el juego asigna el atributo con retraso al respawnear
	local startTime = tick()
	while not IsKolo() and (tick() - startTime < 2) do
		task.wait(0.1)
	end

	if not IsKolo() then return end -- Si tras 2 segundos no es 2011x, se detiene con seguridad
	setupKolo(character)

	local playerFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild(LocalPlayer.Name)
	if playerFolder then
		table.insert(State.connections, playerFolder:GetAttributeChangedSignal("Character"):Connect(function()
			if IsKolo() then
				setupKolo(LocalPlayer.Character)
			else
				CleanupAll()
			end
		end))
	end
end

-- Conectar eventos principales de vida del personaje
LocalPlayer.CharacterRemoving:Connect(function()
	CleanupAll()
end)

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
if LocalPlayer.Character then
	OnCharacterAdded(LocalPlayer.Character)
end

local function WaitForSounds()
	local assets   = workspace:FindFirstChild("Assets") or workspace:WaitForChild("Assets", 30)
	if not assets then return nil, nil end
	local songs    = assets:FindFirstChild("Songs") or assets:WaitForChild("Songs", 30)
	if not songs then return nil, nil end
	local normal   = songs:FindFirstChild("NormalChase") or songs:WaitForChild("NormalChase", 30)
	local lastLife = songs:FindFirstChild("LastLifeChase") or songs:WaitForChild("LastLifeChase", 30)
	return normal, lastLife
end

local function ApplySoundIds(normalSound, lastLifeSound, chaseId, lastLifeId)
	normalSound.SoundId   = chaseId
	lastLifeSound.SoundId = lastLifeId
	normalSound.Volume    = 3.5
	lastLifeSound.Volume  = 3.5
	normalSound:GetPropertyChangedSignal("SoundId"):Connect(function()
		if normalSound.SoundId ~= chaseId then normalSound.SoundId = chaseId end
	end)
	lastLifeSound:GetPropertyChangedSignal("SoundId"):Connect(function()
		if lastLifeSound.SoundId ~= lastLifeId then lastLifeSound.SoundId = lastLifeId end
	end)
end

local function ApplyRageSound(rageSound, rageId)
	rageSound.SoundId = rageId
	rageSound.Volume  = 1
	rageSound:GetPropertyChangedSignal("SoundId"):Connect(function()
		if rageSound.SoundId ~= rageId then rageSound.SoundId = rageId end
	end)
end

local function MonitorSongs(chaseId, lastLifeId)
	local assets = workspace:WaitForChild("Assets", 60)
	if not assets then return end
	local songs  = assets:WaitForChild("Songs", 60)
	if not songs then return end

	local function tryApply()
		local normal   = songs:FindFirstChild("NormalChase")
		local lastLife = songs:FindFirstChild("LastLifeChase")
		if normal and lastLife then
			ApplySoundIds(normal, lastLife, chaseId, lastLifeId)
		end
	end

	tryApply()

	songs.ChildAdded:Connect(function(child)
		if child.Name == "NormalChase" or child.Name == "LastLifeChase" then
			task.wait(0.1)
			tryApply()
		end
	end)
end

local function MonitorRageSong(rageId)
	local assets = workspace:WaitForChild("Assets", 60)
	if not assets then return end
	local songs = assets:WaitForChild("Songs", 60)
	if not songs then return end

	local function tryApply()
		local rage = songs:FindFirstChild("Rage")
		if rage then ApplyRageSound(rage, rageId) end
	end

	tryApply()
	songs.ChildAdded:Connect(function(child)
		if child.Name == "Rage" then
			task.wait(0.1)
			tryApply()
		end
	end)
end

local function LoadRageTheme()
	local rageId
	local ok, result = pcall(function()
		writefile(RageFileName, game:HttpGet(RageThemeUrl))
		rageId = getcustomasset(RageFileName)
	end)
	if not ok or not rageId then
		warn("Failed to load Rage theme:", result)
		return
	end
	MonitorRageSong(rageId)
end

task.spawn(LoadRageTheme)

task.spawn(function()
	local chaseId, lastLifeId
	local okC, resC = pcall(function()
		writefile(ChaseFileName, game:HttpGet(ChaseThemeUrl))
		chaseId = getcustomasset(ChaseFileName)
	end)
	local okL, resL = pcall(function()
		writefile(LastLifeFileName, game:HttpGet(LastLifeThemeUrl))
		lastLifeId = getcustomasset(LastLifeFileName)
	end)
	if not okC or not chaseId then
		warn("Failed to load Chase theme:", resC)
		return
	end
	if not okL or not lastLifeId then
		warn("Failed to load Last Life theme:", resL)
		return
	end
	MonitorSongs(chaseId, lastLifeId)
end)

local function isKolossosDefault(mdl)
	return mdl:FindFirstChild("Rage", true) ~= nil
		or mdl:FindFirstChild("upperjaggedteeth", true) ~= nil
end

local selectPreview    = nil
local selectSyncConn   = nil

local function destroySelectPreview()
	if selectSyncConn then selectSyncConn:Disconnect() selectSyncConn = nil end
	if selectPreview and selectPreview.Parent then selectPreview:Destroy() end
	selectPreview = nil
end

local function spawnSelectPreview(original)
	if selectPreview and selectPreview.Parent then return end
	if not original or not original.Parent then return end

	for _, v in ipairs(original:GetDescendants()) do
		if v:IsA("BasePart") then v.Transparency = 1 end
	end

	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. SELECT_MODEL_ID)
	if not ok or #objects == 0 then return end
	local mdl    = objects[1]:Clone()

	local skinHum = mdl:FindFirstChildOfClass("Humanoid")
	if skinHum then skinHum:Destroy() end

	local newHrp = mdl:FindFirstChild("HumanoidRootPart")
	if newHrp then
		newHrp.Anchored     = true
		newHrp.Transparency = 1
	end

	for _, p in ipairs(mdl:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CanCollide = false
			if p.Name == "Waist" then p.Transparency = 1 end
		end
	end

	mdl.Parent    = original
	selectPreview = mdl

	local origHrp = original:FindFirstChild("HumanoidRootPart")
	if origHrp and newHrp then
		newHrp.CFrame = origHrp.CFrame
	end

	if selectSyncConn then selectSyncConn:Disconnect() end
	selectSyncConn = RunService.Stepped:Connect(function()
		if not original.Parent then
			destroySelectPreview()
			return
		end
		if newHrp and origHrp then
			newHrp.CFrame = origHrp.CFrame
		end
	end)

	-- anim
	local origHum   = original:FindFirstChildOfClass("Humanoid")
	local animator  = origHum and origHum:FindFirstChildOfClass("Animator")
	if animator then
		local anim         = Instance.new("Animation")
		anim.AnimationId   = SELECT_ANIM_ID
		local ok2, track   = pcall(function() return animator:LoadAnimation(anim) end)
		if ok2 and track then
			track.Looped = true
			track:Play()
		end
	end
end

local function watchMapFolder(mapFolder)
	local function checkDefault(child)
		if (child.Name == "Default" or child.Name == "Miku")
			and child:IsA("Model")
			and isKolossosDefault(child) then
			task.wait(0.1)
			spawnSelectPreview(child)
		end
	end

	for _, child in ipairs(mapFolder:GetChildren()) do
		checkDefault(child)
	end

	mapFolder.ChildAdded:Connect(checkDefault)
	mapFolder.ChildRemoved:Connect(function(child)
		if child.Name == "Default" or child.Name == "Miku" then
			destroySelectPreview()
		end
	end)
end

local function startSelectMap()
    task.spawn(function()
        if not Enabled then return end
        
        local selectMap = workspace:WaitForChild("SelectMap", 120)
        if not selectMap then return end

        for _, mapFolder in ipairs(selectMap:GetChildren()) do
            watchMapFolder(mapFolder)
        end
        
        table.insert(State.connections, selectMap.ChildAdded:Connect(function(child)
            task.wait(0.1)
            watchMapFolder(child)
        end))
        
        table.insert(State.connections, selectMap.ChildRemoved:Connect(function()
            destroySelectPreview()
        end))
    end)
end

-- slec
local function startNameOverride()
    if not Enabled then return end

    local function applyTextChanges(charSelect)
        local selectScreen = charSelect:FindFirstChild("SelectScreen", true)
        local charLabel = selectScreen and selectScreen:FindFirstChild("char")
        
        if charLabel then
            if charLabel.Text == "2011x" then
                charLabel.Text = CHAR_NAME
            end
            -- Escuchar si cambia el texto después
            table.insert(State.connections, charLabel:GetPropertyChangedSignal("Text"):Connect(function()
                if charLabel.Text == "2011x" then
                    charLabel.Text = CHAR_NAME
                end
            end))
        end
    end

    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    table.insert(State.connections, playerGui.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "CharSelect" then
            applyTextChanges(descendant)
        end
    end))
    
    -- Por si ya existe al iniciar
    local existingCharSelect = playerGui:FindFirstChild("CharSelect", true)
    if existingCharSelect then
        applyTextChanges(existingCharSelect)
    end
end

-- W sc.
local function startVictoryScreen()
	task.spawn(function()
		while Enabled do
			local function watchResScreen(resScreen)
				table.insert(State.connections, resScreen.ChildAdded:Connect(function(child)
					-- 1. Si el jugador local NO está usando a 2011x, no hacemos nada
					if not IsKolo() then return end
					
					-- 2. Validar que sea un modelo de victoria válido
					if not (child:IsA("Model") and child.Name == "") then return end
					
					task.spawn(function()
						task.wait(0.1)
						if not child.Parent then return end
						
						local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. AssetId)
						if not ok or #objects == 0 then return end
						
						local mdl      = objects[1]:Clone()
						local skinHum  = mdl:FindFirstChildOfClass("Humanoid")
						if skinHum then skinHum:Destroy() end
						
						for _, p in ipairs(mdl:GetDescendants()) do
							if p:IsA("BasePart") then
								p.CanCollide = false
								p.Anchored   = false
								p.Massless   = true
							end
						end
						
						for _, p in ipairs(child:GetDescendants()) do
							if p:IsA("BasePart") then p.Transparency = 1 end
						end
						
						local origHRP = child:FindFirstChild("HumanoidRootPart")
						local skinHRP = mdl:FindFirstChild("HumanoidRootPart") or mdl:FindFirstChildWhichIsA("BasePart")
						mdl.Parent    = child
						
						if origHRP and skinHRP then
							mdl:PivotTo(origHRP.CFrame)
							skinHRP.Transparency = 1
							local weld   = Instance.new("Motor6D")
							weld.Part0   = origHRP
							weld.Part1   = skinHRP
							weld.C0      = CFrame.new(0, 0, 0)
							weld.Parent  = origHRP
						end
					end)
				end))
			end

			table.insert(State.connections, workspace.ChildAdded:Connect(function(child)
				if child.Name == "RES_Screen" then watchResScreen(child) end
			end))
			
			local existing = workspace:FindFirstChild("RES_Screen")
			if existing then watchResScreen(existing) end
			break
		end
	end)
end

--

startSelectMap()
startNameOverride()
startVictoryScreen()
