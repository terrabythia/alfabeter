local random = math.random
local log = require "lib.log"
local inspect = require "lib.inspect"
local class = require "lib.middleclass"
local bump = require "lib.bump"

local wordIndexes = require "resources.words.index"

local TileCollection = require "src.TileCollection"

local Level = class('Level')

local world = bump.newWorld()
local stubs = {}
local tileCollection

-- TODO: the tiles should accelerate over time
local gravity = 2.5

local ready = false
local mouseDown = false

local floor
local tileCharFont

local tileSound
local tileSound2

function Level:initialize(width, height)

    -- start new game!
    self.width = width
    self.height = height

    tileSound = love.audio.newSource("resources/sounds/tick.wav", "static")
    tileSound2 = love.audio.newSource("resources/sounds/tick2.wav", "static")
    tileCharFont = love.graphics.newFont(30)

    -- build the floor
    floor = {name = "FLOOR", x = 0, y = height - 10, w = width, h = 10}
    world:add(floor, floor.x, floor.y, floor.w, floor.h)

    for i = 1, 5 do
        local stub = { x = (i * 2 * 50), y = floor.y - (50 / 2), w = 50, h = 50 / 2 }
        world:add(stub, stub.x, stub.y, stub.w, stub.h)
        table.insert(stubs, stub)
    end

    tileCollection = TileCollection:new(world, 10, 10)

end

local function getWord()
    local selected = tileCollection.selection;
    local wordParts = {}
    local wordIndex = {}
    for i = 1, #selected do
        if i < 4 then wordIndex[i] = selected[i].char end
        wordParts[i] = selected[i].char
    end

    return table.concat(wordParts, ""):lower(), table.concat(wordIndex, ""):lower()
end

local function checkWord()

--    if true then
--       return true
--    end

    local selected = tileCollection.selection
    if #selected < 3 then
        return false
    end

    local word, start = getWord()

    -- check wheter the index for this word exists
    if not table.contains(wordIndexes, start) then
        return false
    end

    local words = require( string.format("resources.words.%s", start) )

    if (table.contains(words, word)) then
        words = nil
        return true
    end

    --- Word does not exist!
    words = nil
    return false

end

function Level:mousedragged()

    local tile = tileCollection:findByPosition(love.mouse.getPosition())

    log.info('----- CHECK ------');

    local tileSelection = tileCollection.selection
    if tile then

        local last = tileCollection:lastSelected()

        if 0 == #tileSelection then
            -- 1: #tileSelection == 0 > select
            tileCollection:select(tile)
            log.info('select first')
        elseif last == tile then
            -- 2: tileSelection[end] == tile? do nothing
            log.info('is Last')
        elseif tileCollection:isSelected(tile) then
            -- 3: tile in tiles ? > unselect backwards
            tileCollection:deselect(tile)
            log.info('deselect')
        else
            -- check wheter its inside or outside the range..
            if (tile.column >= last.column - 1 and
                tile.column <= last.column + 1 and
                tile.row >= last.row - 1 and
                tile.row <= last.row + 1) then
                -- 5: tile in range ? select
                tileCollection:select(tile)
                log.info('select next')
            else
                tileCollection:clearSelection()
                mouseDown = false
                log.info('clear')
            end

        end


    end

end

function Level:update(dt)

    if mouseDown then

        self:mousedragged()

    end

    local tiles = tileCollection.tiles;
    for i = 1, #tiles do
        local tile = tiles[i]
        if tile.isStationary then
            -- when the tiles are all stationary for the first time
            -- the game is ready to receive mouse events
            ready = true
            if tile.acceleration > 1 then
                tileSound2:play()
            end
            tile.acceleration = 1
        else
            -- todo: get better at math!
            tile.acceleration = tile.acceleration + (dt * (tile.acceleration * 3.5))
            log.info('update acceleration', tile.acceleration, 1 / dt)
        end
    end

end

function Level:draw()

    -- draw the floor
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("fill", floor.x, floor.y, floor.w, floor.h)

    for _, stub in pairs(stubs) do
        love.graphics.rectangle("fill", stub.x, stub.y, stub.w, stub.h)
    end

    local tiles = tileCollection.tiles;
    for i = 1, #tiles do

        -- try to move the body to the bottom of the screen
        local tile = tiles[i]
        local actualX, actualY = world:move(tile, tile.x, tile.y + ((gravity * 3) + (tile.acceleration)))

        tile.isStationary = actualY == tile.y
        tile.x, tile.y = actualX, actualY

        if tile.isDown then
            love.graphics.setColor(0, 0, 255)
        else
            love.graphics.setColor(0, 255, 0)
        end

        love.graphics.rectangle("fill", tile.x, tile.y, 50, 50)

        -- debug: draw the row:column on the tile
        love.graphics.setColor(255, 255, 255)
--        love.graphics.print(string.format("%i:%i", tile.row, tile.column), tile.x + 10, tile.y + 10)

        -- draw the character
        love.graphics.setFont(tileCharFont)
        love.graphics.print(tile.char, tile.x + 10, tile.y + 10)

    end

end

function Level:mousepressed(x, y)

    if not ready then return end

    if #tileCollection.selection > 2 then
        local tile = tileCollection:findByPosition(love.mouse.getPosition())
        if tile then
            local last = tileCollection:lastSelected()
            if last == tile then
                -- check word now!
                -- only clear selection if not a word??
                if checkWord() then
                    log.info('WORD EXISTS!')
                    tileCollection:removeSelected()
                    tileCollection:clearSelection()
                else
                    log.info('WORD DOES NOT EXIST!')
                    tileCollection:clearSelection()
                end
                return
            end
        end
    end

    mouseDown = true

end

function Level:mousereleased(x, y)

    mouseDown = false

end

return Level


