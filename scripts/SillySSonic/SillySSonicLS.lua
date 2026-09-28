
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("SaiyanUpdateNotice") then
	CoreGui.SaiyanUpdateNotice:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SaiyanUpdateNotice"
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

local closeButton = Instance.new("TextButton")
closeButton.Name = "Cerrar"
closeButton.Size = UDim2.new(0, 160, 0, 40)
closeButton.Position = UDim2.new(0.5, 20, 0.8, -10)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "Close"
closeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.SourceSansBold
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton
closeButton.Parent = frame

local copyButton = Instance.new("TextButton")
copyButton.Name = "Copiar"
copyButton.Size = UDim2.new(0, 160, 0, 40)
copyButton.Position = UDim2.new(0.5, -180, 0.8, -10)
copyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
copyButton.Text = "Copy page to clipboard"
copyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
copyButton.TextSize = 13
copyButton.Font = Enum.Font.SourceSansBold
local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 6)
copyCorner.Parent = copyButton
copyButton.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "HEY THERE, USER!"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 28
titleLabel.Font = Enum.Font.FredokaOne
titleLabel.Parent = frame

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(0, 260, 0, 180)
infoLabel.Position = UDim2.new(0, 210, 0, 60)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "If you are seeing this, you kind of executed a repost of saiyan's silly super sonic script for outcome memories\n\ni'd appreciate if you looked through my pages, so please go check my actual scriptblox account, making this script wasn't easy so atleast credit me when reposting\n\nyou can find me on youtube and scriptblox under my alias MisterSaiyan, you can also check my personal page for more stuff.\n\nDon't worry, there's a button right away to copy it onto your clipboard\n\n\- Your Friend, Sonic The Hedgehog"
infoLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
infoLabel.TextSize = 12
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Font = Enum.Font.SourceSans
infoLabel.Parent = frame

closeButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

copyButton.MouseButton1Click:Connect(function()
	local link = "https://mistersaiyan.github.io/cosas/web/" 
	
	pcall(function()
		setclipboard(link)
	end)
	
	copyButton.Text = "Copied!"
	task.wait(1.5)
	copyButton.Text = "Copy page to clipboard"
end)
