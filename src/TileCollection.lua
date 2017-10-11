local random = math.random
local log = require "lib.log"
local inspect = require "lib.inspect"

require "src.helpers.table"

local class = require "lib.middleclass"

local Tile = require "src.entities.Tile"

local chars = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}

local TileCollection = class('TileCollection')

math.randomseed(os.time())

function TileCollection:initialize(world, rows, columns)

    self.tiles = {}
    self.selection = {}
    self.world = world
    self.rows, self.columns = rows, columns

    for r = 1, rows do
        for c = 1, columns do
            local tile = Tile:new(chars[random(1, #chars)], 11 - r, c, c * 50, (r * 50) - 100)
            table.insert(self.tiles, tile)
            self.world:add(tile, tile.x, tile.y, 50, 50)
        end
    end

end

function TileCollection:findByPosition(x, y)
    local items, len = self.world:queryPoint(x, y)
    if (len > 0) then
        for i = 0, len do
            if self:has(items[i]) then
                return items[i]
            end
        end
    end
    return nil
end

function TileCollection:indexOf(tile)

    return table.indexOf(self.tiles, tile)

end

function TileCollection:has(tile)

    return table.contains(self.tiles, tile)

end

function TileCollection:remove(tile)
    if self:has(tile) then
        self.world:remove(tile)
        table.remove(self.tiles, self:indexOf(tile))
    end
end

function TileCollection:select(tile)
    if self:has(tile) and not table.contains(self.selection, tile) then
        table.insert(self.selection, tile)
        tile:down()
    end
    for i = 1, #self.selection do
        log.info(string.format("%i:%i", self.selection[i]:getMatrixPosition()))
    end

end

function TileCollection:deselect(tile)
    local index = table.indexOf(self.selection, tile)
    if index > -1 then
        local count = #self.selection - index
        for i = 1, count do
            self.selection[#self.selection]:up()
            table.remove(self.selection, #self.selection)
        end
    end
end

function TileCollection:clearSelection()
    for i = 1, #self.selection do
        self.selection[i]:up()
    end
    self.selection = {}
end

function TileCollection:lastSelected()
    if #self.selection > 0 then
        return self.selection[#self.selection]
    end
    return nil
end

function TileCollection:isSelected(tile)
    return table.contains(self.selection, tile)
end

function TileCollection:removeSelected()

    local addAgain = {}
    for i = 1, self.columns do
       addAgain[i] = 0
    end
    for i = 1, #self.selection do
        local item = self.selection[i]

        addAgain[item.column] = addAgain[item.column] + 1

        self:remove(item)


        for i = 1, #self.tiles do
            local tile = self.tiles[i]
            if tile.column == item.column and tile.row > item.row then
                tile:matrixMoveDown()
            end
        end
    end

    for c = 1, #addAgain do
        for j = 1, addAgain[c] do
            local tile = Tile:new(chars[random(1, #chars)], 10 - (addAgain[c] - j), c, c * 50, (40 + (60 * j)) * -1)
            table.insert(self.tiles, tile)
            self.world:add(tile, tile.x, tile.y, 50, 50)
        end
    end

    self.selection = {}

    log.info('ADD AGAIN:')
    log.info(inspect(addAgain))

end

return TileCollection