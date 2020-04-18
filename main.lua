local debug = false
local next_debug_toggle = 0
local concept_store

function love.load()
    concept_store = love.graphics.newImage("Assets/concept.jpg")
end

function love.update(delta)
    if love.keyboard.isDown("escape") then love.event.quit() end
    if love.keyboard.isDown("f4") and next_debug_toggle < love.timer.getTime() then
        debug = not debug
        next_debug_toggle = love.timer.getTime() + 0.2
    end

    -- At start of day, calculate when customers appear

    -- skip time faster if no customers present

    -- Add dialog options if customer is requesting something.
end

function love.draw()
    -- Draw shop
    love.graphics.draw(concept_store)
    -- Draw player

    -- Draw customers
end