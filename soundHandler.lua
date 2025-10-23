local soundHandler = {}
soundHandler.musicVolume = 0.2
soundHandler.sfxVolume = 1
soundHandler.songList = {} -- so UIHandler can loop through it

local currentSong

function soundHandler.load()
    -- Songs
    soundHandler.TitleTheme = love.audio.newSource("assets/sounds/music/normal/02 - Title Theme.mp3", "stream")
    soundHandler.DOT = love.audio.newSource("assets/sounds/music/normal/03 - Definitely Our Town.mp3", "stream")
    soundHandler.SilentForest = love.audio.newSource("assets/sounds/music/normal/04 - Silent Forest.mp3", "stream")
    soundHandler.PortTown = love.audio.newSource("assets/sounds/music/normal/07 - Port Town.mp3", "stream")
    soundHandler.Shop = love.audio.newSource("assets/sounds/music/normal/08 - Shop.mp3", "stream")
    soundHandler.WTWR = love.audio.newSource("assets/sounds/music/normal/19 - Where The Winds Roam.mp3", "stream")
    soundHandler.TheJourney = love.audio.newSource("assets/sounds/music/normal/20 - The Journey.mp3", "stream")

    soundHandler.footstep = love.audio.newSource("assets/sounds/DIRT - Run 1.wav", "static")
    soundHandler.punchWhoosh = love.audio.newSource("assets/sounds/punch whoosh.wav", "static")

    soundHandler.punchHit = love.audio.newSource("assets/sounds/enemyHit.wav", "static")

    soundHandler.songList = {
        soundHandler.TitleTheme,
        soundHandler.DOT,
        soundHandler.SilentForest,
        soundHandler.PortTown,
        soundHandler.Shop,
        soundHandler.WTWR,
        soundHandler.TheJourney
    }

    soundHandler.applyVolumes()
end

function soundHandler.applyVolumes()
    -- set all music
    for _, song in ipairs(soundHandler.songList) do
        song:setVolume(soundHandler.musicVolume)
    end

    -- set sfx
    soundHandler.footstep:setVolume(soundHandler.sfxVolume * 0.5)
    soundHandler.punchWhoosh:setVolume(soundHandler.sfxVolume * 0.25)
end

function soundHandler.playRandomSong()
    if currentSong then currentSong:stop() end
    local i = love.math.random(#soundHandler.songList)
    currentSong = soundHandler.songList[i]
    currentSong:setLooping(false)
    currentSong:play()
end

function soundHandler.update(dt)
    if currentSong and not currentSong:isPlaying() then
        soundHandler.playRandomSong()
    end
end

return soundHandler
