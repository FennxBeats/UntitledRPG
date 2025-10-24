local worldHandler = require "worldHandler"
local soundHandler = require "soundHandler"
local anim8 = require "libs/anim8"

local player = {
    speed = 300,
    dir = "down",
    state = "idle",
    mouseWasDown = false,
    walkTimer = 0,
    health = 100,
    maxHealth = 100,
    justPunched = false,
    punchRange = 120,
    punchDamage = 5,
    lastCombatTime = 0,
    healTimer = 0,
    healDelay = 30, -- seconds after combat
    healRate = 1   -- heal per second

}

function player.takeDamage(amount)
    player.health = player.health - amount
    player.lastCombatTime = love.timer.getTime()
    if player.health <= 0 then
        player.health = 0
        print("player dead :(")
    end
end

function player.getPunchBox()
    local size, length = 80, player.punchRange
    local x, y, w, h

    if player.dir == "up" then
        w, h = size, length
        x = player.x - w/2
        y = player.y - h
    elseif player.dir == "down" then
        w, h = size, length
        x = player.x - w/2
        y = player.y
    elseif player.dir == "left" then
        w, h = length, size
        x = player.x - w
        y = player.y - h/2
    elseif player.dir == "right" then
        w, h = length, size
        x = player.x
        y = player.y - h/2
    end

    return x, y, w, h
end

function player.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    player.collider = worldHandler.world:newRectangleCollider(0, 0, 60, 90)
    player.collider:setFixedRotation(true)
    local imgPath = "assets/player/"
    player.images = {
        idle = {
            up = love.graphics.newImage(imgPath .. "idle_up.png"),
            down = love.graphics.newImage(imgPath .. "idle_down.png"),
            left = love.graphics.newImage(imgPath .. "idle_side.png"),
            right = love.graphics.newImage(imgPath .. "idle_side_right.png")
        },
        run = {
            up = love.graphics.newImage(imgPath .. "run_up.png"),
            down = love.graphics.newImage(imgPath .. "run_down.png"),
            left = love.graphics.newImage(imgPath .. "run_side.png"),
            right = love.graphics.newImage(imgPath .. "run_side_right.png")
        },
        punch = {
            up = love.graphics.newImage(imgPath .. "punch_up.png"),
            down = love.graphics.newImage(imgPath .. "punch_down.png"),
            left = love.graphics.newImage(imgPath .. "punch_side.png"),
            right = love.graphics.newImage(imgPath .. "punch_side_right.png")
        }
    }

    local grid = anim8.newGrid(32, 32, 256, 32)
    local baseIdle  = anim8.newAnimation(grid("1-8", 1), 0.1)
    local baseRun   = anim8.newAnimation(grid("1-8", 1), 0.1)
    local basePunch = anim8.newAnimation(grid("1-8", 1), 0.1)
    basePunch:onLoop(function() basePunch:pause() end)
    player.sharedPunchAnim = basePunch:clone()

    player.anims = {
        idle = { up = baseIdle:clone(), down = baseIdle:clone(), left = baseIdle:clone(), right = baseIdle:clone() },
        run  = { up = baseRun:clone(),  down = baseRun:clone(),  left = baseRun:clone(),  right = baseRun:clone() },
        punch= { up = player.sharedPunchAnim, down = player.sharedPunchAnim, left = player.sharedPunchAnim, right = player.sharedPunchAnim }
    }

    player.anim = player.anims.idle.down
end

function player.update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()
    player.justPunched = false

    local moveX, moveY = 0, 0
    local moving = false
    if love.keyboard.isDown("d", "right") then moveX, player.dir, moving = moveX + 1, "right", true end
    if love.keyboard.isDown("a", "left")  then moveX, player.dir, moving = moveX - 1, "left", true end
    if love.keyboard.isDown("w", "up")    then moveY, player.dir, moving = moveY - 1, "up", true end
    if love.keyboard.isDown("s", "down")  then moveY, player.dir, moving = moveY + 1, "down", true end

    local len = math.sqrt(moveX^2 + moveY^2)
    if len > 0 then moveX, moveY = moveX / len, moveY / len end

    local mouseDown = love.mouse.isDown(1)
    local mousePressed = mouseDown and not player.mouseWasDown
    local punchAnim = player.sharedPunchAnim

    -- handle punch state
    if mousePressed and player.state ~= "punch" then
        player.state = "punch"
        player.lastCombatTime = love.timer.getTime()
        punchAnim:gotoFrame(1)
        punchAnim:resume()
    elseif player.state == "punch" then
        punchAnim:update(dt)

        -- play whoosh for air punches
        if punchAnim.position == 2 and not punchAnim.hit1Played then
            local s1 = soundHandler.punchWhoosh:clone()
            s1:setPitch(0.5 + math.random()*0.5)
            s1:play()
            punchAnim.hit1Played = true
        end
        if punchAnim.position == 5 and not punchAnim.hit2Played then
            local s2 = soundHandler.punchWhoosh:clone()
            s2:setPitch(0.5 + math.random()*0.5)
            s2:play()
            punchAnim.hit2Played = true
        end

        -- reset flags
        if punchAnim.position == #punchAnim.frames then
            punchAnim:gotoFrame(1)
            punchAnim:pause()
            punchAnim.hit1Played = false
            punchAnim.hit2Played = false
            player.state = moving and "run" or "idle"
        end
    else
        player.state = moving and "run" or "idle"
    end

    -- movement sounds
    if moving then
        player.collider:setLinearVelocity(moveX * player.speed, moveY * player.speed)
        player.walkTimer = player.walkTimer - dt
        if player.walkTimer <= 0 then
            local stepSound = soundHandler.footstep:clone()
            stepSound:setPitch(0.9 + math.random()*0.2)
            stepSound:play()
            player.walkTimer = 0.4
        end
    else
        player.collider:setLinearVelocity(0, 0)
        player.walkTimer = 0
    end

    local mapHandler = require("mapHandler")
    local map = mapHandler.gameMap1
    if map then
        local scale = mapHandler.scale
        local tileW, tileH = map.tilewidth * scale, map.tileheight * scale
        local mapW, mapH = map.width * tileW, map.height * tileH
        local clampedX = math.max(0, math.min(player.x, mapW))
        local clampedY = math.max(0, math.min(player.y, mapH))
        player.collider:setPosition(clampedX, clampedY)
    end

    player.anim = player.anims[player.state][player.dir]
    player.anim:update(dt)
    player.mouseWasDown = mouseDown

    -- healing logic
    local now = love.timer.getTime()
    local timeSinceCombat = now - player.lastCombatTime

    -- only heal if not in combat for 30s AND not full HP
    if timeSinceCombat >= player.healDelay and player.health < player.maxHealth then
        player.healTimer = player.healTimer + dt
        if player.healTimer >= 1 then
            player.health = math.min(player.maxHealth, player.health + player.healRate)
            player.healTimer = 0
        end
    else
        -- stop healing if in combat or full HP
        player.healTimer = 0
    end

    -- if fully healed, reset combat timer so regen won't instantly restart
    if player.health >= player.maxHealth then
        player.lastCombatTime = now
    end

end

function player.draw()
    local scale = 7
    local frameW, frameH = 32*scale, 32*scale

    local bx, by, bw, bh = player.getPunchBox()
    love.graphics.setColor(1,0,0,0.5)
    love.graphics.rectangle("line", bx, by, bw, bh)
    love.graphics.setColor(1,1,1,1)

    player.anim:draw(
        player.images[player.state][player.dir],
        player.x - frameW/2,
        player.y - frameH/2,
        nil, scale, scale
    )
end

function player.drawHealth()
    if player.health >= player.maxHealth then return end

    local barW, barH = 100, 8
    local x, y = player.x - barW/2, player.y - 80
    local fill = barW * (player.health / player.maxHealth)

    love.graphics.setColor(0,0,0,0.6)
    love.graphics.rectangle("fill", x, y, barW, barH, barH/2, barH/2)

    love.graphics.setColor(0,1,0)
    love.graphics.rectangle("fill", x, y, fill, barH, barH/2, barH/2)

    love.graphics.setColor(1,1,1)
end

return player
