local EnemyHandler = {}

local player= require "player"

local Slime = require "enemies.Slime"
local enemies = {}

function EnemyHandler.load()
    table.insert(enemies, Slime.new(400, 300))
end

function EnemyHandler.update(dt)
    for i, e in ipairs(enemies) do
        e:update(dt, player)
    end
end

function EnemyHandler.draw()
    for i, e in ipairs(enemies) do
        e:draw()
    end
end

return EnemyHandler