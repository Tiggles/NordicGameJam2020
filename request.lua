Request = {}

local strength_lines = {
    "I'm helping a friend move this weekend.",
    "I'm need help moving some stuff.",
    ""
}

local underwater_breathing_lines = {
    "I'm diving this weekend.",
}

local speed_lines = {
    "There's a marathon soon.",

}

local responses = {
    accept = { "I have just the thing", "Follow me", "Sure, this way" }
}

function Request:new()
    local request = {
        requested_powers = {},
        voice_lines = {}
    }
    self.__index = self
    return setmetatable(request, self)
end