local Monkey = require(script.Monkey)
local function SetUpEnemy(part)

	if part:GetAttribute("EnemySetup") then
		return
	end
	
	if part:GetAttribute("Handler") then
		part:SetAttribute("EnemySetup", true)
		require(script:FindFirstChild(part:GetAttribute("Handler"))).AddNew(part)
	end
	
end

--// Hook existing + future Monkeys
workspace.DescendantAdded:Connect(SetUpEnemy)
for _, obj in ipairs(workspace:GetDescendants()) do
	SetUpEnemy(obj)
end
