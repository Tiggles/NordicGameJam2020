HELP_SHOP = [[
    You run a small potion shop in the city.
    In your opening hours every day from
    10:00 to 18:00, customers will come to you
    with their problems. The better you do, the
    higher the rate of customers will become.

    You are closed on sundays.
]]

HELP_NEXT = [[
    Click space or left mouse
    button to continue. 
]]

HELP_CONVERSATION = [[ 
    If you have the potion in stock, you can sell it, but
    the faster the better. If you don't have it in stock,
    you can tell the customer to come back a week from 
    today, but only once. Otherwise, you can decline.
]]

HELP_INVENTORY = [[
    Your inventory shows the potions in stock and
    the amount of ingredients available. Click the
    left and right buttons to navigate your
    inventory. To the bottom you can see your 
    current balance and go to your garden. 
    
    Time doesn't stop in the garden.
]]

HELP_GARDEN = [[
    In your garden, you can plant ingredients. After
    a certain amount of time, they can be picked,
    and used for brewing potions.
    
    Every ingredient has a price to plant,
    except seaweed.
]]

HELP_BREWING = [[
    Brewing potions is done using the ingredients
    from your garden. Add the ingredients to your
    cauldrons by clicking on an ingredient and
    then a cauldron to brew.
]]

Help = {}

function Help:new()
    local help = {
        page = 1,
        page_count = 4
    }
    self.__index = self
    return setmetatable(help, self)
end

function Help:next_page(game_state)
    if self.page == self.page_count then
        game_state.current_location = "menu"
        self.page = 1
    else
        self.page = self.page + 1
    end

end


INGREDIENTS_WARNING = [[
        You need at least
      two of an ingredient.
]]

CUSTOMER_LEFT = "    Customer left."