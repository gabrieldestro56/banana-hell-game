local module = {}

local Player = game.Players.LocalPlayer 
local DialogFrame = Player.PlayerGui.Dialog:WaitForChild("Background")

function module.Typewriter(textLabel, text, speed)
    textLabel.Text = text
    textLabel.MaxVisibleGraphemes = 0
    local total = utf8.len(text)
    for i = 1, total do
        textLabel.MaxVisibleGraphemes = i
        task.wait(speed)
    end
end

function module.DoDialog(Dialog: {})
    
    DialogFrame.Visible = true

    for _, Speech in Dialog do
        DialogFrame.Title.Text = Speech.Title
        module.Typewriter(DialogFrame.Speech, Speech.Text, 0.05)
        task.wait(1)
    end

    DialogFrame.Visible = false 

end

return module 