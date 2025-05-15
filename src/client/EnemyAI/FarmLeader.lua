local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local Dialog = require(StarterPlayer.StarterPlayerScripts.Client.Dialog)
local Constants = require(player.PlayerScripts.Client.Constants)
local DamageHandler = require(player.PlayerScripts.Client.DamageHandler)

local FarmLeader = {

	Cache = {},
	Animations = {},
    LastShot = os.clock(),
    LastBomb = os.clock(),
    isDead = false,
    DamageRestrict = os.clock()

}

function FarmLeader.ProcessDeath(MonkeyEnemy)
    if FarmLeader.isDead then
        return
    end
	Constants.Game.PAUSE = true
    FarmLeader.isDead = true
    Dialog.DoDialog({
        {
            Title = "Senhor Fazendeiro",
            Text = "Está bem..."
        },
        {
            Title = "Senhor Fazendeiro",
            Text = "A fazenda agora é sua, bananinha..."
        },
        {
            Title = "Banana",
            Text = "🍌🎉"
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

    Constants.Spawn.CURRENT_ENEMY = "Farmer"

    Constants.Game.IS_VICTORY = true
    Constants:ChangeValue("Victory")

end

function FarmLeader.SetTouchEvents(MonkeyEnemy)

    MonkeyEnemy.ClickDetector.MouseClick:Connect(function()
        for _ = 1, Constants.Weapon.BULLET_COUNT do
            DamageHandler.TakeDamage(MonkeyEnemy)
        end
    end)
    local connection = MonkeyEnemy.Touched:Connect(function(hitPart)
		if hitPart.Name == Constants.Weapon.BULLET_NAME then
			DamageHandler.TakeDamage(MonkeyEnemy)
			return
		end
	end)
end

function FarmLeader.DoDialog()
    Dialog.DoDialog({
        {
            Title = "????",
            Text = "Parceiro...",
        },
        {
            Title = "Banana",
            Text = "🍌?",
        },
        {
            Title = "????",
            Text = "Você já abusou demais deste campo, hora de você enfrentar a justiça.",
        },
        {
            Title = "Senhor Fazendeiro",
            Text = "Prepare-se para o seu fim!",
        },
        {
            Title = "Banana",
            Text = "🍌😨",
        },
    })
end

function FarmLeader.AddNew(FarmBoss)

    Constants.Game.PAUSE = true
    Constants.Spawn.CAN_SPAWN = false

	FarmLeader.DoDialog()

    Constants.Game.PAUSE = false
    Constants.Spawn.CAN_SPAWN = true
    
    Constants.Game.CURRENT_BOSS = {Model = FarmBoss, Title = "SENHOR FAZENDEIRO"}
    Constants:ChangeValue("BossFight")
    FarmLeader.SetTouchEvents(FarmBoss)

	FarmBoss:SetAttribute("Health", Constants.Boss.FarmLeader.HEALTH)
	table.insert(FarmLeader.Cache, FarmBoss)

end

function FarmLeader.ProcessMovement(dt)
    if Constants.Game.PAUSE then
        return
    end
	for _ , Boss in FarmLeader.Cache do
        
		task.spawn(function()
            --// Se movimenta até o jogador 
            if not Boss.Parent then return end
			local toPlayer = Constants.Player.Banana.Position - Boss.Position
			local flatDir  = Vector3.new(toPlayer.X, 0, toPlayer.Z)
			if flatDir.Magnitude < 0.1 then return end

			local moveDelta = flatDir.Unit * Constants.Boss.FarmLeader.MOVE_SPEED * dt
			local newPos = Boss.Position + moveDelta
			Boss.Position = CFrame.new(newPos, newPos + flatDir).Position

            --//Toma dano de tiros
            if os.clock() - FarmLeader.DamageRestrict > 0.02 then
                local overlap = OverlapParams.new()
                overlap.FilterDescendantsInstances = {workspace.Dangerzones}
                overlap.FilterType = Enum.RaycastFilterType.Exclude
                local parts = workspace:GetPartsInPart(Boss, overlap)
                for _ , part in parts do
                    if part.Name == "Bullet" then
                        DamageHandler.TakeDamage(Boss)
                    end
                end
            end

            --// Tiro
            if os.clock() - FarmLeader.LastShot > Constants.Boss.FarmLeader.SHOOT_INTERVAL then

                local Start = Boss.CFrame
                local Target = Constants.Player.Banana.CFrame

                local direction = (Target.Position - Start.Position).Unit
                local distancePastPlayer = 50
                local extendedEndPosition = Target.Position + direction * distancePastPlayer
                local extendedEnd = CFrame.new(extendedEndPosition)

                DamageHandler.CreateLineOfDanger({
                    Start = Start,
                    End = extendedEnd,
                    Size = Constants.Boss.FarmLeader.BULLET_SIZE,
                    Duration = 1,
                })
                FarmLeader.LastShot = os.clock()
            end
		end)
	end
end

RunService.RenderStepped:Connect(FarmLeader.ProcessMovement)

return FarmLeader
