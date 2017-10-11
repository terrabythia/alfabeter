local log = require "lib.log"
local inspect = require "lib.inspect"

local Menu = require "src.Menu"
local Level = require "src.Level"

local mainMenu
local level

function love.load()
    local width, height = love.graphics.getDimensions()
--    level = Level:new(width, height)

    -- first initialize menu
    mainMenu = Menu:new(width, height)
    Menu.onNewGame:addAction(
        function()
            mainMenu = nil
            level = Level:new(width, height)
        end
    )

end

function love.update(dt)
    if (level) then level:update(dt) end
    if (mainMenu) then mainMenu:update(dt) end
end

function love.draw()
--    level.draw()
    -- draw the menu?
    if (mainMenu) then mainMenu:draw() end
    if (level) then level:draw() end
end

function love.mousepressed(x, y, button)
    if (mainMenu) then mainMenu:mousepressed(x, y, button) end
    if (level) then level:mousepressed(x, y) end
end

function love.mousereleased(x, y, button)
    if (mainMenu) then mainMenu:mousereleased(x, y, button) end
    if (level) then level:mousereleased(x, y) end

end