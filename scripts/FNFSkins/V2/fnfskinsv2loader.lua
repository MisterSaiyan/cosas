local CoreGui = game:GetService("CoreGui")
        
		game.StarterGui:SetCore("SendNotification", {
        Title = "FNF Skins V2", 
        Text = "Made by MisterSaiyan | Head sync comes disabled by default, enable it if you use head cosmetics ", 
        Icon = "", Duration = 10
    })

    		game.StarterGui:SetCore("SendNotification", {
        Title = "Version Check", 
        Text = "This is intended for 0.22 (Base Game)", 
        Icon = "", Duration = 10
    })

loadstring(game:HttpGet("https://raw.githubusercontent.com/MisterSaiyan/cosas/refs/heads/main/scripts/FNFSkins/V2/AmyGFV2.lua"))()

loadstring(game:HttpGet("https://raw.githubusercontent.com/MisterSaiyan/cosas/refs/heads/main/scripts/FNFSkins/V2/SonicBFV2.lua"))()
