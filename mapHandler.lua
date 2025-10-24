local worldHandler = require "worldHandler"
local sti = require "libs/sti"

local mapHandler = {}

mapHandler.scale = 7
mapHandler.currentMapName = nil
mapHandler.maps = {}

-- For backwards compatibility
mapHandler.gameMap1 = nil

-- Load a map
function mapHandler.load(mapName)
    mapName = mapName or "map1"

    if mapName == "map1" then
        mapHandler.maps[mapName] = sti("assets/maps/map1.lua")
        mapHandler.gameMap1 = mapHandler.maps[mapName]
    elseif mapName == "map2" then
        mapHandler.maps[mapName] = sti("assets/maps/map2.lua")
    else
        error("Unknown map: "..mapName)
    end

    mapHandler.currentMapName = mapName
end

function mapHandler.getActiveMap()
    return mapHandler.maps[mapHandler.currentMapName] or mapHandler.gameMap1
end

function mapHandler.update(dt)
    local activeMap = mapHandler.getActiveMap()
    if activeMap then
        activeMap:update(dt)
    end
end

function mapHandler.drawFloor()
    local activeMap = mapHandler.getActiveMap()
    if not activeMap then return end

    love.graphics.push()
    love.graphics.scale(mapHandler.scale)
    if activeMap.layers["floor"] then
        activeMap:drawLayer(activeMap.layers["floor"])
    end
    love.graphics.pop()
end

function mapHandler.drawForeground()
    local activeMap = mapHandler.getActiveMap()
    if not activeMap then return end

    love.graphics.push()
    love.graphics.scale(mapHandler.scale)
    if activeMap.layers["foreground"] then
        activeMap:drawLayer(activeMap.layers["foreground"])
    end
    love.graphics.pop()
end

return mapHandler
