local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local SpriteAnimation = require(StarterPlayer.StarterPlayerScripts.Client.SpriteAnimation)
local Constants = require(player.PlayerScripts.Client.Constants)
local DamageHandler = require(player.PlayerScripts.Client.DamageHandler)

local Monkey = {
	Cache = {},
	Animations = {},
}
local TouchedEvents = {}

function Monkey.ProcessDeath(MonkeyEnemy)

	MonkeyEnemy:SetAttribute("isDead", true)
	if TouchedEvents[MonkeyEnemy] then
		TouchedEvents[MonkeyEnemy]:Disconnect()
	end

	TweenService:Create(MonkeyEnemy.SurfaceGui.Sprite, TweenInfo.new(0.25), {
		ImageColor3 = Color3.fromRGB(0,0,0)
	}):Play()

	TweenService:Create(MonkeyEnemy, TweenInfo.new(0.5), {
		Size = Vector3.new(0,0,0)
	})

	task.delay(0.5, function()
		MonkeyEnemy:Destroy()
	end)

	Constants.Game.MONKEYS_KILLED += 1
	Constants:ChangeValue("MonkeysKilled")

end

function Monkey.SetTouchEvents(MonkeyEnemy)
	return MonkeyEnemy.Touched:Connect(function(hitPart)

		if hitPart.Name == Constants.Weapon.BULLET_NAME then
			DamageHandler.TakeDamage(MonkeyEnemy)
			return
		end

	end)
end

function Monkey.AddNew(MonkeyEnemy)
	TouchedEvents[MonkeyEnemy] = Monkey.SetTouchEvents(MonkeyEnemy)
	MonkeyEnemy:SetAttribute("Health", Constants.Enemy.Monkey.HEALTH)
	table.insert(Monkey.Cache, MonkeyEnemy)
	
	local Animator = SpriteAnimation.new({DisplaySprite = MonkeyEnemy.SurfaceGui.Sprite})
	Animator:LoadAnimation({
		Name = "Run",
		Frames = 3,
		SpriteImage = "rbxassetid://129338991607780",
		RectSize = Vector2.new(323, 513),
		FPS = 12
	})

	Animator:PlayAnimation("Run", true)

end

function Monkey.ProcessMovement(dt)
	if Constants.Game.PAUSE then
		return
	end
	for _ , MonkeyEnemy in Monkey.Cache do
		task.spawn(function()
			if MonkeyEnemy:GetAttribute("isDead") then return end
			if not MonkeyEnemy.Parent then return end
			local toPlayer = Constants.Player.Banana.Position - MonkeyEnemy.Position
			local flatDir  = Vector3.new(toPlayer.X, 0, toPlayer.Z)
			if flatDir.Magnitude < 0.1 then return end

			local moveDelta = flatDir.Unit * Constants.Enemy.Monkey.MOVE_SPEED * dt
			local newPos    = MonkeyEnemy.Position + moveDelta
			MonkeyEnemy.Position     = CFrame.new(newPos, newPos + flatDir).Position

			if (MonkeyEnemy.Position - Constants.Player.Banana.Position).Magnitude <= 2 then
				DamageHandler.PlayerTakeDamage()
			end

		end)
	end
	
end

RunService.RenderStepped:Connect(Monkey.ProcessMovement)

return Monkey
