local debug = false
local next_debug_toggle = 0

function love.load()

end

function love.update(delta)
    if love.keyboard.isDown("escape") then love.event.quit() end
    if love.keyboard.isDown("f4") and next_debug_toggle < love.timer.getTime() then
        debug = not debug
        next_debug_toggle = love.timer.getTime() + 0.2
    end
end

function love.draw()

end