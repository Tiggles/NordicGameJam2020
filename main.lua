require "inventory"
require "customer"

local debug = false
local next_debug_toggle = 0

local concept_store
local witch_front
local witch_back
local speech_bubble
local customer_sprites = {}
local game_state = {
    inventory = Inventory:new(),
    customers = {},
    finished_customers = {},
    paused = false
}

local responses = {
    accept = { "I have just the thing", "Follow me", "Sure, this way" },
    postpone = { "I'm out of ingredients, \ncan you come back\nlater?", "Sorry, but we're out for now."},
    decline = {"I don't have anything \nfor that, sorry.", "Hmm, no. Sorry."}
}

local update = function() end
local draw = function() end

function love.load()
    concept_store = love.graphics.newImage("Assets/store.jpg")
    witch_front = love.graphics.newImage("Assets/witch_front.png")
    witch_back = love.graphics.newImage("Assets/witch_back.png")
    speech_bubble = love.graphics.newImage("Assets/speech_bubble.png")
    table.insert(customer_sprites, love.graphics.newImage("Assets/customer_blue.png"))
    table.insert(game_state.customers, Customer:new())
    table.insert(game_state.customers, Customer:new())
    table.insert(game_state.customers, Customer:new())
    -- love.graphics.setColor(0, 0, 0)
end

function love.update(delta)
    if game_state.paused then return end
    if love.keyboard.isDown("escape") then love.event.quit() end
    if love.keyboard.isDown("f4") and next_debug_toggle < love.timer.getTime() then
        debug = not debug
        next_debug_toggle = love.timer.getTime() + 0.2
    end

    local active_customer = game_state.customers[1] ~= nil
    update()
    -- At start of day, calculate when customers appear

    -- skip time faster if no customers present

    -- Add dialog options if customer is requesting something.
end

function love.draw()
    local active_customer = game_state.customers[1] ~= nil
    -- Draw shop
    love.graphics.draw(concept_store)
    -- Draw player

    for i = #game_state.customers, 1, -1 do
        local c = game_state.customers[i]
        love.graphics.draw(customer_sprites[c.color], 285, 260 - i * 60, 0, 4, 4)
    end


    if active_customer then -- should be (game_state.active_customer)
        love.graphics.draw(speech_bubble, 5, 5, 0, 6, 4)
        -- Accept box
        love.graphics.draw(speech_bubble, 400, 200, 0, 3, 1)
        -- Postpone box
        love.graphics.draw(speech_bubble, 400, 300, 0, 3, 1)
        -- Decline box
        love.graphics.draw(speech_bubble, 400, 250, 0, 3, 1)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(responses.accept[1], 410, 215)
        love.graphics.print(responses.postpone[1], 410, 255)
        love.graphics.print(responses.decline[1], 410, 315)
        love.graphics.print(game_state.customers[1]:get_line(), 30, 50, 0)
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.draw(witch_back, 240, 430, 0, 3, 3)

    if game_state.paused then love.graphics.print("PAUSED. Press escape to unpause.") end
end

function dialog_update()

end