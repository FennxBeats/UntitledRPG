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

function Slime:new(x, y)
    local self = setmetatable({}, Slime)
    self.x, self.y = x or 0, y or 0
    
    -- Simple collider without classes
    self.collider = worldHandler.world:newRectangleCollider(x, y, 40, 40)
    self.collider:setFixedRotation(true)
    self.collider:setType('dynamic')
    
    self.speed = 120
    self.health = 60
    self.damage = 10
    self.attackCooldown = 1.0
    self.attackTimer = 0

    local base = "assets/enemies/slime/"
    self.animations = {
        idle = { left = loadFrames(base, "idleLeft/idleLeft", 9), right = loadFrames(base, "idleRight/idleRight", 9) },
        walk = { left = loadFrames(base, "runLeft/runLeft", 7), right = loadFrames(base, "runRight/run", 7) },
        attack = { left = loadFrames(base, "hitLeft/hitLeft", 5), right = loadFrames(base, "hitRight/hit", 5) },
        die = { left = loadFrames(base, "deadLeft/deadLeft", 5), right = loadFrames(base, "deadRight/dead", 5) }
    }

    self.state = "idle"
    self.dir = "right"
    self.frame = 1
    self.frameTimer = 0
    self.frameSpeed = 0.12
    self.isAlive = true
    self.dead = false

    -- knockback & flash
    self.vx = 0
    self.vy = 0
    self.isFlashing = false
    self.flashTimer = 0
    self.knockbackForce = 200
    self.flashDuration = 0.1

    return self
end

function Slime:update(dt, player)
    -- Update position from collider
    if self.collider then
        self.x = self.collider:getX()
        self.y = self.collider:getY()
    end

    if self.state == "die" then
        self.frameTimer = self.frameTimer + dt
        if self.frameTimer >= self.frameSpeed then
            self.frameTimer = 0
            self.frame = self.frame + 1
            if self.frame > #self.animations.die[self.dir] then
                self.dead = true
                if self.collider then
                    self.collider:destroy()
                    self.collider = nil
                end
            end
        end
        return
    end

    if not self.isAlive then return end

    -- knockback
    if self.vx ~= 0 or self.vy ~= 0 then
        self.x = self.x + self.vx * dt
        self.y = self.y + self.vy * dt
        self.vx = self.vx * 0.9
        self.vy = self.vy * 0.9
        if math.abs(self.vx) < 1 then self.vx = 0 end
        if math.abs(self.vy) < 1 then self.vy = 0 end
        
        -- Update collider position during knockback
        if self.collider then
            self.collider:setPosition(self.x, self.y)
        end
    else
        -- Normal movement - use your original direct position system
        local dx, dy = player.x - self.x, player.y - self.y
        local dist = math.sqrt(dx*dx + dy*dy)

        if dist > 40 then
            self.state = "walk"
            -- Move by directly updating position (your original system)
            self.x = self.x + (dx/dist) * self.speed * dt
            self.y = self.y + (dy/dist) * self.speed * dt
            
            -- Update collider position
            if self.collider then
                self.collider:setPosition(self.x, self.y)
            end
        else
            self.state = "attack"
        end

        if dx < 0 then self.dir = "left" else self.dir = "right" end
    end

    -- flash timer
    if self.isFlashing then
        self.flashTimer = self.flashTimer - dt
        if self.flashTimer <= 0 then
            self.isFlashing = false
        end
    end

    -- animation
    self.frameTimer = self.frameTimer + dt
    if self.frameTimer >= self.frameSpeed then
        self.frameTimer = 0
        local animSet = self.animations[self.state] and self.animations[self.state][self.dir]
        if animSet then
            self.frame = self.frame + 1
            if self.frame > #animSet then self.frame = 1 end
        end
    end

    -- attack cooldown
    self.attackTimer = math.max(0, self.attackTimer - dt)
    if self.state == "attack" and self.attackTimer <= 0 then
        player.takeDamage(self.damage)
        self.attackTimer = self.attackCooldown
    end
end

function Slime:takeDamage(amount, sourceX, sourceY)
    self.health = self.health - amount
    if self.health <= 0 and self.isAlive then
        self.isAlive = false
        self:onDeath()
    else
        -- knockback
        if sourceX and sourceY then
            local dx, dy = self.x - sourceX, self.y - sourceY
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist > 0 then
                local force = self.knockbackForce or 200
                self.vx = (dx / dist) * force
                self.vy = (dy / dist) * force
            end
        end
        -- flash
        self.isFlashing = true
        self.flashTimer = self.flashDuration or 0.1
    end
end

function Slime:onDeath()
    self.state = "die"
    self.frame = 1
    self.frameTimer = 0
    -- Stop movement when dead
    if self.collider then
        self.collider:setLinearVelocity(0, 0)
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
        love.graphics.setColor(1, 0.5, 0.5)  -- flash red
    else
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.draw(img, self.x, self.y, 0, scale, scale, img:getWidth()/2, img:getHeight()/2)
    love.graphics.setColor(1,1,1)
    
    -- Draw collider for debugging (always visible)
    if self.collider then
        love.graphics.setColor(1, 0, 0, 0.8)  -- Red with some transparency
        local cx, cy = self.collider:getPosition()
        local cw, ch = 40, 40  -- Same size as collider creation
        love.graphics.rectangle("line", cx - cw/2, cy - ch/2, cw, ch)
        love.graphics.setColor(1, 1, 1)
    end
end

return Slime