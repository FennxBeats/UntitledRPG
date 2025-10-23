-- worldHandler.lua
local wf = require "libs/windfield"

local worldHandler = {}

worldHandler.world = wf.newWorld(0, 0)

function worldHandler.load()
    -- No collision classes needed
end

function worldHandler.update(dt)
    worldHandler.world:update(dt)
end

function worldHandler.draw()
    worldHandler.world:draw()
end

return worldHandler