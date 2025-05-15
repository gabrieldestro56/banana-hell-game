local Constants = require(script.Parent.Constants)

Constants:SubscribeToValue("MonkeysKilled", function()

    if Constants.Game.MONKEYS_KILLED < 35 then
        return
    end
    
    if game.Workspace:FindFirstChild("KingMonkey") then
        return
    end

    if Constants.Game.HAS_DEFEATED_MONKEY_KING then
        return
    end

    --// Spawna o rei macaco
    local King = game.ReplicatedStorage:WaitForChild("KingMonkey"):Clone()
    King.Parent = workspace

end)

Constants:SubscribeToValue("FarmersKilled", function()

    if Constants.Game.FARMERS_KILLED < 30 then
        return
    end

    if not Constants.Game.HAS_DEFEATED_MONKEY_KING then
        return
    end

    if game.Workspace:FindFirstChild("FarmLeader") then
        return
    end

    local FarmerLeader = game.ReplicatedStorage:WaitForChild("FarmLeader"):Clone()
    FarmerLeader.Parent = workspace

end)

