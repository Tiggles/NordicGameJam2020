Request = {}

local POWERS = {
    "Speed",
    "Strength",
    "Underwater Breathing",
    "Night Vision",
    "Endurance"
}

local strength_lines = {
    "I'm helping a friend move this weekend.",
    "I'm need help moving some stuff.",
    "I just wanna rip & tear."
}

local underwater_breathing_lines = {
    "I'm diving this weekend.",
    "I want to explore the ocean."
}

local speed_lines = {
    "There's a marathon soon.",
    "My child is a fast runner and \n I wanna show him up."
}

local nightvision_lines = {
    "Somebody is pooping in my yard at night,\n and I want to catch them."
}

local endurance_lines = {
    "I enjoy powerwalking, but I \n want to do it longer."
}

local function lines_from_power(power)
    if power == POWERS[1] then -- SPEED
        return speed_lines[love.math.random(#speed_lines)]
    elseif power == POWERS[2] then -- STRENGTH
        return strength_lines[love.math.random(#strength_lines)]
    elseif power == POWERS[3] then -- UNDERWATER_BREATHING
        return underwater_breathing_lines[love.math.random(#underwater_breathing_lines)]
    elseif power == POWERS[4] then -- NIGHT VISION
        return nightvision_lines[love.math.random(#nightvision_lines)]
    elseif power == POWERS[5] then -- ENDURANCE
        return endurance_lines[love.math.random(#endurance_lines)]
    end

    return "#ERROR: Didn't match any power: " .. power
end

function Request:new()
    local power = POWERS[love.math.random(#POWERS)]
    print(power)
    local request = {
        requested_powers = power,
        line = lines_from_power(power)
    }
    self.__index = self
    return setmetatable(request, self)
end

function Request:get_line()
    return self.line
end