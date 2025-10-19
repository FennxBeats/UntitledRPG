-- mapHandler.lua
local worldHandler = require "worldHandler"

local sti = require "libs/sti"

local mapHandler = {}

mapHandler.scale = 7

function mapHandler.load()
    mapHandler.gameMap1 = sti("assets/maps/map1.lua")
end

function mapHandler.update(dt)
        mapHandler.gameMap1:update(dt)
end


-- FIX THE ERROR ME!!!

function mapHandler.drawFloor()
    love.graphics.push()
    love.graphics.scale(mapHandler.scale)
    mapHandler.gameMap1:drawLayer(mapHandler.gameMap1.layers["floor"])
    love.graphics.pop()
end

function mapHandler.drawForeground()
    love.graphics.push()
    love.graphics.scale(mapHandler.scale)
    mapHandler.gameMap1:drawLayer(mapHandler.gameMap1.layers["foreground"])
    love.graphics.pop()
end

return mapHandler
