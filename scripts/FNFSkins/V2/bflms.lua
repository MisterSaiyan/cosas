	local originalSonicSoloID = "rbxassetid://136212496176401"
	local BFTheme = true
	
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

	local ModernLMS = loadCustomAsset(
		"https://raw.githubusercontent.com/MisterSaiyan/cosas/main/bfthingv2.mp3",
		"bfthing.mp3"
	)

    local function canUseModernLMS()
		local soloFolder = game:GetService("ReplicatedStorage"):FindFirstChild("ClientAssets")
			and game.ReplicatedStorage.ClientAssets:FindFirstChild("Sounds")
			and game.ReplicatedStorage.ClientAssets.Sounds:FindFirstChild("mus")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus:FindFirstChild("Game")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game:FindFirstChild("Round")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game.Round:FindFirstChild("SoloTheme")

		local sonicSolo = soloFolder and soloFolder:FindFirstChild("SonicSolo")
		return sonicSolo
	end

	local function SetTheme()
		local soloFolder = game:GetService("ReplicatedStorage"):FindFirstChild("ClientAssets")
			and game.ReplicatedStorage.ClientAssets:FindFirstChild("Sounds")
			and game.ReplicatedStorage.ClientAssets.Sounds:FindFirstChild("mus")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus:FindFirstChild("Game")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game:FindFirstChild("Round")
			and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game.Round:FindFirstChild("SoloTheme")

		local sonicSolo = soloFolder and soloFolder:FindFirstChild("SonicSolo")
		if not sonicSolo then
			warn("No se encontró SonicSolo")
			return
		end

		if not originalSonicSoloID or originalSonicSoloID == "" then
			originalSonicSoloID = sonicSolo.SoundId
		end

		if BFTheme then
			if not canUseModernLMS() then
				sonicSolo.SoundId = originalSonicSoloID
				sonicSolo.Volume = 1
				sonicSolo.Looped = false
				BFTheme = false
				return
			end
			sonicSolo.SoundId = ModernLMS
			sonicSolo.Volume = 1.5
			sonicSolo.Looped = false
			return
		end

		sonicSolo.SoundId = originalSonicSoloID
		sonicSolo.Volume = 1
		sonicSolo.Looped = false
	end

				if BFTheme and not canUseModernLMS() then
					BFTheme = false
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

			local LMSsound = soloFolder and soloFolder:FindFirstChild("SonicSolo")
			if not LMSsound then
				warn("No se encontró SonicSolo")
				return
			end

			LMSsound:Stop()
