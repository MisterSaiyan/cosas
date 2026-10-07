-- FNF Skins for 0.1A Loader
local CoreGui = game:GetService("CoreGui")
        
		game.StarterGui:SetCore("SendNotification", {
        Title = "FNF Skins V2", 
        Text = "Made by MisterSaiyan | Head sync comes disabled by default, enable it if you use head cosmetics ", 
        Icon = "", Duration = 10
    })

    		game.StarterGui:SetCore("SendNotification", {
        Title = "Version Check", 
        Text = "This is intended for 0.1A (Sobbe's Copy)", 
        Icon = "", Duration = 10
    })

loadstring(game:HttpGet("https://raw.githubusercontent.com/MisterSaiyan/cosas/refs/heads/main/scripts/FNFSkins/V2/0.1A/GF0.1A.lua"))()

local function loadAsync(label, url)
    task.spawn(function()
        local ok, err = pcall(function()
            local source = game:HttpGet(url)
            local chunk, compileError = loadstring(source)
            if not chunk then
                error(compileError)
            end
            chunk()
        end)

        if not ok then
            warn("[FNF Skins][" .. label .. "] " .. tostring(err))
        end
    end)
end

loadAsync("BF", "https://raw.githubusercontent.com/MisterSaiyan/cosas/refs/heads/main/scripts/FNFSkins/V2/0.1A/BF0.1A.lua")
loadAsync("LMS", "https://raw.githubusercontent.com/MisterSaiyan/cosas/refs/heads/main/scripts/FNFSkins/V2/0.1A/bflms0.1a.lua")
