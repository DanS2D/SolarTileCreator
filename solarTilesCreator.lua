
local M = {
	tileSets = {},
	tileSheets = {},
	map = {
		layers = {},
		tileWidth = 0,
		tileHeight = 0,
		filePath = nil,
	},
	group = display.newGroup()
}
local bit = require("plugin.bit")
local json = require("json")
local ioExt = require("ext.io")
local stringExt = require("ext.string")
local newSprite = display.newSprite
local newImageRect = display.newImageRect
local newRect = display.newRect
local bAnd = bit.band
local bRShift = bit.rshift

local function tileProperties(tileNum, tileset)
	for i = 1, #tileset.tiles do
		local tile = tileset.tiles[i]

		if (tile.id == tileNum) then
			return tile.properties
		end
	end

	return nil
end

function M:_createTile(tileNum, tileset)
	local tileWidth = self.map.tileWidth
	local tileHeight = self.map.tileHeight
	local tileNo = bAnd(0xFFFFFFF, tileNum)

	if (tileNo > 0) then
		local animated = false

		for i = 1, #tileset.tiles do
			local tile = tileset.tiles[i]
			local tileProperties = tileProperties(tileNo, tileset)

			if (tileProperties ~= nil) then					
				if (tileProperties[1].name == "animated" and tileProperties[1].value == true) then
					animated = true
					break
				end
			end
		end

		if (animated) then
			-- todo: fill in with real data
			local sequenceData =
			{
				name = "todo",
				start = tileNo,
				count = 1,
				time = 100,
				loopCount = 0, -- Optional ; default is 0 (loop indefinitely)
				loopDirection = "bounce" -- Optional ; values include "forward" or "bounce"
			}

			return newSprite(self.tileSheets[1], sequenceData)
		else
			local imageSheet = nil
			local drawTileNum = tileNo
			local rotation = 0
			local FLIPPED_HORIZONTALLY_FLAG = 0x80000000
			local FLIPPED_VERTICALLY_FLAG = 0x40000000
			local FLIPPED_DIAGONALLY_FLAG = 0x20000000
			local flippedHorizontally = 0
			local flippedVertically = 0
			local flippedDiagonally = 0

			for i = 1, #self.tileSets do
				local curTileCount = self.tileSets[i].tileCount
				local startTileID = self.tileSets[i].startTileID

				if (tileNo <= curTileCount) then
					imageSheet = self.tileSheets[i]
					drawTileNum = tileNo
					rotation = bRShift(tileNum, 28)
					flippedHorizontally = bAnd(tileNum, FLIPPED_HORIZONTALLY_FLAG)
					flippedVertically = bAnd(tileNum, FLIPPED_VERTICALLY_FLAG)
					flippedDiagonally = bAnd(tileNum, FLIPPED_DIAGONALLY_FLAG)

					--print(("flipped Horiz: 0x%x, Vert: 0x%x, Diag: 0x%x"):format(flippedHorizontally, flippedVertically, flippedDiagonally))

					if (bRShift(tileNum, 28) == 0xA) then -- 90 degrees
						rotation = 90
					elseif (bRShift(tileNum, 28) == 0xC) then -- 180 degrees
						rotation = 180
					elseif (bRShift(tileNum, 28) == 0x6) then -- 270 degrees
						rotation = 270
					end

					break
				else
					if (#self.tileSheets >= i + 1) then
						imageSheet = self.tileSheets[i + 1]
						startTileID = self.tileSets[i + 1].startTileID
						drawTileNum = (tileNo - startTileID) + 1
						print(("i: %d, start tile ID: %d, tileNum: %d, drawTileNum: %d"):format(i, startTileID, tileNum, drawTileNum))
					end
					break
				end
			end

			--local tile = newImageRect(imageSheet, drawTileNum, tileWidth, tileHeight), rotation
			--tile.rotation = rotation
			local sequenceData =
			{
				name = "todo",
				start = drawTileNum,
				count = 1,
				time = 100,
				loopCount = 0, -- Optional ; default is 0 (loop indefinitely)
				loopDirection = "bounce" -- Optional ; values include "forward" or "bounce"
			}
			local tile = newSprite(imageSheet, sequenceData)

			if (flippedHorizontally ~= 0) then
				--tile.xScale = -1
				
				print(("flippedHor: 0x%x"):format(flippedHorizontally))
			end

			if (flippedVertically ~= 0) then
				--tile.yScale = -1
				print(("flippedVer: 0x%x"):format(flippedVertically))
			end

			if (flippedDiagonally ~= 0) then
				--tile.rotation = 90
				--tile.xScale = 1
				--tile.yScale = 1
				print(("flippedDiag: 0x%x"):format(flippedDiagonally))
			end

			return tile
		end
	else
		return nil
	end
end

--display.setDefault("background", 1, 1, 1)

function M:drawMapLayers(mapFilePath)
	local tileWidth = self.map.tileWidth
	local tileHeight = self.map.tileHeight

	for i = 1, #self.map.layers do
		local x = 0
		local y = 0
		local limit = math.min(120, #self.map.layers[i].data)
		local t = 0
		local rows = 20
		local k = 1

		for j = 1, 200 do
			 t = t + 1

			if (j % rows == 0) then
				t = (self.map.layers[i].width * k)
				k = k + 1
			end

			local tileNum = self.map.layers[i].data[t]
			local tile = self:_createTile(tileNum, self.tileSets[1])
			--tile.alpha = math.random(1, 255) / 255

			if (tile ~= nil) then
				--print(j, tileNum)
				tile.x = x + (tileWidth / 2)
				tile.y = y + (tileHeight / 2)
				self.group:insert(tile)
			end

			x = x + tileWidth

			if (j % rows == 0) then
				--print(j)
			--if (j % self.map.layers[i].width == 0) then
			--next = self.layers[1].
				x = 0
				y = y + tileHeight
			end
		end
	end
end

function M:loadMap(fileName)
	local data, pos, msg = json.decodeFile(fileName)
	self.map.filePath = fileName:getFilePath()

	if (type(data) ~= "table") then
		print(("Failed to load map: %s\nDecode failed at %d : %s"):format(pos, msg))
		return
	end

	--print(("Loaded map: %s\ndata: %s"):format(fileName, json.prettify(data)))
	
	-- load all tilesets associated with this map
	if (type(data.tilesets) == "table" and #data.tilesets > 0) then
		for i = 1, #data.tilesets do
			local tileset = data.tilesets[i]
			--print(json.prettify(tileset))

			local fileName = tileset.source:getFileName()
			self:loadTileSheet(("%s/%s"):format(self.map.filePath, fileName), tileset.firstgid)
		end
	end

	-- get the layer data
	if (type(data.layers) == "table" and #data.layers > 0) then
		for i = 1, #data.layers do
			local currentLayer = data.layers[i]

			self.map.layers[#self.map.layers + 1] = 
			{
				id = currentLayer.id,
				name = currentLayer.name,
				opacity = currentLayer.opacity,
				visible = currentLayer.visible,
				type = currentLayer.type,
				x = currentLayer.x,
				y = currentLayer.y,
				width = currentLayer.width,
				height = currentLayer.height,
				data = currentLayer.data,
			}
		end
	end

	-- get other map properties
	self.map.tileWidth = data.tilewidth
	self.map.tileHeight = data.tileheight

	self:drawMapLayers(self.map.filePath)


	local function onKeyEvent(event)
		local keyName = event.keyName
		local phase = event.phase
		local moveAmount = 32

		--print(keyName)
	
		if (phase == "up") then
			if (keyName:lower() == "enter") then
			elseif (keyName:lower() == "i") then
				local newScale = self.group.xScale + 0.1
				transition.to(self.group, {xScale = newScale, yScale = newScale})
			elseif (keyName:lower() == "o") then
				local newScale = self.group.xScale - 0.1
				transition.to(self.group, {xScale = newScale, yScale = newScale})
			end
		else
			if (keyName:lower() == "right") then
				self.group.x = self.group.x - moveAmount
			elseif (keyName:lower() == "left") then
				self.group.x = self.group.x + moveAmount
			elseif (keyName:lower() == "up") then
				self.group.y = self.group.y + moveAmount
			elseif (keyName:lower() == "down") then
				self.group.y = self.group.y - moveAmount
			end
		end
	
		return true
	end
	
	Runtime:addEventListener("key", onKeyEvent)
end

function M:loadTileSheet(fileName, startTileID)
	-- image is expected to be in the same directory as the tile json data
	local data, pos, msg = json.decodeFile(fileName)

	if (type(data) ~= "table") then
		print(("Failed to load tilesheet: %s\nDecode failed at %d : %s"):format(pos, msg))
		return	
	end

	--print(("Loaded tilesheet: %s\ndata: %s"):format(fileName, json.prettify(data)))
	-- need to load the image data here too (spritesheet)

	self.tileSets[#self.tileSets + 1] = 
	{
		tileWidth = data.tilewidth,
		tileHeight = data.tileheight,
		tiles = data.tiles,
		type = data.type,
		tileCount = data.tilecount,
		spacing = data.spacing,
		margin = data.margin,
		name = data.name,
		image = data.image,
		imageWidth = data.imagewidth,
		imageHeight = data.imageheight,
		startTileID = startTileID
	}

	local tileSheetOptions =
	{
		width = self.tileSets[#self.tileSets].tileWidth,
		height = self.tileSets[#self.tileSets].tileHeight,
		numFrames = self.tileSets[#self.tileSets].tileCount,
		sheetContentWidth = self.tileSets[#self.tileSets].imageWidth, -- width of original 1x size of entire sheet
		sheetContentHeight = self.tileSets[#self.tileSets].imageHeight -- height of original 1x size of entire sheet
	}

	-- load the tilesheet (imagesheet)
	self.tileSheets[#self.tileSheets + 1] = graphics.newImageSheet(("%s/%s"):format(self.map.filePath, data.image), tileSheetOptions)
end

return M
