local class = require "lib.middleclass"
local Entity = require "src.entities.Entity"

local Tile = class('Tile', Entity)

function Tile:initialize(char, row, column, x, y)
    self.isStationary = true
    self.acceleration = 1
    self.isDown = false
    self.char = char
    self.row, self.column = row, column
    self.x, self.y = x, y
end

function Tile:getMatrixPosition()
    return self.row, self.column
end

function Tile:setMatrixRowPosition(row)
    self.row = row
end

function Tile:matrixMoveDown()
    if (self.row > 0) then
        self:setMatrixRowPosition( self.row - 1 )
    end
end

function Tile:down()
    self.isDown = true
end

function Tile:up()
    self.isDown = false
end

return Tile