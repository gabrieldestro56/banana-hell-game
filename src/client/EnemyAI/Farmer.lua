local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local Constants = require(player.PlayerScripts.Client.Constants)
local DamageHandler = require(player.PlayerScripts.Client.DamageHandler)

local FarmerModule = {
	Cache = {},
	Animations = {},
}

function FarmerModule.ProcessDeath(Farmer)
	Farmer:SetAttribute("isDead", true)

	TweenService:Create(Farmer.SurfaceGui.Sprite, TweenInfo.new(0.25), {
		ImageColor3 = Color3.fromRGB(0,0,0)
	}):Play()

	TweenService:Create(Farmer, TweenInfo.new(0.5), {
		Size = Vector3.new(0,0,0)
	})

	task.delay(0.5, function()
		Farmer:Destroy()
	end)

	Constants.Game.FARMERS_KILLED += 1
	Constants:ChangeValue("FarmersKilled")

end

function FarmerModule.SetTouchEvents(Farmer)
	Farmer.Touched:Connect(function(hitPart)

		if hitPart.Name == Constants.Weapon.BULLET_NAME then
			DamageHandler.TakeDamage(Farmer)
			return
		end

	end)
end

function FarmerModule.AddNew(Farmer)
	FarmerModule.SetTouchEvents(Farmer)
	Farmer:SetAttribute("Health", Constants.Enemy.Farmer.HEALTH)
	table.insert(FarmerModule.Cache, Farmer)
end

function FarmerModule.ProcessMovement(dt)
	if Constants.Game.PAUSE then
		return
	end
	for _ , Farmer in FarmerModule.Cache do
		task.spawn(function()
			if Farmer:GetAttribute("isDead") then return end
			if not Farmer.Parent then return end
			local toPlayer = Constants.Player.Banana.Position - Farmer.Position
			local flatDir  = Vector3.new(toPlayer.X, 0, toPlayer.Z)
			if flatDir.Magnitude < 0.1 then return end

			local moveDelta = flatDir.Unit * Constants.Enemy.Farmer.MOVE_SPEED * dt
			local newPos    = Farmer.Position + moveDelta
			Farmer.Position     = CFrame.new(newPos, newPos + flatDir).Position

			if (Farmer.Position - Constants.Player.Banana.Position).Magnitude <= 2 then
				DamageHandler.PlayerTakeDamage()
			end

		end)
	end
	
end

RunService.RenderStepped:Connect(FarmerModule.ProcessMovement)

return FarmerModule
