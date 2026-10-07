	local originalSonicSoloID = "rbxassetid://86323356232926"
	local BFTheme = true

	local Workspace = game:GetService("Workspace")
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local theme80
	local theme80Connection
	local ModernLMS
	
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

local function configureReplicatedLMS()
	if BFTheme and not canUseModernLMS() then
		BFTheme = false
	end
	SetTheme()

	local soloFolder = game:GetService("ReplicatedStorage"):FindFirstChild("ClientAssets")
		and game.ReplicatedStorage.ClientAssets:FindFirstChild("Sounds")
		and game.ReplicatedStorage.ClientAssets.Sounds:FindFirstChild("mus")
		and game.ReplicatedStorage.ClientAssets.Sounds.mus:FindFirstChild("Game")
		and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game:FindFirstChild("Round")
		and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game.Round:FindFirstChild("SoloTheme")
	local lmsSound = soloFolder and soloFolder:FindFirstChild("SonicSolo")
	if not lmsSound then
		warn("No se encontró SonicSolo")
		return
	end

	lmsSound:Stop()
end

local function applyTheme80()
	if not theme80 or not theme80.Parent or not ModernLMS then
		return
	end

	if theme80.SoundId ~= originalSonicSoloID then
		return
	end

	theme80.SoundId = ModernLMS
	theme80.Volume = 1.5
	theme80.Looped = false
	print("[LMS] Theme80s LMS reemplazado")
end

local function bindTheme80()
	local assets = Workspace:FindFirstChild("Assets")
	local songs = assets and assets:FindFirstChild("Songs")
	local candidate = songs and songs:FindFirstChild("Theme80s")
	if not candidate or not candidate:IsA("Sound") then
		return
	end

	if candidate == theme80 then
		applyTheme80()
		return
	end

	if theme80Connection then
		theme80Connection:Disconnect()
	end

	theme80 = candidate
	theme80Connection = candidate:GetPropertyChangedSignal("SoundId"):Connect(applyTheme80)
	applyTheme80()
end

Workspace.DescendantAdded:Connect(function(instance)
	if instance.Name == "Theme80s" then
		task.defer(bindTheme80)
	end
end)

Workspace.DescendantRemoving:Connect(function(instance)
	if instance == theme80 then
		if theme80Connection then
			theme80Connection:Disconnect()
			theme80Connection = nil
		end
		theme80 = nil
	end
end)

player.CharacterAdded:Connect(bindTheme80)
bindTheme80()

task.spawn(function()
	ModernLMS = loadCustomAsset(
		"https://raw.githubusercontent.com/MisterSaiyan/cosas/main/bflmsFIX.mp3",
		"bflmsFIX.mp3"
	)

	if not ModernLMS then
		warn("[LMS] No se cargó el audio de reemplazo; el menú puede continuar")
		return
	end

	configureReplicatedLMS()
	applyTheme80()
end)
