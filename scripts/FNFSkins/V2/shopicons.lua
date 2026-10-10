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

-- iconos

local BFIcon = myAsset("bf.png")
local GFIcon = myAsset("gf.png")

-- BF

task.spawn(function()
    _G.FNFShopIconsKeepBF = false
    task.wait(0.3)
    _G.FNFShopIconsKeepBF = true
    while _G.FNFShopIconsKeepBF do
        pcall(function() -- om 0.2 anni
            game:GetService("Players").LocalPlayer.PlayerGui.GameUI.shop.display.fram2.CharSelection["Sonic"].Icon.Border.Icon2.Visible = false
            game:GetService("Players").LocalPlayer.PlayerGui.GameUI.shop.display.fram2.CharSelection["Sonic"].Icon.Border.Icon.Image = BFIcon
        end)
        pcall(function() -- for 0.1a by sobii
        game:GetService("Players").LocalPlayer.PlayerGui.GameUI.shop.display.fram2.CharSelection["Sonic"].Border.ImageLabel.Image = BFIcon
        end)
        pcall(function()
            local CharDisplay = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.shop.display.fram2.CharDisplay
            if not CharDisplay.Visible then return end
            if CharDisplay.CharName.Text == "Sonic" then
                CharDisplay.CharImage.Image = BFIcon
            end
            local CharInfoIcon = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.shop.display.fram2.Info.CharInfo.CharIcon.Border.ImageLabel
            if CharDisplay.CharName.Text == "Sonic" then
                CharInfoIcon.Image = BFIcon
            end
        end)
        task.wait()
    end
end)

-- GF

task.spawn(function()
    _G.FNFShopIconsKeepGF = false
    task.wait(0.3)
    _G.FNFShopIconsKeepGF = true
    while _G.FNFShopIconsKeepGF do
        pcall(function() -- om 0.2 anni
            game:GetService("Players").LocalPlayer.PlayerGui.GameUI.shop.display.fram2.CharSelection["Amy"].Icon.Border.Icon2.Visible = false
            game:GetService("Players").LocalPlayer.PlayerGui.GameUI.shop.display.fram2.CharSelection["Amy"].Icon.Border.Icon.Image = GFIcon
        end)
        pcall(function() -- for 0.1a by sobii
             game:GetService("Players").LocalPlayer.PlayerGui.GameUI.shop.display.fram2.CharSelection["Amy"].Border.ImageLabel.Image = GFIcon
        end)
        pcall(function()
            local CharDisplay = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.shop.display.fram2.CharDisplay
            if not CharDisplay.Visible then return end
            if CharDisplay.CharName.Text == "Amy" then
                CharDisplay.CharImage.Image = GFIcon
            end
            local CharInfoIcon = game:GetService("Players").LocalPlayer.PlayerGui.GameUI.shop.display.fram2.Info.CharInfo.CharIcon.Border.ImageLabel
            if CharDisplay.CharName.Text == "Amy" then
                CharInfoIcon.Image = GFIcon
            end
        end)
        task.wait()
    end
end)
