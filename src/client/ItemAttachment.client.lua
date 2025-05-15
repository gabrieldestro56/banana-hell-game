-- ItemAttachmentController.lua (LocalScript)

--// Services
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")

--// References
local Camera   = workspace.CurrentCamera
local Banana   = workspace:WaitForChild("Banana")
local Item     = workspace:WaitForChild("Item")

--// Precompute your Item’s starting offset from the Banana
-- so it orbits at the same radius & height you’ve already placed it in Studio.
local initialOffset = Item.Position - Banana.Position
local radius        = Vector3.new(initialOffset.X, 0, initialOffset.Z).Magnitude
local heightOffset  = initialOffset.Y

--// Every frame: project mouse onto Banana’s plane, then
--   1) set Item.Position = Banana.Position + directionXZ * radius + Y‐offset
--   2) orient Item so it “looks at” that same projected mouse point
RunService.RenderStepped:Connect(function()
	-- 1) build a world‐space ray from the camera through the mouse
	local mouseXY = UserInputService:GetMouseLocation()
	local ray     = Camera:ScreenPointToRay(mouseXY.X, mouseXY.Y)

	-- 2) intersect that ray with the horizontal plane at Banana.Y
	local planeY    = Banana.Position.Y
	local origin    = ray.Origin
	local direction = ray.Direction
	local t         = (planeY - origin.Y) / direction.Y
	local hitPos    = origin + direction * t   -- world point under your mouse

	-- 3) compute the X/Z direction from Banana → hitPos
	local dirXZ = Vector3.new(hitPos.X - Banana.Position.X, 0, hitPos.Z - Banana.Position.Z)
	if dirXZ.Magnitude < 0.001 then 
		return 
	end
	local unitDir = dirXZ.Unit

	-- 4) place Item at the same radius & height around Banana
	local itemPos = Banana.Position 
		+ Vector3.new(unitDir.X * radius, heightOffset, unitDir.Z * radius)

	-- 5) orient Item so it “looks” at the mouse‐projected point
	--    (we match the Y to the item’s Y so it only Y‐rotates)
	local lookAt   = Vector3.new(hitPos.X, itemPos.Y, hitPos.Z)
	Item.CFrame   = CFrame.new(itemPos, lookAt)
end)
