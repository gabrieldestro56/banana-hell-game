-- TopDownController.lua (LocalScript)

--// Services
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Constants = require(script.Parent.Constants)

--// References
local Banana  = workspace:WaitForChild("Banana")
local Camera  = workspace.CurrentCamera

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

Character:PivotTo(game.Workspace.PlayerHold.CFrame)
Character.HumanoidRootPart.Anchored = true

local Animator = require(script.Parent.SpriteAnimation).new({ DisplaySprite = Banana.SurfaceGui.Sprite })
Animator:LoadAnimation({
	Name = "Run",
	Frames = 3,
	SpriteImage = "rbxassetid://132841946621127",
	RectSize = Vector2.new(185, 374),
	FPS = 12,
})

Animator:LoadAnimation({
	Name = "Idle",
	Frames = 1,
	SpriteImage = "rbxassetid://81460388130687",
	RectSize = Vector2.new(185, 374),
	FPS = 12,
})


local isWalkingAnimationPlaying = false

--// State
local keysDown = {
	Forward  = false,
	Backward = false,
	Left     = false,
	Right    = false,
}

local keyMap = {
	[Enum.KeyCode.W]     = "Forward",
	[Enum.KeyCode.Up]    = "Forward",
	[Enum.KeyCode.S]     = "Backward",
	[Enum.KeyCode.Down]  = "Backward",
	[Enum.KeyCode.A]     = "Left",
	[Enum.KeyCode.Left]  = "Left",
	[Enum.KeyCode.D]     = "Right",
	[Enum.KeyCode.Right] = "Right",
}

--// Input handlers
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	local dir = keyMap[input.KeyCode]
	if dir then
		keysDown[dir] = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
	local dir = keyMap[input.KeyCode]
	if dir then
		keysDown[dir] = false
	end
end)

--// Main loop
RunService.RenderStepped:Connect(function(dt)
	-- 1) Movement

	if Constants.Game.PAUSE then
		return
	end

	local moveVec = Vector3.new()
	if keysDown.Forward  then moveVec += Vector3.new( 1, 0, 0) end
	if keysDown.Backward then moveVec += Vector3.new( -1, 0,  0) end
	if keysDown.Left     then moveVec += Vector3.new(  0, 0,  -1) end
	if keysDown.Right    then moveVec += Vector3.new( 0, 0,  1) end

	if moveVec.Magnitude > 0 then
		moveVec = moveVec.Unit * Constants.Player.MOVE_SPEED * dt
		-- preserve Y
		local newPos = Banana.Position + moveVec
		Banana.Position = Vector3.new(newPos.X, Banana.Position.Y, newPos.Z)
		Banana.Orientation = Vector3.new(0,90,0)
		
		if not isWalkingAnimationPlaying then
			Animator:PlayAnimation("Run", true)
			isWalkingAnimationPlaying = true
		end
		
	else
		Animator:PlayAnimation("Idle", true)
		isWalkingAnimationPlaying = false
	end

	-- 2) Camera follow
	local targetPos = Banana.Position
	local camPos    = targetPos + Vector3.new(0, Constants.Player.STUDS_ABOVE, 0)
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame      = CFrame.new(camPos, targetPos)
end)
