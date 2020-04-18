Inventory = {}

function Inventory:new()
    local inventory = {
        potions = {
            speed_potions = 0,
            strength_potions = 0,
            underwater_breathing_potions = 0,
            endurance_potions = 0
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

function Inventory:has_next_page()

end

function Inventory:next_page()

end