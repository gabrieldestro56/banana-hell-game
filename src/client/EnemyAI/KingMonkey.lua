local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local Dialog = require(StarterPlayer.StarterPlayerScripts.Client.Dialog)
local Constants = require(player.PlayerScripts.Client.Constants)
local DamageHandler = require(player.PlayerScripts.Client.DamageHandler)

local KingMonkey = {

	Cache = {},
	Animations = {},
    LastLeap = os.clock(),
    isLeaping = false,
    isDead = false,

}

function KingMonkey.ProcessDeath(MonkeyEnemy)

    if KingMonkey.isDead then
        return
    end

    Constants.Game.PAUSE = true
    KingMonkey.isDead = true

    Dialog.DoDialog({
        {
            Title = "Rei Macaco",
            Text = "Não é possivel..."
        },
        {
            Title = "Rei Macaco",
            Text = "Eu voltarei... e me vingarei..."
        }
    })

    TweenService:Create(MonkeyEnemy.SurfaceGui.Sprite, TweenInfo.new(0.25), {
		ImageColor3 = Color3.fromRGB(0,0,0)
	}):Play()

	TweenService:Create(MonkeyEnemy, TweenInfo.new(0.5), {
		Size = Vector3.new(0,0,0)
	})

	task.delay(0.5, function()
		MonkeyEnemy:Destroy()
	end)

    for _ , enemy in game.Workspace:GetChildren() do
        local Handler = enemy:GetAttribute("Handler")
        if Handler and (Handler == "Monkey" or Handler == "Farmer") then
            DamageHandler.TakeDamage(enemy, 9999)
        end
    end

    Constants.Game.PAUSE = false
    Constants.Spawn.CURRENT_ENEMY = "Farmer"
    Constants.Game.HAS_DEFEATED_MONKEY_KING = true

end

function KingMonkey.SetTouchEvents(MonkeyEnemy)
	MonkeyEnemy.Touched:Connect(function(hitPart)

		if hitPart.Name == Constants.Weapon.BULLET_NAME then
			DamageHandler.TakeDamage(MonkeyEnemy)
			return
		end

	end)
end

function KingMonkey.DoDialog()
    Dialog.DoDialog({
        {
            Title = "????",
            Text = "EI VOCÊ!",
        },
        {
            Title = "Banana",
            Text = "🍌?",
        },
        {
            Title = "????",
            Text = "Sim, você mesmo, você se acha durão né?",
        },
        {
            Title = "Rei Macaco",
            Text = "Vou te dar uma surra pra você aprender.",
        },
        {
            Title = "Banana",
            Text = "🍌😨",
        },
    })
end

function KingMonkey.AddNew(MonkeyEnemy)

    Constants.Game.PAUSE = true
    Constants.Spawn.CAN_SPAWN = false

	KingMonkey.DoDialog()

    Constants.Game.PAUSE = false
    Constants.Spawn.CAN_SPAWN = true
    
    Constants.Game.CURRENT_BOSS = {Model = MonkeyEnemy, Title = "REI MACACO"}
    Constants:ChangeValue("BossFight")
    
    KingMonkey.SetTouchEvents(MonkeyEnemy)

	MonkeyEnemy:SetAttribute("Health", Constants.Boss.KingMonkey.HEALTH)
	table.insert(KingMonkey.Cache, MonkeyEnemy)

end

function KingMonkey.ProcessMovement(dt)
    if Constants.Game.PAUSE then
		return
	end
    if KingMonkey.isDead then
        return
    end
	for _ , King in KingMonkey.Cache do
		task.spawn(function()

            King.SurfaceGui.Sprite.Image = "rbxassetid://129755756476163"

            if os.clock() - KingMonkey.LastLeap < Constants.Boss.KingMonkey.LEAP_INTERVAL then
                return
            end

            if KingMonkey.isLeaping then
                return
            end

            KingMonkey.LastLeap = os.clock()

            local PlayerPosition = Constants.Player.Banana.CFrame
            
            DamageHandler.CreateDangerZone({
                CFrame = PlayerPosition,
                Size = Constants.Boss.KingMonkey.LEAP_ATTACK_SIZE,
                Duration = Constants.Boss.KingMonkey.LEAP_DURATION,
            })
            
            local CurrentCFrame = King.CFrame
            local OriginalSize = King.Size
            
            TweenService:Create(King, TweenInfo.new(Constants.Boss.KingMonkey.LEAP_DURATION / 2), {
                CFrame = CurrentCFrame:Lerp(PlayerPosition, 0.5),
                Size = Vector3.new(OriginalSize.X * 1.5, OriginalSize.Y, OriginalSize.Z * 1.5)
            }):Play()

            task.wait((Constants.Boss.KingMonkey.LEAP_DURATION / 2) - 0.5)

            King.SurfaceGui.Sprite.Image = "rbxassetid://82095231798715"

            TweenService:Create(King, TweenInfo.new(Constants.Boss.KingMonkey.LEAP_DURATION / 2), {
                CFrame = PlayerPosition,
                Size = OriginalSize
            }):Play()

            task.wait(Constants.Boss.KingMonkey.LEAP_DURATION / 2)

            KingMonkey.LastLeap = os.clock()
            KingMonkey.isLeaping = false

		end)
	end
end

RunService.RenderStepped:Connect(KingMonkey.ProcessMovement)

return KingMonkey
