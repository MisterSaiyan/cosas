local CoreGui = game:GetService("CoreGui")
        
		game.StarterGui:SetCore("SendNotification", {
        Title = "2022x - BF Over 2011x", 
        Text = "Made by MisterSaiyan", 
        Icon = "", Duration = 10
    })

    		game.StarterGui:SetCore("SendNotification", {
        Title = "Reminder", 
        Text = "Execute this before using 2011x", 
        Icon = "", Duration = 10
    })

local BASE_URL = "https://raw.githubusercontent.com/MisterSaiyan/cosas/main/shopicons/"
local ShopModel = 97163073527228

local function myAsset(fileName)
    local folder = "FNFShopIcons"
    local path = folder .. "/" .. fileName

    if not isfolder(folder) then
        makefolder(folder)
    end

    if not isfile(path) then
        local ok, data = pcall(function()
            return game:HttpGet(BASE_URL .. fileName)
        end)
        if not ok then
            error("No se pudo descargar " .. fileName .. ": " .. tostring(data))
        end
        writefile(path, data)
    end

    return getcustomasset(path)
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local XIcon = myAsset("Xbf.png")
local XBanner = myAsset("2022Xthing.png")

local runId = (_G.Cream2011xGeneration or 0) + 1
_G.Cream2011xGeneration = runId
_G.Cream2011xKeepTask1 = false

local scheduled = false
local refresh
local watchedProperties = setmetatable({}, { __mode = "k" })

local function isCurrent()
    return _G.Cream2011xGeneration == runId and _G.Cream2011xKeepTask1
end

local function scheduleRefresh()
    if scheduled or not isCurrent() then return end
    scheduled = true
    task.delay(0.05, function()
        scheduled = false
        if isCurrent() then
            refresh()
        end
    end)
end

local function watchProperty(instance, property)
    local properties = watchedProperties[instance]
    if not properties then
        properties = {}
        watchedProperties[instance] = properties
    end
    if properties[property] then return end
    properties[property] = true
    instance:GetPropertyChangedSignal(property):Connect(scheduleRefresh)
end

local function setImage(instance, image)
    if not instance or not (instance:IsA("ImageLabel") or instance:IsA("ImageButton")) then return end
    watchProperty(instance, "Image")
    if instance.Image ~= image then
        instance.Image = image
    end
end

local function applyCharacterIcon(root)
    local selection = root:FindFirstChild("CharSelection")
    local card = selection and selection:FindFirstChild("2011x")
    if not card then return end

    local icon = card:FindFirstChild("Icon")
    local border = icon and icon:FindFirstChild("Border")
    local primaryIcon = border and border:FindFirstChild("Icon")
    local secondaryIcon = border and border:FindFirstChild("Icon2")

    setImage(primaryIcon, XIcon)
    setImage(secondaryIcon, XIcon)
    if secondaryIcon and secondaryIcon:IsA("GuiObject") then
        watchProperty(secondaryIcon, "Visible")
        if not secondaryIcon.Visible then
            secondaryIcon.Visible = true
        end
    end

    local alternateBorder = card:FindFirstChild("Border")
    setImage(alternateBorder and alternateBorder:FindFirstChild("ImageLabel"), XIcon)
end

local function applySelectedIcon(root)
    local display = root:FindFirstChild("CharDisplay")
    local nameLabel = display and display:FindFirstChild("CharName")
    if not display or not display:IsA("GuiObject") or not nameLabel or not nameLabel:IsA("TextLabel") then
        return
    end

    watchProperty(display, "Visible")
    watchProperty(nameLabel, "Text")
    if not display.Visible or nameLabel.Text ~= "2011x / X" then return end

    setImage(display:FindFirstChild("CharImage"), XBanner)

    local info = root:FindFirstChild("Info")
    local charInfo = info and info:FindFirstChild("CharInfo")
    local charIcon = charInfo and charInfo:FindFirstChild("CharIcon")
    local border = charIcon and charIcon:FindFirstChild("Border")
    setImage(border and border:FindFirstChild("ImageLabel"), XIcon)
end

refresh = function()
    if not isCurrent() then return end

    local gameUI = playerGui:FindFirstChild("GameUI")
    local shop = gameUI and gameUI:FindFirstChild("shop")
    local display = shop and shop:FindFirstChild("display")
    local root = display and display:FindFirstChild("fram2")
    if not root then return end

    applyCharacterIcon(root)
    applySelectedIcon(root)
end

local function initShopIcons()
    local gameUI = playerGui:WaitForChild("GameUI", 30)
    if not gameUI then return end

    scheduleRefresh()

    -- Escuchar solo si se añade la tienda o la selección de personajes
    table.insert(watchedProperties, gameUI.DescendantAdded:Connect(function(child)
        if child.Name == "shop" or child.Name == "CharSelection" or child.Name == "CharDisplay" then
            task.wait(0.05)
            scheduleRefresh()
        end
    end))
end

task.spawn(initShopIcons)

task.delay(0.3, function()
    if _G.Cream2011xGeneration ~= runId then return end
    _G.Cream2011xKeepTask1 = true
    scheduleRefresh()
end)

-- Model in Shop

local function loadAsset(id)
	local ok, objects = pcall(game.GetObjects, game, "rbxassetid://" .. id)
	if not ok or not objects or #objects == 0 then return nil end
	return objects[1]:Clone()
end

-- Replace the replicatedstorage char (affects viewport, character selection and inventory)

task.spawn(function()
    local storage = game:GetService("ReplicatedStorage")
    local skins = storage
        :WaitForChild("ClientAssets")
        :WaitForChild("Characters")
        :WaitForChild("EXE")
        :WaitForChild("2011x")
        :WaitForChild("Skins")

    local originalDefault = skins:WaitForChild("Default")
    local originalMiku = skins:WaitForChild("miku")
    
    local replacement = loadAsset(ShopModel)
    if not replacement then return end

    local replacement2 = replacement:Clone()

    -- Configuración para Default
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

    -- Configuración para Miku
    replacement2.Name = "miku"
    if not replacement2:FindFirstChild("Sphere.003") then
        local fallback = Instance.new("Part")
        fallback.Name = "Sphere.003"
        fallback.Size = Vector3.new(0.1, 0.1, 0.1)
        fallback.Transparency = 1
        fallback.CanCollide = false
        fallback.CanTouch = false
        fallback.CanQuery = false
        fallback.Anchored = true
        fallback.Parent = replacement2
    end
    if not replacement2:FindFirstChild("Sphere.007") then
        local fallback = Instance.new("Part")
        fallback.Name = "Sphere.007"
        fallback.Size = Vector3.new(0.1, 0.1, 0.1)
        fallback.Transparency = 1
        fallback.CanCollide = false
        fallback.CanTouch = false
        fallback.CanQuery = false
        fallback.Anchored = true
        fallback.Parent = replacement2
    end
    replacement2.Parent = skins
    originalMiku:Destroy()
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/MisterSaiyan/cosas/refs/heads/main/BFexe/BFSkinMain.lua"))()
