
	local CoreGui = game:GetService("CoreGui")
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer

	if CoreGui:FindFirstChild("SaiyanUpdateNotice") then
		CoreGui.SaiyanUpdateNotice:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "FNFSkinsv2Menu"
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = CoreGui

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Size = UDim2.new(0, 150, 0, 150)
	imageLabel.Position = UDim2.new(0, 550, 0, 290)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://75296394588681"
	imageLabel.Parent = screenGui
	imageLabel.ZIndex = 9

	local frame = Instance.new("Frame")
	frame.Name = "Frame"
	frame.Size = UDim2.new(0, 500, 0, 350)
	frame.Position = UDim2.new(0.5, -250, 0.5, -175)
	frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = frame

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(30, 30, 30)
	uiStroke.Thickness = 2
	uiStroke.Parent = frame

	local CurrentVersion = Instance.new("TextButton")
	CurrentVersion.Name = "Base Game"
	CurrentVersion.Size = UDim2.new(0, 160, 0, 40)
	CurrentVersion.Position = UDim2.new(0.5, 20, 0.8, -10)
	CurrentVersion.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	CurrentVersion.Text = "Execute for Base Game (0.2)"
	CurrentVersion.TextColor3 = Color3.fromRGB(0, 0, 0)
	CurrentVersion.TextSize = 14
	CurrentVersion.Font = Enum.Font.SourceSansBold
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = CurrentVersion
	CurrentVersion.Parent = frame

	local SobbeVersion = Instance.new("TextButton")
	SobbeVersion.Name = "Sobbe"
	SobbeVersion.Size = UDim2.new(0, 160, 0, 40)
	SobbeVersion.Position = UDim2.new(0.5, -180, 0.8, -10)
	SobbeVersion.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SobbeVersion.Text = "Execute for Sobbe's 0.1A"
	SobbeVersion.TextColor3 = Color3.fromRGB(0, 0, 0)
	SobbeVersion.TextSize = 14
	SobbeVersion.Font = Enum.Font.SourceSansBold
	local sobbeCorner = Instance.new("UICorner")
	sobbeCorner.CornerRadius = UDim.new(0, 6)
	sobbeCorner.Parent = SobbeVersion
	SobbeVersion.Parent = frame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 50)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "FNF Skins V2 - Version Selector"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 28
	titleLabel.Font = Enum.Font.FredokaOne
	titleLabel.Parent = frame

	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(0, 260, 0, 180)
	infoLabel.Position = UDim2.new(0, 210, 0, 60)
	infoLabel.BackgroundTransparency = 1
	infoLabel.Text = "Hello! Due to the 0.1A's lms nature, just wanted to let you choose which version do you wish to execute\n\nThis is merely for the lms song side of the script, shouldn't be any visual changes aside hammer recoloring not working for amy in 0.1A\n\n"
	infoLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
	infoLabel.TextSize = 12
	infoLabel.TextWrapped = true
	infoLabel.TextXAlignment = Enum.TextXAlignment.Left
	infoLabel.TextYAlignment = Enum.TextYAlignment.Top
	infoLabel.Font = Enum.Font.SourceSans
	infoLabel.Parent = frame

	local function executeVersion(url)
		screenGui:Destroy()

		task.spawn(function()
			local ok, source = pcall(function()
				return game:HttpGet(url)
			end)
			if not ok then
				warn("[FNF Skins] No se pudo descargar el script:", source)
				return
			end

			local compileError
			local chunk
			if type(loadstring) ~= "function" then
				warn("[FNF Skins] loadstring no está disponible en este entorno")
				return
			end

			chunk, compileError = loadstring(source)
			if not chunk then
				warn("[FNF Skins] Error al compilar el script:", compileError)
				return
			end

			local ran, runtimeError = pcall(chunk)
			if not ran then
				warn("[FNF Skins] Error al ejecutar el script:", runtimeError)
			end
		end)
	end

	CurrentVersion.MouseButton1Click:Connect(function()
		executeVersion("https://raw.githubusercontent.com/MisterSaiyan/cosas/refs/heads/main/scripts/FNFSkins/fnfskinsv2.lua")
	end)

	SobbeVersion.MouseButton1Click:Connect(function()
		executeVersion("https://raw.githubusercontent.com/MisterSaiyan/cosas/refs/heads/main/scripts/FNFSkins/V2/0.1A/fnfskinsv2A.lua")
	end)
