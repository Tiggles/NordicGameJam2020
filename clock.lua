Clock = {}

function Clock:new(opening_hour, closing_hour, start_hour, start_minutes)
    local clock = {
        opening_hour = opening_hour,
        closing_hour = closing_hour,
        hours = start_hour,
        minutes = start_minutes
    }
    self.__index = self
    return setmetatable(clock, self)
end

function Clock:update(delta)
    self.minutes = self.minutes + (delta * 24)
    if self.minutes > 60 then
        self.hours = self.hours + 1
        self.minutes = 0
    end
    if self.hours == 24 then
        self.hours = 0
    end
end

local function pad(val, threshold, padding_char)
    local padded_val = tostring(val)
    if val < threshold then
        padded_val = padding_char .. padded_val
    end
    return padded_val
end

function Clock:to_string()
    return pad(math.floor(self.hours), 10, "0") .. ":" .. pad(math.floor(self.minutes), 10, "0")
end

function Clock:is_open()
    return self.hours >= self.opening_hour and self.hours < self.closing_hour
end