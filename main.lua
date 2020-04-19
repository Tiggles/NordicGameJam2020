require "inventory"
require "customer"

local debug = false
local next_action_allowed = 0

local store
local witch_front
local witch_back
local garden
local music
local potions = {}
local response_bubble
local customer_sprites = {}
local customer_head
local responses = {
    accept = { "I have just the thing", "Maybe this is for you?", "Sure, take this." },
    postpone = { "I'm out of ingredients, can you come back later?", "Sorry, but we're out for now."},
    decline = {"I don't have anything for that, sorry.", "Hmm, no. Sorry."}
}
local game_state = {
    inventory = Inventory:new(),
    customers = {},
    finished_customers = {},
    postponed_customers = {},
    paused = false,
    clock = {10, 0},
    queued_response = {
        accept = responses.accept[love.math.random(#responses.accept)],
        postpone = responses.postpone[love.math.random(#responses.postpone)],
        decline = responses.decline[love.math.random(#responses.decline)]
    },
    cauldrons = {},
    money = 200,
    current_location = "store"
}

local accept_box = {x = 500, y = 100, width = 345, height = 55}
local postpone_box = {x = 500, y = accept_box.y + accept_box.height + 15, width = 345, height = 55}
local decline_box = {x = 500, y = postpone_box.y + postpone_box.height + 15, width = 345, height = 55}
local goto_garden_button = {x = 700, y = 628, width = 160, height = 38}
local goto_store_button = {x = 7, y = 628, width = 185, height = 38}

local update = function() end
local draw = function() end

function love.load()
    love.graphics.setDefaultFilter( "nearest", "nearest")
    store = love.graphics.newImage("Assets/store.png")
    witch_front = love.graphics.newImage("Assets/witch_front.png")
    witch_back = love.graphics.newImage("Assets/witch_back.png")
    response_bubble = love.graphics.newImage("Assets/response_bubble.png")
    customer_head = love.graphics.newImage("Assets/customer_head.png")
    garden = love.graphics.newImage("Assets/garden.png")
    potions.strength = love.graphics.newImage("Assets/potion_strength.png")
    potions.speed = love.graphics.newImage("Assets/potion_speed.png")
    potions.nightvision = love.graphics.newImage("Assets/potion_nightvision.png")
    potions.underwater = love.graphics.newImage("Assets/potion_underwater.png")
    potions.endurance = love.graphics.newImage("Assets/potion_endurance.png")
    music = love.audio.newSource("Assets/elevator_music.wav", "static")
    music:setLooping(true)
    music:play()
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

    if game_state.current_location == "store" then
        if love.mouse.isDown("1") then
            local x, y = love.mouse.getPosition()
            if active_customer and next_action_allowed < love.timer.getTime() then
                if is_colliding({x = x, y = y}, accept_box) then
                    local power = game_state.customers[1]:get_power()
                    local remaining_potions = get_remaining_potions(power)
                    if remaining_potions ~= 0 then
                        game_state.inventory:use_potion(power)
                        table.remove(game_state.customers, 1)
                    end
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
                    print("None")
                end
            end
            if is_colliding({x=x, y=y}, goto_garden_button) then
                game_state.current_location = "garden"
                music:pause()
            else
            end
        end
    elseif game_state.current_location == "garden" then
        if love.mouse.isDown("1") then
            local x, y = love.mouse.getPosition()
            if is_colliding({x=x, y=y}, goto_store_button) then
                music:play()
                game_state.current_location = "store"
            end
        end
    end
    -- At start of day, calculate when customers appear

    -- skip time faster if no customers present

    -- Add dialog options if customer is requesting something.
end

function love.draw()
    local active_customer = game_state.customers[1] ~= nil

    if game_state.current_location == "store" then
        love.graphics.draw(store, 0, 0, 0, 3, 3)

        for i = 1, #game_state.customers do
            local c = game_state.customers[i]
            love.graphics.draw(customer_sprites[c.color], 190, 220 + i * 60, 0, 4, 4)
        end

        draw_conversation(active_customer)
        draw_inventory()
    elseif game_state.current_location == "garden" then
        love.graphics.draw(garden, 0, 0, 0, 3, 3)
    end

    if game_state.paused then love.graphics.print("PAUSED. Press escape to unpause.") end
end

function is_colliding(point, box)
    return point.x > box.x and point.x < box.width + box.x and point.y > box.y and point.y < box.y + box.height
end

function draw_inventory()
    love.graphics.draw(potions.strength, 540, 375, 0, 3, 3)
    love.graphics.draw(potions.speed, 720, 375, 0, 3, 3)
    love.graphics.draw(potions.nightvision, 540, 470, 0, 3, 3)
    love.graphics.draw(potions.endurance, 720, 470, 0, 3, 3)
    love.graphics.draw(potions.underwater, 630, 560, 0, 3, 3)

    love.graphics.print(game_state.inventory:get_strength(), 600, 382)
    love.graphics.print(game_state.inventory:get_speed(), 780, 382)
    love.graphics.print(game_state.inventory:get_nightvision(), 600, 472)
    love.graphics.print(game_state.inventory:get_endurance(), 780, 472)
    love.graphics.print(game_state.inventory:get_underwater_breathing(), 690, 572)
end

function draw_conversation(active_customer)
    if active_customer then
        local power = game_state.customers[1]:get_power()
        local remaining_potions = get_remaining_potions(power)
        if remaining_potions == 0 then
            love.graphics.setColor(0.6, 0.6, 0.6)
        end
        love.graphics.draw(response_bubble, accept_box.x, accept_box.y)
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(response_bubble, postpone_box.x, postpone_box.y)
        love.graphics.draw(response_bubble, decline_box.x, decline_box.y)
        love.graphics.draw(customer_head, 510, 30)

        love.graphics.setColor(0, 0, 0)
        love.graphics.print(game_state.customers[1]:get_line(), 580, 40, 0)
        if debug then
            love.graphics.rectangle("line", accept_box.x, accept_box.y, accept_box.width, accept_box.height)
            love.graphics.rectangle("line", postpone_box.x, postpone_box.y, postpone_box.width, postpone_box.height)
            love.graphics.rectangle("line", decline_box.x, decline_box.y, decline_box.width, decline_box.height)
        end

        love.graphics.print(game_state.queued_response.accept .. " (" .. game_state.customers[1]:get_power() .. ")", accept_box.x + 25, accept_box.y + 22)
        love.graphics.print(game_state.queued_response.postpone , postpone_box.x + 25, postpone_box.y + 22)
        love.graphics.print(game_state.queued_response.decline, decline_box.x + 25, decline_box.y + 22)
        love.graphics.setColor(1, 1, 1)
    end
end

function get_remaining_potions(power)
    if power == "Speed" then
        return game_state.inventory:get_speed()
    elseif power == "Strength" then
        return game_state.inventory:get_strength()
    elseif power == "Underwater Breathing" then
        return game_state.inventory:get_underwater_breathing()
    elseif power == "Night Vision" then
        return game_state.inventory:get_nightvision()
    elseif power == "Endurance" then
        return game_state.inventory:get_endurance()
    end
end

local function dialog_update()

end
