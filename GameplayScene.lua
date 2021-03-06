local gStoryboard = require("storyboard")
local gScene = gStoryboard.newScene()
local gPhysics = require("physics")
gPhysics.start()
gPhysics.setGravity(0, 0)

local gBackgroundImg = {}
local gScoreText
local gPowerupText

local gGame
local gScreenGroup

local gCurrentlyTouchedPoint = {}
local gTouchingPoints = {}

local trajectories = {
	function(t, p) return 2 * p * t, 3.7 * (t^2 - t) end,
	function(t, p) return 2 * p * t, 2 * (math.cos(6*t) - 1) / (4*p) end,
	function(t, p) return t + 0.1*math.sin(60*p*t), t^2 - t - 0.1*math.cos(60*p*t) end,
	--function(t, p) return t, -t^2 + p * t end
}

local sizes = {
	{w=38, h=55},
	{w=18, h=54},
	{w=38, h=55},
	{w=38, h=55},
	{w=72, h=64},
	{w=50, h=58},
	{w=18, h=84},
	{w=100, h=72},
	{w=64, h=64},
	{w=72, h=134},
}

local function trajectory(fun, time, param)
	local x, y = trajectories[fun % table.getn(trajectories) + 1](time / 1000, param);
	return display.contentWidth * 0.18 + x * display.contentWidth, display.contentHeight * 0.73 + y * display.contentHeight * 0.73
end

local function zonk(event)
	if event.phase == "began" then
		gStoryboard.gotoScene("MenuScene", "fade", 300)
	end

	return true
end

local function jesus()
	gEnd = display.newImageRect("gfx/game/end.png", display.contentWidth, display.contentHeight)
	gEnd.x, gEnd.y = display.contentWidth / 2,  display.contentHeight / 2
	gScene.view:insert(gEnd)

	gEnd:addEventListener("touch", zonk)

	return true

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
			jesus()
		end
	else
		gGame.turningDirection = 0
    end

	return true
end

local function sfdsafaRocket()

	audio.play(_G.sound.explosion)

	gGame.rocket = display.newImageRect("gfx/game/rocket.png", 76 / 2, 134 / 2)
	gGame.rocket.x, gGame.rocket.y = 420, 210
	gScreenGroup:insert(gGame.rocket)
	gPhysics.addBody(gGame.rocket, { density = 1, friction = -1, bounce = 1, radius = 20 })
	gGame.rocket:setLinearVelocity(0, -100)

	if gGame.rocketShadow ~= nil then
		gGame.rocketShadow:removeSelf()
		gGame.rocketShadow = nil
	end

	if not gGame.siloBoom then
		gGame.siloBoom = display.newImageRect("gfx/game/boom.png", 240 / 2, 152 / 2)
		gGame.siloBoom.x, gGame.siloBoom.y = 310, 260
	end
end

local function sfdsafaSilos()

	audio.play(_G.sound.explosion)

	gGame.silos = display.newImageRect("gfx/game/rocket.png", 76 / 2, 134 / 2)
	gGame.silos.x, gGame.silos.y = 310, 260
	gScreenGroup:insert(gGame.silos)
	gPhysics.addBody(gGame.silos, { density = 1, friction = -1, bounce = 1, radius = 20 })
	gGame.silos:setLinearVelocity(0, -100)

	if not gGame.rocketBoom then
		gGame.rocketBoom = display.newImageRect("gfx/game/boom.png", 240 / 2, 152 / 2)
		gGame.rocketBoom.x, gGame.rocketBoom.y = 420, 210
	end
end


local function hitRocket(dmg)
	gGame.rocketLife = gGame.rocketLife - dmg

	if gGame.rocketLifeImgBack then
		gGame.rocketLifeImgBack:removeSelf()
		gGame.rocketLifeImg:removeSelf()
		gGame.rocketLifeImgBack = nil
		gGame.rocketLifeImg = nil
	end

	if gGame.rocketLife < 0 then
		gGame.silos:removeSelf()
		gGame.silos = nil
		timer.performWithDelay(1, sfdsafaSilos, 1)

		if gGame.silosLifeImgBack then
		gGame.silosLifeImgBack:removeSelf()
		gGame.silosLifeImg:removeSelf()
		gGame.silosLifeImgBack = nil
		gGame.silosLifeImg = nil
	end
	
	else
		gGame.rocketLifeImgBack = display.newRect(390, 120, 60, 10)
		gGame.rocketLifeImgBack:setFillColor(255, 0, 0)
		gGame.rocketLifeImg = display.newRect(390, 120, gGame.rocketLife, 10)
		gGame.rocketLifeImg:setFillColor(0, 255, 0)
	end
end

local function hitSilos(dmg)
	gGame.silosLife = gGame.silosLife - dmg

	if gGame.silosLifeImgBack then
		gGame.silosLifeImgBack:removeSelf()
		gGame.silosLifeImg:removeSelf()
		gGame.silosLifeImgBack = nil
		gGame.silosLifeImg = nil
	end

	if gGame.silosLife < 0 then
		gGame.rocket:removeSelf()
		gGame.rocket = nil
		timer.performWithDelay(1, sfdsafaRocket, 1)

	if gGame.rocketLifeImgBack then
		gGame.rocketLifeImgBack:removeSelf()
		gGame.rocketLifeImg:removeSelf()
		gGame.rocketLifeImgBack = nil
		gGame.rocketLifeImg = nil
	end

	else
		gGame.silosLifeImgBack = display.newRect(280, 230, 60, 10)
		gGame.silosLifeImgBack:setFillColor(255, 0, 0)
		gGame.silosLifeImg = display.newRect(280, 230, gGame.silosLife, 10)
		gGame.silosLifeImg:setFillColor(0, 255, 0)
	end
end

local function onCollision(event)
	if not gGame then return end

	if event.object1 == gGame.rocket then
		event.object2:removeSelf()
		hitRocket(14)
	end
	if event.object2 == gGame.rocket then
		event.object1:removeSelf()
		hitRocket(14)
	end
	if event.object1 == gGame.silos then
		event.object2:removeSelf()
		hitSilos(46)
	end
	if event.object2 == gGame.silos then
		event.object1:removeSelf()
		hitSilos(46)
	end
end

local function nextFrame()
	if (gGame.silos and gGame.silos.y < -100) or (gGame.rocket and gGame.rocket.y < -100) then
		jesus()
	end

	gGame.time = gGame.time + 1000 / 60.0
	gGame.timeToNext = gGame.timeToNext + 1000 / 60.0

	gScoreText.text = 20 - math.round(gGame.time / 1000)
	if gGame.time > 20000 then
		if gGame.silosLife > 0 then
			gGame.rocket:removeSelf()
			gGame.rocket = nil
			timer.performWithDelay(1, sfdsafaRocket, 1)
			gGame.silosLife = 0
		end

		if gGame.rocketLife > 0 then
			gGame.silos:removeSelf()
			gGame.silos = nil
			timer.performWithDelay(1, sfdsafaSilos, 1)
			gGame.rocketLife = 0
		end
	end

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

		local iggfdgsd = math.min(9, gGame.bullId)
		local bullet = display.newImageRect("gfx/game/items/" .. iggfdgsd .. ".png", sizes[iggfdgsd + 1].w / 2, sizes[iggfdgsd + 1].h / 2)
		bullet.x, bullet.y, bullet.start, bullet.fun, bullet.param = 100, 100, gGame.time, gGame.bullId, gGame.param
		table.insert(gGame.bullets, bullet)
		gScreenGroup:insert(bullet)
		gGame.bullId = gGame.bullId + 1
		gPhysics.addBody(bullet, { density = 1, friction = -1, bounce = 1, radius = 20 })

		gGame.param = 0.1

		audio.play(_G.sound.shot)
	end

	if gGame.turningDirection > 0 then
		gGame.param = gGame.param + 0.01
	elseif gGame.turningDirection < 0 then
		gGame.param = gGame.param - 0.01
	end
	--gScoreText.text = gGame.param

	for i = 1, 100, 1 do
		gGame.trajectory[i].x, gGame.trajectory[i].y = trajectory(gGame.bullId, (2000 / 100) * (i-1), gGame.param)
	end

	for i = 1, #gGame.bullets, 1 do
		gGame.bullets[i].x, gGame.bullets[i].y = trajectory(gGame.bullets[i].fun, gGame.time - gGame.bullets[i].start, gGame.bullets[i].param)
		if gGame.bullets[i].rotation ~= nil then
			gGame.bullets[i].rotation = gGame.bullets[i].rotation + 5
		end
		--local x2, y2 = trajectory(gGame.bullets[i].fun, gGame.time - gGame.bullets[i].start + 0.0000001, gGame.bullets[i].param)
		--gGame.bullets[i].rotation = math.atan2(y2 - gGame.bullets[i].y, x2 - gGame.bullets[i].x) * 180 / math.pi
	end

	--local x, y = trajectory(0, gGame.time, gGame.param)
	--gGame.bulletTest.x = x
	--gGame.bulletTest.y = y
	--local x2, y2 = trajectory(0, gGame.time + 0.0000001, gGame.param)
	--gGame.bulletTest.rotation = math.atan2(y2 - y, x2 - x) * 180 / math.pi

	return true
end

local function destroyAllData()
	print("xxx")
	if not gGame or not gGame.cannon then
		return
	end

	if gGame.rocketLifeImgBack then
		gGame.rocketLifeImgBack:removeSelf()
		gGame.rocketLifeImg:removeSelf()
		gGame.rocketLifeImgBack = nil
		gGame.rocketLifeImg = nil
	end

	if gGame.silosLifeImgBack then
		gGame.silosLifeImgBack:removeSelf()
		gGame.silosLifeImg:removeSelf()
		gGame.silosLifeImgBack = nil
		gGame.silosLifeImg = nil
	end
	print("ssss")
	if gGame.cannonShadow then
		gGame.cannonShadow:removeSelf()
	end
	gGame.cannon:removeSelf()
	if gGame.rocketShadow then
	gGame.rocketShadow:removeSelf()
end
	gGame.rocket:removeSelf()
	gGame.silos:removeSelf()

	if gGame.siloBoom then
	gGame.siloBoom:removeSelf()
end

	if gGame.rocketBoom then

	gGame.rocketBoom:removeSelf()
end


	gGame.cannonShadow = nil
	gGame.cannon = nil
	gGame.rocketShadow = nil
	gGame.rocket = nil
	gGame.silos = nil
	gGame.siloBoom = nil
	gGame.rocketBoom = nil
end

function gScene:createScene(event)
	gTouchingPoints = {}
	destroyAllData()

	gScreenGroup = self.view

	gBackground = display.newImageRect("gfx/game/background.png", display.contentWidth, display.contentHeight)
	gBackground.x, gBackground.y = display.contentWidth / 2,  display.contentHeight / 2
	gScreenGroup:insert(gBackground)

	gScoreText = display.newText("0", 0, 0, "Good Times Rg", 50)
	gScoreText:setTextColor(255, 255, 255, 128)
	gScoreText.x, gScoreText.y = 430, 47 / 2
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

	gGame.silos = display.newImageRect("gfx/game/silo.png", 86 / 2, 24 / 2)
	gGame.silos.x, gGame.silos.y = 310, 260
	gScreenGroup:insert(gGame.silos)
	gPhysics.addBody(gGame.silos, "static")

	gGame.anotherSilo = display.newImageRect("gfx/game/silo.png", 86 / 2, 24 / 2)
	gGame.anotherSilo.x, gGame.anotherSilo.y = 360, 235
	gScreenGroup:insert(gGame.anotherSilo)
	gPhysics.addBody(gGame.anotherSilo, "static")


	gGame.rocketLife = 60
	gGame.silosLife = 60

	gGame.bullets = {}

	gGame.trajectory = {}
	for i = 1, 100, 1 do
		gGame.trajectory[i] = display.newImageRect("gfx/game/marker.png", 2, 2)
		gGame.trajectory[i].alpha = 0.7
		gScreenGroup:insert(gGame.trajectory[i])
	end

	gGame.param = 0.1
	gGame.turningDirection = 0
	gGame.bullId = 0

	gGame.logicTimer = timer.performWithDelay(1000 / 60, function() return nextFrame() end, 0)
end

function gScene:enterScene(event)
	gStoryboard.purgeScene("MenuScene")
	Runtime:addEventListener("touch", onTouch)
	Runtime:addEventListener("collision", onCollision)
end

function gScene:exitScene(event)
	if gGame.logicTimer then
		timer.cancel(gGame.logicTimer)
		gGame.logicTimer = nil
	end

	Runtime:removeEventListener("touch", onTouch)
	Runtime:removeEventListener("collision", onCollision)

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
