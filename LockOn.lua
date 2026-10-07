-- Lock-On Script (Bigger GUI + Working Smooth Slider)

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
-- Bigger + Clean GUI
-------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LockOnGui"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 200, 0, 85) -- bigger
main.Position = UDim2.new(0.5, -100, 0.84, 0)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

-- Soft shadow
local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 32, 1, 32)
shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
shadow.AnchorPoint = Vector2.new(0.5, 0.5)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6014261993"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.48
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49, 49, 450, 450)
shadow.ZIndex = 0
shadow.Parent = main

-- Toggle track (the smooth bar)
local track = Instance.new("Frame")
track.Name = "Track"
track.Size = UDim2.new(0, 64, 0, 32)
track.Position = UDim2.new(0, 18, 0.5, -16)
track.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
track.BorderSizePixel = 0
track.Parent = main

local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(1, 0)
trackCorner.Parent = track

-- Slider circle
local slider = Instance.new("Frame")
slider.Name = "Slider"
slider.Size = UDim2.new(0, 26, 0, 26)
slider.Position = UDim2.new(0, 3, 0.5, -13)
slider.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
slider.BorderSizePixel = 0
slider.Parent = track

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = slider

-- Label
local label = Instance.new("TextLabel")
label.Name = "Label"
label.Size = UDim2.new(0, 100, 0, 36)
label.Position = UDim2.new(0, 92, 0.5, -18)
label.BackgroundTransparency = 1
label.Text = "LOCK  •  OFF"
label.TextColor3 = Color3.fromRGB(215, 215, 225)
label.TextSize = 16
label.Font = Enum.Font.GothamMedium
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = main

-------------------------------------------------
-- Dragging system
-------------------------------------------------
local dragging = false
local dragStart = nil
local startPos = nil

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

main.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

-------------------------------------------------
-- Logic
-------------------------------------------------
local isOn = false
local connection = nil
local humanoidRootPart = nil
local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

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
		-- Slide to the right + green
		TweenService:Create(slider, tweenInfo, {
			Position = UDim2.new(1, -29, 0.5, -13),
			BackgroundColor3 = Color3.fromRGB(65, 230, 120)
		}):Play()

		TweenService:Create(track, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(28, 68, 45)
		}):Play()

		label.Text = "LOCK  •  ON"
		label.TextColor3 = Color3.fromRGB(100, 255, 150)
	else
		-- Slide to the left + red
		TweenService:Create(slider, tweenInfo, {
			Position = UDim2.new(0, 3, 0.5, -13),
			BackgroundColor3 = Color3.fromRGB(255, 75, 75)
		}):Play()

		TweenService:Create(track, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		}):Play()

		label.Text = "LOCK  •  OFF"
		label.TextColor3 = Color3.fromRGB(215, 215, 225)
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

				local rootPos = humanoidRootPart.Position
				local targetPos = target.Position
				local direction = (targetPos - rootPos).Unit

				local distance = 9
				local height = 3.5

				local camPos = rootPos - direction * distance + Vector3.new(0, height, 0)
				camera.CFrame = CFrame.lookAt(camPos, targetPos)

				-- Face the target
				humanoidRootPart.CFrame = CFrame.lookAt(rootPos, Vector3.new(targetPos.X, rootPos.Y, targetPos.Z))
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
local clickStart = nil

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		clickStart = input.Position
	end
end)

main.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if clickStart and (input.Position - clickStart).Magnitude < 10 then
			toggleLock()
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.C then
		toggleLock()
	end
end)

print("wassupp big dogzz ty for using the script, press c for the keybind ^^")
