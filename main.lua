-- main.lua
local gameMap1Handler = require "mapCollisions.gameMap1Handler"

local camera = require "libs/camera"

local player = require "player"
local mapHandler = require "mapHandler"
local worldHandler = require "worldHandler"

local cam = camera()

function love.load()
    love.window.setMode(0, 0, { fullscreen = true })
    player.load()
    mapHandler.load()
    worldHandler.load()
    gameMap1Handler.load()
end

function love.update(dt)
    player.update(dt)
    mapHandler.update(dt)
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
        player.draw()
        worldHandler.draw()
    cam:detach()
    love.graphics.print("X: " .. player.x .. " Y: " .. player.y, 10, 10)
end