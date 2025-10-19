--gameMap1Handler.lua

local worldHandler = require "worldHandler"

local gameMap1Handler = {}

function gameMap1Handler.load()
    local fountain1 = worldHandler.world:newRectangleCollider(2510, 690, 250, 240)
    fountain1:setType("static")
end

function gameMap1Handler.update()
    
end

function gameMap1Handler.draw()
    
end

return gameMap1Handler