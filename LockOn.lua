-- Lock-On Script (Clean GUI Version)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Clean old GUI
if player.PlayerGui:FindFirstChild("LockOnGui") then
	player.PlayerGui.LockOnGui:Destroy()
end

-------------------------------------------------
-- Clean GUI
-------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LockOnGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main container
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 180, 0, 55)
main.Position = UDim2.new(0.5, -90, 0.87, 0)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
main.BorderSizePixel = 0
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

-- Soft shadow
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6014261993"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.55
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49, 49, 450, 450)
shadow.ZIndex = 0
shadow.Parent = main

-- Toggle track
local track = Instance.new("Frame")
track.Name = "Track"
track.Size = UDim2.new(0, 52, 0, 28)
track.Position = UDim2.new(0, 14, 0.5, -14)
track.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
track.BorderSizePixel = 0
track.Parent = main

local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(1, 0)
trackCorner.Parent = track

-- Slider circle
local slider = Instance.new("Frame")
slider.Name = "Slider"
slider.Size = UDim2.new(0, 22, 0, 22)
slider.Position = UDim2.new(0, 3, 0.5, -11)
slider.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
slider.BorderSizePixel = 0
slider.Parent = track

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = slider

-- Label
local label = Instance.new("TextLabel")
label.Name = "Label"
label.Size = UDim2.new(0, 100, 1, 0)
label.Position = UDim2.new(0, 72, 0, 0)
label.BackgroundTransparency = 1
label.Text = "LOCK  •  OFF"
label.TextColor3 = Color3.fromRGB(220, 220, 230)
label.TextSize = 15
label.Font = Enum.Font.GothamMedium
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = main

-- Keybind hint
local keyHint = Instance.new("TextLabel")
keyHint.Size = UDim2.new(0, 28, 0, 18)
keyHint.Position = UDim2.new(1, -38, 0.5, -9)
keyHint.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
keyHint.Text = "C"
keyHint.TextColor3 = Color3.fromRGB(180, 180, 190)
keyHint.TextSize = 12
keyHint.Font = Enum.Font.GothamBold
keyHint.Parent = main

local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 5)
keyCorner.Parent = keyHint

-------------------------------------------------
-- Logic
-------------------------------------------------
local isOn = false
local connection = nil
local humanoidRootPart = nil
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function getNearestPlayer()
	if not humanoidRootPart then return nil end
	local nearest, shortest = nil, math.huge
	for _, other in pairs(Players:GetPlayers()) do
		if other ~= player and other.Character then
			local root = other.Character:FindFirstChild("HumanoidRootPart")
			if root then
				local dist = (humanoidRootPart.Position - root.Position).Magnitude
				if dist < shortest then
					shortest = dist
					nearest = root
				end
			end
		end
	end
	return nearest
end

local function onCharacterAdded(character)
	humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
end

if player.Character then
	onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

local function setToggle(state)
	isOn = state
	if isOn then
		TweenService:Create(slider, tweenInfo, {
			Position = UDim2.new(1, -25, 0.5, -11),
			BackgroundColor3 = Color3.fromRGB(70, 220, 120)
		}):Play()
		TweenService:Create(track, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(35, 70, 50)
		}):Play()
		label.Text = "LOCK  •  ON"
		label.TextColor3 = Color3.fromRGB(120, 255, 160)
	else
		TweenService:Create(slider, tweenInfo, {
			Position = UDim2.new(0, 3, 0.5, -11),
			BackgroundColor3 = Color3.fromRGB(255, 85, 85)
		}):Play()
		TweenService:Create(track, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(45, 45, 52)
		}):Play()
		label.Text = "LOCK  •  OFF"
		label.TextColor3 = Color3.fromRGB(220, 220, 230)
	end
end

local function toggleLock()
	setToggle(not isOn)
	if isOn then
		connection = RunService.RenderStepped:Connect(function()
			if not humanoidRootPart or not humanoidRootPart.Parent then return end
			local target = getNearestPlayer()
			if target then
				camera.CameraType = Enum.CameraType.Scriptable
				camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Position)
				local rootPos = humanoidRootPart.Position
				humanoidRootPart.CFrame = CFrame.lookAt(rootPos, Vector3.new(target.Position.X, rootPos.Y, target.Position.Z))
			end
		end)
	else
		if connection then
			connection:Disconnect()
			connection = nil
		end
		camera.CameraType = Enum.CameraType.Custom
	end
end

-------------------------------------------------
-- Inputs
-------------------------------------------------
main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 
		or input.UserInputType == Enum.UserInputType.Touch then
		toggleLock()
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.C then
		toggleLock()
	end
end)

print("✅ Clean Lock-On loaded | Press C or click the bar")
