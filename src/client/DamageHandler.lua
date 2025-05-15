local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Constants = require(script.Parent.Constants)
local module = {}

local DisplaySample = ReplicatedStorage.Damage

local function DamageDisplay(enemy, damage)
    
    local Sample = DisplaySample:Clone()
    Sample.DamageText.Text = damage
    Sample.Parent = enemy

    TweenService:Create(Sample, TweenInfo.new(0.1), {
        ExtentsOffset = Vector3.new(0,0,-5)
    }):Play()
    
    task.delay(0.25, function()
        TweenService:Create(Sample, TweenInfo.new(0.25), {
            Size = UDim2.fromScale(0, 0),
        }):Play()
        task.wait(0.25)
        Sample:Destroy()
    end)

end

local function DangerZoneFlick(Dangerzone)
    task.spawn(function()
        while Dangerzone.Parent do
            TweenService:Create(Dangerzone.Decal, TweenInfo.new(0.1), {
                Color3 = Color3.fromRGB(0,0,0)
            }):Play()
            task.wait(0.1)
            if Dangerzone.Parent then
                TweenService:Create(Dangerzone.Decal, TweenInfo.new(0.1), {
                    Color3 = Color3.fromRGB(255,255,255)
                }):Play()
            end
            task.wait(0.1)
        end
    end)
end

local function DamageWithinDangerzone(Dangerzone)
    
    local Parts = Dangerzone:GetTouchingParts()
    for _ , Part in Parts do
        if Part.Name == "Banana" then
            module.PlayerTakeDamage()
        end
    end

end

function module.CreateDangerZone(Parameters)
    
    local Danger = ReplicatedStorage.Dangerzone:Clone()
    Danger.CFrame = Parameters.CFrame
    Danger.Size = Vector3.new(Parameters.Size, 3, Parameters.Size)
    Danger.Parent = workspace.Dangerzones
    
    DangerZoneFlick(Danger)

    task.delay(Parameters.Duration, function()

        DamageWithinDangerzone(Danger)

        TweenService:Create(Danger, TweenInfo.new(0.25), {
            Size = Vector3.new(Parameters.Size * 1.2, 3, Parameters.Size * 1.2),
        }):Play()

        if Danger:FindFirstChild("Decal") then
            TweenService:Create(Danger.Decal, TweenInfo.new(0.25), {
                Transparency = 1
            }):Play()
        end

        task.wait(0.25)

        Danger:Destroy()

    end)

end

function module.CreateLineOfDanger(Parameters)
    local Start = Parameters.Start
    local End = Parameters.End
    local Size = Parameters.Size
    local Duration = Parameters.Duration

    local DirectionVector = (End.Position - Start.Position)
    local Magnitude = DirectionVector.Magnitude
    local DirectionUnit = DirectionVector.Unit

    local Count = math.floor(Magnitude / Size)

    for i = 0, Count do
        local Position = Start.Position + DirectionUnit * (i * Size)
        local CFrameAtPosition = CFrame.new(Position)

        module.CreateDangerZone({
            CFrame = CFrameAtPosition,
            Size = Size,
            Duration = Duration
        })
    end
end

function module.TakeDamage(enemy, custom)
    
    local Damage = custom or Constants.Weapon.BULLET_DAMAGE
    local Health = enemy:GetAttribute("Health")
    local Handler = enemy:GetAttribute("Handler")
    local FinalHealth = Health - Damage

    enemy:SetAttribute("Health", FinalHealth)
    if FinalHealth <= 0 then
        require(script.Parent.EnemyAI:FindFirstChild(Handler)).ProcessDeath(enemy)
        local EXP = Constants.EXP[Handler]
        Constants.Player.EXP += EXP
        Constants:ChangeValue("EXP")
    end

    DamageDisplay(enemy, Damage)

    if Constants.Enemy[Handler] then
        Constants.Player.Score += Constants.Enemy[Handler].SCORE
    elseif Constants.Boss[Handler] then
        Constants.Player.Score += Constants.Boss[Handler].SCORE
    end

    Constants:ChangeValue("Score")

end

function module.PlayerTakeDamage()
    
    if Constants.Player.IS_INVULNERABLE then
        return
    end

    if Constants.Game.PAUSE then
        return
    end

    Constants.Player.IS_INVULNERABLE = true
    Constants.Player.Health -= 1

    Constants:ChangeValue("Health")
    Constants:ChangeValue("Invulnerability")

    task.delay(2, function()
        Constants.Player.IS_INVULNERABLE = false
        Constants:ChangeValue("Invulnerability")
    end)

end

return module