-- originally created in may 2016, revived in may 2018

timer = 0
loss = 0
debugmode = true -- debug mode?
godmode = false -- lets you walk over water LIKE JESUS DID HAHA GET IT

local levels = require("levels") -- loads levels
local currentLevel

local playerspeed

function GetCharPos()
	local charposx = ((chartilex - 1) * 32) + 1
	local charposy = ((chartiley - 1) * 32) + 1
	return {charposx, charposy}
end

function LoadMap(levelNum)
	loss = 0
	timer = 0

	currentLevel = levels[levelNum]
	TileTable = currentLevel.TileTable
	Move("check")
	--[[
    TileTable = { -- size is 25x19
        {2,2,2,2,2,2,2,2,1,1,3,2,2,2,2,2,2,2,2,2,2,1,1,2,1},
        {2,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
        {1,2,1,2,2,2,2,1,2,2,2,2,2,2,2,2,2,1,2,1,2,1,2,2,1},
        {1,2,2,1,2,1,1,1,1,2,2,2,2,2,1,2,2,2,2,2,1,2,1,2,2},
        {2,2,1,2,1,2,2,2,2,2,2,2,2,1,2,1,2,1,2,2,2,2,1,2,1},
        {1,1,2,1,2,1,2,2,2,2,2,1,2,1,2,2,2,2,2,2,1,2,2,2,2},
        {2,2,1,2,1,2,1,1,1,1,2,1,2,1,2,2,2,2,1,1,2,2,2,2,2},
        {1,2,2,1,2,1,2,2,2,2,2,1,2,1,2,2,2,2,1,2,1,2,2,2,2},
        {1,2,1,2,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,2,2,2,2,2},
        {2,2,2,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,2,2,2,2,2},
        {2,2,1,2,2,2,2,2,1,1,2,2,1,1,2,2,1,1,1,2,2,2,2,2,2},
        {2,2,2,2,2,2,2,2,1,2,1,1,2,1,2,2,2,1,2,1,2,2,2,2,2},
        {2,2,2,2,2,2,2,2,2,1,2,2,1,2,1,2,1,2,1,2,2,2,2,2,2},
        {2,2,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2}
    }
	]]--
end

function GenerateMap(seed)
    TileTable = {}
    if seed then
        love.math.setRandomSeed(seed)
    end
    seedl,seedh = love.math.getRandomSeed()
    while #TileTable < 20 do
        table.insert(TileTable,{})
    end
    for i,v in pairs(TileTable) do
        while #v < 26 do
            table.insert(v,love.math.random(1,3))
        end
    end
    TileTable[love.math.random(10,19)][love.math.random(16,25)] = 4
    TileTable[1][1] = 1
    return TileTable
end

function Move(key) -- movement and collision system
	local jump
	
	-- movement variables, movex is amount of horizontal tiles to move and movey is amount of vertical tiles to move
	local movex = 0
	local movey = 0
	local moveto -- tile to move to
	local movefrom -- tile moved from
	
    if love.keyboard.isDown("space") then
        jump = true
    end
    if key == "w" or key == "up" then
		movey = -1
    elseif key == "s" or key == "down" then
        movey = 1
    elseif key == "a" or key == "left" then
        movex = -1
    elseif key == "d" or key == "right" then
        movex = 1
	elseif key == "m" and debugmode then -- godmode toggle
		if godmode then godmode = false elseif not godmode then godmode = true end -- confusing but gets the job done
	elseif key == "check" then
		movex = 0
		movey = 0
    end
	if jump then
		movex = movex * 2
		movey = movey * 2
	end
	print(movey)
	print(movex)
	print(chartiley)
	print(chartilex)
	print(TileTable[1][4])
	
	--checking if the character didn't reach the border or something
	if (chartiley + movey) >= 15 or (chartiley + movey) <= 0 then
		return
	end
	if (chartilex + movex) >= 26 or (chartilex + movex) <= 0 then
		return
	end
	
	movefrom = TileTable[chartiley][chartilex]
    moveto = TileTable[chartiley + movey][chartilex + movex]
	
	-- checking collision
	if godmode then -- you're god
		chartilex = chartilex + movex
		chartiley = chartiley + movey
		return
	end
	if moveto == 2 then -- if you hit water, you can't pass
		chartilex = currentLevel.StartLocation[1]
		chartiley = currentLevel.StartLocation[2]
		return
	elseif moveto == 3 then -- if you hit the finish line, you win!
		if (currentLevel.id + 1) <= levels.levelCount then
			LoadMap(currentLevel.id + 1) -- load level woohoo
		end
	--ice
	elseif movefrom == 4 then
		TileTable[chartiley][chartilex] = 2
	elseif movefrom == 5 then
		TileTable[chartiley][chartilex] = 4
	elseif movefrom == 6 then
		TileTable[chartiley][chartilex] = 5
	elseif movefrom == 7 then
		TileTable[chartiley][chartilex] = 6
	end
	-- now to move the player
	chartilex = chartilex + movex
	chartiley = chartiley + movey
end

function love.load(arg)
    -- genseed = tonumber(arg[1]) -- really old depricated feature
    TileW, TileH = 32, 32
    chartilex = 1
    chartiley = 1
    terrain = love.graphics.newImage("terrain2.png")
    titlescreen = love.graphics.newImage("awedd2.png")
	--declaring tiles and setting tile textures
    tiles = {}
    tiles[1] = love.graphics.newQuad(0,0,32,32,terrain:getDimensions()) -- grass
    tiles[2] = love.graphics.newQuad(32,0,32,32,terrain:getDimensions()) -- void(?)
    tiles[3] = love.graphics.newQuad(64,0,32,32,terrain:getDimensions()) -- finish
	tiles[4] = love.graphics.newQuad(0,128,32,128,terrain:getDimensions()) -- thinnest ice
	tiles[5] = love.graphics.newQuad(32,128,64,128,terrain:getDimensions()) -- thin ice
	tiles[6] = love.graphics.newQuad(64,128,96,128,terrain:getDimensions()) -- thick ice
	tiles[7] = love.graphics.newQuad(96,128,128,128,terrain:getDimensions()) -- thickest ice

    char = love.graphics.newImage("char.png")
    bgm1 = love.audio.newSource("bgm1.mp3")
    timer = 0

    loaded = false
    finished = false
end

function love.update(dt)
    if loaded == true and finished == false then
        timer = timer + dt
    end
    love.audio.play(bgm1)
	print("gay")
end

function love.draw()
	if not loaded then
        love.graphics.draw(titlescreen,0,0,0)
    end
    if TileTable == nil then return end
    for rowIndex=1, #TileTable do
        local row = TileTable[rowIndex]
        for columnIndex=1, #row do
            local number = row[columnIndex]
            love.graphics.draw(terrain, tiles[number], (columnIndex-1)*TileW, (rowIndex-1)*TileH)
        end
    end
	local charpos = GetCharPos()
    love.graphics.draw(char,charpos[1],charpos[2])
	love.graphics.print({{0,0,0},"Level: "..currentLevel.id})
    love.graphics.print({{0,0,0},"Time: "..timer},0,10)
	love.graphics.print({{0,0,0},"Losses: "..loss},0,20)
	love.graphics.print({{0,0,0},love.filesystem.getIdentity()},0,69)
	if debugmode then
		love.graphics.print({{0,0,0},"(Pixel) X: "..charpos[1]..", Y: "..charpos[2]},0,30)
		love.graphics.print({{0,0,0},"(Tile) X: "..chartilex..", Y: "..chartiley},0,40)
	end
	if godmode then
		love.graphics.print({{0,0,0},"God mode enabled!"},0,50)
	end
end

function love.keypressed(key,scancode,isrepeat)
	if key == "escape" then
		love.event.quit()
	end
    if loaded == true then
        Move(key)
    else
		LoadMap(1)
		Move("check")
        loaded = true
    end
end