local TweenService = game:GetService("TweenService")
local module = {}

local player = game.Players.LocalPlayer
local Blackscreen = player.PlayerGui:WaitForChild("Transition"):WaitForChild("Frame")

function module.Transition(bool)
    TweenService:Create(Blackscreen, TweenInfo.new(0.25), {
        BackgroundTransparency = bool and 0 or 1
    }):Play()
end

return module 