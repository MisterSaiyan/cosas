local SoundService = game:GetService("SoundService")
local originalRage = nil

local function loadCustomAsset(url, filename)
	if not isfile(filename) then
		writefile(filename, game:HttpGet(url))
	end
	return getcustomasset(filename)
end

local RETROXRAGE = loadCustomAsset(
	"https://raw.githubusercontent.com/MisterSaiyan/cosas/main/RetroXRage.mp3",
	"RetroRage.mp3"
)

task.spawn(function()
	local theme = game:GetService("ReplicatedStorage")
	:FindFirstChild("ClientAssets")
	and game.ReplicatedStorage.ClientAssets:FindFirstChild("Sounds")
	and game.ReplicatedStorage.ClientAssets.Sounds:FindFirstChild("mus")
	and game.ReplicatedStorage.ClientAssets.Sounds.mus:FindFirstChild("Game")
	and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game:FindFirstChild("Round")
	and game.ReplicatedStorage.ClientAssets.Sounds.mus.Game.Round:FindFirstChild("ChaseThemes")
    :FindFirstChild("2011x")
    :FindFirstChild("RETRO")
    :FindFirstChild("Rage")
	if not theme then
		warn("burps")
		return
	end
	theme.SoundId = RETROXRAGE
	theme.Volume = 1.5
	theme.Looped = false
end)
