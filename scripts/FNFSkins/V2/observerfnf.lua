local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local localPlayer = Players.LocalPlayer

		game.StarterGui:SetCore("SendNotification", {
        Title = "FNF Skins V2", 
        Text = "Observer Enabled | Made by MisterSaiyan", 
        Icon = "", Duration = 10
    })

local ASSET_ID = 137895615579863
local SUPER_ID = 138131908852771
local CosmeticCompToggle = true
local HatCosmeticToggle = true
local ShoesCosmeticToggle = true
local HeadSyncToggle = false
local CHASE_RELEASE_DELAY = 1.5

local GFHideJacketaswell = false
local GFJacketOriginalColors = setmetatable({}, { __mode = "k" })

--Iconos FirstLife BF

local IconNormalBF = "rbxassetid://70591552067670" -- Expression.Regular
local ExpressionNormalBF = "rbxassetid://97503507235837" -- Eyes.Regular
local ExpressionChasedBF = "rbxassetid://74170907471721" -- Eyes.Chased

-- LastLife BF

local DownedIconBF = "rbxassetid://82487791860646" -- Expression.Downed

local IconLastLifeBF = "rbxassetid://80808006481637" -- Expression.LastLife
local ExpressionLastLifeBF = "rbxassetid://126888188456611" -- Reemplaza Eyes.Regular si estas en lastlife

local characterConfigs = {
	Amy = {
		assetId = 73695760388601,
		alwaysVisibleObjectNames = {
			"Hammer",
			"Axe",
			"MagicalAmy",
		},
		weaponColorReplacements = {
			{
				from = Color3.fromRGB(255, 217, 0),
				to = Color3.fromRGB(27, 42, 53),
			},
			{
				from = Color3.fromRGB(255, 0, 102),
				to = Color3.fromRGB(86, 36, 36),
			},
			{
				from = Color3.fromRGB(255, 0, 0),
				to = Color3.fromRGB(91, 93, 105),
			},
		},
		icons = {
			normal = "rbxassetid://73222561332765",
			eyesNormal = "rbxassetid://79752501485749",
			eyesChased = "rbxassetid://113659883065962",
			downed = "rbxassetid://91117693958700",
			lastLife = "rbxassetid://119311173785729",
			eyesLastLife = "rbxassetid://86029426878323",
			layout = {
				eyes = {
					position = UDim2.fromScale(0.45, 0.39),
					size = UDim2.fromScale(0.60, 0.60),
				},
				expression = {
					position = UDim2.fromScale(0.45, 0.39),
					size = UDim2.fromScale(0.60, 0.60),
				},
			},
		},
		cosmeticRoots = {
			TMOSTH = true,
		},
		shirtCosmetics = {
			TMOSTH = true,
			Cosmetic = true,
			AmyChristmasDress = true,
			coatthingy = true,
			Sleeve = true,
			lowerleg = true,
			upperleg = true,
			["modern dress"] = true,
		},
		hatCosmetics = {},
		shoesCosmetics = {},
		shirtGroup = "Vestido",
		jacketGroup = "Chaqueta",
	},
	Sonic = {
		assetId = ASSET_ID,
		hideShadowPartA = true,
		destroyPartNames = {
			["head new"] = true,
			headnewfocus = true,
		},
		basePartNames = {
			"hed", "Cube.001", "Cube.002", "Cube.003", "Cube.004",
			"Ear1", "Ear2", "Sphere.017", "Sphere.030", "eye1", "eye2",
			"eyes", "joy1", "joy2", "muzzl", "normal", "nose", "Body",
			"RIndex1", "RIndex2", "RMiddle1", "RMiddle2", "RPinky1", "RPinky2",
			"RThumb1", "RThumb2", "Right Hand", "LIndex1", "LIndex2",
			"LMiddle1", "LMiddle2", "LPinky1", "LPinky2", "LThumb1", "LThumb2",
			"Left Hand", "LArm1", "LArm2", "LArm3", "LArm4", "LArm5",
			"RArm1", "RArm2", "RArm3", "RArm4", "RArm5", "LFoot",
			"RFoot", "LFoot1", "LFoot2", "LFoot3", "LFoot4", "LFoot5",
			"RLeg1", "RLeg2", "RLeg3", "RLeg4", "RLeg5", "RSleeve", "Cape",
			"LSleeve", "tail", "belly", "Sphere.003", "Sphere.006",
			"Sphere.007", "Sphere.010", "left backspike", "right backspike",
			"angry", "Coloreye1", "Coloreye2",
			"Cube.015", "Cube.016", "burger", "Cube.009", "Cube.014",
			"exportme", "Cube.011", "ears", "ears.001", "ears.002", "ears.003",
			"replace", "aah", "head new", "headnewFocus", "altedxport.005",
			"altedxport.006", "Cube", "muzzle new", "sdgdsagsd",
			"altedxport.001", "altedxport.003", "remodelSphere.010",
			"Cube.017", "Cube.008",
			"superMoist_quillB", "superMoist_quillBotR", "superMoist_quillF",
			"superMoist_quillR", "superMoist_quillTopR", "superMoist_wiskerss",
			"Weld", "topbottomquill", "Cone.002", "Cone.003", "Mouth2",
		},
		icons = {
			normal = IconNormalBF,
			eyesNormal = ExpressionNormalBF,
			eyesChased = ExpressionChasedBF,
			downed = DownedIconBF,
			lastLife = IconLastLifeBF,
			eyesLastLife = ExpressionLastLifeBF,
			layout = {
				eyes = {
					position = UDim2.fromScale(0.171, 0.126643255),
					imageColor = Color3.new(0, 0, 0),
				},
				expression = {
					preserveLayout = true,
				},
			},
		},
		cosmeticRoots = {
			Shadow = true,
			SHOVEL = true,
			Bodyy = true,
			["Cube.001"] = true,
			["Cube.014"] = true,
		},
		shirtCosmetics = {
			HyperCape = true,
			RedCape = true,
			PacedCape = true,
			EnergyCape = true,
			DevilHunter = true,
			PostMortemCape = true,
			superMoist_cape = true,
			Bodyy = true,
			SHORT = true,
			BrownScarg = true,
		},
		hatCosmetics = {
			Hair = true,
			hairpiece = true,
			topquill = true,
			quilllow = true,
			quill = true,
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
		},
		shoesCosmetics = {
			superMoist_shoes = true,
			["Right Shoe"] = true,
			Weld = true,
			["Sphere.018"] = true,
			LFoot = true,
			RFoot = true,
			Cube = true,
		},
		shirtGroup = "Camisa",
		shirtModel = "poleronmodel",
		forcedHideRoots = {
			["superMoist_shoes"] = true,
			["head new"] = true,
			["headnewFocus"] = true,
		},
	},
}

local sonicBasePartNames = {}
for _, partName in ipairs(characterConfigs.Sonic.basePartNames) do
	sonicBasePartNames[partName] = true
end
characterConfigs.Sonic.basePartNames = sonicBasePartNames

local trackedPlayers = {}
local playerConnections = {}
local spawnConnections = {}
local activeModels = {}

local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

local function hasNamedDescendant(root, name)
	if not root then
		return false
	end

	for _, descendant in ipairs(root:GetDescendants()) do
		if descendant.Name == name then
			return true
		end
	end

	return false
end

local function getActiveAssetId(root, config)
	if config == characterConfigs.Sonic and hasNamedDescendant(root, "superMoist_quills") then
		return SUPER_ID
	end
	return config.assetId
end

local function isSuperMoistCapeWeld(part)
	return part
		and part.Name == "Weld"
		and part.Parent
		and part.Parent.Name == "superMoist_cape"
end

local function getCharacterConfig(player)
	local models = { player.Character }
	local playersFolder = workspace:FindFirstChild("Players")
	if playersFolder then
		table.insert(models, playersFolder:FindFirstChild(player.Name))
	end

	for _, model in ipairs(models) do
		if model then
			local ok, characterName = pcall(function()
				return model:GetAttribute("Character")
			end)
			if ok and characterConfigs[characterName] then
				return characterConfigs[characterName]
			end
		end
	end

	return nil
end

local shoeComponentPartNames = {
	LFoot = true,
	RFoot = true,
	Cube = true,
}

local function isShoesCosmeticContainer(container)
	if not container or not (container:IsA("Model") or container:IsA("Folder")) then
		return false
	end

	local hasShoePart = false
	local hasWeld = false
	for _, child in ipairs(container:GetChildren()) do
		if shoeComponentPartNames[child.Name]
			and (child:IsA("BasePart") or child:IsA("Model") or child:IsA("Folder")) then
			hasShoePart = true
			if child:FindFirstChild("Weld", true) then
				hasWeld = true
			end
		elseif child.Name == "Weld" then
			hasWeld = true
		end
	end
	return hasShoePart and hasWeld
end

local function getCosmeticType(object, model, config)
	if not object or not model then
		return nil
	end

	local current = object
	while current and current ~= model do
		if config then
			local isBasePartName = current == object
				and current:IsA("BasePart")
				and config.basePartNames
				and config.basePartNames[current.Name]
			if not isBasePartName and config.hatCosmetics and config.hatCosmetics[current.Name] then
				return "hat"
			elseif isShoesCosmeticContainer(current) then
				return "shoes"
			elseif not isBasePartName and ((config.cosmeticRoots and config.cosmeticRoots[current.Name])
				or (config.shirtCosmetics and config.shirtCosmetics[current.Name])) then
				return "cosmetic"
			end
		end
		current = current.Parent
	end
	return nil
end

local function belongsToCosmeticRoot(object, model, config)
	local cosmeticType = getCosmeticType(object, model, config)
	if cosmeticType == "hat" then
		return CosmeticCompToggle and HatCosmeticToggle
	elseif cosmeticType == "shoes" then
		return ShoesCosmeticToggle
	elseif cosmeticType == "cosmetic" then
		return CosmeticCompToggle
	end
	return false
end

local function isOriginalHedCube001(object, model)
	if object.Name ~= "Cube.001" then
		return false
	end

	local current = object.Parent
	while current and current ~= model do
		if current.Name == "hed" then
			return true
		end
		current = current.Parent
	end
	return false
end

local function isShadowPartA(object, model, config)
	if not config or not config.hideShadowPartA then
		return false
	end

	local current = object
	local foundA = false
	while current and current ~= model do
		if current.Name == "A" then
			foundA = true
		elseif current.Name == "Shadow" and foundA then
			return true
		end
		current = current.Parent
	end
	return false
end

local function belongsToShoesCosmetic(object, model)
	local current = object
	while current and current ~= model do
		if isShoesCosmeticContainer(current) then
			return true
		end
		current = current.Parent
	end
	return false
end

local function hasHatCosmetic(model, config, exceptModel)
	if not model then return false end
	for _, object in ipairs(model:GetDescendants()) do
		if (not exceptModel or not object:IsDescendantOf(exceptModel))
			and config.hatCosmetics[object.Name] then
			return true
		end
	end
	return false
end

local function hasShirtCosmetic(model, config, exceptModel)
	if not model then return false end
	for _, object in ipairs(model:GetDescendants()) do
		if config.shirtCosmetics[object.Name]
			and (not exceptModel or not object:IsDescendantOf(exceptModel)) then
			return true
		end
	end
	return false
end

local function hasShoesCosmetic(model, config, exceptModel)
	if not model then return false end
	for _, object in ipairs(model:GetDescendants()) do
		if (not exceptModel or not object:IsDescendantOf(exceptModel))
			and ((config.shoesCosmetics and config.shoesCosmetics[object.Name]
			and not shoeComponentPartNames[object.Name])
			or isShoesCosmeticContainer(object)) then
			return true
		end
	end
	return false
end

local function restoreJacketColors(insertedModel)
	for part, originalColor in pairs(GFJacketOriginalColors) do
		if not part.Parent then
			GFJacketOriginalColors[part] = nil
		elseif part:IsDescendantOf(insertedModel) then
			part.Color = originalColor
			GFJacketOriginalColors[part] = nil
		end
	end
end

local function setGroupVisibility(group, visible)
	if not group then return end

	local objects = { group }
	for _, object in ipairs(group:GetDescendants()) do
		table.insert(objects, object)
	end

	for _, object in ipairs(objects) do
		if object:IsA("BasePart") then
			object.Transparency = (object.Name == "Weld" or isSuperMoistCapeWeld(object))
				and 1 or (visible and 0 or 1)
			object.CanCollide = false
		elseif object:IsA("Decal") or object:IsA("Texture") then
			object.Transparency = visible and 0 or 1
		end
	end
end

local function updateInsertedHat(model, insertedModel, config)
	if not model or not insertedModel then return end

	local visible = not (CosmeticCompToggle and HatCosmeticToggle
		and hasHatCosmetic(model, config, insertedModel))
	for _, object in ipairs(insertedModel:GetDescendants()) do
		if object:IsA("BasePart")
			and (object.Name == "bhat" or object.Name == "hat" or object.Name == "sas") then
			object.Transparency = visible and 0 or 1
			object.CanCollide = false
		end
	end
end

local function updateInsertedShoes(model, insertedModel, config)
	if not model or not insertedModel then return end

	local hideShoesGroups = ShoesCosmeticToggle and hasShoesCosmetic(model, config, insertedModel)
	for _, object in ipairs(insertedModel:GetDescendants()) do
		if (object.Name == "Shoes" or object.Name == "Thing2")
			and (object:IsA("Model") or object:IsA("Folder")) then
			setGroupVisibility(object, not hideShoesGroups)
		end
	end
end

local function restoreCosmeticVisibility(model, config, exceptModel)
	if not model then return end

	for _, cosmeticNames in ipairs({
		config.cosmeticRoots or {},
		config.shirtCosmetics or {},
		config.hatCosmetics or {},
	}) do
		for cosmeticName in pairs(cosmeticNames) do
			for _, cosmetic in ipairs(model:GetDescendants()) do
				if cosmetic.Name == cosmeticName
					and (not exceptModel or not cosmetic:IsDescendantOf(exceptModel)) then
					setGroupVisibility(cosmetic, belongsToCosmeticRoot(cosmetic, model, config))
				end
			end
		end
	end
	for _, cosmetic in ipairs(model:GetDescendants()) do
		if (not exceptModel or not cosmetic:IsDescendantOf(exceptModel))
			and isShoesCosmeticContainer(cosmetic) then
			setGroupVisibility(cosmetic, ShoesCosmeticToggle)
		end
	end
end

local function updateShirt(model, insertedModel, config)
	if not model or not insertedModel or not config then
		return
	end

	local hasCosmetic = CosmeticCompToggle and hasShirtCosmetic(model, config, insertedModel)

	local shirtGroup = config.shirtGroup and insertedModel:FindFirstChild(config.shirtGroup, true)
	if config.shirtModel then
		setGroupVisibility(insertedModel:FindFirstChild(config.shirtModel, true), not hasCosmetic)
		setGroupVisibility(shirtGroup, hasCosmetic)
	elseif config.jacketGroup then
		setGroupVisibility(shirtGroup, not hasCosmetic)
		setGroupVisibility(
			insertedModel:FindFirstChild(config.jacketGroup, true),
			not (hasCosmetic and GFHideJacketaswell)
		)

		if hasCosmetic and GFHideJacketaswell then
			for _, name in ipairs({ "LSleeve", "RSleeve", "Arms" }) do
				local target = insertedModel:FindFirstChild(name, true)
				if target then
					local objects = { target }
					for _, object in ipairs(target:GetDescendants()) do
						table.insert(objects, object)
					end
					for _, object in ipairs(objects) do
						if object:IsA("BasePart") then
							if GFJacketOriginalColors[object] == nil then
								GFJacketOriginalColors[object] = object.Color
							end
							object.Color = Color3.fromRGB(255, 255, 255)
						end
					end
				end
			end
		else
			restoreJacketColors(insertedModel)
		end

		for _, name in ipairs({ "LSleeve", "RSleeve" }) do
			local sleeve = insertedModel:FindFirstChild(name, true)
			if sleeve then
				setGroupVisibility(sleeve, true)
			end
		end
	else
		setGroupVisibility(shirtGroup, true)
	end
end

local function shouldHideSourcePart(object, model, exceptModel, config)
	if not object:IsA("BasePart") or (exceptModel and object:IsDescendantOf(exceptModel)) then
		return false
	end

	local forcedHide = config and config.forcedHideRoots and config.forcedHideRoots[object.Name]
	local protectedShoe = ShoesCosmeticToggle and belongsToShoesCosmetic(object, model)
	local cosmeticType = getCosmeticType(object, model, config)
	local isProtectedCosmetic = belongsToCosmeticRoot(object, model, config)
	local isBasePart = config and config.basePartNames and config.basePartNames[object.Name]
	local isOriginalBasePart = isBasePart
		and object.Name == "Cube.001"
		and isOriginalHedCube001(object, model)

	if isShadowPartA(object, model, config) then
		return true
	end

	if config and config.basePartNames then
		return (forcedHide and not protectedShoe)
			or isOriginalBasePart
			or ((isBasePart or cosmeticType ~= nil) and not isProtectedCosmetic)
	end
	return (forcedHide and not protectedShoe) or not isProtectedCosmetic
end

local function showAmyWeapon(model, config, object)
	if not model or not config or not config.alwaysVisibleObjectNames then
		return
	end

	local weaponRoot
	if object then
		local current = object
		while current and current ~= model do
			for _, name in ipairs(config.alwaysVisibleObjectNames) do
				if current.Name == name then
					weaponRoot = current
					break
				end
			end
			if weaponRoot then
				break
			end
			current = current.Parent
		end
		if not weaponRoot then
			return
		end
	else
		for _, name in ipairs(config.alwaysVisibleObjectNames) do
			weaponRoot = model:FindFirstChild(name, true)
			if weaponRoot then
				break
			end
		end
	end
	if not weaponRoot then
		return
	end

	local parts = {}
	if weaponRoot:IsA("BasePart") then
		table.insert(parts, weaponRoot)
	end
	for _, descendant in ipairs(weaponRoot:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(parts, descendant)
		end
	end
	for _, part in ipairs(parts) do
		part.Transparency = 0
		part.CanCollide = false
		for _, replacement in ipairs(config.weaponColorReplacements or {}) do
			if part.Color == replacement.from then
				part.Color = replacement.to
				break
			end
		end
	end
end

local function applyInsertedModelFixes(model, config)
	if not model or not config then
		return
	end

	for _, object in ipairs(model:GetDescendants()) do
		if object:IsA("BasePart") then
			if config.destroyPartNames
				and config.destroyPartNames[string.lower(object.Name)] then
				object:Destroy()
			elseif isShadowPartA(object, model, config) then
				object.Transparency = 1
				object.CanCollide = false
			end
		end
	end
end

local function hideSourcePartIfNeeded(object, model, exceptModel, config)
	if shouldHideSourcePart(object, model, exceptModel, config) then
		object.Transparency = 1
		object.CanCollide = false
	end
end

local function hideModelParts(model, exceptModel, config)
	if not model then
		return
	end

	for _, object in ipairs(model:GetDescendants()) do
		hideSourcePartIfNeeded(object, model, exceptModel, config)
	end
end

local function setupCharacter(modelInfo)
	if not modelInfo or not modelInfo.source.Parent or not modelInfo.inserted.Parent then
		return
	end

	restoreCosmeticVisibility(modelInfo.source, modelInfo.config, modelInfo.inserted)
	hideModelParts(modelInfo.source, modelInfo.inserted, modelInfo.config)
	showAmyWeapon(modelInfo.source, modelInfo.config)
	updateShirt(modelInfo.source, modelInfo.inserted, modelInfo.config)
	updateInsertedHat(modelInfo.source, modelInfo.inserted, modelInfo.config)
	updateInsertedShoes(modelInfo.source, modelInfo.inserted, modelInfo.config)
end

local function getBooleanState(root, names)
	if not root then return false end

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

local iconGuiDefaults = setmetatable({}, { __mode = "k" })

local function setFolderState(folder, activeName, imageId, zIndex, layout)
	if not folder then return end

	for _, child in ipairs(folder:GetChildren()) do
		if child:IsA("ImageLabel") or child:IsA("ImageButton") then
			local defaults = iconGuiDefaults[child]
			if not defaults then
				defaults = {
					position = child.Position,
					size = child.Size,
					anchorPoint = child.AnchorPoint,
					scaleType = child.ScaleType,
					imageColor = child.ImageColor3,
				}
				iconGuiDefaults[child] = defaults
			end
			child.Position = defaults.position
			child.Size = defaults.size
			child.AnchorPoint = defaults.anchorPoint
			child.ScaleType = defaults.scaleType
			child.ImageColor3 = defaults.imageColor

			local isActive = child.Name == activeName
			child.Visible = isActive
			if isActive then
				child.Image = imageId
				child.ZIndex = zIndex
				if layout and layout.imageColor then
					child.ImageColor3 = layout.imageColor
				end
				if not (layout and layout.preserveLayout) then
					if layout and layout.position then
						child.Position = layout.position
					end
					if layout and layout.size then
						child.AnchorPoint = Vector2.new(0.5, 0.5)
						child.Size = layout.size
						child.ScaleType = Enum.ScaleType.Fit
					end
				end
			end
		end
	end
end

local chasedIconState = setmetatable({}, { __mode = "k" })

local function applyObservedIcon(targetPlayer)
	local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
	local round = playerGui and playerGui:FindFirstChild("Round")
	local gameGui = round and round:FindFirstChild("Game")
	local teams = gameGui and gameGui:FindFirstChild("Teams")
	local playerFrame = teams and teams:FindFirstChild(targetPlayer.Name)
	local frame = playerFrame and playerFrame:FindFirstChild("Frame")
	local characterGui = frame and frame:FindFirstChild("Character")
	if not characterGui then return end

	local config = getCharacterConfig(targetPlayer)
	if not config or not config.icons then return end

	local model = targetPlayer.Character
	local playersFolder = workspace:FindFirstChild("Players")
	local visualModel = playersFolder and playersFolder:FindFirstChild(targetPlayer.Name)
	local function hasState(names)
		return getBooleanState(visualModel, names)
			or getBooleanState(model, names)
			or getBooleanState(targetPlayer, names)
	end

	local isLastLife = hasState({ "LastLife", "IsLastLife", "SecondLife" })
	local isDowned = hasState({ "Downed", "IsDowned", "BeingDowned" })
	local isChased = hasState({ "Chased", "IsChased", "InChase", "BeingChased" })
	local chasedState = chasedIconState[targetPlayer]
	if not chasedState then
		chasedState = { visible = false, lostAt = nil, generation = 0 }
		chasedIconState[targetPlayer] = chasedState
	end
	if isChased then
		if not chasedState.visible or chasedState.lostAt then
			chasedState.visible = true
			chasedState.lostAt = nil
			chasedState.generation += 1
		end
	elseif chasedState.visible then
		if not chasedState.lostAt then
			chasedState.lostAt = os.clock()
			chasedState.generation += 1
			local generation = chasedState.generation
			task.delay(CHASE_RELEASE_DELAY, function()
				if chasedIconState[targetPlayer] == chasedState
					and chasedState.generation == generation then
					applyObservedIcon(targetPlayer)
				end
			end)
		elseif os.clock() - chasedState.lostAt >= CHASE_RELEASE_DELAY then
			chasedState.visible = false
			chasedState.lostAt = nil
			chasedState.generation += 1
		end
	end

	local eyesState = chasedState.visible and "Chased" or "Regular"
	local expressionState = isLastLife and "LastLife" or "Regular"
	local eyesImage = chasedState.visible and config.icons.eyesChased or config.icons.eyesNormal
	local expressionImage = isLastLife and config.icons.lastLife or config.icons.normal

	if isLastLife and not chasedState.visible then
		eyesImage = config.icons.eyesLastLife
	end
	if isDowned then
		expressionState = "Downed"
		expressionImage = config.icons.downed
	end

	local layout = config.icons.layout
	setFolderState(
		characterGui:FindFirstChild("Eyes"),
		isDowned and "" or eyesState,
		eyesImage,
		10,
		layout and layout.eyes
	)
	setFolderState(
		characterGui:FindFirstChild("Expression"),
		expressionState,
		expressionImage,
		5,
		layout and layout.expression
	)
end

local stateNames = {
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

local function connectStateWatchers(player, character, connections, watchedRoots)
	local watchedValues = {}
	watchedRoots = watchedRoots or setmetatable({}, { __mode = "k" })
	local function refreshIcon()
		applyObservedIcon(player)
	end

	local function watchValueObject(object)
		if not stateNames[object.Name] or not object:IsA("ValueBase") or watchedValues[object] then
			return
		end
		watchedValues[object] = true
		table.insert(connections, object.Changed:Connect(refreshIcon))
	end

	local function watchRoot(root)
		if not root or watchedRoots[root] then
			return
		end
		watchedRoots[root] = true

		for stateName in pairs(stateNames) do
			table.insert(connections, root:GetAttributeChangedSignal(stateName):Connect(refreshIcon))
		end
		for _, descendant in ipairs(root:GetDescendants()) do
			watchValueObject(descendant)
		end
		table.insert(connections, root.DescendantAdded:Connect(function(descendant)
			watchValueObject(descendant)
			if stateNames[descendant.Name] then
				refreshIcon()
			end
		end))
		table.insert(connections, root.DescendantRemoving:Connect(function(descendant)
			if stateNames[descendant.Name] then
				task.defer(refreshIcon)
			end
		end))
	end

	watchRoot(player)
	watchRoot(character)
	return watchedRoots
end

local function setupPlayerModel(player)
	if trackedPlayers[player] then return end
	trackedPlayers[player] = true
	playerConnections[player] = {}

	local function onCharacterAdded(character)
		chasedIconState[player] = nil
		for _, connection in ipairs(spawnConnections[player] or {}) do
			connection:Disconnect()
		end
		spawnConnections[player] = {}
		local connections = spawnConnections[player]
		local watchedStateRoots = connectStateWatchers(player, character, connections)

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			humanoid = character:WaitForChild("Humanoid", 5)
			if not humanoid or player.Character ~= character then return end
		end

		local setupStarted = false
		local function trySetup()
			if setupStarted or not character.Parent or player.Character ~= character then return end
			local config = getCharacterConfig(player)
			if not config then return end
			setupStarted = true

			local players_folder = workspace:FindFirstChild("Players")
			local old_visual = players_folder and players_folder:FindFirstChild(player.Name)

			local sourceRoot = old_visual or character
			local activeAssetId = getActiveAssetId(sourceRoot, config)
			local mdl = loadAsset(activeAssetId)
			if not mdl then
				warn("[ObserverFNF] Failed to load replacement asset:", activeAssetId)
				setupStarted = false
				return
			end

			applyInsertedModelFixes(mdl, config)

			for _, object in ipairs(mdl:GetDescendants()) do
				local protectedShoe = ShoesCosmeticToggle
					and belongsToShoesCosmetic(object, mdl)
				if object:IsA("BasePart")
					and config.forcedHideRoots
					and config.forcedHideRoots[object.Name]
					and not protectedShoe then
					object.Transparency = 1
					object.CanCollide = false
				end
			end

			if old_visual then
				mdl.Parent = old_visual
			else
				mdl.Parent = character
			end
			mdl:SetAttribute("AssetId", activeAssetId)
			local hrp = character:WaitForChild("HumanoidRootPart", 5)
			local new_hrp = mdl:WaitForChild("HumanoidRootPart", 5)
			if not hrp or not new_hrp then
				warn("[ObserverFNF] Character or replacement asset is missing HumanoidRootPart:", player.Name)
				mdl:Destroy()
				setupStarted = false
				return
			end

			new_hrp.Anchored = true
			local mdlHum = mdl:FindFirstChildOfClass("Humanoid")
			if mdlHum then mdlHum:Destroy() end
			local mdlAnim = mdl:FindFirstChildOfClass("Animator")
			if mdlAnim then mdlAnim:Destroy() end

			for _, v in ipairs(mdl:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CanCollide = false
					if v.Name == "HumanoidRootPart" or v.Name == "RootPart" or isSuperMoistCapeWeld(v) then
						v.Transparency = 1
					end
				end
			end
			new_hrp.Transparency = 1
			local new_waist = mdl:FindFirstChild("Waist", true)
			if new_waist and new_waist:IsA("BasePart") then new_waist.Transparency = 1 end
			activeModels[player] = {
				source = sourceRoot,
				inserted = mdl,
				config = config,
			}
			setupCharacter(activeModels[player])

			local motorMap = {}
			for _, oldMotor in ipairs(character:GetDescendants()) do
				if oldMotor:IsA("Motor6D") then
					local newMotor = nil
					-- First try: search within same parent name in mdl
					if oldMotor.Parent then
						local parentName = oldMotor.Parent.Name
						local mdlParent = mdl:FindFirstChild(parentName, true)
						if mdlParent then
							newMotor = mdlParent:FindFirstChild(oldMotor.Name)
							if not (newMotor and newMotor:IsA("Motor6D")) then
								newMotor = nil
							end
						end
					end
					-- Fallback: global search
					if not newMotor then
						newMotor = mdl:FindFirstChild(oldMotor.Name, true)
						if not (newMotor and newMotor:IsA("Motor6D")) then
							newMotor = nil
						end
					end
					if newMotor then
						motorMap[oldMotor] = newMotor
					end
				end
			end

			new_hrp.CFrame = hrp.CFrame

			local syncConnection
			syncConnection = RunService.PreSimulation:Connect(function()
				if not character.Parent or not hrp.Parent or not new_hrp.Parent then
					syncConnection:Disconnect()
					return
				end
				new_hrp.CFrame = hrp.CFrame
				if HeadSyncToggle then
					for oldMotor, newMotor in pairs(motorMap) do
						if oldMotor.Parent and newMotor.Parent then
							newMotor.Transform = oldMotor.Transform
						end
					end
				end
			end)
			table.insert(connections, syncConnection)

			local cosmeticNames = {}
			for cosmeticName in pairs(config.cosmeticRoots) do
				cosmeticNames[cosmeticName] = true
			end
			for cosmeticName in pairs(config.shirtCosmetics) do
				cosmeticNames[cosmeticName] = true
			end
			for cosmeticName in pairs(config.hatCosmetics or {}) do
				cosmeticNames[cosmeticName] = true
			end
			for cosmeticName in pairs(config.shoesCosmetics or {}) do
				cosmeticNames[cosmeticName] = true
			end
			table.insert(connections, sourceRoot.DescendantAdded:Connect(function(object)
				if object:IsA("BasePart") then
					hideSourcePartIfNeeded(object, sourceRoot, mdl, config)
				end
				showAmyWeapon(sourceRoot, config, object)

				local root = object
				while root and root ~= sourceRoot
					and not cosmeticNames[root.Name]
					and not isShoesCosmeticContainer(root) do
					root = root.Parent
				end
				if not root or root == sourceRoot or root:IsDescendantOf(mdl) then return end

				setGroupVisibility(root, belongsToCosmeticRoot(root, sourceRoot, config))
				if config.shirtCosmetics[root.Name] then
					updateShirt(sourceRoot, mdl, config)
				end
				updateInsertedHat(sourceRoot, mdl, config)
				updateInsertedShoes(sourceRoot, mdl, config)
			end))

			applyObservedIcon(player)
		end

		local function watchCharacterConfig(model)
			table.insert(connections, model:GetAttributeChangedSignal("Character"):Connect(trySetup))
			connectStateWatchers(player, model, connections, watchedStateRoots)
		end

		watchCharacterConfig(character)
		local playersFolder = workspace:FindFirstChild("Players")
		if playersFolder then
			local visual = playersFolder:FindFirstChild(player.Name)
			if visual then
				watchCharacterConfig(visual)
			end
			table.insert(connections, playersFolder.ChildAdded:Connect(function(child)
				if child.Name == player.Name then
					watchCharacterConfig(child)
					trySetup()
				end
			end))
		end
		table.insert(connections, workspace.ChildAdded:Connect(function(child)
			if child.Name == "Players" then
				local visual = child:FindFirstChild(player.Name)
				if visual then
					watchCharacterConfig(visual)
				end
				table.insert(connections, child.ChildAdded:Connect(function(added)
					if added.Name == player.Name then
						watchCharacterConfig(added)
						trySetup()
					end
				end))
				trySetup()
			end
		end))

		trySetup()

		table.insert(connections, character.AncestryChanged:Connect(function()
			if not character.Parent then
				for _, connection in ipairs(connections) do
					connection:Disconnect()
				end
				spawnConnections[player] = nil
				activeModels[player] = nil
			end
		end))
	end

	if player.Character then onCharacterAdded(player.Character) end
	table.insert(playerConnections[player], player.CharacterAdded:Connect(onCharacterAdded))
end

local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild("PlayerGui")
playerGui.DescendantAdded:Connect(function(descendant)
	if descendant.Name == "Character" or descendant.Name == "Eyes" or descendant.Name == "Expression" then
		for player in pairs(trackedPlayers) do
			applyObservedIcon(player)
		end
	end
end)

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= localPlayer then setupPlayerModel(p) end
end
Players.PlayerAdded:Connect(function(p)
	if p ~= localPlayer then setupPlayerModel(p) end
end)
Players.PlayerRemoving:Connect(function(player)
	for _, connection in ipairs(playerConnections[player] or {}) do
		connection:Disconnect()
	end
	for _, connection in ipairs(spawnConnections[player] or {}) do
		connection:Disconnect()
	end
	playerConnections[player] = nil
	spawnConnections[player] = nil
	activeModels[player] = nil
	trackedPlayers[player] = nil
end)

-- Observer configuration

local function createObserverTabButton(texto, orden)
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

local function getSharedConfigTopBar()
    local bfGui = CoreGui:FindFirstChild("ConfiguracionesBF")
    if bfGui then
        local bar = bfGui:FindFirstChild("ContenedorHorizontal")
        if bar then
            return bar
        end
    end
    return nil
end

local ObserverSharedBar = getSharedConfigTopBar()
local ObsConfigOpen = false

local function ensureObserverButton()
    if ObserverSharedBar and ObserverSharedBar:FindFirstChild("Observer") then
        return ObserverSharedBar:FindFirstChild("Observer")
    end

    local bar = ObserverSharedBar or (function()
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "ObserverConfigButtons"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.Parent = CoreGui

        local topBar = Instance.new("Frame")
        topBar.Name = "ContenedorHorizontal"
        topBar.Size = UDim2.new(0, 0, 0, 42)
        topBar.AutomaticSize = Enum.AutomaticSize.X
        topBar.Position = UDim2.new(0, 500, 0, 12)
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

    local existingButton = bar:FindFirstChild("Observer")
    if existingButton then
        return existingButton
    end

    local observerButton = createObserverTabButton("Observer", 3)
    observerButton.Name = "Observer"
    observerButton.Parent = bar

    return observerButton
end

local ObserverButton = ensureObserverButton()

local function ensureObserverPanel()
    local panel = rawget(_G, "ObserverConfigPanel")
    if panel and panel.Parent then
        return panel
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ObserverConfigMenu"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = CoreGui

    local panel = Instance.new("Frame")
    panel.Name = "ObserverConfigPanel"
    panel.Size = UDim2.new(0, 250, 0, 222)
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

    _G.ObserverConfigPanel = panel
    return panel
end

local ObsPanel = ensureObserverPanel()

local function createObserverConfigRow(parent, labelText, valueRef, onToggle)
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

local function refreshTrackedCosmetics()
	for _, modelInfo in pairs(activeModels) do
		setupCharacter(modelInfo)
	end
end

local function toggleCosmeticComp()
	CosmeticCompToggle = not CosmeticCompToggle
	refreshTrackedCosmetics()
end

local function toggleHatCosmetics()
	HatCosmeticToggle = not HatCosmeticToggle
	refreshTrackedCosmetics()
end

local function toggleShoesCosmetics()
	ShoesCosmeticToggle = not ShoesCosmeticToggle
	refreshTrackedCosmetics()
end

local function toggleHideAmyJacket()
	GFHideJacketaswell = not GFHideJacketaswell
	refreshTrackedCosmetics()
end

local function toggleHeadSync()
	HeadSyncToggle = not HeadSyncToggle
end

local function setObserverConfigVisible(visible)
	ObsConfigOpen = visible
	ObsPanel.Visible = visible
	ObserverButton.Text = visible and "Close" or "Observer"
end

createObserverConfigRow(ObsPanel, "Cosmetic Comp.", function() return CosmeticCompToggle end, toggleCosmeticComp)
createObserverConfigRow(ObsPanel, "Hat Cosmetics (BF)", function() return HatCosmeticToggle end, toggleHatCosmetics)
createObserverConfigRow(ObsPanel, "Shoes Cosmetics (BF)", function() return ShoesCosmeticToggle end, toggleShoesCosmetics)
createObserverConfigRow(ObsPanel, "Hide Amy Jacket (GF)", function() return GFHideJacketaswell end, toggleHideAmyJacket)

ObserverButton.MouseButton1Click:Connect(function()
	setObserverConfigVisible(not ObsConfigOpen)
end)

setObserverConfigVisible(false)
