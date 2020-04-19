Clock = {}

local days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}

function Clock:new(opening_hour, closing_hour, start_hour, start_minutes, clock_speed)
    local clock = {
        opening_hour = opening_hour,
        closing_hour = closing_hour,
        hours = start_hour,
        minutes = start_minutes,
        day = 1,
        week = 0,
        clock_speed = clock_speed
    }
    self.__index = self
    return setmetatable(clock, self)
end

function Clock:update(delta)
    self.minutes = self.minutes + (delta * self.clock_speed)
    if self.minutes > 60 then
        self.hours = self.hours + 1
        self.minutes = 0
    end
    if self.hours == 24 then
        self.hours = 0
        self.day = self.day % #days + 1
        if self.day == 1 then
            self.week = self.week + 1
        end
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
    local sectioned_minutes = self.minutes - self.minutes % 10 
    return days[self.day].. " " .. pad(math.floor(self.hours), 10, "0") .. ":" .. pad(math.floor(sectioned_minutes), 10, "0")
end

function Clock:is_open()
    return self.hours >= self.opening_hour and self.hours < self.closing_hour and self.day ~= 7
end

function Clock:skip_to_open()
    if self.hours >= self.closing_hour or self.day == 7 then
        self.day = self.day % #days + 1
    end
    self.hours = self.opening_hour
    self.minutes = 0
    if self.day == 1 then
        self.week = self.week + 1
    end
end
