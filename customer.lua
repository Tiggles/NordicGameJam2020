require "request"


Customer = {}
function Customer:new()
    local new_customer = {
        request = Request:new(),
        color = math.random(1),
        served = false
    }
    self.__index = self
    return setmetatable(new_customer, self)
end

function Customer:get_line()
    return self.request:get_line()
end

function Customer:get_power()
    return self.request.requested_powers
end