	local originalAmySoloID = "rbxassetid://71594974901466"
	local GFTheme = true
	
	local function loadCustomAsset(url, filename)
		local ok, asset = pcall(function()
			local folder = filename:match('^(.*)/')
			if folder and not isfolder(folder) then
				makefolder(folder)
			end

			if not isfile(filename) then
				writefile(filename, game:HttpGet(url))
			end
			return getcustomasset(filename)
		end)

		if not ok then
			warn("[CinematicAudio] No se pudo cargar", filename, asset)
			return nil
		end

		return asset
	end

	local AmyLMS = loadCustomAsset(
		"https://raw.githubusercontent.com/MisterSaiyan/cosas/main/gfthing.mp3",
		"gfsolothingfix.mp3"
	)

    local function canUseModernLMS()
		local soloFolder = game:GetService("ReplicatedStorage"):FindFirstChild("ClientAssets")
			and game.ReplicatedStorage.ClientAssets:FindFirstChild("Sounds")
			and game.ReplicatedStorage.ClientAssets.Sounds:FindFirstChild("mus")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus:FindFirstChild("Game")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game:FindFirstChild("Round")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game.Round:FindFirstChild("SoloTheme")

		local amySolo = soloFolder and soloFolder:FindFirstChild("AmySolo")
		return amySolo
	end

	local function SetTheme()
		local soloFolder = game:GetService("ReplicatedStorage"):FindFirstChild("ClientAssets")
			and game.ReplicatedStorage.ClientAssets:FindFirstChild("Sounds")
			and game.ReplicatedStorage.ClientAssets.Sounds:FindFirstChild("mus")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus:FindFirstChild("Game")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game:FindFirstChild("Round")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game.Round:FindFirstChild("SoloTheme")

		local amySolo = soloFolder and soloFolder:FindFirstChild("AmySolo")
		if not amySolo then
			warn("No se encontró AmySolo")
			return
		end

		if not originalAmySoloID or originalAmySoloID == "" then
			originalAmySoloID = amySolo.SoundId
		end

		if GFTheme then
			if not canUseModernLMS() then
				amySolo.SoundId = originalAmySoloID
				amySolo.Volume = 1
				amySolo.Looped = false
				GFTheme = false
				return
			end
			amySolo.SoundId = AmyLMS
			amySolo.Volume = 1.5
			amySolo.Looped = false
			return
		end

		amySolo.SoundId = originalAmySoloID
		amySolo.Volume = 1
		amySolo.Looped = false
	end

				if GFTheme and not canUseModernLMS() then
					GFTheme = false
					SetTheme()
				end
			SetTheme()

			-- Detener
				local soloFolder = game:GetService("ReplicatedStorage"):FindFirstChild("ClientAssets")
				and game.ReplicatedStorage.ClientAssets:FindFirstChild("Sounds")
				and game.ReplicatedStorage.ClientAssets.Sounds:FindFirstChild("mus")
				and game.ReplicatedStorage.ClientAssets.Sounds.mus:FindFirstChild("Game")
				and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game:FindFirstChild("Round")
				and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game.Round:FindFirstChild("SoloTheme")

			local LMSsound = soloFolder and soloFolder:FindFirstChild("AmySolo")
			if not LMSsound then
				warn("No se encontró AmySolo")
				return
			end

			LMSsound:Stop()

local theme80 = game:GetService("Workspace")
    :WaitForChild("Assets")
    :WaitForChild("Songs")
    :WaitForChild("Theme80s")

local function SetTheme()
    if theme80.SoundId ~= originalAmySoloID then
        return
    end

    if not AmyLMS then
        warn("[LMS] No se cargó el audio de reemplazo")
        return
    end

    theme80.SoundId = AmyLMS
    theme80.Volume = 1.5
    theme80.Looped = false
    print("[LMS] Theme80s LMS reemplazado")
end

theme80:GetPropertyChangedSignal("SoundId"):Connect(SetTheme)
SetTheme()
