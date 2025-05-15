local ConversationalAIAcceptanceService = game:GetService("ConversationalAIAcceptanceService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Constants = require(script.Parent.Constants)
local DamageHandler = require(script.Parent.DamageHandler)
local Dialog = require(script.Parent.Dialog)

local Player = game.Players.LocalPlayer
local CardContainer = Player.PlayerGui:WaitForChild("Cards"):WaitForChild("CardContainer")
local CardTemplate = CardContainer:WaitForChild("CardTemplate")

local Skills = {
    {
        {
            Handler = "Dash",
            Title = "Avanço Implacável",
            Description = "Torna-se inalvejável e realiza um avanço na direção do movimento",
        },
        {
            Handler = "Cataclism",
            Title = "Cataclisma",
            Description = "Elimina todos os inimigos não especiais visíveis",
        }
    },
     {
        {
            Handler = "Damage1",
            Title = "Balas Reforçadas",
            Description = "Aumenta o dano das suas balas em 50%",
        },
        {
            Handler = "Reload1",
            Title = "Carregador Melhorado",
            Description = "Aumenta a velocidade do seu gatilho em 25%",
        },
        {
            Handler = "BulletCount1",
            Title = "Espingarda",
            Description = "Dispara +2 projéteis porém perde 15% do dano.",
        }
    },
    {
        {
            Handler = "Damage2",
            Title = "Balas de Ouro",
            Description = "Aumenta o dano das suas balas em 50%",
        },
        {
            Handler = "Reload2",
            Title = "Dedos rápidos",
            Description = "Aumenta a velocidade do seu gatilho em 45%",
        },
        {
            Handler = "BulletCount2",
            Title = "Munição Caça-Pato",
            Description = "Dispara +3 projéteis porém perde 25% do dano.",
        }
    },
}

local function HandlePurchase(Handler: string)

    local Actions = {
        ["Dash"] = function()
            Constants.Player.Skill = "Dash"
        end,
        ["Cataclism"] = function()
            Constants.Player.Skill = "Cataclism"
        end,
        ["Damage1"] = function()
            Constants.Weapon.BULLET_DAMAGE *= 1.5
        end,
        ["Reload1"] = function()
            Constants.Weapon.BULLET_INTERVAL *= 0.75
        end,
        ["BulletCount1"] = function()
            Constants.Weapon.BULLET_COUNT += 2
            Constants.Weapon.BULLET_DAMAGE *= 0.85
        end,
        ["Damage2"] = function()
            Constants.Weapon.BULLET_DAMAGE *= 1.5
        end,
        ["Reload2"] = function()
            Constants.Weapon.BULLET_INTERVAL *= 0.45
        end,
        ["BulletCount2"] = function()
            Constants.Weapon.BULLET_COUNT += 3
            Constants.Weapon.BULLET_DAMAGE *= 0.75
        end,
    }

    if Actions[Handler] then
        Actions[Handler]()
    end

end

local function PromptCards(Cards, firstTime)
       
    TweenService:Create(CardTemplate, TweenInfo.new(0.25), {
        BackgroundTransparency = 0.5
    }):Play()

    if firstTime then
        task.spawn(function()
        Dialog.DoDialog({
            {Title = "Narrador", Text = "Olha só, você ficou mais forte!"},
            {Title = "Narrador", Text = "Conforme você mata inimigos, ganha experiência"},
            {Title = "Narrador", Text = "Escolha uma habilidade para lhe acompanhar pela jornada"},
            {Title = "Banana", Text = "💪🍌"},
        })
        end)
    end

    for _ , card in Cards do
        
        local new = CardTemplate:Clone() :: ImageLabel
        new.Parent = CardTemplate.Parent
        new.Title.Text = card.Title
        new.Description.Text = card.Description
        new.Visible = true

        local button = new:WaitForChild("Click") :: TextButton

        task.delay(2, function()
            button.MouseButton1Click:Connect(function()
            
            HandlePurchase(card.Handler)

            TweenService:Create(CardTemplate, TweenInfo.new(0.25), {
                BackgroundTransparency = 1
            }):Play()

            for _ , card in CardTemplate.Parent:GetChildren() do
                if card:IsA("ImageLabel") and card ~= CardTemplate then
                    card:Destroy()
                end
            end

            Constants.Game.PAUSE = false

        end)
        end)

        local ORIGINAL_SIZE = new.Size

        button.MouseEnter:Connect(function()
            TweenService:Create(new, TweenInfo.new(0.15), {
                Size = UDim2.fromOffset(ORIGINAL_SIZE.X.Offset * 1.2, ORIGINAL_SIZE.Y.Offset * 1.2)
            }):Play()
        end)

        button.MouseLeave:Connect(function()
            TweenService:Create(new, TweenInfo.new(0.15), {
                Size = ORIGINAL_SIZE
            }):Play()
        end)

    end

end

local function UseSkill(input, gp)

    if input.KeyCode ~= Enum.KeyCode.Space then
        return
    end

    if os.clock() - Constants.Player.SkillTimestamp <= 10 then
        return
    end

    if Constants.Player.Skill == "Dash" then
        Constants.Player.IS_INVULNERABLE = true
        Constants.Player.MOVE_SPEED *= 2
        task.delay(1, function()
            Constants.Player.MOVE_SPEED /= 2
            Constants.Player.IS_INVULNERABLE = false
        end)
    else
        for _ , enemy in game.Workspace:GetChildren() do
            local Handler = enemy:GetAttribute("Handler")
            if Handler and (Handler == "Monkey" or Handler == "Farmer") then
                local _, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(enemy.Position)
                if onScreen then
                    DamageHandler.TakeDamage(enemy, 9999)
                end
            end
        end
    end

    Constants.Player.SkillTimestamp = os.clock()
    
end

local function HandleEXPGain()

    local EXP = Constants.Player.EXP
    local Level = Constants.Player.Level
    local CurrentLevelCap = Constants.LevelCaps[Level]

    if not CurrentLevelCap then
        return
    end

    if EXP <= CurrentLevelCap then
        return
    end

    Constants.Player.EXP = 0
    PromptCards(Skills[Constants.Player.Level], Constants.Player.Level == 1)

    Constants.Player.Level += 1
    Constants.Game.PAUSE = true
    Constants:ChangeValue("Pause")

end

Constants:SubscribeToValue("EXP", HandleEXPGain)
UserInputService.InputBegan:Connect(UseSkill)