require "request"


Customer = {}
function Customer:new_customer()
    local new_customer = {
        request = Request:new()
    }
    self.__index = self
    return setmetatable(Customer, self)
end