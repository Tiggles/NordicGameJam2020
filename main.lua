require "inventory"
require "customer"

local debug = false
local next_debug_toggle = 0

local concept_store
local witch_front
local witch_back
local speech_bubble
local customer_sprites = {}
local responses = {
    accept = { "I have just the thing", "Follow me", "Sure, this way" },
    postpone = { "I'm out of ingredients, \ncan you come back\nlater?", "Sorry, but we're out for now."},
    decline = {"I don't have anything \nfor that, sorry.", "Hmm, no. Sorry."}
}
local game_state = {
    inventory = Inventory:new(),
    customers = {},
    finished_customers = {},
    paused = false,
    clock = { 10, 0},
    queued_response = {
        accept = responses.accept[love.math.random(#responses.accept)],
        postpone = responses.postpone[love.math.random(#responses.postpone)],
        decline = responses.decline[love.math.random(#responses.decline)]
    }
}

local accept_box = {x = 485, y = 200, width = 375, height = 80}
local postpone_box = {x = 485, y = accept_box.y + accept_box.height + 15, width = 375, height = 80}
local decline_box = {x = 485, y = postpone_box.y + postpone_box.height + 15, width = 375, height = 80}

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
    love.graphics.draw(concept_store)

    for i = 1, #game_state.customers do
        local c = game_state.customers[i]
        love.graphics.draw(customer_sprites[c.color], 190, 220 + i * 60, 0, 4, 4)
    end

    if active_customer then
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(game_state.customers[1]:get_line(), 550, 50, 0)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("line", accept_box.x, accept_box.y, accept_box.width, accept_box.height)
        love.graphics.rectangle("line", postpone_box.x, postpone_box.y, postpone_box.width, postpone_box.height)
        love.graphics.rectangle("line", decline_box.x, decline_box.y, decline_box.width, decline_box.height)
    end

    if game_state.paused then love.graphics.print("PAUSED. Press escape to unpause.") end
end

local function dialog_update()

end