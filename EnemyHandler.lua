-- EnemyHandler.lua
local EnemyHandler = {}

local soundHandler = require "soundHandler"
local mapHandler = require "mapHandler"
local Slime = require "enemies.Slime"

local enemies = {}
local aggroRange = 600 -- distance where enemies start chasing

function EnemyHandler.load()
    local gameMap1Handler = require "spawnsPerMap/gameMap1Handler"
    if mapHandler.currentMapName == "map1" then
        gameMap1Handler.spawnEnemies()
    end
end

function EnemyHandler.addEnemy(e)
    table.insert(enemies, e)
end

function EnemyHandler.update(dt, player)
    for i = #enemies, 1, -1 do
        local e = enemies[i]

        if e.collider then
            e.x = e.collider:getX()
            e.y = e.collider:getY()
        end

        -- remove dead enemies that finished death animation
        if e.dead then
            table.remove(enemies, i)
            goto continue
        end

        -- distance to player
        local dx, dy = player.x - e.x, player.y - e.y
        local dist = math.sqrt(dx * dx + dy * dy)

        if e.isAlive then
            if dist <= aggroRange then
                e:update(dt, player)
            else
                -- idle animation
                e.state = "idle"
                e.frameTimer = e.frameTimer + dt
                if e.frameTimer >= e.frameSpeed then
                    e.frameTimer = 0
                    local animSet = e.animations.idle[e.dir]
                    if animSet then
                        e.frame = e.frame + 1
                        if e.frame > #animSet then e.frame = 1 end
                    end
                end
            end
        else
            -- handle death animation
            if e.state ~= "die" then e:onDeath() end
            e.frameTimer = e.frameTimer + dt
            if e.frameTimer >= e.frameSpeed then
                e.frameTimer = 0
                e.frame = e.frame + 1
                local animSet = e.animations.die[e.dir]
                if animSet and e.frame > #animSet then
                    e.dead = true
                end
            end
        end

        -- punch logic (handled in player file)
        local punchAnim = player.sharedPunchAnim
        if player.state == "punch" then
            if punchAnim.position == 2 and not punchAnim.hit1Played then
                local s1 = soundHandler.punchWhoosh:clone()
                s1:setPitch(0.5 + math.random() * 0.5)
                s1:play()
                punchAnim.hit1Played = true
            end
            if punchAnim.position == 5 and not punchAnim.hit2Played then
                local s2 = soundHandler.punchWhoosh:clone()
                s2:setPitch(0.5 + math.random() * 0.5)
                s2:play()
                punchAnim.hit2Played = true
            end

            local bx, by, bw, bh = player.getPunchBox()
            local overlaps = e.x + 20 > bx and e.x - 20 < bx + bw and e.y + 20 > by and e.y - 20 < by + bh
            if overlaps and e.isAlive then
                if punchAnim.position == 2 and not punchAnim.hit1Hit then
                    e:takeDamage(player.punchDamage, player.x, player.y)
                    local hitS1 = soundHandler.punchHit:clone()
                    hitS1:setPitch(0.5 + math.random() * 0.5)
                    hitS1:play()
                    punchAnim.hit1Hit = true
                end
                if punchAnim.position == 5 and not punchAnim.hit2Hit then
                    e:takeDamage(player.punchDamage, player.x, player.y)
                    local hitS2 = soundHandler.punchHit:clone()
                    hitS2:setPitch(0.5 + math.random() * 0.5)
                    hitS2:play()
                    punchAnim.hit2Hit = true
                end
            end

            -- reset flags when animation loops
            if punchAnim.position == 1 then
                punchAnim.hit1Played = false
                punchAnim.hit2Played = false
                punchAnim.hit1Hit = false
                punchAnim.hit2Hit = false
            end
        end

        ::continue::
    end
end

function EnemyHandler.draw()
    for _, e in ipairs(enemies) do
        e:draw()
    end
end

return EnemyHandler