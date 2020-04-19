require "inventory"
require "customer"
require "clock"

local debug = false
local next_action_allowed = 0
local next_customer_allowed = math.random(6)

local store
local store_closed
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
    clock = Clock:new(10, 18, 10, 0, 120),
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
    store_closed = love.graphics.newImage("Assets/store_closed.png")
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
end

function love.update(delta)
    if game_state.paused then return end
    if love.keyboard.isDown("escape") then love.event.quit() end
    if love.keyboard.isDown("f4") and next_action_allowed < love.timer.getTime() then
        debug = not debug
        next_action_allowed = love.timer.getTime() + 0.2
    end

    local active_customer = game_state.customers[1] ~= nil

    if game_state.current_location == "store" or game_state.current_location == "garden" then
        game_state.clock:update(delta)
    end

    if game_state.clock:is_open() and next_customer_allowed < love.timer.getTime() then
        table.insert(game_state.customers, Customer:new())
        next_customer_allowed = love.timer.getTime() + 10 + math.random(6)
    end

    if not game_state.clock:is_open() and #game_state.customers > 0 then game_state.customers = {} end

    if game_state.current_location == "store" then

        if not game_state.clock:is_open() and love.keyboard.isDown("space") then
            game_state.clock:skip_to_open()
        end

        if game_state.clock.hours == game_state.clock.opening_hour and #game_state.postponed_customers > 0 then
            for i = #game_state.postponed_customers, 1, -1 do
                local p_c = game_state.postponed_customers[i]
                if p_c.week == game_state.clock.week and p_c.day == game_state.clock.day then
                    game_state.postponed_customers[i].already_postponed = true
                    table.insert(game_state.customers, game_state.postponed_customers[i])
                    table.remove(game_state.postponed_customers, 1)
                end
            end
        end

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
                elseif is_colliding({x=x, y=y}, postpone_box) and game_state.customers[1].already_postponed == false then
                    table.insert(game_state.postponed_customers, game_state.customers[1])
                    table.remove(game_state.customers, 1)
                    game_state.postponed_customers[#game_state.postponed_customers].week = game_state.clock.week + 1
                    game_state.postponed_customers[#game_state.postponed_customers].day = game_state.clock.day
                    next_action_allowed = love.timer.getTime() + 0.2
                elseif is_colliding({x=x, y=y}, decline_box) then
                    table.remove(game_state.customers, 1)
                    next_action_allowed = love.timer.getTime() + 0.2
                else
                    print("None")
                end
            end
            if is_colliding({x=x, y=y}, goto_garden_button) then
                game_state.current_location = "garden"
                music:pause()
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
        if game_state.clock:is_open() then
            love.graphics.draw(store, 0, 0, 0, 3, 3)
        else
            love.graphics.draw(store_closed, 0, 0, 0, 3, 3)
            -- love.graphics.print("Press space to skip to open hours.")
        end

        for i = 1, #game_state.customers do
            local c = game_state.customers[i]
            love.graphics.draw(customer_sprites[c.color], 190, 220 + i * 60, 0, 4, 4)
        end

        love.graphics.print(game_state.clock:to_string())

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
    if game_state.inventory.page == 1 then
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
end

function draw_conversation(active_customer)
    if active_customer then
        local power = game_state.customers[1]:get_power()
        local already_postponed = game_state.customers[1].already_postponed
        local remaining_potions = get_remaining_potions(power)
        if remaining_potions == 0 then
            love.graphics.setColor(0.6, 0.6, 0.6)
        end
        love.graphics.draw(response_bubble, accept_box.x, accept_box.y)
        love.graphics.setColor(1, 1, 1)
        if already_postponed then
            love.graphics.setColor(0.6, 0.6, 0.6)
        end
        love.graphics.draw(response_bubble, postpone_box.x, postpone_box.y)
        love.graphics.setColor(1, 1, 1)
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
