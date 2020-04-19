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
        money = 200,
        ingredients = {

        },
        page = 1
    }
    self.__index = self
    return setmetatable(inventory, self)
end

function Inventory:add_money(amount)
    self.money = self.money + math.floor(amount)
end

function Inventory:has_enough_money(to_spend)
    return self.money >= to_spend
end

function Inventory:spend_money(amount)
    self.money = math.max(self.money - amount, 0)
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

function Inventory:has_next_page()
    return self.page == 1
end

function Inventory:has_previous_page()
    return self.page == 2
end

function Inventory:next_page()
    self.page = math.min(self.page + 1, 2)
end

function Inventory:previous_page()
    self.page = math.max(self.page - 1, 1)
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