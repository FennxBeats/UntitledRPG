-- enemies/Slime.lua
local Enemy = require("enemies.Enemy")
local Slime = setmetatable({}, { __index = Enemy })
Slime.__index = Slime

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
    self.speed = 60
    self.health = 30
    self.damage = 10
    self.attackCooldown = 1.0 -- seconds between hits
    self.attackTimer = 0

    local base = "assets/enemies/slime/"
    self.animations = {
        idle = {
            left = loadFrames(base, "idleLeft/idleLeft", 9),
            right = loadFrames(base, "idleRight/idleRight", 9),
        },
        walk = {
            left = loadFrames(base, "runLeft/runLeft", 7),
            right = loadFrames(base, "runRight/run", 7),
        },
        attack = {
            left = loadFrames(base, "hitLeft/hitLeft", 5),
            right = loadFrames(base, "hitRight/hit", 5),
        },
        die = {
            left = loadFrames(base, "deadLeft/deadLeft", 5),
            right = loadFrames(base, "deadRight/dead", 5),
        }
    }

    self.state = "idle"
    self.dir = "right"
    self.frame = 1
    self.frameTimer = 0
    self.frameSpeed = 0.12
    self.isAlive = true
    return self
end

function Slime:update(dt, player)
    if self.state == "die" then
        -- play death frames once, then remove
        self.frameTimer = self.frameTimer + dt
        if self.frameTimer >= self.frameSpeed then
            self.frameTimer = 0
            self.frame = self.frame + 1
            if self.frame > #self.animations.die[self.dir] then
                self.dead = true -- mark for removal
            end
        end
        return
    end

    if not self.isAlive then return end

    local dx, dy = player.x - self.x, player.y - self.y
    local dist = math.sqrt(dx*dx + dy*dy)

    if dist > 40 then
        self.state = "walk"
        self.x = self.x + (dx/dist) * self.speed * dt
        self.y = self.y + (dy/dist) * self.speed * dt
    else
        self.state = "attack"
    end

    if dx < 0 then self.dir = "left" else self.dir = "right" end

    -- animation frame
    self.frameTimer = self.frameTimer + dt
    if self.frameTimer >= self.frameSpeed then
        self.frameTimer = 0
        local animSet = self.animations[self.state][self.dir]
        self.frame = self.frame + 1
        if self.frame > #animSet then self.frame = 1 end
    end

    -- attack cooldown
    self.attackTimer = math.max(0, self.attackTimer - dt)
    if self.state == "attack" and self.attackTimer <= 0 then
        player.takeDamage(self.damage)
        self.attackTimer = self.attackCooldown
    end
end
    -- attack cooldown
    self.attackTimer = math.max(0, self.attackTimer - dt)
    if self.state == "attack" and self.attackTimer <= 0 then
        player.takeDamage(self.damage)
        self.attackTimer = self.attackCooldown
    end

-- put this near the other functions inside Slime.lua
function Slime:onDeath()
    self.state = "die"
    self.frame = 1
    self.deathTimer = 0
    self.frameTimer = 0
end


function Slime:draw()
    if self.dead then return end
    local animSet = self.animations[self.state][self.dir]
    local img = animSet[self.frame]
    local scale = 5
    love.graphics.draw(img, self.x, self.y, 0, scale, scale, img:getWidth()/2, img:getHeight()/2)
end


return Slime
