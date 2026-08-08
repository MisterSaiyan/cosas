local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local ASSET_ID = 108016890710520
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

local function isAmy()
    local model = getPlayerModel()
    return model and model:GetAttribute("Character") == "Amy"
end

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
			local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. 108016890710520)
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

local function setupCharacter(char)
    if not isScriptActive then return end
    if syncConn then syncConn:Disconnect() syncConn = nil end
    if currentMdl and currentMdl.Parent then currentMdl:Destroy() currentMdl = nil end

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

    local playersFolder = workspace:FindFirstChild("Players")
    local oldVisual = playersFolder and playersFolder:FindFirstChild(player.Name)
    if oldVisual then
        for _, v in ipairs(oldVisual:GetDescendants()) do
            if v:IsA("BasePart") then v.Transparency = 1 end
        end
    end

    task.defer(function()
        local mdl = loadAsset(ASSET_ID)
        if not mdl or not isScriptActive then 
            if mdl then mdl:Destroy() end
            return 
        end

        if oldVisual then mdl.Parent = oldVisual else mdl.Parent = char end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local newHrp = mdl:FindFirstChild("HumanoidRootPart")
        if not hrp or not newHrp then mdl:Destroy() return end

        newHrp.Anchored = true
        newHrp.Transparency = 1

        local mdlHum = mdl:FindFirstChildOfClass("Humanoid")
        if mdlHum then mdlHum:Destroy() end
        local mdlAnim = mdl:FindFirstChildOfClass("Animator")
        if mdlAnim then mdlAnim:Destroy() end

task.spawn(function()
            for _, v in ipairs(mdl:GetDescendants()) do
                if v:IsA("BasePart") then
                    -- Excluimos los ojos o esferas importantes para que no pierdan sus propiedades
                    if v.Name ~= "Sphere.002" and v.Name ~= "eye1" and v.Name ~= "eye2" then
                        v.CanCollide = false
                    end
                    
                    if v.Name == "HumanoidRootPart" or v.Name == "Waist" then
                        v.Transparency = 1
                    end
                elseif v:IsA("Trail") or v:IsA("Beam") then
                    v.Enabled = false
                end
            end
        end)

        newHrp.CFrame = hrp.CFrame
        currentMdl = mdl

        local hammerhandle = mdl:FindFirstChild("AxeHandle")
        local hammerjoint = hammerhandle and hammerhandle:FindFirstChild("Joint")

        local rightHand = char:FindFirstChild("RightHand")

        syncConn = RunService.Stepped:Connect(function()
            if not char.Parent or not hrp.Parent or not newHrp.Parent then
                if syncConn then syncConn:Disconnect() end
                return
            end
            newHrp.CFrame = hrp.CFrame
            if hammerhandle and hammerjoint and rightHand then
                local relativeCFrame = rightHand.CFrame:Inverse() * hammerhandle.CFrame
                hammerjoint.C0 = relativeCFrame
            end
        end)
    end)
end

local function startScript()
    if isScriptActive then return end
    task.wait(1) -- Reducido de 3 a 1 para agilizar la entrada
    setupAmyViewport()
    isScriptActive = true
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
        task.wait(0.5)
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
