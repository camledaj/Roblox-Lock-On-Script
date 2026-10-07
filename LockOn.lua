--[[
	Lock-On  —  LocalScript for YOUR game
	Place in: StarterPlayer → StarterPlayerScripts
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local BIND_NAME = "LockOnCamera"
local MAX_RANGE = 400
local CAMERA_DISTANCE = 10
local CAMERA_HEIGHT = 3.2
local smoothness = 0.35

pcall(function()
	RunService:UnbindFromRenderStep(BIND_NAME)
end)
local oldGui = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("LockOnGui")
if oldGui then
	oldGui:Destroy()
end

local humanoidRootPart = nil
local humanoid = nil
local savedAutoRotate = true

local function onCharacterAdded(character)
	humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
	humanoid = character:WaitForChild("Humanoid", 10)
	if humanoid then
		savedAutoRotate = humanoid.AutoRotate
	end
end

if player.Character then
	task.spawn(onCharacterAdded, player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LockOnGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 100
screenGui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(228, 118)
main.Position = UDim2.new(0.5, -114, 0.82, 0)
main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
main.BorderSizePixel = 0
main.Active = true
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(48, 48, 58)
stroke.Thickness = 1
stroke.Parent = main

local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 14)
pad.PaddingBottom = UDim.new(0, 14)
pad.PaddingLeft = UDim.new(0, 16)
pad.PaddingRight = UDim.new(0, 16)
pad.Parent = main

local toggleRow = Instance.new("Frame")
toggleRow.BackgroundTransparency = 1
toggleRow.Size = UDim2.new(1, 0, 0, 36)
toggleRow.Parent = main

local track = Instance.new("TextButton")
track.Name = "Track"
track.AutoButtonColor = false
track.Text = ""
track.Size = UDim2.fromOffset(64, 32)
track.Position = UDim2.fromOffset(0, 2)
track.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
track.BorderSizePixel = 0
track.Parent = toggleRow

local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(1, 0)
trackCorner.Parent = track

local knob = Instance.new("Frame")
knob.Name = "Knob"
knob.Size = UDim2.fromOffset(26, 26)
knob.Position = UDim2.fromOffset(3, 3)
knob.BackgroundColor3 = Color3.fromRGB(255, 75, 75)
knob.BorderSizePixel = 0
knob.Active = false
knob.Parent = track

local knobCorner = Instance.new("UICorner")
knobCorner.CornerRadius = UDim.new(1, 0)
knobCorner.Parent = knob

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -76, 1, 0)
title.Position = UDim2.fromOffset(76, 0)
title.Text = "LOCK  •  OFF"
title.TextColor3 = Color3.fromRGB(215, 215, 225)
title.TextSize = 16
title.Font = Enum.Font.GothamMedium
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = toggleRow

local smoothRow = Instance.new("Frame")
smoothRow.BackgroundTransparency = 1
smoothRow.Size = UDim2.new(1, 0, 0, 44)
smoothRow.Position = UDim2.fromOffset(0, 48)
smoothRow.Parent = main

local smoothLabel = Instance.new("TextLabel")
smoothLabel.BackgroundTransparency = 1
smoothLabel.Size = UDim2.new(1, 0, 0, 16)
smoothLabel.Text = "SMOOTHNESS"
smoothLabel.TextColor3 = Color3.fromRGB(140, 140, 155)
smoothLabel.TextSize = 11
smoothLabel.Font = Enum.Font.GothamBold
smoothLabel.TextXAlignment = Enum.TextXAlignment.Left
smoothLabel.Parent = smoothRow

local bar = Instance.new("TextButton")
bar.Name = "SmoothBar"
bar.AutoButtonColor = false
bar.Text = ""
bar.Size = UDim2.new(1, 0, 0, 18)
bar.Position = UDim2.fromOffset(0, 22)
bar.BackgroundColor3 = Color3.fromRGB(36, 36, 44)
bar.BorderSizePixel = 0
bar.Parent = smoothRow

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(1, 0)
barCorner.Parent = bar

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.new(smoothness, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(90, 170, 255)
fill.BorderSizePixel = 0
fill.Parent = bar

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = fill

local handle = Instance.new("Frame")
handle.Name = "Handle"
handle.AnchorPoint = Vector2.new(0.5, 0.5)
handle.Size = UDim2.fromOffset(18, 18)
handle.Position = UDim2.new(smoothness, 0, 0.5, 0)
handle.BackgroundColor3 = Color3.fromRGB(240, 240, 250)
handle.BorderSizePixel = 0
handle.ZIndex = 2
handle.Parent = bar

local handleCorner = Instance.new("UICorner")
handleCorner.CornerRadius = UDim.new(1, 0)
handleCorner.Parent = handle

local draggingWindow = false
local dragStart = nil
local startPos = nil

main.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local pos = input.Position
	local inset = GuiService:GetGuiInset()
	local abs = Vector2.new(pos.X, pos.Y) - inset
	if track.AbsolutePosition.X <= abs.X and abs.X <= track.AbsolutePosition.X + track.AbsoluteSize.X
		and track.AbsolutePosition.Y <= abs.Y and abs.Y <= track.AbsolutePosition.Y + track.AbsoluteSize.Y then
		return
	end
	if bar.AbsolutePosition.X <= abs.X and abs.X <= bar.AbsolutePosition.X + bar.AbsoluteSize.X
		and bar.AbsolutePosition.Y <= abs.Y and abs.Y <= bar.AbsolutePosition.Y + bar.AbsoluteSize.Y then
		return
	end
	draggingWindow = true
	dragStart = pos
	startPos = main.Position
end)

UserInputService.InputChanged:Connect(function(input)
	if not draggingWindow then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	if not dragStart or not startPos then
		return
	end
	local delta = input.Position - dragStart
	main.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingWindow = false
	end
end)

local slidingSmooth = false

local function setSmoothFromX(x)
	local absX = bar.AbsolutePosition.X
	local width = math.max(bar.AbsoluteSize.X, 1)
	local t = math.clamp((x - absX) / width, 0, 1)
	smoothness = t
	fill.Size = UDim2.new(t, 0, 1, 0)
	handle.Position = UDim2.new(t, 0, 0.5, 0)
end

bar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		slidingSmooth = true
		setSmoothFromX(input.Position.X)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not slidingSmooth then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		setSmoothFromX(input.Position.X)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		slidingSmooth = false
	end
end)

local isOn = false
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function getNearestRoot()
	if not humanoidRootPart then
		return nil
	end
	local origin = humanoidRootPart.Position
	local nearest = nil
	local shortest = MAX_RANGE

	for _, other in Players:GetPlayers() do
		if other ~= player then
			local char = other.Character
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				local root = char:FindFirstChild("HumanoidRootPart")
				if hum and hum.Health > 0 and root then
					local dist = (origin - root.Position).Magnitude
					if dist < shortest then
						shortest = dist
						nearest = root
					end
				end
			end
		end
	end
	return nearest
end

local function setToggleVisual(on)
	if on then
		TweenService:Create(knob, tweenInfo, {
			Position = UDim2.fromOffset(35, 3),
			BackgroundColor3 = Color3.fromRGB(65, 230, 120),
		}):Play()
		TweenService:Create(track, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(28, 68, 45),
		}):Play()
		title.Text = "LOCK  •  ON"
		title.TextColor3 = Color3.fromRGB(100, 255, 150)
	else
		TweenService:Create(knob, tweenInfo, {
			Position = UDim2.fromOffset(3, 3),
			BackgroundColor3 = Color3.fromRGB(255, 75, 75),
		}):Play()
		TweenService:Create(track, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(40, 40, 48),
		}):Play()
		title.Text = "LOCK  •  OFF"
		title.TextColor3 = Color3.fromRGB(215, 215, 225)
	end
end

local function stopLock()
	pcall(function()
		RunService:UnbindFromRenderStep(BIND_NAME)
	end)
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	UserInputService.MouseIconEnabled = true
	if humanoid then
		humanoid.AutoRotate = savedAutoRotate
	end
	camera.CameraType = Enum.CameraType.Custom
end

local function startLock()
	RunService:BindToRenderStep(BIND_NAME, Enum.RenderPriority.Camera.Value + 1, function(dt)
		if not humanoidRootPart or not humanoidRootPart.Parent then
			return
		end

		UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		UserInputService.MouseIconEnabled = false
		camera.CameraType = Enum.CameraType.Scriptable

		if humanoid then
			humanoid.AutoRotate = false
		end

		local target = getNearestRoot()
		if not target then
			return
		end

		local rootPos = humanoidRootPart.Position
		local targetPos = target.Position
		local flat = Vector3.new(targetPos.X, rootPos.Y, targetPos.Z)
		local dir = flat - rootPos
		if dir.Magnitude < 0.05 then
			return
		end
		dir = dir.Unit

		local desiredCam = rootPos - dir * CAMERA_DISTANCE + Vector3.new(0, CAMERA_HEIGHT, 0)
		local desiredCFrame = CFrame.lookAt(desiredCam, targetPos)

		local speed = 2 + (1 - smoothness) * 22
		local alpha = 1 - math.exp(-speed * dt)
		camera.CFrame = camera.CFrame:Lerp(desiredCFrame, alpha)

		local face = CFrame.lookAt(rootPos, flat)
		humanoidRootPart.CFrame = CFrame.new(rootPos) * CFrame.Angles(0, select(2, face:ToEulerAnglesYXZ()), 0)
	end)
end

local function toggleLock()
	isOn = not isOn
	setToggleVisual(isOn)
	if isOn then
		startLock()
	else
		stopLock()
	end
end

track.MouseButton1Click:Connect(toggleLock)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Enum.KeyCode.C then
		toggleLock()
	end
end)

player.CharacterRemoving:Connect(function()
	if isOn then
		stopLock()
		task.defer(function()
			if isOn then
				startLock()
			end
		end)
	end
end)
print("wassupp big dogzz ty for using the script, press c for the keybind ^^")
