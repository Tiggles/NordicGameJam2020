require "inventory"
require "customer"

local debug = false
local next_action_allowed = 0

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
    postponed_customers = {},
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
    if love.keyboard.isDown("f4") and next_action_allowed < love.timer.getTime() then
        debug = not debug
        next_action_allowed = love.timer.getTime() + 0.2
    end

    local active_customer = game_state.customers[1] ~= nil
    update()

    if active_customer and next_action_allowed < love.timer.getTime() and love.mouse.isDown("1") then
        local x, y = love.mouse.getPosition()
        if is_colliding({x = x, y = y}, accept_box) then
            print("Accept")
            next_action_allowed = love.timer.getTime() + 0.2
        elseif is_colliding({x=x, y=y}, postpone_box) then
            print("Postpone")
            table.insert(game_state.postponed_customers, game_state.customers[1])
            table.remove(game_state.customers, 1)
            next_action_allowed = love.timer.getTime() + 0.2
        elseif is_colliding({x=x, y=y}, decline_box) then
            print("Decline")
            table.remove(game_state.customers, 1)
            next_action_allowed = love.timer.getTime() + 0.2
        else
            print("--------------------------")
        end
    end
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
        if debug then
            love.graphics.rectangle("line", accept_box.x, accept_box.y, accept_box.width, accept_box.height)
            love.graphics.rectangle("line", postpone_box.x, postpone_box.y, postpone_box.width, postpone_box.height)
            love.graphics.rectangle("line", decline_box.x, decline_box.y, decline_box.width, decline_box.height)
        end
        love.graphics.print(game_state.queued_response.accept, accept_box.x + 5, accept_box.y + 10)
        love.graphics.print(game_state.queued_response.postpone , postpone_box.x + 5, postpone_box.y + 10)
        love.graphics.print(game_state.queued_response.decline, decline_box.x + 5, decline_box.y + 10)
    end

    if game_state.paused then love.graphics.print("PAUSED. Press escape to unpause.") end
end

function is_colliding(point, box)
    return point.x > box.x and point.x < box.width + box.x and point.y > box.y and point.y < box.y + box.height
end

local function dialog_update()

end