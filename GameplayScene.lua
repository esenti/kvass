local gStoryboard = require("storyboard")
local gButtonsManager  = require("ButtonsManager")
local gScene = gStoryboard.newScene()
local gPhysics = require("physics")
gPhysics.start()
gPhysics.setGravity(0, 10)

local gBackgroundImg = {}
local gScoreText
local gPowerupText

local gGame
local gScreenGroup

local gCurrentlyTouchedPoint = {}
local gTouchingPoints = {}


local function magic(fun, time, param)
	return display.contentWidth / 2 + math.sin(time / 1000) * 50 * param, display.contentHeight / 2 + math.cos(time / 1000) * 50
end

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
		if gTouchingPoints[1].x < display.contentWidth / 2 then
			gGame.turningDirection = -1
		else
			gGame.turningDirection = 1
		end

		if gTouchingPoints[1].y < 20 then
			gStoryboard.gotoScene("MenuScene", "fade", 300)
		end
	else
		gGame.turningDirection = 0
    end

	return true
end

local function nextFrame()
	gGame.time = gGame.time + 1000 / 60.0
	gGame.timeToNext = gGame.timeToNext + 1000 / 60.0

	if gGame.timeToNext < 500 then
		gPowerupText.text = "3"
	elseif gGame.timeToNext < 1000 then
		gPowerupText.text = "2"
	elseif gGame.timeToNext < 1500 then
		gPowerupText.text = "1"
	elseif gGame.timeToNext < 1700 then
		gPowerupText.text = "0"
	else
		gGame.timeToNext = 0

		local bullet = display.newImageRect("gfx/game/items/bullet.png", 32, 32)
		bullet.x, bullet.y, bullet.start, bullet.fun, bullet.param = 100, 100, gGame.time, gGame.bullId, gGame.param
		table.insert(gGame.bullets, bullet)
		gScreenGroup:insert(bullet)
		gGame.bullId = gGame.bullId + 1
	end

	if gGame.turningDirection > 0 then
		gGame.param = gGame.param + 0.01
	elseif gGame.turningDirection < 0 then
		gGame.param = gGame.param - 0.01
	end
	gScoreText.text = gGame.param

	for i = 1, 100, 1 do
		gGame.trajectory[i].x, gGame.trajectory[i].y = magic(gGame.bullId, (10000 / 100) * i, gGame.param)
	end

	for i = 1, #gGame.bullets, 1 do
		gGame.bullets[i].x, gGame.bullets[i].y = magic(gGame.bullets[i].fun, gGame.time - gGame.bullets[i].start, gGame.bullets[i].param)
	end

	--gGame.cannon.rotation = gGame.cannonAngle

	local xxx, yyy = magic(0, gGame.time, gGame.param)
	gGame.bulletTest.x = xxx
	gGame.bulletTest.y = yyy
	gGame.bulletTest.rotation = 45

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

	gBackground = display.newImageRect("gfx/game/background.png", display.contentWidth, display.contentHeight)
	gBackground.x, gBackground.y = display.contentWidth / 2,  display.contentHeight / 2
	gScreenGroup:insert(gBackground)

	gScoreText = display.newText("0", 0, 0, "Good Times Rg", 20)
	gScoreText.x, gScoreText.y = 156 / 2, 47 / 2
	gScreenGroup:insert(gScoreText)

	gPowerupText = display.newText("", 0, 0, "Good Times Rg", 96)
	gPowerupText.x, gPowerupText.y = display.contentWidth / 2,  display.contentHeight / 2 - 100
	gPowerupText:setTextColor(255, 255, 255, 128)
	gScreenGroup:insert(gPowerupText)

	gScoreText.text = "0"
	gPowerupText.text = "X"

	gGame = {}
	gGame.logicTimer = nil
	gGame.points = 0
	gGame.time = 0
	gGame.timeToNext = 0

	gGame.cannonShadow = display.newImageRect("gfx/game/cannon_shadow.png", 169 / 2, 95 / 2)
	gGame.cannonShadow.x, gGame.cannonShadow.y = 70, display.contentHeight - 138/2 + 10
	gScreenGroup:insert(gGame.cannonShadow)

	gGame.cannon = display.newImageRect("gfx/game/cannon.png", 100 / 2, 76 / 2)
	gGame.cannon.x, gGame.cannon.y = 60, display.contentHeight - 138/2
	gScreenGroup:insert(gGame.cannon)
	gPhysics.addBody(gGame.cannon, "static")


	gGame.rocketShadow = display.newImageRect("gfx/game/rocket_shadow.png", 153 / 2, 100 / 2)
	gGame.rocketShadow.x, gGame.rocketShadow.y = 445, 220
	gScreenGroup:insert(gGame.rocketShadow)

	gGame.rocket = display.newImageRect("gfx/game/rocket.png", 76 / 2, 134 / 2)
	gGame.rocket.x, gGame.rocket.y = 420, 210
	gScreenGroup:insert(gGame.rocket)
	gPhysics.addBody(gGame.rocket, "static")

	gGame.silo = display.newImageRect("gfx/game/silo.png", 86 / 2, 24 / 2)
	gGame.silo.x, gGame.silo.y = 310, 260
	gScreenGroup:insert(gGame.silo)
	gPhysics.addBody(gGame.silo, "static")

	gGame.anotherSilo = display.newImageRect("gfx/game/silo.png", 86 / 2, 24 / 2)
	gGame.anotherSilo.x, gGame.anotherSilo.y = 360, 235
	gScreenGroup:insert(gGame.anotherSilo)
	gPhysics.addBody(gGame.anotherSilo, "static")

	gGame.bullet = display.newImageRect("gfx/game/items/bullet.png", 38 / 2, 55 / 2)
	gGame.bullet.x, gGame.bullet.y = 100, 100
	gGame.bullet.rotation = 90
	gScreenGroup:insert(gGame.bullet)
	gPhysics.addBody(gGame.bullet, { density = 1, friction = -1, bounce = 1, radius = 20 })
	gGame.bullet:setLinearVelocity(20, 5)

	gGame.bulletTest = display.newImageRect("gfx/game/items/red.png", 32, 32)
	gGame.bulletTest.x, gGame.bulletTest.y = 100, 100
	gScreenGroup:insert(gGame.bulletTest)

	gGame.bullets = {}

	gGame.trajectory = {}
	for i = 1, 100, 1 do
		gGame.trajectory[i] = display.newImageRect("gfx/game/marker.png", 4, 4)
		gScreenGroup:insert(gGame.trajectory[i])
	end

	gGame.param = 0
	gGame.turningDirection = 0
	gGame.bullId = 1

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
