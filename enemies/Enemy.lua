-- enemies/Enemy.lua
local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y, img, frameW, frameH, frameCount, speed, health, damage)
    local self = setmetatable({}, Enemy)
    self.x, self.y = x, y
    self.img = img
    self.frameW, self.frameH = frameW, frameH
    self.frameCount = frameCount or 1
    self.speed = speed or 100
    self.health = health or 20
    self.damage = damage or 10
    self.currentFrame = 1
    self.timer = 0
    self.animSpeed = 0.15
    self.isAlive = true
    return self
end

function Enemy:update(dt, player)
    if not self.isAlive then return end
    local dx, dy = player.x - self.x, player.y - self.y
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist > 0 then
        self.x = self.x + (dx/dist) * self.speed * dt
        self.y = self.y + (dy/dist) * self.speed * dt
    end

    self.timer = self.timer + dt
    if self.timer > self.animSpeed then
        self.timer = 0
        self.currentFrame = self.currentFrame % self.frameCount + 1
    end

    -- simple hit check
    if dist < 40 then
        player.takeDamage(self.damage)
    end
end

function Enemy:draw()
    if not self.isAlive then return end
    local quad = love.graphics.newQuad(
        (self.currentFrame - 1) * self.frameW, 0,
        self.frameW, self.frameH,
        self.img:getDimensions()
    )
    love.graphics.draw(self.img, quad, self.x, self.y, 0, 5, 5, self.frameW / 2, self.frameH / 2)
end

function Enemy:takeDamage(amount)
    self.health = self.health - amount
    if self.health <= 0 and self.isAlive then
        self.health = 0
        self.isAlive = false
        if self.onDeath then self:onDeath() end
    end
end




return Enemy
