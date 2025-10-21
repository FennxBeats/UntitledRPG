local soundHandler = require "soundHandler"

local UIHandler = {}

UIHandler.paused = false
UIHandler.menuState = "pause" -- "pause" or "options"

local mainFont = love.graphics.newFont("assets/fonts/Hey Comic.ttf", 26)
local boldFont = love.graphics.newFont("assets/fonts/Hey Comic.ttf", 48)

local pauseMenuBg
local resumeBtn
local quitBtn
local optBtn
local backBtn

local screenW, screenH
local menuX, menuY
local buttonSpacing = 220
local buttonScale = 0.5
local bgScale = 0.8

local hoveredButton = nil

-- slider data
local musicSlider = {x = 0, y = 0, w = 400, h = 10, value = 0.2}
local sfxSlider   = {x = 0, y = 0, w = 400, h = 10, value = 0.5}
local dragging = nil

function UIHandler.load()

    pauseMenuBg = love.graphics.newImage("assets/ui/BoxesBanners/Box_Orange_Rounded.png")
    resumeBtn = love.graphics.newImage("assets/ui/ButtonsText/PremadeButtons_Resume.png")
    quitBtn   = love.graphics.newImage("assets/ui/ButtonsText/PremadeButtons_ExitOrange.png")
    optBtn    = love.graphics.newImage("assets/ui/ButtonsText/PremadeButtons_Options.png")
    backBtn   = love.graphics.newImage("assets/ui/ButtonsText/PremadeButtons_Check.png")

    screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
    menuX = screenW / 2
    menuY = screenH / 2

    musicSlider.x = menuX - musicSlider.w / 2
    musicSlider.y = menuY - 50
    sfxSlider.x = menuX - sfxSlider.w / 2
    sfxSlider.y = menuY + 50
end

function UIHandler.keypressed(key)
    if key == "escape" then
        if UIHandler.menuState == "pause" then
            UIHandler.paused = not UIHandler.paused
        elseif UIHandler.menuState == "options" then
            UIHandler.menuState = "pause"
        end
    end
end

function UIHandler.mousemoved(x, y)
    if not UIHandler.paused then return end
    hoveredButton = nil

    local buttons = {}

    if UIHandler.menuState == "pause" then
        buttons = {
            {name = "resume", y = menuY - 250, img = resumeBtn},
            {name = "opt",    y = menuY - 250 + buttonSpacing, img = optBtn},
            {name = "quit",   y = menuY - 250 + buttonSpacing * 2, img = quitBtn}
        }
    elseif UIHandler.menuState == "options" then
        buttons = {
            {name = "back", y = menuY + 150, img = backBtn}
        }
    end

    for _, btn in ipairs(buttons) do
        local w = btn.img:getWidth() * buttonScale
        local h = btn.img:getHeight() * buttonScale
        local bx = menuX - w / 2
        local by = btn.y
        if x > bx and x < bx + w and y > by and y < by + h then
            hoveredButton = btn.name
        end
    end

    if dragging == "music" then
        musicSlider.value = math.max(0, math.min(1, (x - musicSlider.x) / musicSlider.w))
        UIHandler.updateVolumes()
    elseif dragging == "sfx" then
        sfxSlider.value = math.max(0, math.min(1, (x - sfxSlider.x) / sfxSlider.w))
        UIHandler.updateVolumes()
    end
end

function UIHandler.mousepressed(x, y, button)
    if not UIHandler.paused or button ~= 1 then return end

    if UIHandler.menuState == "pause" then
        if hoveredButton == "resume" then
            UIHandler.paused = false
        elseif hoveredButton == "opt" then
            UIHandler.menuState = "options"
        elseif hoveredButton == "quit" then
            love.event.quit()
        end
    elseif UIHandler.menuState == "options" then
        if hoveredButton == "back" then
            UIHandler.menuState = "pause"
        end

        -- check sliders
        if x > musicSlider.x and x < musicSlider.x + musicSlider.w and y > musicSlider.y - 10 and y < musicSlider.y + 20 then
            dragging = "music"
        elseif x > sfxSlider.x and x < sfxSlider.x + sfxSlider.w and y > sfxSlider.y - 10 and y < sfxSlider.y + 20 then
            dragging = "sfx"
        end
    end
end

function UIHandler.mousereleased(_, _, button)
    if button == 1 then
        dragging = nil
    end
end

function UIHandler.updateVolumes()
    if not soundHandler then return end
    soundHandler.musicVolume = musicSlider.value
    soundHandler.sfxVolume = sfxSlider.value
    soundHandler.applyVolumes()
end

function UIHandler.update(dt)
    if UIHandler.paused then return end
end

function UIHandler.draw()
    if not UIHandler.paused then return end

    -- dim background
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    love.graphics.setColor(1, 1, 1, 1)

    -- draw menu background
    local bgW = pauseMenuBg:getWidth() * bgScale
    local bgH = pauseMenuBg:getHeight() * bgScale
    love.graphics.draw(pauseMenuBg, menuX - bgW/2, menuY - bgH/2, 0, bgScale, bgScale)

    -- button draw helper
    local function drawButton(img, y, name)
        love.graphics.setFont(mainFont)
        local scale = buttonScale
        if hoveredButton == name then
            love.graphics.setColor(1, 1, 0.8, 1)
            scale = scale * 1.1
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.draw(img, menuX - (img:getWidth() * scale)/2, y, 0, scale, scale)
    end

    if UIHandler.menuState == "pause" then
        drawButton(resumeBtn, menuY - 250, "resume")
        drawButton(optBtn,    menuY - 250 + buttonSpacing, "opt")
        drawButton(quitBtn,   menuY - 250 + buttonSpacing * 2, "quit")

    elseif UIHandler.menuState == "options" then
        love.graphics.setFont(boldFont)
        love.graphics.printf("OPTIONS MENU", 0, menuY - 150, screenW, "center")
        love.graphics.setFont(mainFont)

        local function drawSlider(label, slider)
            local knobX = slider.x + slider.w * slider.value
            local knobY = slider.y

            -- label
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(label, 0, slider.y - 40, screenW, "center")

            -- bright orange cylinder bar
            love.graphics.setColor(1, 0.5, 0)
            love.graphics.setLineWidth(10)
            love.graphics.line(slider.x, knobY, slider.x + slider.w, knobY)

            -- round end caps
            love.graphics.circle("fill", slider.x, knobY, 5)
            love.graphics.circle("fill", slider.x + slider.w, knobY, 5)

            -- knob (bright orange)
            love.graphics.setColor(1, 0.7, 0)
            love.graphics.circle("fill", knobX, knobY, 12)
            love.graphics.setColor(1, 0.3, 0)
            love.graphics.circle("line", knobX, knobY, 12)
        end

        drawSlider("Music Volume", musicSlider)
        drawSlider("SFX Volume", sfxSlider)
        drawButton(backBtn, menuY + 150, "back")
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return UIHandler
