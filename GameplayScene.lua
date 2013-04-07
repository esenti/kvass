local gStoryboard = require("storyboard")
local gButtonsManager  = require("ButtonsManager")
local gScene = gStoryboard.newScene()

local gBackgroundImg = {}
local gScoreText
local gPowerupText

local gGame
local gScreenGroup

local gCurrentlyTouchedPoint = {}
local gTouchingPoints = {}

local function onTouch(event)
	if event.phase == "began" then
		table.insert(gTouchingPoints, {x = event.x, y = event.y, id = event.id})
    elseif event.phase == "moved" then
		for i = 1, #gTouchingPoints, 1 do
			if gTouchingPoints[i].id == event.id then
				gTouchingPoints[i].x = event.x
				gTouchingPoints[i].y = event.y
				break
			end
		end
    elseif event.phase == "ended" or event.phase == "cancelled" then
		for i = 1, #gTouchingPoints, 1 do
			if gTouchingPoints[i].id == event.id then
				table.remove(gTouchingPoints, i)
				break
			end
		end

	end

	if #gTouchingPoints > 0 then
		print("CLICKED " .. gTouchingPoints[1].x .. ", " .. gTouchingPoints[1].y) 

		if gTouchingPoints[1].y < 50 then
			gStoryboard.gotoScene("MenuScene", "fade", 300)
		end
	else
		--gGame.player.turningDirection = 0
    end

	return true
end

local function nextFrame()
	gGame.time = gGame.time + 1000 / 60.0

	print("message")
	gGame.bullet.x = display.contentWidth / 2 - math.sin(gGame.time / 1000) * 200
	gGame.bullet.y = display.contentHeight / 2 + math.cos(gGame.time / 1000) * 200
	gGame.bullet:setFillColor(255, (math.sin(gGame.time / 10000) + 1) * 128, 0)

	gScoreText.text = math.round(gGame.time / 1000)
	gPowerupText.text = 100 - math.round(gGame.time / 1000)
	-- for i = 1, #gGame.player.data, 1 do
	-- end
	return true
end

local function destroyAllData()
	if not gGame then
		return
	end
	gGame.cannon:removeSelf()
	gGame.cannon = nil
	gGame.rocket:removeSelf()
	gGame.rocket = nil
	gGame.bullet:removeSelf()
	gGame.bullet = nil
end

function gScene:createScene(event)
	gTouchingPoints = {}
	destroyAllData()

	gScreenGroup = self.view

	print(display.contentWidth)
	print(display.contentHeight)
	gBackground = display.newImageRect("gfx/game/background.png", display.contentWidth, display.contentHeight)
	gBackground.x, gBackground.y = display.contentWidth / 2,  display.contentHeight / 2
	gScreenGroup:insert(gBackground)

	gScoreText = display.newText("0", 0, 0, "Good Times Rg", 20)
	gScoreText.x, gScoreText.y = 156 / 2, 47 / 2
	gScreenGroup:insert(gScoreText)

	gPowerupText = display.newText("", 0, 0, "Good Times Rg", 96)
	gPowerupText.x, gPowerupText.y = display.contentWidth / 2,  display.contentHeight / 2 - 100
	gPowerupText:setTextColor(255, 255, 255, 64)
	gScreenGroup:insert(gPowerupText)

	gScoreText.text = "0"
	gPowerupText.text = ""

	gGame = {}
	gGame.logicTimer = nil
	gGame.points = 0
	gGame.time = 0

	gGame.cannon = display.newImageRect("gfx/game/cannon.png", 181, 138)
	gGame.cannon.x, gGame.cannon.y = 100, display.contentHeight - 138/2
	gScreenGroup:insert(gGame.cannon)

	gGame.rocket = display.newImageRect("gfx/game/rocket.png", 211, 371)
	gGame.rocket.x, gGame.rocket.y = 100, 100
	gScreenGroup:insert(gGame.rocket)
	
	gGame.bullet = display.newImageRect("gfx/game/items/1.png", 67, 67)
	gGame.bullet.x, gGame.bullet.y = 100, 100
	gScreenGroup:insert(gGame.bullet)

	gGame.silo = display.newImageRect("gfx/game/silo.png", 245, 69)
	gGame.silo.x, gGame.silo.y = 100, 100
	gScreenGroup:insert(gGame.silo)

	gGame.logicTimer = timer.performWithDelay(1000 / 60, function() return nextFrame() end, 0)
end

function gScene:enterScene(event)
	gStoryboard.purgeScene("MenuScene")
	Runtime:addEventListener("touch", onTouch)
end

function gScene:exitScene(event)
	if gGame.logicTimer then
		timer.cancel(gGame.logicTimer)
		gGame.logicTimer = nil
	end

	Runtime:removeEventListener("touch", onTouch)

	destroyAllData()
	gBackground:removeSelf()
	gBackground = nil
	gScoreText:removeSelf()
	gScoreText = nil
	gPowerupText:removeSelf()
	gPowerupText = nil

	gGame = nil
end

function gScene:destroyScene(event)
end

gScene:addEventListener("createScene", gScene)
gScene:addEventListener("enterScene", gScene)
gScene:addEventListener("exitScene", gScene)
gScene:addEventListener("destroyScene", gScene)

return gScene