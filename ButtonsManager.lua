-- © 2012 Blerdo (http://blerdo.com)
-- 
-- Code written by Piotr Machowski
-- 
-----------------------------------

local gButtonsManager = {}

gButtonsManager.new = function(_imgName, _width, _height, _onRelease, _sound, _xPos, _yPos) -- _xPos, _yPos and _onRelease may be nil

	-- field declarations
	local active -- boolean
	local default
	local tap
	local set
	local sound
	local imgName = _imgName

	-- private function declarations
	local init --constructor
	local buttonHandler
	local onRelease

	local m = display.newGroup()
	m.data = {} -- used for data passing

	function init()
		-- m = display.newGroup()
		-- m:insert(set)
		-- set.data = m.data -- copy so event.target.data works correctly

		default = display.newImageRect(m, _imgName .."_btn.png", _width, _height)
		tap = display.newImageRect(m, _imgName .."_btn_tap.png", _width, _height)
		
		default:setReferencePoint(display.CenterReferencePoint)
		tap:setReferencePoint(display.CenterReferencePoint)

		-- sound = storyboard.gameData.buttonSound

		if _xPos and _yPos then
			default.x, default.y = _xPos, _yPos
			tap.x, tap.y = _xPos, _yPos
		else
			default.x, default.y = 0, 0
			tap.x, tap.y = 0, 0
		end

		if _onRelease then
			onRelease = _onRelease
		else
			onRelease = function()
				-- nothing
				end
		end

		if _sound then
			sound = _sound
		end

		tap.isVisible = false

		m.touch = buttonHandler
		active = false
	end

	function m.stayClicked()
		tap.isVisible = true
		default.isVisible = false
	end

	function m.release()
		default.isVisible = true
		tap.isVisible = false
	end

	function m.changeImage(img)
		display.remove(default)
		display.remove(tap)
		default = display.newImageRect(m, img .."_btn.png", _width, _height)
		tap = display.newImageRect(m, img .."_btn_tap.png", _width, _height)
		m.release()
	end

	function m.activate()
		m:addEventListener("touch", m)
		active = true
	end

	function m.deactivate()
		m:removeEventListener("touch", m)
		active = false
	end

	function m.isActive()
		return active
	end

	function buttonHandler(self, event)
		if event.phase == "began" then
			tap.isVisible = true
			default.isVisible = false
			display.getCurrentStage():setFocus(self, event.id)
			self.isFocus = true
		elseif self.isFocus then
			local bounds = self.contentBounds
			local x,y = event.x,event.y
			local withinBounds = bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
		
			if event.phase == "moved" then
				if withinBounds then
					tap.isVisible = true
					default.isVisible = false
				else
					default.isVisible = true
					tap.isVisible = false
				end
			elseif event.phase == "ended" or event.phase == "cancelled" then 
				if tap then 
					default.isVisible = true
					tap.isVisible = false
				end
				if event.phase == "ended" then
					default.isVisible = true
					tap.isVisible = false
					if withinBounds then
						if sound then
							if audio.play(sound, { channel = 1}) == 0 then print("Sound from btn has not been played.") end
						end
						onRelease(event)
					end
					display.getCurrentStage():setFocus(self, nil)
					self.isFocus = false
				end
			end
		end
		return true
	end

	m.oldRemoveSelf = m.removeSelf
	function m:removeSelf(  )
		self:removeEventListener("touch", self)
		display.remove(default)
		display.remove(tap)

		print("gButtonsManager instance destroyed: " .. imgName)
		self:oldRemoveSelf()
		self = nil
	end

	init()
	return m
end

return gButtonsManager