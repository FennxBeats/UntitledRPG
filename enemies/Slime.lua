-- enemies/Slime.lua
local Slime = {}
Slime.__index = Slime

local worldHandler = require "worldHandler"

local function loadFrames(basePath, prefix, frameCount)
    local frames = {}
    for i = 1, frameCount do
        frames[i] = love.graphics.newImage(basePath .. prefix .. i .. ".png")
    end
    return frames
end

function Slime.new(x, y)
    local self = setmetatable({}, Slime)
    self.x, self.y = x or 0, y or 0

    -- Collider (simple rectangle, no classes)
    self.collider = worldHandler.world:newRectangleCollider(self.x, self.y, 40, 40)
    self.collider:setFixedRotation(true)
    self.collider:setType("dynamic")

    -- Base stats
    self.speed = 120
    self.health = 60
    self.damage = 10
    self.attackCooldown = 1.0
    self.attackTimer = 0

    -- Animation setup
    local base = "assets/enemies/slime/"
    self.animations = {
        idle = {
            left = loadFrames(base, "idleLeft/idleLeft", 9),
            right = loadFrames(base, "idleRight/idleRight", 9)
        },
        walk = {
            left = loadFrames(base, "runLeft/runLeft", 7),
            right = loadFrames(base, "runRight/run", 7)
        },
        die = {
            left = loadFrames(base, "deadLeft/deadLeft", 5),
            right = loadFrames(base, "deadRight/dead", 5)
        }
    }

    -- Animation / state
    self.state = "idle"
    self.dir = "right"
    self.frame = 1
    self.frameTimer = 0
    self.frameSpeed = 0.12
    self.isAlive = true
    self.dead = false

    -- knockback + flash vars
    self.vx, self.vy = 0, 0
    self.isFlashing = false
    self.flashTimer = 0
    self.knockbackForce = 200
    self.flashDuration = 0.1

    return self
end

function Slime:update(dt, player)
    -- Always keep x/y synced to collider if it exists
    if self.collider then
        self.x = self.collider:getX()
        self.y = self.collider:getY()
    end

    -- death handling
    if self.state == "die" then
        self.frameTimer = self.frameTimer + dt
        if self.frameTimer >= self.frameSpeed then
            self.frameTimer = 0
            self.frame = self.frame + 1
            if self.frame > #self.animations.die[self.dir] then
                self.dead = true
            end
        end
        return
    end

    if not self.isAlive then return end

    if self.knockbackTimer and self.knockbackTimer > 0 then
        -- set physics velocity
        if self.collider then
            self.collider:setLinearVelocity(self.vx, self.vy)
        end

        -- damp velocities over time
        self.vx = self.vx * (1 - math.min(1, 6 * dt))
        self.vy = self.vy * (1 - math.min(1, 6 * dt))

        self.knockbackTimer = self.knockbackTimer - dt
        if self.knockbackTimer <= 0 then
            self.knockbackTimer = 0
            if self.collider then
                self.collider:setLinearVelocity(0, 0)
            end
            self.vx, self.vy = 0, 0
        end
    else
        -- Normal AI movement: chase player using physics velocity
        local dx, dy = player.x - self.x, player.y - self.y
        local dist = math.sqrt(dx*dx + dy*dy)
        local attackRange = 40

        -- DEBUG: Add these prints to see what's happening
        if love.keyboard.isDown("f1") then
            print("Slime debug:")
            print("  Distance to player:", dist)
            print("  Attack range:", attackRange)
            print("  In range:", dist <= attackRange)
            print("  Attack timer:", self.attackTimer)
            print("  Can attack:", self.attackTimer <= 0)
            print("  Player health:", player.health)
        end

        -- SIMPLE: Deal damage every second when player is in range
        if dist <= attackRange then
            -- Player is in range - deal damage every second
            self.attackTimer = self.attackTimer - dt
            if self.attackTimer <= 0 then
                print("SLIME IS ABOUT TO ATTACK PLAYER!")
                player:takeDamage(self.damage)
                self.attackTimer = self.attackCooldown
                print("Player took damage! Health:", player.health)
            end
            -- Stop moving when attacking
            if self.collider then
                self.collider:setLinearVelocity(0, 0)
            end
            self.state = "idle"
        else
            -- Player is out of range - chase
            self.state = "walk"
            local nx, ny = dx / dist, dy / dist
            local vx, vy = nx * self.speed, ny * self.speed
            if self.collider then
                self.collider:setLinearVelocity(vx, vy)
            end
        end

        if dx < 0 then self.dir = "left" else self.dir = "right" end
    end

    -- flash timer
    if self.isFlashing then
        self.flashTimer = self.flashTimer - dt
        if self.flashTimer <= 0 then self.isFlashing = false end
    end

    -- sync x/y from collider after physics change
    if self.collider then
        self.x, self.y = self.collider:getPosition()
    end

    -- clamp inside map bounds
    local mapHandler = require("mapHandler")
    local map = mapHandler.gameMap1
    if map then
        local scale = mapHandler.scale
        local tileW, tileH = map.tilewidth * scale, map.tileheight * scale
        local mapW, mapH = map.width * tileW, map.height * tileH
        local clampedX = math.max(0, math.min(self.x, mapW))
        local clampedY = math.max(0, math.min(self.y, mapH))
        if self.collider then
            self.collider:setPosition(clampedX, clampedY)
            self.x, self.y = self.collider:getPosition()
        end
    end

    -- animation
    self.frameTimer = self.frameTimer + dt
    if self.frameTimer >= self.frameSpeed then
        self.frameTimer = 0
        local animSet = self.animations[self.state] and self.animations[self.state][self.dir]
        if animSet then
            self.frame = self.frame + 1
            if self.frame > #animSet then 
                self.frame = 1
            end
        end
    end
end

function Slime:takeDamage(amount, sourceX, sourceY)
    self.health = self.health - amount
    if self.health <= 0 and self.isAlive then
        self.isAlive = false
        self:onDeath()
        return
    end

    -- knockback
    if sourceX and sourceY and self.collider then
        local dx, dy = self.x - sourceX, self.y - sourceY
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist > 0 then
            local force = self.knockbackForce or 200
            self.vx = (dx / dist) * force
            self.vy = (dy / dist) * force
            self.collider:setLinearVelocity(self.vx, self.vy)
            self.knockbackTimer = 0.18
        end
    end

    -- flash
    self.isFlashing = true
    self.flashTimer = self.flashDuration or 0.1
end

function Slime:onDeath()
    self.state = "die"
    self.frame = 1
    self.frameTimer = 0
    if self.collider then
        self.collider:setLinearVelocity(0, 0)
        self.collider:destroy()
        self.collider = nil
    end
end

function Slime:draw()
    if self.dead then return end
    local scale = 5
    local animSet = self.animations[self.state] and self.animations[self.state][self.dir]
    if not animSet then return end
    if self.frame > #animSet then self.frame = 1 end
    local img = animSet[self.frame]
    if not img then return end

    if self.isFlashing then
        love.graphics.setColor(1, 0.5, 0.5)
    else
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.draw(img, self.x, self.y, 0, scale, scale, img:getWidth() / 2, img:getHeight() / 2)
    love.graphics.setColor(1, 1, 1)

    -- debug collider
    if self.collider and self.isAlive then
        love.graphics.setColor(1, 0, 0, 0.8)
        local cx, cy = self.collider:getPosition()
        local cw, ch = 40, 40
        love.graphics.rectangle("line", cx - cw / 2, cy - ch / 2, cw, ch)
        love.graphics.setColor(1, 1, 1)
    end

    -- debug attack range
    love.graphics.setColor(1, 0, 0, 0.3)
    love.graphics.circle("line", self.x, self.y, 40)
    love.graphics.setColor(1, 1, 1)
end

return Slime