local Constants = require(script.Parent.Constants)
local Dialog = require(script.Parent.Dialog)
local Transition = require(script.Parent.Transition)
local Player = game.Players.LocalPlayer
local Menu = Player.PlayerGui:WaitForChild("Menu")
local Gameplay = Player.PlayerGui:WaitForChild("Gameplay")
local JogarButton = Menu:WaitForChild("Jogar")

JogarButton.MouseButton1Click:Connect(function()
    if Constants.Player.IN_GAME then
        return
    end
    
    Constants.Player.IN_GAME = true
    Transition.Transition(true)
    task.wait(0.3)
    Dialog.DoDialog(
{        {
            Title = "Narrador",
            Text = "Há muito tempo atrás...",
        },
        {
            Title = "Narrador",
            Text = "Você era uma banana feliz em sua bananeira...",
        },
        {
            Title = 'Narrador',
            Text = "Até que um dia...",
        },
        {
            Title = "Narrador",
            Text = "Uma ventania forte te jogou pra fora da árvore, caindo na cabeça de um fazendeiro.",
        },
        {
            Title = "Narrador",
            Text = "Essa confusão toda chamou uma atenção indejesada..."
        }
    }
    )

    Menu.Enabled = false
    Gameplay.Enabled = true

    Transition.Transition(false)

    Dialog.DoDialog({
        {Title = "Instruções", Text = "Aperte WASD ou Setinhas para se mover"},
        {Title = "Instruções", Text = "Quando desbloquear uma habilidade, aperte espaço para usá-la."},
        {Title = "Instruções", Text = "Clique com o botão do mouse esquerdo para atirar."},
        {Title = "Banana", Text = "🍌👍"},
    })

    Constants.Spawn.CAN_SPAWN = true

end)


