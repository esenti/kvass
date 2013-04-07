local gStoryboard = require("storyboard")
local gButtonsManager  = require("ButtonsManager")
local gScene = gStoryboard.newScene()

local gBackgroundImg
local gBlackBackgroundRect
local gStartBtn
local gHTPBtn
local gSoundBtn
local gMusicBtn

local gHTPBackBtn
local gHTPImg

local function toOnOff(value)
	if value then
		return "on"
	end
	return "off"
end

local function deactivateMenuButtons()
	gBlackBackgroundRect = display.newRect(0, 0, display.contentWidth, display.contentHeight)
	gBlackBackgroundRect:setFillColor(0, 0, 0, 196)
	gStartBtn:deactivate()
	gHTPBtn:deactivate()
	gSoundBtn:deactivate()
	gMusicBtn:deactivate()
end

local function activateMenuButtons()
	if gBlackBackgroundRect then
		gBlackBackgroundRect:removeSelf()
		gBlackBackgroundRect = nil
	end

	gStartBtn:activate()
	gHTPBtn:activate()
	gSoundBtn:activate()
	gMusicBtn:activate()
end

local function startGameBtnClicked()
	gStoryboard.gotoScene("GameplayScene", "fade", 300)
	return true
end

local function howToPlayBackBtnClicked()
	gHTPBackBtn:removeEventListener("touch", gHTPBackBtn)
	activateMenuButtons()
	gHTPImg:removeSelf()
	gHTPBackBtn:removeSelf()
end

local function howToPlayBtnClicked()
	deactivateMenuButtons()
	gHTPImg = display.newImageRect("gfx/htp/background.png", 440, 303)
	gHTPImg.x, gHTPImg.y = display.contentWidth / 2, display.contentHeight / 2
	gHTPBackBtn = gButtonsManager.new("gfx/htp/back", 59, 63, howToPlayBackBtnClicked, _G.sound.button, 0, 0)
	gHTPBackBtn.x, gHTPBackBtn.y = gHTPImg.x - 165, gHTPImg.y + 95
	gHTPBackBtn:addEventListener("touch", gHTPBackBtn)
	return true
end

local function soundBtnClicked()
	_G.userData.isSound = not _G.userData.isSound
	gSoundBtn.changeImage("gfx/menu/sound_"..toOnOff(_G.userData.isSound))
	gSoundBtn.x, gSoundBtn.y = display.contentWidth - 72.5, display.contentHeight - 25
	return true
end

local function musicBtnClicked()
	_G.userData.isMusic = not _G.userData.isMusic
	if _G.userData.isMusic then
		audio.resume(1)
	else
		audio.pause(1)
	end

	gMusicBtn.changeImage("gfx/menu/music_"..toOnOff(_G.userData.isMusic))
	gMusicBtn.x, gMusicBtn.y = display.contentWidth - 25, display.contentHeight - 25
	return true
end

function gScene:createScene(event)
	local screenGroup = self.view

	-- Background image
	gBackgroundImg = display.newImageRect("gfx/menu/background.png", 568, 384)
	gBackgroundImg.x, gBackgroundImg.y = display.contentWidth / 2, display.contentHeight / 2

	-- Buttons
	gStartBtn = gButtonsManager.new("gfx/menu/start", 153, 85, startGameBtnClicked, _G.sound.button, display.contentWidth/2, display.contentHeight - 85 / 2)
	gHTPBtn = gButtonsManager.new("gfx/menu/htp", 75, 70, howToPlayBtnClicked, _G.sound.button, 25, 25)
	gSoundBtn = gButtonsManager.new("gfx/menu/sound_"..toOnOff(_G.userData.isSound), 75, 70, soundBtnClicked, _G.sound.button, display.contentWidth - 72.5, display.contentHeight - 25)
	gMusicBtn = gButtonsManager.new("gfx/menu/music_"..toOnOff(_G.userData.isMusic), 75, 70, musicBtnClicked, _G.sound.button, display.contentWidth - 25, display.contentHeight - 25)
	
	-- Add everything to screen group
	screenGroup:insert(gBackgroundImg)
	screenGroup:insert(gStartBtn)
	screenGroup:insert(gHTPBtn)
	screenGroup:insert(gSoundBtn)
	screenGroup:insert(gMusicBtn)
end

function gScene:enterScene(event)
	gStoryboard.purgeScene("GameplayScene")
	activateMenuButtons()
end

function gScene:exitScene(event)
	deactivateMenuButtons()
	gBackgroundImg:removeSelf()
	gStartBtn:removeSelf()
	gHTPBtn:removeSelf()
	gSoundBtn:removeSelf()
	gMusicBtn:removeSelf()
	gBackgroundImg = nil
	gStartBtn = nil
	gHTPBtn = nil
	gFBBtn = nil
	gGCBtn = nil
	gSoundBtn = nil
	gMusicBtn = nil
end

function gScene:destroyScene(event)
end

gScene:addEventListener("createScene", gScene)
gScene:addEventListener("enterScene", gScene)
gScene:addEventListener("exitScene", gScene)
gScene:addEventListener("destroyScene", gScene)

return gScene