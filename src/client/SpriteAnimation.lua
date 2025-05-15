local Sprite = {}
Sprite.__index = Sprite

-- Plays the named animation. If isLooped is true, loops indefinitely.
function Sprite:PlayAnimation(name: string, isLooped: boolean)
	local anim = self.Animations[name]
	if not anim then
		warn("Sprite:PlayAnimation - animation '" .. tostring(name) .. "' not loaded.")
		return
	end

	-- Increment a unique ID to stop any previous playing animation
	self._currentAnimId = (self._currentAnimId or 0) + 1
	local thisId = self._currentAnimId

	-- Apply the static properties
	self.DisplaySprite.Image = anim.Image
	self.DisplaySprite.ImageRectSize = anim.RectSize

	-- Build frame offsets
	local offsets = {}
	if type(anim.Frames) == "table" then
		-- Frames is a table of Vector2 offsets
		for i, v in ipairs(anim.Frames) do
			offsets[i] = v
		end
	elseif type(anim.Frames) == "number" then
		-- Frames is a count, calculate offsets in a single row
		for i = 1, anim.Frames do
			offsets[i] = Vector2.new(
				(i - 1) * anim.RectSize.X,
				0
			)
		end
	else
		warn("Sprite:PlayAnimation - invalid Frames type for '" .. tostring(name) .. "'.")
		return
	end

	-- Coroutine to update frames
	task.spawn(function()
		repeat
			for _, offset in ipairs(offsets) do
				-- If a new animation started, exit
				if self._currentAnimId ~= thisId then
					return
				end
				self.DisplaySprite.ImageRectOffset = offset
				task.wait(1 / anim.FPS)
			end
		until not isLooped
	end)
end

-- Load an animation definition
function Sprite:LoadAnimation(params)
	assert(params.Name, "Sprite:LoadAnimation - Name is required")
	assert(params.Frames, "Sprite:LoadAnimation - Frames is required")
	assert(params.SpriteImage, "Sprite:LoadAnimation - SpriteImage is required")
	assert(params.RectSize, "Sprite:LoadAnimation - RectSize is required")

	self.Animations[params.Name] = {
		FPS = params.FPS or 20,
		Frames = params.Frames,
		Image = params.SpriteImage,
		RectSize = params.RectSize,
	}
end

-- Constructor: pass DisplaySprite = the ImageLabel to render onto
function Sprite.new(params)
	assert(params.DisplaySprite, "Sprite.new - DisplaySprite ImageLabel is required")

	local self = setmetatable({}, Sprite)
	self.DisplaySprite = params.DisplaySprite
	self.Animations = {}
	self._currentAnimId = 0
	return self
end

return Sprite
