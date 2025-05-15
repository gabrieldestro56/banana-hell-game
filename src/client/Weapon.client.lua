--// Variables
local Banana             = workspace:WaitForChild("Banana")
local Player             = game.Players.LocalPlayer
local Mouse              = Player:GetMouse()
local UserInputService   = game:GetService("UserInputService")
local Debris             = game:GetService("Debris")
local Constants = require(script.Parent.Constants)

local BulletTemplate     = game.ReplicatedStorage:WaitForChild("Bullet")

--// Functions
local function CreateBulletObject()
	
	local newB = BulletTemplate:Clone()
	newB.Anchored    = false
	newB.CanCollide  = false
	newB.CFrame      = workspace.Item.CFrame
	newB.Parent      = workspace
	return newB
	
end

local function FireWeapon(input, gameProcessed)
	
	if gameProcessed then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
		return
	end

	--// Cooldown do tiro
	if Constants.Weapon.LAST_SHOT and os.clock() - Constants.Weapon.LAST_SHOT <= Constants.Weapon.BULLET_INTERVAL then
		return
	end 
	
	Constants.Weapon.LAST_SHOT = os.clock()

	for i = 1, Constants.Weapon.BULLET_COUNT do
		local bullet = CreateBulletObject()
		local startPos = bullet.Position

		local mouseHit = Mouse.Hit.Position
		local targetPos = Vector3.new(
			mouseHit.X + (if Constants.Weapon.BULLET_COUNT ~= 1 then math.random(-2, 2) else 0),
			startPos.Y,
			mouseHit.Z + (if Constants.Weapon.BULLET_COUNT ~= 1 then math.random(-2, 2) else 0)
		)

		local dir = (targetPos - startPos).Unit

		local bv = Instance.new("BodyVelocity")
		bv.MaxForce    = Vector3.new(1e5, 1e5, 1e5)
		bv.Velocity    = dir * Constants.Weapon.BULLET_SPEED
		bv.Parent      = bullet

		Debris:AddItem(bullet, Constants.Weapon.BULLET_LIFETIME)
	end

end

--// Hookup
UserInputService.InputBegan:Connect(FireWeapon)
