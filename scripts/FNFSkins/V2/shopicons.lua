local BASE_URL = "https://raw.githubusercontent.com/MisterSaiyan/cosas/main/shopicons/"

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

local BFIcon = myAsset("bf.png")
local GFIcon = myAsset("gf.png")
local runId = (_G.FNFShopIconsGeneration or 0) + 1
_G.FNFShopIconsGeneration = runId
_G.FNFShopIconsKeepBF = false
_G.FNFShopIconsKeepGF = false
local scheduled = false
local refresh
local watchedProperties = setmetatable({}, { __mode = "k" })

local function isCurrent()
    return _G.FNFShopIconsGeneration == runId
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
    if instance.Image ~= image then instance.Image = image end
end

local function applyCharacterIcon(root, characterName, image)
    local card = root
        and root:FindFirstChild("CharSelection")
        and root.CharSelection:FindFirstChild(characterName)
    local icon = card and card:FindFirstChild("Icon")
    local border = icon and icon:FindFirstChild("Border")
    local primaryIcon = border and border:FindFirstChild("Icon")
    local secondaryIcon = border and border:FindFirstChild("Icon2")

    setImage(primaryIcon, image)
    if secondaryIcon and secondaryIcon:IsA("GuiObject") then
        watchProperty(secondaryIcon, "Visible")
        if secondaryIcon.Visible then secondaryIcon.Visible = false end
    end
end

local function applySelectedIcon(root, characterName, image)
    local display = root and root:FindFirstChild("CharDisplay")
    local nameLabel = display and display:FindFirstChild("CharName")
    if not display or not display:IsA("GuiObject") or not nameLabel or not nameLabel:IsA("TextLabel") then
        return
    end

    watchProperty(display, "Visible")
    watchProperty(nameLabel, "Text")
    if not display.Visible or nameLabel.Text ~= characterName then return end

    setImage(display:FindFirstChild("CharImage"), image)
    local info = root:FindFirstChild("Info")
    local charInfo = info and info:FindFirstChild("CharInfo")
    local charIcon = charInfo and charInfo:FindFirstChild("CharIcon")
    local border = charIcon and charIcon:FindFirstChild("Border")
    setImage(border and border:FindFirstChild("ImageLabel"), image)
end

refresh = function()
    if not isCurrent() then return end
    local gameUI = playerGui:FindFirstChild("GameUI")
    local shop = gameUI and gameUI:FindFirstChild("shop")
    local display = shop and shop:FindFirstChild("display")
    local root = display and display:FindFirstChild("fram2")
    if not root then return end

    if _G.FNFShopIconsKeepBF then
        applyCharacterIcon(root, "Sonic", BFIcon)
        applySelectedIcon(root, "Sonic", BFIcon)
    end
    if _G.FNFShopIconsKeepGF then
        applyCharacterIcon(root, "Amy", GFIcon)
        applySelectedIcon(root, "Amy", GFIcon)
    end
end

playerGui.DescendantAdded:Connect(scheduleRefresh)
playerGui.DescendantRemoving:Connect(scheduleRefresh)
scheduleRefresh()
task.delay(0.3, function()
    if not isCurrent() then return end
    _G.FNFShopIconsKeepBF = true
    _G.FNFShopIconsKeepGF = true
    scheduleRefresh()
end)
