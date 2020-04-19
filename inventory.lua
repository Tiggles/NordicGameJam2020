Inventory = {}

function Inventory:new()
    local inventory = {
        potions = {
            speed_potions = 1,
            strength_potions = 1,
            underwater_breathing_potions = 1,
            nightvision_potions = 1,
            endurance_potions = 1
        },
        ingredients = {
            spinach = 1,
            coffee = 1,
            cat_eyes = 1,
            camel_hump = 1,
            seaweed = 1
        },
        page = 1
    }
    self.__index = self
    return setmetatable(inventory, self)
end

function Inventory:get_speed()
    return self.potions.speed_potions
end

function Inventory:get_strength()
    return self.potions.strength_potions
end

function Inventory:get_underwater_breathing()
    return self.potions.underwater_breathing_potions
end

function Inventory:get_endurance()
    return self.potions.endurance_potions
end

function Inventory:get_nightvision()
    return self.potions.nightvision_potions
end

function Inventory:get_spinach()
    return self.ingredients.spinach
end

function Inventory:get_coffee()
    return self.ingredients.coffee
end

function Inventory:get_cat_eyes()
    return self.ingredients.cat_eyes
end

function Inventory:get_camel_hump()
    return self.ingredients.camel_hump
end

function Inventory:get_seaweed()
    return self.ingredients.seaweed
end










function Inventory:has_next_page()
    return self.page == 1
end

function Inventory:has_previous_page()
    return self.page == 2
end

function Inventory:next_page()
    self.page = self.page + 1
end

function Inventory:previous_page()
    self.page = self.page - 1
end

function Inventory:use_potion(power)
    if power == "Speed" then
        self.potions.speed_potions = self.potions.speed_potions - 1
    elseif power == "Strength" then
        self.potions.strength_potions = self.potions.strength_potions - 1
    elseif power == "Underwater Breathing" then
        self.potions.underwater_breathing_potions = self.potions.underwater_breathing_potions - 1
    elseif power == "Night Vision" then
        self.potions.nightvision_potions = self.potions.nightvision_potions - 1
    elseif power == "Endurance" then
        self.potions.endurance_potions = self.potions.endurance_potions - 1
    else
        print("#ERROR: " .. power " not handled")
    end
end

function Inventory:add_potion(power)
    if power == "Speed" then
        self.potions.speed_potions = self.potions.speed_potions + 1
    elseif power == "Strength" then
        self.potions.strength_potions = self.potions.strength_potions + 1
    elseif power == "Underwater Breathing" then
        self.potions.underwater_breathing_potions = self.potions.underwater_breathing_potions + 1
    elseif power == "Night Vision" then
        self.potions.nightvision_potions = self.potions.nightvision_potions + 1
    elseif power == "Endurance" then
        self.potions.endurance_potions = self.potions.endurance_potions + 1
    else
        print("#ERROR: " .. power " not handled")
    end
end

function Inventory:add_ingredient(ingredient)
    if ingredient == "spinach" then
        self.ingredients.spinach = self.ingredients.spinach + 1
    elseif ingredient == "coffee" then
        self.ingredients.coffee = self.ingredients.coffee + 1
    elseif ingredient == "cat_eyes" then
        self.ingredients.cat_eyes = self.ingredients.cat_eyes + 1
    elseif ingredient == "camel_hump" then
        self.ingredients.camel_hump = self.ingredients.camel_hump + 1
    elseif ingredient == "seaweed" then
        self.ingredients.seaweed = self.ingredients.seaweed + 1
    else
        print("#ERROR: " .. ingredient " not handled")
    end
end
