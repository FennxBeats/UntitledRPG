-- enemy.lua
local Slime = {}
Slime.__index = Slime

function Slime.new(x, y)
    local self = setmetatable({}, Slime)
    self.x = x or 0
    self.y = y or 0
    self.radius = 16  -- placeholder size
    self.speed = 80   -- pixels per second
    return self
end

function Slime:update(dt, player)
    -- simple behaviour: move toward player
    local dx = player.x - self.x
    local dy = player.y - self.y
    local dist = math.sqrt(dx*dx + dy*dy)
    if dist > 0 then
        self.x = self.x + (dx/dist) * self.speed * dt
        self.y = self.y + (dy/dist) * self.speed * dt
    end
end

function Slime:draw()
    love.graphics.setColor(1, 0, 0)  -- red enemy
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(1, 1, 1)  -- reset color
end

return Slime
