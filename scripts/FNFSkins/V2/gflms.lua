	local originalAmySoloID = "rbxassetid://136212496176401"
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
		"gfsolothing.mp3"
	)

    local function canUseModernLMS()
		local soloFolder = game:GetService("ReplicatedStorage"):FindFirstChild("ClientAssets")
			and game.ReplicatedStorage.ClientAssets:FindFirstChild("Sounds")
			and game.ReplicatedStorage.ClientAssets.Sounds:FindFirstChild("mus")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus:FindFirstChild("Game")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game:FindFirstChild("Round")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game.Round:FindFirstChild("SoloTheme")

		local amysolo = soloFolder and soloFolder:FindFirstChild("AmySolo")
		return amysolo
	end

	local function SetTheme()
		local soloFolder = game:GetService("ReplicatedStorage"):FindFirstChild("ClientAssets")
			and game.ReplicatedStorage.ClientAssets:FindFirstChild("Sounds")
			and game.ReplicatedStorage.ClientAssets.Sounds:FindFirstChild("mus")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus:FindFirstChild("Game")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game:FindFirstChild("Round")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game.Round:FindFirstChild("SoloTheme")

		local amysolo = soloFolder and soloFolder:FindFirstChild("AmySolo")
		if not amysolo then
			warn("No se encontró AmySolo")
			return
		end

		if not originalAmySoloID or originalAmySoloID == "" then
			originalAmySoloID = amysolo.SoundId
		end

		if GFTheme then
			if not canUseModernLMS() then
				amysolo.SoundId = originalAmySoloID
				amysolo.Volume = 1
				amysolo.Looped = false
				GFTheme = false
				return
			end
			amysolo.SoundId = AmyLMS
			amysolo.Volume = 1.5
			amysolo.Looped = false
			return
		end

		amysolo.SoundId = originalAmySoloID
		amysolo.Volume = 1
		amysolo.Looped = false
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