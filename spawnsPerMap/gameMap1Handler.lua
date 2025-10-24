-- spawnsPerMap/gameMap1Handler.lua
local Slime = require "enemies.Slime"
local worldHandler = require "worldHandler"

local gameMap1Handler = {}

function gameMap1Handler.load()
    local fountain1 = worldHandler.world:newRectangleCollider(2510, 690, 250, 240)
    fountain1:setType("static")
    
    local water1 = worldHandler.world:newRectangleCollider(2110, 1655, 500, 290)
    water1:setType("static")
end

function gameMap1Handler.spawnEnemies()
    local EnemyHandler = require "EnemyHandler"
    EnemyHandler.addEnemy(Slime.new(400, 300))
    EnemyHandler.addEnemy(Slime.new(3198, 2633))

end

return gameMap1Handler