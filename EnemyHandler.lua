local EnemyHandler = {}

local player= require "player"

local Slime = require "enemies.Slime"
local enemies = {}

function EnemyHandler.load()
    table.insert(enemies, Slime.new(400, 300))
end

function EnemyHandler.update(dt)
    for i = #enemies, 1, -1 do
        local e = enemies[i]
        e:update(dt, player)
        if e.dead then
            table.remove(enemies, i)
        elseif player.justPunched and e.isAlive then
            local dx, dy = e.x - player.x, e.y - player.y
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist < player.punchRange then
                e:takeDamage(player.punchDamage)
            end
        end
    end
end



function EnemyHandler.draw()
    for i, e in ipairs(enemies) do
        e:draw()
    end
end

return EnemyHandler