local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local Constants = require(script.Parent.Constants)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local UI = Player.PlayerGui
local Menu = UI:WaitForChild("Menu")
local Gameplay = UI:WaitForChild("Gameplay")

local HeartDisplay = Gameplay:WaitForChild("HeartContainer")
local ScoreDisplay = Gameplay:WaitForChild("ScoreContainer") 

local Gameover = UI:WaitForChild("Gameover")
local DeathContainer = Gameover:WaitForChild("Container")

local DeathImage = DeathContainer:WaitForChild("Death")
local Title = DeathContainer:WaitForChild("Title")
local Score = DeathContainer:WaitForChild("Score")

--// Logica do coração
local function Death(isVictory)
    
    Constants.Game.PAUSE = true
    Gameplay.Enabled = false

    DeathImage.Visible = true
    if isVictory then
        DeathImage.Image = "rbxassetid://127430196461386"
    else
        DeathImage.Image = "rbxassetid://132846743252432"
    end

    task.wait(1)

    TweenService:Create(DeathContainer, TweenInfo.new(0.25), {
        BackgroundTransparency = 0
    }):Play()


    Title.Text = isVictory and "YOU WON!" or "GAME OVER"
    Title.Visible = true
    Score.Visible = true

    local Temp = Instance.new("NumberValue")

    Temp.Changed:Connect(function()
        Score.Text = string.format("SCORE: %06d", Constants.Player.Score)
    end)

    TweenService:Create(Temp, TweenInfo.new(0.5), {
        Value = Constants.Player.Score,
    }):Play()

    task.wait(3)

    Constants.Player.Level = 1
    Constants.Player.Health = 3
    Constants.Player.Score = 0
    Constants.Player.EXP = 0
    Constants.Player.Skill = "None"
    Constants.Spawn.CAN_SPAWN = false
    Constants.Player.IN_GAME = false

    Constants.Game.HAS_DEFEATED_MONKEY_KING = false
    
    Constants.Game.MONKEYS_KILLED = 0
    Constants.Game.FARMERS_KILLED = 0

    Constants.Game.CURRENT_BOSS = "None"
    Constants:ChangeValue("BossFight")

    Constants.Weapon = {
        BULLET_SPEED = 200,
        BULLET_DAMAGE = 10,
        BULLET_PENETRATION = 1,
        BULLET_LIFETIME = 5,
        BULLET_NAME = "Bullet",
        BULLET_KNOCKBACK = 50,
        BULLET_INTERVAL = 0.25,
        BULLET_COUNT = 1,
        LAST_SHOT = os.clock(),
    }

    for _ , part in game.Workspace:GetChildren() do
        if part:GetAttribute("EnemySetup") then
            part:Destroy()
        end
    end

    DeathImage.Visible = false
    Title.Visible = false
    Score.Visible = false
    DeathContainer.BackgroundTransparency = 1

    Menu.Enabled = true

end

local function ClearHearts()
    for _ , heart in HeartDisplay:GetChildren() do
        if heart ~= HeartDisplay.HeartSample and heart:IsA("ImageLabel") then
            heart:Destroy()
        end
    end
end

local function CreateHearts(hearts: number)
    for _ = 1, hearts do
        local heart = HeartDisplay.HeartSample:Clone()
        heart.Parent = HeartDisplay
        heart.Visible = true
        heart.Name = "Heart"
    end
end

Constants:SubscribeToValue("Health", function()

    ClearHearts()
    if Constants.Player.Health > 0 then
        CreateHearts(Constants.Player.Health)
    end

    if Constants.Player.Health <= 0 then
        Death()
    end

end)

--// Lógica do score
local Temp = Instance.new("NumberValue")

Temp.Changed:Connect(function()
    ScoreDisplay.TextLabel.Text = string.format("%06d", Temp.Value)
end)

Constants:SubscribeToValue("Score", function()

    TweenService:Create(Temp, TweenInfo.new(0.1), {
        Value = Constants.Player.Score
    }):Play()

end)

local BossFightUI = Gameplay:WaitForChild("BossHealthBackground")
local Healthbar = BossFightUI:WaitForChild("Health")

Constants:SubscribeToValue("BossFight", function()

    if Constants.Game.CURRENT_BOSS == "None" then
        BossFightUI.Visible = false
        return
    end

    BossFightUI.Visible = true
    Healthbar.Size = UDim2.fromScale(1, 1)
    Healthbar.Parent.Title.Text = Constants.Game.CURRENT_BOSS.Title

    local model = Constants.Game.CURRENT_BOSS.Model
    model:GetAttributeChangedSignal("Health"):Connect(function()
        if Constants.Game.CURRENT_BOSS.Model == model then 
            TweenService:Create(Healthbar, TweenInfo.new(0.1), {
                Size = UDim2.fromScale( model:GetAttribute("Health") / Constants.Boss[model.Name].HEALTH , 1)
            }):Play()
            if model:GetAttribute("Health") <= 0 then
                BossFightUI.Visible = false 
            end
        end

    end)

end)

Constants:SubscribeToValue("Victory", function()
    if Constants.Game.IS_VICTORY then
        Death(true)
    end
end)
