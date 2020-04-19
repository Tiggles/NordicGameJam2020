require "inventory"
require "customer"
require "clock"
require "help"

local debug = false
local next_action_allowed = 0
local next_customer_allowed = math.random(6)

local store
local store_closed
local witch_front
local witch_back
local arrow_left
local arrow_right
local coin
local garden
local music
local potions = {}
local potion_positions = {
    strength = {x=540, y=375, width=48, height=48},
    speed = {x=720, y=375, width=48, height=48},
    nightvision = {x=540, y=470, width=48, height=48},
    endurance = {x=720, y=470, width=48, height=48},
    underwater = {x=630, y=560, width=48, height=48}
}
local potion_ingredients = {
    strength = {spinach = 2},
    speed = {coffee = 2},
    nightvision = {cat_eyes = 2},
    endurance = {camel_hump = 2},
    underwater = {seaweed = 2}
}
local potion_times = {
    strength = 10,
    speed = 10,
    endurance = 10,
    nightvision = 10,
    underwater = 10
}
local ingredients = {}
local selected_ingredient
local selected_potion
local response_bubble
local ingredient_bubble
local customer_sprites = {}
local customer_head
local spinach_cursor
local coffee_cursor
local cat_eyes_cursor
local camel_hump_cursor
local seaweed_cursor
local potion_strength_cursor
local potion_speed_cursor
local potion_endurance_cursor
local potion_nightvision_cursor
local potion_underwater_cursor
local arrow_cursor
local showing_upgrades = false
local responses = {
    accept = { "I have just the thing.", "Maybe this is for you?", "Take this." },
    postpone = { "I'm out of ingredients, can you come back later?", "Sorry, but we're out for now."},
    decline = {"I don't have anything for that, sorry.", "Hmm, no. Sorry."}
}
local ingredient_times = {
    spinach = 10,
    coffee = 20,
    cat_eyes = 40,
    camel_hump = 60,
    seaweed = 5
}
local ingredients_prices = {
    spinach = 10,
    coffee = 50,
    cat_eyes = 500,
    camel_hump = 1000,
    seaweed = 0
}
local help = {}

local potion_price = {}
potion_price["Speed"] = 400
potion_price["Strength"] = 150
potion_price["Underwater Breathing"] = 50
potion_price["Night Vision"] = 1200
potion_price["Endurance"] = 1500

local game_state = {
    help = Help:new(),
    game_started = false,
    inventory = Inventory:new(),
    customers = {},
    finished_customers = {},
    postponed_customers = {},
    paused = false, -- Probably deleteable, but do we want to take the chance?
    clock = Clock:new(10, 18, 10, 0, 20),
    queued_response = {
        accept = responses.accept[love.math.random(#responses.accept)],
        postpone = responses.postpone[love.math.random(#responses.postpone)],
        decline = responses.decline[love.math.random(#responses.decline)]
    },
    cauldrons = {
        a = {x=300, y=200, width=76, height=81, content = {}},
        b = {x=390, y=200, width=76, height=81, content = {}},
        c = {x=300, y=300, width=76, height=81, content = {}},
        d = {x=390, y=300, width=76, height=81, content = {}},
    },
    upgrades = {
        cauldrons = 2,
        plant_growing_speed = 1,
        max_inventory = 5
    },
    upgrade_prices = {

    },
    money = 200,
    current_location = "menu",
    garden_contents = {}
}

local garden_plot_start_x = 236
local garden_plot_start_y = 45
local plot_width = 97
local plot_height = 97
local num_x_plots = 5
local num_y_plots = 5
local message = { message = "", expiration = 0 }
local garden_plots = {}

for i = 1, num_x_plots do
    garden_plots[i] = {}
    for j = 1, num_y_plots do
        garden_plots[i][j] = {
            x = i*plot_width+garden_plot_start_x,
            y = j*plot_height+garden_plot_start_y,
            width = plot_width,
            height = plot_height
        }
    end
end

local menu_start_box = { x = 260, y = 220, width = 345, height = 60 }
local menu_help_box = { x = 260, y = 290, width = 345, height = 60 }
local menu_quit_box = { x = 260, y = 360, width = 345, height = 60 }

local inventory_left_box = {x = 490, y = 576, width = 17 * 3, height = 14 * 3}
local inventory_right_box = {x = 805, y = 576, width = 17 * 3, height = 14 * 3}
local accept_box = {x = 500, y = 100, width = 345, height = 55}
local postpone_box = {x = 500, y = accept_box.y + accept_box.height + 15, width = 345, height = 55}
local decline_box = {x = 500, y = postpone_box.y + postpone_box.height + 15, width = 345, height = 55}
local goto_garden_button = {x = 700, y = 628, width = 160, height = 38}
local goto_store_button = {x = 7, y = 628, width = 185, height = 38}

local spinach_button_box = {x = 15, y = 15, width = 249, height = 60}
local coffee_button_box = {x = 15, y = 85, width = 249, height = 60}
local cat_eyes_button_box = {x = 15, y = 155, width = 249, height = 60}
local camel_hump_button_box = {x = 15, y = 225, width = 249, height = 60}
local seaweed_button_box = {x = 15, y = 295, width = 249, height = 60}

local update = function() end
local draw = function() end

function has_ingredients(potion)
    for ingredient, needed_quantity in pairs(potion_ingredients[potion]) do
        if ingredient == "spinach" then
            if game_state.inventory:get_spinach() < needed_quantity then
                return false
            end
        elseif ingredient == "coffee" then
            if game_state.inventory:get_coffee() < needed_quantity then
                return false
            end
        elseif ingredient == "cat_eyes" then
            if game_state.inventory:get_cat_eyes() < needed_quantity then
                return false
            end

        elseif ingredient == "camel_hump" then
            if game_state.inventory:get_camel_hump() < needed_quantity then
                return false
            end
        elseif ingredient == "seaweed" then
            if game_state.inventory:get_seaweed() < needed_quantity then
                return false
            end
        end
    end
    return true
end

function use_ingredients(potion)
    for ingredient, needed_quantity in pairs(potion_ingredients[potion]) do
        for i = 1, needed_quantity do
            game_state.inventory:use_ingredient(ingredient)
        end
    end
end

function love.load()
    love.filesystem.setIdentity("screenshot_example")

    love.graphics.setDefaultFilter( "nearest", "nearest")
    store = love.graphics.newImage("Assets/store.png")
    cauldron_full = love.graphics.newImage("Assets/cauldron_full.png")
    store_closed = love.graphics.newImage("Assets/store_closed.png")
    witch_front = love.graphics.newImage("Assets/witch_front.png")
    witch_back = love.graphics.newImage("Assets/witch_back.png")
    response_bubble = love.graphics.newImage("Assets/response_bubble.png")
    ingredient_bubble = love.graphics.newImage("Assets/ingredient_bubble.png")
    customer_head = love.graphics.newImage("Assets/customer_head.png")
    garden = love.graphics.newImage("Assets/garden.png")
    arrow_left = love.graphics.newImage("Assets/arrow_left.png")
    arrow_right = love.graphics.newImage("Assets/arrow_right.png")
    coin = love.graphics.newImage("Assets/coin.png")

    help.store = love.graphics.newImage("Assets/Help/store_help.png")
    help.garden = love.graphics.newImage("Assets/Help/garden_help.png")
    help.brewing = love.graphics.newImage("Assets/Help/brewing_help.png")
    help.big_message = love.graphics.newImage("Assets/big_message.png")
    help.small_message = love.graphics.newImage("Assets/small_message.png")

    potions.strength = love.graphics.newImage("Assets/potion_strength.png")
    potions.speed = love.graphics.newImage("Assets/potion_speed.png")
    potions.nightvision = love.graphics.newImage("Assets/potion_nightvision.png")
    potions.underwater = love.graphics.newImage("Assets/potion_underwater.png")
    potions.endurance = love.graphics.newImage("Assets/potion_endurance.png")

    ingredients.spinach = love.graphics.newImage("Assets/spinach.png")
    ingredients.coffee = love.graphics.newImage("Assets/coffee.png")
    ingredients.cat_eyes = love.graphics.newImage("Assets/cat_eyes.png")
    ingredients.camel_hump = love.graphics.newImage("Assets/camel_hump.png")
    ingredients.seaweed = love.graphics.newImage("Assets/seaweed.png")

    music = love.audio.newSource("Assets/elevator_music.wav", "static")
    music:setLooping(true)
    table.insert(customer_sprites, love.graphics.newImage("Assets/customer_blue.png"))
    for i = 1, num_x_plots do
        game_state.garden_contents[i] = {}
        for j = 1, num_y_plots do
            game_state.garden_contents[i][j] = {}
        end
    end

    spinach_cursor = love.mouse.newCursor("Assets/spinach.png", 8, 8)
    coffee_cursor = love.mouse.newCursor("Assets/coffee.png", 8, 8)
    cat_eyes_cursor = love.mouse.newCursor("Assets/cat_eyes.png", 8, 8)
    camel_hump_cursor = love.mouse.newCursor("Assets/camel_hump.png", 8, 8)
    seaweed_cursor = love.mouse.newCursor("Assets/seaweed.png", 8, 8)
    potion_strength_cursor = love.mouse.newCursor("Assets/potion_strength.png", 8, 8)
    potion_speed_cursor = love.mouse.newCursor("Assets/potion_speed.png", 8, 8)
    potion_endurance_cursor = love.mouse.newCursor("Assets/potion_endurance.png", 8, 8)
    potion_nightvision_cursor = love.mouse.newCursor("Assets/potion_nightvision.png", 8, 8)
    potion_underwater_cursor = love.mouse.newCursor("Assets/potion_underwater.png", 8, 8)
    arrow_cursor = love.mouse.getSystemCursor("arrow")

end

function love.update(delta)
    if game_state.current_location == "menu" then
        if love.mouse.isDown("1") and next_action_allowed < love.timer.getTime()  then
            local x, y = love.mouse.getPosition()
            if is_colliding({x = x, y = y}, menu_start_box) then
                game_state.current_location = "store"
                next_action_allowed = love.timer.getTime() + 0.2
                game_state.game_started = true
                music:play()
            elseif is_colliding({x = x, y = y}, menu_help_box) then
                game_state.current_location = "help"
                next_action_allowed = love.timer.getTime() + 0.2
            elseif is_colliding({x = x, y = y}, menu_quit_box) then
                love.event.quit()
            end
        end

        return
    end

    if game_state.current_location == "help" then
        if next_action_allowed < love.timer.getTime() and (love.keyboard.isDown("space") or love.mouse.isDown("1")) then
            game_state.help:next_page(game_state)
            next_action_allowed = love.timer.getTime() + 0.2
        end
        return
    end

    -- if love.keyboard.isDown("escape") then love.event.quit() end
    if love.keyboard.isDown("f4") and next_action_allowed < love.timer.getTime() then
        debug = not debug
        next_action_allowed = love.timer.getTime() + 0.2
    end

    for i = #game_state.customers, 1, -1 do
        game_state.customers[i].time_bonus = game_state.customers[i].time_bonus - (delta * 10)
        if game_state.customers[i].time_bonus <= 0 then
            table.remove(game_state.customers, i)
            message.message = CUSTOMER_LEFT
            message.expiration = 1.5
        end
    end

    message.expiration = message.expiration - delta

    local active_customer = game_state.customers[1] ~= nil

    if game_state.current_location == "store" or game_state.current_location == "garden" then
        game_state.clock:update(delta)
    end

    if game_state.clock:is_open() and next_customer_allowed < love.timer.getTime() and #game_state.customers < 5 then
        table.insert(game_state.customers, Customer:new())
        next_customer_allowed = love.timer.getTime() + 10 + math.random(6)
    end

    if not game_state.clock:is_open() and #game_state.customers > 0 then
        game_state.customers = {}
        message.message = "Shop closed"
        message.expiration = 51000
    end

    -- update garden times
    for i = 1, num_x_plots do
        for j = 1, num_y_plots do
            if game_state.garden_contents[i][j].name ~= nil then
                if game_state.garden_contents[i][j].time_left > 0 then
                    game_state.garden_contents[i][j].time_left = game_state.garden_contents[i][j].time_left - delta
                end
                
                if game_state.garden_contents[i][j].time_left < 0 then
                    game_state.garden_contents[i][j].time_left = 0
                end
            end
        end
    end

    -- update cauldron times
    if game_state.cauldrons.a.content.name ~= nil then
        if game_state.cauldrons.a.content.time_left > 0 then
            game_state.cauldrons.a.content.time_left = game_state.cauldrons.a.content.time_left - delta
        end

        if game_state.cauldrons.a.content.time_left < 0 then
            game_state.cauldrons.a.content.time_left = 0
        end
    end

    if game_state.cauldrons.b.content.name ~= nil then
        if game_state.cauldrons.b.content.time_left > 0 then
            game_state.cauldrons.b.content.time_left = game_state.cauldrons.b.content.time_left - delta
        end

        if game_state.cauldrons.b.content.time_left < 0 then
            game_state.cauldrons.b.content.time_left = 0
        end
    end

    if game_state.cauldrons.c.content.name ~= nil then
        if game_state.cauldrons.c.content.time_left > 0 then
            game_state.cauldrons.c.content.time_left = game_state.cauldrons.c.content.time_left - delta
        end

        if game_state.cauldrons.c.content.time_left < 0 then
            game_state.cauldrons.c.content.time_left = 0
        end
    end

    if game_state.cauldrons.d.content.name ~= nil then
        if game_state.cauldrons.d.content.time_left > 0 then
            game_state.cauldrons.d.content.time_left = game_state.cauldrons.d.content.time_left - delta
        end

        if game_state.cauldrons.d.content.time_left < 0 then
            game_state.cauldrons.d.content.time_left = 0
        end
    end


    if game_state.current_location == "store" then
        if love.keyboard.isDown("escape") then
            game_state.current_location = "menu"
        end

        if not game_state.clock:is_open() and love.keyboard.isDown("space") then
            game_state.clock:skip_to_open()
        end
        local x, y = love.mouse.getPosition()
        if love.mouse.isDown("1") then
            if is_colliding({x=x, y=y}, inventory_left_box) then
                game_state.inventory:previous_page()
            elseif is_colliding({x=x, y=y}, inventory_right_box) then
                game_state.inventory:next_page()
            end
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
            local action_happened = false
            if is_colliding({x=x, y=y}, game_state.cauldrons.a) then
                if game_state.cauldrons.a.content.name == nil and selected_potion ~= nil then
                    if has_ingredients(selected_potion) then
                        use_ingredients(selected_potion)
                        game_state.cauldrons.a.content.name = selected_potion
                        game_state.cauldrons.a.content.time_left = potion_times[selected_potion]
                    else
                        message.message = INGREDIENTS_WARNING
                        message.expiration = 2
                    end
                end

                if game_state.cauldrons.a.content.name ~= nil then
                    if game_state.cauldrons.a.content.time_left == 0 then
                        selected_potion = nil
                        game_state.inventory:add_potion(game_state.cauldrons.a.content.name)
                        game_state.cauldrons.a.content = {}
                    end
                end
            elseif is_colliding({x=x, y=y}, game_state.cauldrons.b) then
                if game_state.cauldrons.b.content.name == nil and selected_potion ~= nil then
                    if has_ingredients(selected_potion) then
                        use_ingredients(selected_potion)
                        game_state.cauldrons.b.content.name = selected_potion
                        game_state.cauldrons.b.content.time_left = potion_times[selected_potion]
                    else
                        message.message = INGREDIENTS_WARNING
                        message.expiration = 2
                    end
                end

                if game_state.cauldrons.b.content.name ~= nil then
                    if game_state.cauldrons.b.content.time_left == 0 then
                        selected_potion = nil
                        game_state.inventory:add_potion(game_state.cauldrons.b.content.name)
                        game_state.cauldrons.b.content = {}
                    end
                end
            elseif game_state.upgrades.cauldrons > 2 and is_colliding({x=x, y=y}, game_state.cauldrons.c) then
                if game_state.cauldrons.c.content.name == nil and selected_potion ~= nil then
                    if has_ingredients(selected_potion) then
                        use_ingredients(selected_potion)
                        game_state.cauldrons.c.content.name = selected_potion
                        game_state.cauldrons.c.content.time_left = potion_times[selected_potion]
                    else
                        message.message = INGREDIENTS_WARNING
                        message.expiration = 2
                    end
                end

                if game_state.cauldrons.c.content.name ~= nil then
                    if game_state.cauldrons.c.content.time_left == 0 then
                        selected_potion = nil
                        game_state.inventory:add_potion(game_state.cauldrons.c.content.name)
                        game_state.cauldrons.c.content = {}
                    end
                end
            elseif game_state.upgrades.cauldrons > 3 and is_colliding({x=x, y=y}, game_state.cauldrons.d) then
                if game_state.cauldrons.d.content.name == nil and selected_potion ~= nil then
                    if has_ingredients(selected_potion) then
                        use_ingredients(selected_potion)
                        game_state.cauldrons.d.content.name = selected_potion
                        game_state.cauldrons.d.content.time_left = potion_times[selected_potion]
                    else
                        message.message = INGREDIENTS_WARNING
                        message.expiration = 2
                    end
                end

                if game_state.cauldrons.d.content.name ~= nil then
                    if game_state.cauldrons.d.content.time_left == 0 then
                        selected_potion = nil
                        game_state.inventory:add_potion(game_state.cauldrons.d.content.name)
                        game_state.cauldrons.d.content = {}
                    end
                end
            end

            if active_customer and next_action_allowed < love.timer.getTime() then
                if is_colliding({x = x, y = y}, accept_box) then
                    local power = game_state.customers[1]:get_power()
                    local remaining_potions = get_remaining_potions(power)
                    if remaining_potions ~= 0 then
                        game_state.inventory:use_potion(power)
                        game_state.inventory:add_money(game_state.customers[1].time_bonus + potion_price[power])
                        table.remove(game_state.customers, 1)
                    end
                    action_happened = true
                    next_action_allowed = love.timer.getTime() + 0.2
                elseif is_colliding({x=x, y=y}, postpone_box) and game_state.customers[1].already_postponed == false then
                    table.insert(game_state.postponed_customers, game_state.customers[1])
                    table.remove(game_state.customers, 1)
                    game_state.postponed_customers[#game_state.postponed_customers].week = game_state.clock.week + 1
                    game_state.postponed_customers[#game_state.postponed_customers].day = game_state.clock.day
                    action_happened = true
                    next_action_allowed = love.timer.getTime() + 0.2
                elseif is_colliding({x=x, y=y}, decline_box) then
                    table.remove(game_state.customers, 1)
                    action_happened = true
                    next_action_allowed = love.timer.getTime() + 0.2
               else
                    print("None")
                end

                if action_happened then
                    game_state.queued_response = {
                        accept = responses.accept[love.math.random(#responses.accept)],
                        postpone = responses.postpone[love.math.random(#responses.postpone)],
                        decline = responses.decline[love.math.random(#responses.decline)]
                    }
                end
            end

            if is_colliding({x=x, y=y}, goto_garden_button) then
                selected_potion = nil
                game_state.current_location = "garden"
                music:pause()
            elseif is_colliding({x=x, y=y}, potion_positions.strength) then
                selected_potion = "strength"
            elseif is_colliding({x=x, y=y}, potion_positions.speed) then
                selected_potion = "speed"
            elseif is_colliding({x=x, y=y}, potion_positions.endurance) then
                selected_potion = "endurance"
            elseif is_colliding({x=x, y=y}, potion_positions.nightvision) then
                selected_potion = "nightvision"
            elseif is_colliding({x=x, y=y}, potion_positions.underwater) then
                selected_potion = "underwater"
            else
                selected_potion = nil
            end
        end
    elseif game_state.current_location == "garden" then
        if love.mouse.isDown("1") then
            local x, y = love.mouse.getPosition()
            if is_colliding({x=x, y=y}, goto_store_button) then
                music:play()
                selected_ingredient = nil
                game_state.current_location = "store"
            elseif is_colliding({x=x, y=y}, spinach_button_box) then
                selected_ingredient = "spinach"
            elseif is_colliding({x=x, y=y}, coffee_button_box) then
                selected_ingredient = "coffee"
            elseif is_colliding({x=x, y=y}, cat_eyes_button_box) then
                selected_ingredient = "cat_eyes"
            elseif is_colliding({x=x, y=y}, camel_hump_button_box) then
                selected_ingredient = "camel_hump"
            elseif is_colliding({x=x, y=y}, seaweed_button_box) then
                selected_ingredient = "seaweed"
            else
                local garden_plot_clicked = false
                -- Check if colliding with plot
                for i = 1, num_x_plots do
                    for j = 1, num_y_plots do
                        if is_colliding({x=x, y=y}, garden_plots[i][j]) then
                            garden_plot_clicked = true

                            if game_state.garden_contents[i][j].name == nil then
                                if selected_ingredient ~= nil then
                                    if game_state.inventory:has_enough_money(ingredients_prices[selected_ingredient]) then
                                        game_state.inventory:spend_money(ingredients_prices[selected_ingredient])
                                        game_state.garden_contents[i][j].name = selected_ingredient
                                        game_state.garden_contents[i][j].time_left = ingredient_times[selected_ingredient]
                                    end
                                end
                            else
                                if game_state.garden_contents[i][j].time_left == 0 then
                                    selected_ingredient = nil
                                    game_state.inventory:add_ingredient(game_state.garden_contents[i][j].name)
                                    game_state.garden_contents[i][j] = {}
                                end
                            end


                        end
                    end
                end

                if garden_plot_clicked == false then
                    selected_ingredient = nil
                end
            end
        end
    end
end

function play_or_resume(started)
    if started then return "Resume" else return "Play" end
end

function play_or_resume_distance(started)
    if started then return 148 else return 160 end
end

function love.draw()
    if game_state.current_location == "menu" then
        if debug then
            love.graphics.rectangle("line", menu_start_box.x, menu_start_box.y, menu_start_box.width, menu_start_box.height)
            love.graphics.rectangle("line", menu_help_box.x, menu_help_box.y, menu_help_box.width, menu_help_box.height)
            love.graphics.rectangle("line", menu_quit_box.x, menu_quit_box.y, menu_quit_box.width, menu_quit_box.height)
        end

        love.graphics.draw(response_bubble, menu_start_box.x, menu_start_box.y)
        love.graphics.draw(response_bubble, menu_help_box.x, menu_help_box.y)
        love.graphics.draw(response_bubble, menu_quit_box.x, menu_quit_box.y)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(play_or_resume(game_state.game_started), menu_start_box.x + play_or_resume_distance(game_state.game_started), menu_start_box.y + 25)
        love.graphics.print("How to", menu_help_box.x + 150, menu_help_box.y + 25)
        love.graphics.print("Quit", menu_quit_box.x + 160, menu_quit_box.y + 25)
        love.graphics.setColor(1, 1, 1)
        return
    end

    if game_state.current_location == "help" then
        if game_state.help.page == 1 then
            love.graphics.draw(help.store)
            love.graphics.draw(help.big_message)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(HELP_SHOP, 0, 20)
            love.graphics.setColor(1, 1, 1)
        elseif game_state.help.page == 2 then
            love.graphics.draw(help.store)
            love.graphics.draw(help.big_message, 120, 100)
            love.graphics.draw(help.big_message, 120, 450)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(HELP_CONVERSATION, 120, 120)
            love.graphics.print(HELP_INVENTORY, 120, 460)
            love.graphics.setColor(1, 1, 1)

        elseif game_state.help.page == 3 then
            love.graphics.draw(help.garden)
            love.graphics.draw(help.big_message, 400, 20)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(HELP_GARDEN, 400, 35)
            love.graphics.setColor(1, 1, 1)
        elseif game_state.help.page == 4 then
            love.graphics.draw(help.brewing)
            love.graphics.draw(help.big_message, 150, 400)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(HELP_BREWING, 155, 425)
            love.graphics.setColor(1, 1, 1)
        end
        love.graphics.draw(help.small_message, 350, 580)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(HELP_NEXT, 350, 595)
        love.graphics.setColor(1, 1, 1)
        return
    end

    local active_customer = game_state.customers[1] ~= nil

    if game_state.current_location == "store" then
        if selected_potion == "strength" then
            love.mouse.setCursor(potion_strength_cursor)
        elseif selected_potion == "speed" then
            love.mouse.setCursor(potion_speed_cursor)
        elseif selected_potion == "endurance" then
            love.mouse.setCursor(potion_endurance_cursor)
        elseif selected_potion == "nightvision" then
            love.mouse.setCursor(potion_nightvision_cursor)
        elseif selected_potion == "underwater" then
            love.mouse.setCursor(potion_underwater_cursor)
        else
            love.mouse.setCursor(arrow_cursor)
        end
        if game_state.clock:is_open() then
            love.graphics.draw(store, 0, 0, 0, 3, 3)
        else
            love.graphics.draw(store_closed, 0, 0, 0, 3, 3)
        end

        for i = 1, #game_state.customers do
            local c = game_state.customers[i]
            love.graphics.draw(customer_sprites[c.color], 190, 220 + i * 60, 0, 4, 4)
        end

        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 380, 550, 100, 20)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(game_state.clock:to_string(), 388, 553)

        draw_conversation(active_customer)
        draw_inventory()
        draw_cauldrons()

        if message.message ~= "" and message.expiration > 0 then
            love.graphics.draw(help.small_message, 350, 580)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(message.message, 355, 600)
            love.graphics.setColor(1, 1, 1)
        end
    elseif game_state.current_location == "garden" then
        love.graphics.draw(garden, 0, 0, 0, 3, 3)
        draw_garden_plots()
        draw_garden_menu()
        love.graphics.draw(coin, 195, 634, 0, 3, 3)
        love.graphics.print(game_state.inventory.money, 220, 638)

        if selected_ingredient == "spinach" then
            love.mouse.setCursor(spinach_cursor)
        elseif selected_ingredient == "coffee" then
            love.mouse.setCursor(coffee_cursor)
        elseif selected_ingredient == "cat_eyes" then
            love.mouse.setCursor(cat_eyes_cursor)
        elseif selected_ingredient == "camel_hump" then
            love.mouse.setCursor(camel_hump_cursor)
        elseif selected_ingredient == "seaweed" then
            love.mouse.setCursor(seaweed_cursor)
        else
            love.mouse.setCursor(arrow_cursor)
        end

        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 280, 0, 100, 20)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(game_state.clock:to_string(), 280, 3)
    end

    if game_state.paused then love.graphics.print("PAUSED. Press escape to unpause.") end
end

function is_colliding(point, box)
    return point.x > box.x and point.x < box.width + box.x and point.y > box.y and point.y < box.y + box.height
end

function draw_inventory()
    if game_state.inventory:has_previous_page() then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(0.6, 0.6, 0.6)
    end
    love.graphics.draw(arrow_left, inventory_left_box.x, inventory_left_box.y, 0, 3, 3)

    if game_state.inventory:has_next_page() then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(0.6, 0.6, 0.6)
    end
    love.graphics.draw(arrow_right, inventory_right_box.x, inventory_right_box.y, 0, 3, 3)

    love.graphics.setColor(1, 1, 1)

    if game_state.inventory.page == 1 then -- potions
        love.graphics.draw(potions.strength, potion_positions.strength.x, potion_positions.strength.y, 0, 3, 3)
        love.graphics.draw(potions.speed, potion_positions.speed.x, potion_positions.speed.y, 0, 3, 3)
        love.graphics.draw(potions.nightvision, potion_positions.nightvision.x, potion_positions.nightvision.y, 0, 3, 3)
        love.graphics.draw(potions.endurance, potion_positions.endurance.x, potion_positions.endurance.y, 0, 3, 3)
        love.graphics.draw(potions.underwater, potion_positions.underwater.x, potion_positions.underwater.y, 0, 3, 3)

        love.graphics.print("Quantity: "..game_state.inventory:get_strength(), 590, 382)
        love.graphics.print("Quantity: "..game_state.inventory:get_speed(), 770, 382)
        love.graphics.print("Quantity: "..game_state.inventory:get_nightvision(), 590, 472)
        love.graphics.print("Quantity: "..game_state.inventory:get_endurance(), 770, 472)
        love.graphics.print("Quantity: "..game_state.inventory:get_underwater_breathing(), 680, 572)

        love.graphics.draw(coin, 590, 402, 0, 2, 2)
        love.graphics.draw(coin, 770, 402, 0, 2, 2)
        love.graphics.draw(coin, 590, 492, 0, 2, 2)
        love.graphics.draw(coin, 770, 492, 0, 2, 2)
        love.graphics.draw(coin, 680, 592, 0, 2, 2)

        love.graphics.print(potion_price["Strength"], 610, 402)
        love.graphics.print(potion_price["Speed"], 790, 402)
        love.graphics.print(potion_price["Night Vision"], 610, 492)
        love.graphics.print(potion_price["Endurance"], 790, 492)
        love.graphics.print(potion_price["Underwater Breathing"], 700, 592)

    else -- inventory
        love.graphics.draw(ingredients.spinach, 540, 375, 0, 3, 3)
        love.graphics.draw(ingredients.coffee, 720, 375, 0, 3, 3)
        love.graphics.draw(ingredients.cat_eyes, 540, 470, 0, 3, 3)
        love.graphics.draw(ingredients.camel_hump, 720, 470, 0, 3, 3)
        love.graphics.draw(ingredients.seaweed, 630, 560, 0, 3, 3)

        love.graphics.print("Quantity: "..game_state.inventory:get_spinach(), 590, 382)
        love.graphics.print("Quantity: "..game_state.inventory:get_coffee(), 770, 382)
        love.graphics.print("Quantity: "..game_state.inventory:get_cat_eyes(), 590, 472)
        love.graphics.print("Quantity: "..game_state.inventory:get_camel_hump(), 770, 472)
        love.graphics.print("Quantity: "..game_state.inventory:get_seaweed(), 680, 572)
    end

    love.graphics.draw(coin, 500, 634, 0, 3, 3)
    love.graphics.print(game_state.inventory.money, 540, 638)
end

function draw_cauldrons()
    love.graphics.draw(cauldron_full, game_state.cauldrons.a.x, game_state.cauldrons.a.y, 0, 3, 3)
    love.graphics.draw(cauldron_full, game_state.cauldrons.b.x, game_state.cauldrons.b.y, 0, 3, 3)

    if game_state.upgrades.cauldrons > 2 then
        love.graphics.draw(cauldron_full, game_state.cauldrons.c.x, game_state.cauldrons.c.y, 0, 3, 3)
    end

    if game_state.upgrades.cauldrons > 3 then
        love.graphics.draw(cauldron_full, game_state.cauldrons.d.x, game_state.cauldrons.d.y, 0, 3, 3)
    end

    if game_state.cauldrons.a.content.name ~= nil then
        if game_state.cauldrons.a.content.name == "strength" then
            love.graphics.draw(potions.strength, game_state.cauldrons.a.x+16, game_state.cauldrons.a.y-30, 0, 3, 3)
        elseif game_state.cauldrons.a.content.name == "speed" then
            love.graphics.draw(potions.speed, game_state.cauldrons.a.x+16, game_state.cauldrons.a.y-30, 0, 3, 3)
        elseif  game_state.cauldrons.a.content.name == "endurance" then
            love.graphics.draw(potions.endurance, game_state.cauldrons.a.x+16, game_state.cauldrons.a.y-30, 0, 3, 3)
        elseif  game_state.cauldrons.a.content.name == "nightvision" then
            love.graphics.draw(potions.nightvision, game_state.cauldrons.a.x+16, game_state.cauldrons.a.y-30, 0, 3, 3)
        elseif  game_state.cauldrons.a.content.name == "underwater" then
            love.graphics.draw(potions.underwater, game_state.cauldrons.a.x+16, game_state.cauldrons.a.y-30, 0, 3, 3)
        end

        local time_text = "?"

        if game_state.cauldrons.a.content.time_left == 0 then
            time_text = "Done"
        else
            time_text = math.ceil(game_state.cauldrons.a.content.time_left)
        end

        love.graphics.print(time_text, game_state.cauldrons.a.x+30, game_state.cauldrons.a.y+30)
    end

    if game_state.cauldrons.b.content.name ~= nil then
        if game_state.cauldrons.b.content.name == "strength" then
            love.graphics.draw(potions.strength, game_state.cauldrons.b.x+16, game_state.cauldrons.b.y-30, 0, 3, 3)
        elseif game_state.cauldrons.b.content.name == "speed" then
            love.graphics.draw(potions.speed, game_state.cauldrons.b.x+16, game_state.cauldrons.b.y-30, 0, 3, 3)
        elseif game_state.cauldrons.b.content.name == "endurance" then
            love.graphics.draw(potions.endurance, game_state.cauldrons.b.x+16, game_state.cauldrons.b.y-30, 0, 3, 3)
        elseif game_state.cauldrons.b.content.name == "nightvision" then
            love.graphics.draw(potions.nightvision, game_state.cauldrons.b.x+16, game_state.cauldrons.b.y-30, 0, 3, 3)
        elseif game_state.cauldrons.b.content.name == "underwater" then
            love.graphics.draw(potions.underwater, game_state.cauldrons.b.x+16, game_state.cauldrons.b.y-30, 0, 3, 3)
        end

        local time_text = "?"

        if game_state.cauldrons.b.content.time_left == 0 then
            time_text = "Done"
        else
            time_text = math.ceil(game_state.cauldrons.b.content.time_left)
        end

        love.graphics.print(time_text, game_state.cauldrons.b.x+30, game_state.cauldrons.b.y+30)
    end

    if game_state.cauldrons.c.content.name ~= nil then
        if game_state.cauldrons.c.content.name == "strength" then
            love.graphics.draw(potions.strength, game_state.cauldrons.c.x+16, game_state.cauldrons.c.y-30, 0, 3, 3)
        elseif game_state.cauldrons.c.content.name == "speed" then
            love.graphics.draw(potions.speed, game_state.cauldrons.c.x+16, game_state.cauldrons.c.y-30, 0, 3, 3)
        elseif  game_state.cauldrons.c.content.name == "endurance" then
            love.graphics.draw(potions.endurance, game_state.cauldrons.c.x+16, game_state.cauldrons.c.y-30, 0, 3, 3)
        elseif  game_state.cauldrons.c.content.name == "nightvision" then
            love.graphics.draw(potions.nightvision, game_state.cauldrons.c.x+16, game_state.cauldrons.c.y-30, 0, 3, 3)
        elseif  game_state.cauldrons.c.content.name == "underwater" then
            love.graphics.draw(potions.underwater, game_state.cauldrons.c.x+16, game_state.cauldrons.c.y-30, 0, 3, 3)
        end

        local time_text = "?"

        if game_state.cauldrons.c.content.time_left == 0 then
            time_text = "Done"
        else
            time_text = math.ceil(game_state.cauldrons.c.content.time_left)
        end

        love.graphics.print(time_text, game_state.cauldrons.c.x+30, game_state.cauldrons.c.y+30)
    end

    if game_state.cauldrons.d.content.name ~= nil then
        if game_state.cauldrons.d.content.name == "strength" then
            love.graphics.draw(potions.strength, game_state.cauldrons.d.x+16, game_state.cauldrons.d.y-30, 0, 3, 3)
        elseif game_state.cauldrons.d.content.name == "speed" then
            love.graphics.draw(potions.speed, game_state.cauldrons.d.x+16, game_state.cauldrons.d.y-30, 0, 3, 3)
        elseif  game_state.cauldrons.d.content.name == "endurance" then
            love.graphics.draw(potions.endurance, game_state.cauldrons.d.x+16, game_state.cauldrons.d.y-30, 0, 3, 3)
        elseif  game_state.cauldrons.d.content.name == "nightvision" then
            love.graphics.draw(potions.nightvision, game_state.cauldrons.d.x+16, game_state.cauldrons.d.y-30, 0, 3, 3)
        elseif  game_state.cauldrons.d.content.name == "underwater" then
            love.graphics.draw(potions.underwater, game_state.cauldrons.d.x+16, game_state.cauldrons.d.y-30, 0, 3, 3)
        end

        local time_text = "?"

        if game_state.cauldrons.d.content.time_left == 0 then
            time_text = "Done"
        else
            time_text = math.ceil(game_state.cauldrons.d.content.time_left)
        end

        love.graphics.print(time_text, game_state.cauldrons.d.x+30, game_state.cauldrons.d.y+30)
    end

end

function draw_garden_plots()
    local plot_offset = {x=22, y=22}

    for i = 1, num_x_plots do
        for j =1, num_y_plots do
            if game_state.garden_contents[i][j].name ~= nil then
                love.graphics.rectangle("line", garden_plots[i][j].x, garden_plots[i][j].y, garden_plots[i][j].width, garden_plots[i][j].height)

                if game_state.garden_contents[i][j].name == "spinach" then
                    love.graphics.draw(ingredients.spinach, garden_plots[i][j].x+plot_offset.x, garden_plots[i][j].y+plot_offset.y, 0, 3, 3)
                elseif game_state.garden_contents[i][j].name == "coffee" then
                    love.graphics.draw(ingredients.coffee, garden_plots[i][j].x+plot_offset.x, garden_plots[i][j].y+plot_offset.y, 0, 3, 3)
                elseif game_state.garden_contents[i][j].name == "cat_eyes" then
                    love.graphics.draw(ingredients.cat_eyes, garden_plots[i][j].x+plot_offset.x, garden_plots[i][j].y+plot_offset.y, 0, 3, 3)
                elseif game_state.garden_contents[i][j].name == "camel_hump" then
                    love.graphics.draw(ingredients.camel_hump, garden_plots[i][j].x+plot_offset.x, garden_plots[i][j].y+plot_offset.y, 0, 3, 3)
                elseif game_state.garden_contents[i][j].name == "seaweed" then
                    love.graphics.draw(ingredients.seaweed, garden_plots[i][j].x+plot_offset.x, garden_plots[i][j].y+plot_offset.y, 0, 3, 3)
                end

                local time_text = "?"

                if game_state.garden_contents[i][j].time_left == 0 then
                    time_text = "Done"
                else
                    time_text = math.ceil(game_state.garden_contents[i][j].time_left)
                end

                love.graphics.print(time_text, garden_plots[i][j].x+plot_offset.x - 10, garden_plots[i][j].y+plot_offset.y + 55)
            end
        end
    end
end

function draw_garden_menu()

    love.graphics.draw(ingredient_bubble, 15, 15)
    love.graphics.draw(ingredient_bubble, 15, 85)
    love.graphics.draw(ingredient_bubble, 15, 155)
    love.graphics.draw(ingredient_bubble, 15, 225)
    love.graphics.draw(ingredient_bubble, 15, 295)

    love.graphics.draw(ingredients.spinach, 22, 20, 0, 3, 3)
    love.graphics.draw(ingredients.coffee, 22, 90, 0, 3, 3)
    love.graphics.draw(ingredients.cat_eyes, 22, 160, 0, 3, 3)
    love.graphics.draw(ingredients.camel_hump, 22, 230, 0, 3, 3)
    love.graphics.draw(ingredients.seaweed, 22, 300, 0, 3, 3)

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("Spinach", 80, 30)
    love.graphics.print("Coffee", 80, 100)
    love.graphics.print("Cat Eyes", 80, 170)
    love.graphics.print("Camel's Hump", 80, 240)
    love.graphics.print("Seaweed", 80, 310)
    love.graphics.setColor(1, 1, 1)

    love.graphics.draw(coin, 190, 25, 0, 3, 3)
    love.graphics.draw(coin, 190, 95, 0, 3, 3)
    love.graphics.draw(coin, 190, 165, 0, 3, 3)
    love.graphics.draw(coin, 190, 235, 0, 3, 3)
    love.graphics.draw(coin, 190, 305, 0, 3, 3)

    love.graphics.setColor(0, 0, 0)
    love.graphics.print(ingredients_prices.spinach, 220, 30)
    love.graphics.print(ingredients_prices.coffee, 220, 100)
    love.graphics.print(ingredients_prices.cat_eyes, 220, 170)
    love.graphics.print(ingredients_prices.camel_hump, 220, 240)
    love.graphics.print(ingredients_prices.seaweed, 220, 310)

    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.print("Inventory: "..game_state.inventory:get_spinach(), 80, 50)
    love.graphics.print("Inventory: "..game_state.inventory:get_coffee(), 80, 120)
    love.graphics.print("Inventory: "..game_state.inventory:get_cat_eyes(), 80, 190)
    love.graphics.print("Inventory: "..game_state.inventory:get_camel_hump(), 80, 260)
    love.graphics.print("Inventory: "..game_state.inventory:get_seaweed(), 80, 330)

    love.graphics.setColor(1, 1, 1)
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
