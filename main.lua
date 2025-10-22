-- main.lua
local gameMap1Handler = require "mapCollisions.gameMap1Handler"

local camera = require "libs/camera"

local EnemyHandler = require "EnemyHandler"
local player = require "player"
local mapHandler = require "mapHandler"
local worldHandler = require "worldHandler"
local soundHandler = require "soundHandler"
local UIHandler = require "UIHandler"

local cam = camera()

function love.load()
    love.window.setMode(0, 0, { fullscreen = true })
    player.load()
    soundHandler.load()
    soundHandler.playRandomSong()
    EnemyHandler.load()
    UIHandler.load()
    mapHandler.load()
    worldHandler.load()
    gameMap1Handler.load()
end

function love.keypressed(key)
    UIHandler.keypressed(key)
end

function love.mousemoved(x, y)
    UIHandler.mousemoved(x, y)
end

function love.mousepressed(x, y, button)
    UIHandler.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    UIHandler.mousereleased(x, y, button)
end

function love.update(dt)
    if UIHandler.paused then
        return
    end

    player.update(dt)
    soundHandler.update(dt)
    EnemyHandler.update(dt)
    mapHandler.update(dt)
    UIHandler.update(dt)
    worldHandler.update(dt)

    local scale = mapHandler.scale
    local map = mapHandler.gameMap1
    local mapW = map.width * map.tilewidth * scale
    local mapH = map.height * map.tileheight * scale
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()

    cam:lookAt(player.x, player.y)

    -- camera bounds
    cam.x = math.max(w / 2, math.min(cam.x, mapW - w / 2))
    cam.y = math.max(h / 2, math.min(cam.y, mapH - h / 2))
end

function love.draw()
    cam:attach()
        mapHandler.drawFloor()
        mapHandler.drawForeground()
        EnemyHandler.draw()
        player.draw()
        worldHandler.draw()
    cam:detach()
    player.drawHealth()
    UIHandler.draw()
end