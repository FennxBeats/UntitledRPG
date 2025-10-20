local soundHandler = {}
local currentSong
local songList = {}

function soundHandler.load()
    -- Songs
    soundHandler.TitleTheme = love.audio.newSource("assets/sounds/music/normal/02 - Title Theme.mp3", "stream")
    soundHandler.DOT = love.audio.newSource("assets/sounds/music/normal/03 - Definitely Our Town.mp3", "stream")
    soundHandler.SilentForest = love.audio.newSource("assets/sounds/music/normal/04 - Silent Forest.mp3", "stream")
    soundHandler.PortTown = love.audio.newSource("assets/sounds/music/normal/07 - Port Town.mp3", "stream")
    soundHandler.Shop = love.audio.newSource("assets/sounds/music/normal/08 - Shop.mp3", "stream")
    soundHandler.WTWR = love.audio.newSource("assets/sounds/music/normal/19 - Where The Winds Roam.mp3", "stream")
    soundHandler.TheJourney = love.audio.newSource("assets/sounds/music/normal/20 - The Journey.mp3", "stream")

    -- Static sounds
    soundHandler.footstep = love.audio.newSource("assets/sounds/DIRT - Run 1.wav", "static")
    soundHandler.punchWhoosh = love.audio.newSource("assets/sounds/punch whoosh.wav", "static")

    -- Volume
    soundHandler.footstep:setVolume(0.2)
    soundHandler.punchWhoosh:setVolume(0.05)

    -- Song list
    songList = {
        soundHandler.TitleTheme,
        soundHandler.DOT,
        soundHandler.SilentForest,
        soundHandler.PortTown,
        soundHandler.Shop,
        soundHandler.WTWR,
        soundHandler.TheJourney
    }

    -- reduce volume and speed up songs 10x
    for _, song in ipairs(songList) do
        song:setVolume(song:getVolume() * 0.05)  -- super quiet
    end
end

function soundHandler.playRandomSong()
    -- Stop previous if any
    if currentSong then
        currentSong:stop()
    end

    -- Pick a random song
    local songIndex = love.math.random(#songList)
    currentSong = songList[songIndex]
    currentSong:setLooping(false)
    currentSong:play()
end

function soundHandler.update(dt)
    -- Trigger next song if current finished
    if currentSong and not currentSong:isPlaying() then
        soundHandler.playRandomSong()
    end
end

return soundHandler
