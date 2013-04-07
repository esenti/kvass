display.setStatusBar(display.HiddenStatusBar)
system.setIdleTimer(false)

math.randomseed(os.time())
math.random()
math.random()
math.random()

system.activate("multitouch")

local gStoryboard 	 = require("storyboard")

local init

function init()
	_G.userData = {}
	_G.userData.isMusic = true
	_G.userData.isSound = true

	_G.sound = {}
	_G.sound.collect = audio.loadSound("audio/collect.wav")
	_G.sound.button	= audio.loadSound("audio/button.wav")
	_G.sound.music 	= audio.loadStream("audio/music.mp3")
	_G.sound.shot 	= audio.loadStream("audio/shot.mp3")
	_G.sound.explosion 	= audio.loadStream("audio/explosion.wav")

	audio.play(_G.sound.music, {channel = 1, loops = -1})
	audio.setVolume(0.2, { channel = 1})
	if not _G.userData.isMusic then audio.pause(1) end

	gStoryboard.gotoScene("MenuScene", "fade", 400)
end

init()
