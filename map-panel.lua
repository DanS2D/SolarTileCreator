local floatingPanel = require("floating-panel")
local editor = require("editor")
local M = {}
local mFloor = math.floor

function M:new(topGroup, gridRows, gridColumns)
	local topGroup = topGroup or error("map-panel: missing topGroup!")

	if (type(gridRows) ~= "number") then 
		error("map-panel: missing rows!")
	end

	if (type(gridColumns) ~= "number") then 
		error("map-panel: missing columns!")
	end

	local panel = floatingPanel:new({
		width = display.contentWidth - (display.contentWidth * 0.4),
		height = (display.contentHeight) - 47,
		title = "Map",
	})
	panel.x = (panel.width * 0.5)
	panel.y = (panel.height * 0.5) + 36
	panel.tiles = {}
	panel.layers = {{}}
	panel.startX = 1
	panel.xCount = mFloor((panel.width / 32) - 1)
	panel.startY = 1
	panel.yCount = mFloor((panel.height / 32) - 1)

	local overlay = {}
	local tileSheetOptions =
	{
		width = 32,
		height = 32,
		numFrames = 8640,
		sheetContentWidth = 3456, -- width of original 1x size of entire sheet
		sheetContentHeight = 2560 -- height of original 1x size of entire sheet
	}
	local sequenceData =
	{
		name = "highlightTile",
		start = 1,
		count = 8640,
		time = 0,
		loopCount = 1, -- Optional ; default is 0 (loop indefinitely)
		loopDirection = "bounce" -- Optional ; values include "forward" or "bounce"
	}

	local imageSheet = graphics.newImageSheet("data/tiles/tilesheet_complete_2X.png", tileSheetOptions)
	
	local highlightTile = display.newSprite(imageSheet, sequenceData)
	highlightTile.strokeWidth = 1
	highlightTile:setStrokeColor(1, 0, 0)
	highlightTile.stroke.effect = "generator.marchingAnts"
	highlightTile.isVisible = false
	panel:insert(highlightTile)

	for i = 1, gridRows * gridColumns do
		panel.layers[1][i] = 0
	end

	-- create overlay grid
	for i = 1, panel.xCount do
		for j = 1, panel.yCount do
			overlay[#overlay + 1] = display.newRect(0, 0, 31, 31)
			overlay[#overlay].strokeWidth = 1
			overlay[#overlay]:setFillColor(0, 0, 0, 0.01)
			overlay[#overlay]:setStrokeColor(1, 1, 1, 0.5)
			overlay[#overlay].x = (i * 32) - (panel.width * 0.5)
			overlay[#overlay].y = (j * 32) - (panel.height * 0.5)
			panel:insert(overlay[#overlay])
		end
	end

	local function placeTile(event)
		local target = event.target
		panel.layers[1][target.tileIndex] = editor.selectedTileId
		--print(("map layer 1, tile index: %d now has tile %d"):format(target.tileIndex, selectedTileId))
		--print("place tile tapped")

		return true
	end

	local function mouseTile(event)
		local target = event.target
		local phase = event.type

		if (phase == "move") then
			highlightTile.isVisible = (editor.selectedTileId > 0)

			if (editor.selectedTileId > 0) then
				highlightTile:setFrame(editor.selectedTileId)
				highlightTile.isVisible = true
				highlightTile.x = target.x
				highlightTile.y = target.y
			end
		end
	
		return true
	end

	function panel:render()
		for i = 1, #self.tiles do
			display.remove(self.tiles[i])
			self.tiles[i] = nil
		end

		self.tiles = {}
		self.tiles = nil
		self.tiles = {}
		local iX = 0
		local jY = 0
	
		for i = self.startX, self.startX + (self.xCount - 1) do
			iX = iX + 1
		
			if (iX > self.xCount) then
				iX = 1
			end
	
			for j = self.startY, self.startY + (self.yCount - 1) do
				jY = jY + 1
	
				if (jY > self.yCount) then
					jY = 1
				end
	
				local index = (i + (self.xCount * j)) -- math: (x + (#mapRows * y))
				local tileIndex = self.layers[1][index]
	
				if (tileIndex > 0) then
					self.tiles[#self.tiles + 1] = display.newImageRect(imageSheet, tileIndex, 32, 32)
				else
					self.tiles[#self.tiles + 1] = display.newRect(0, 0, 32, 32)
					self.tiles[#self.tiles]:setFillColor(0, 0, 0, 0.01)
				end
					
				self.tiles[#self.tiles].x = (iX * 32) - (panel.width * 0.5)
				self.tiles[#self.tiles].y = (jY * 32) - (panel.height * 0.5)
				self.tiles[#self.tiles].tileIndex = index	
				self.tiles[#self.tiles]:addEventListener("tap", placeTile)
				self.tiles[#self.tiles]:addEventListener("touch", placeTile)
				self.tiles[#self.tiles]:addEventListener("mouse", mouseTile)
				self:insert(self.tiles[#self.tiles])
			end
		end

		for i = 1, #overlay do
			overlay[i]:toFront()
		end

		highlightTile:toFront()
	end

	function panel:onKeyEvent(event)
		local keyName = event.keyName
		local phase = event.phase
		
		if (keyName:lower() == "a") then
			self.startX = self.startX - 1

			if (self.startX <= 1) then
				self.startX = 1
			end
		elseif (keyName:lower() == "d") then
			self.startX = self.startX + 1

			if (self.startX >= gridRows) then
				self.startX = gridRows
			end
		elseif (keyName:lower() == "w") then
			self.startY = self.startY - 1

			if (self.startY <= 1) then
				self.startY = 1
			end
		elseif (keyName:lower() == "s") then
			self.startY = self.startY + 1

			if (self.startY > gridColumns) then
				self.startY = gridColumns
			end
		end
	end

	return panel
end

return M
