local worldHandler = require "worldHandler"
local anim8 = require "libs/anim8"

local player = {
    speed = 300, -- pixels per second
    dir = "down",
    state = "idle",
    mouseWasDown = false,
    offsetY = 45 -- adjust this for sprite alignment
}

function player.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    player.collider = worldHandler.world:newRectangleCollider(400, 270, 60, 90)
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
    local moveX, moveY = 0, 0
    local moving = false

    -- movement input
    if love.keyboard.isDown("d", "right") then moveX, player.dir, moving = moveX + 1, "right", true end
    if love.keyboard.isDown("a", "left")  then moveX, player.dir, moving = moveX - 1, "left", true end
    if love.keyboard.isDown("w", "up")    then moveY, player.dir, moving = moveY - 1, "up", true end
    if love.keyboard.isDown("s", "down")  then moveY, player.dir, moving = moveY + 1, "down", true end

    -- normalize movement
    local len = math.sqrt(moveX^2 + moveY^2)
    if len > 0 then moveX, moveY = moveX / len, moveY / len end

    -- handle punch logic
    local mouseDown = love.mouse.isDown(1)
    local mousePressed = mouseDown and not player.mouseWasDown
    local punchAnim = player.sharedPunchAnim

    if mousePressed and player.state ~= "punch" then
        player.state = "punch"
        punchAnim:gotoFrame(1)
        punchAnim:resume()
    elseif player.state == "punch" then
        punchAnim:update(dt)
        if punchAnim.position == #punchAnim.frames then
            punchAnim:gotoFrame(1)
            punchAnim:pause()
            player.state = moving and "run" or "idle"
        end
    else
        player.state = moving and "run" or "idle"
    end
    player.mouseWasDown = mouseDown

    if moving then
        player.collider:setLinearVelocity(moveX * player.speed, moveY * player.speed)
    else
        player.collider:setLinearVelocity(0, 0)
    end

    -- update position from collider
    player.x, player.y = player.collider:getPosition()

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

    -- update current animation
    player.anim = player.anims[player.state][player.dir]
    player.anim:update(dt)
end

function player.draw()
    local scale = 7
    player.anim:draw(
    player.images[player.state][player.dir],
    player.x, player.y,
    nil, scale, scale, 3.5, 3.5
)

end

return player
