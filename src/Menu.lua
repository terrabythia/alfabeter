local class = require "lib.middleclass"
local log = require "lib.log"
local inspect = require "lib.inspect"
local Luvent = require "lib.Luvent"

local gui = require "lib.Gspot"
local menuGui = gui()

local Menu = class('Menu')

Menu.static.onNewGame = Luvent.newEvent()

function Menu:initialize(width, height)

    self.width, self.height = width, height

    -- create buttons
    -- button
    local button = menuGui:button('Start', {x = (self.width - 128) / 2, y = gui.style.unit, w = 128, h = gui.style.unit}) -- a button(label, pos, optional parent) gui.style.unit is a standard gui unit (default 16), used to keep the interface tidy
    button.click = function(this, x, y) -- set element:click() to make it respond to gui's click event
        -- todo: let the parent class know to start the game
        Menu.onNewGame:trigger()
    end

end

function Menu:update(dt)
    menuGui:update(dt)
end

function Menu:draw()
    menuGui:draw()
end

function Menu:mousepressed(x, y, button)
    menuGui:mousepress(x, y, button)
end

function Menu:mousereleased(x, y, button)
    menuGui:mouserelease(x, y, button)
end

return Menu