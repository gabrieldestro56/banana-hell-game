-- EnemySpawner.lua (LocalScript in StarterPlayer ▶ StarterPlayerScripts)

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(script.Parent.Constants)

--// References
local banana      = workspace:WaitForChild("Banana")
local camera      = workspace.CurrentCamera

--// Helpers

local function countMonkeys()
	local n = 0
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj.Name:match("^Monkey") then
			n = n + 1
		end
	end
	return n
end

local function findOffscreenSpawnPos()
	local angle, spawnPos, screenPos, onScreen
	repeat
		angle = math.random() * 2 * math.pi
		spawnPos = banana.Position
			+ Vector3.new(math.cos(angle), 0, math.sin(angle)) * Constants.Spawn.SPAWN_RADIUS
		spawnPos = Vector3.new(spawnPos.X, banana.Position.Y, spawnPos.Z)
		screenPos, onScreen = camera:WorldToViewportPoint(spawnPos)
	until not onScreen
	return spawnPos
end

local function spawnMonkey()
	local spawnPos = findOffscreenSpawnPos()
	local enemyTpl = ReplicatedStorage:FindFirstChild(Constants.Spawn.CURRENT_ENEMY)
	local clone = enemyTpl:Clone()
	clone.Name = "Monkey"..tostring(tick()):gsub("%.","")
	clone.Parent = workspace
	clone.CFrame = CFrame.new(spawnPos)
end

task.spawn(function()
	while true do
		if not Constants.Spawn.CAN_SPAWN then
			task.wait(1)
			continue
		end
		if countMonkeys() < Constants.Spawn.MAX_ENEMIES then
			spawnMonkey()
		end
		task.wait(Constants.Spawn.SPAWN_INTERVAL)
	end
end)
