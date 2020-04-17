Request = {}

function Request:new()
    local request = {

    }
    self.__index = self
    return setmetatable(request, self)
end