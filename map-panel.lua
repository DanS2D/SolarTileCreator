local bit = require("plugin.bit")
local floatingPanel = require("floating-panel")
local editor = require("editor")
local M = {}
local mFloor = math.floor
local bAnd = bit.band
local bOr = bit.bor
local bRShift = bit.rshift
local tileMask = 0xFFFFF
local rotate90Flag, rotate90Value = 0x8000000, 0x8
local rotate180Flag, rotate180Value = 0xC000000, 0xC
local rotate270Flag, rotate270Value = 0xE000000, 0xE
local flipHorizontalFlag, flipHorizontalValue = 0x1000000, 0x2
local flipVerticalFlag, flipVerticalValue = 0x800000, 0x1

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
		title = ("Map (%dx%d - %d Tiles)"):format(gridRows, gridColumns, gridRows * gridColumns),
		buttons = {
			{icon = os.isLinux and "" or "search", action = function()
				
			end},
			{icon = os.isLinux and "" or "search-minus", action = function()
				
			end},
		},
	})
	panel.x = (panel.width * 0.5)
	panel.y = (panel.height * 0.5) + 36
	panel.startX = 1
	panel.xCount = mFloor((panel.width / editor.tileWidth) - 1)
	panel.startY = 1
	panel.yCount = mFloor((panel.height / editor.tileHeight) - 1)
	panel.refresh = true

	local toolList = editor.toolList
	local eventList = editor.eventList
	local groups = {}
	local overlay = {}
	local tileSheetOptions =
	{
		width = editor.tileWidth,
		height = editor.tileHeight,
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
	
	panel.highlightTile = display.newSprite(imageSheet, sequenceData)
	panel.highlightTile.strokeWidth = 1
	panel.highlightTile:setStrokeColor(1, 0, 0)
	panel.highlightTile.stroke.effect = "generator.marchingAnts"
	panel.highlightTile.isVisible = false
	panel:insert(panel.highlightTile)

	function panel.highlightTile:handleRotationAndFlipping()
		editor.selectedTileId = bAnd(tileMask, editor.selectedTileId)

		-- rotation
		if (panel.highlightTile.rotation == 90) then
			editor.selectedTileId = bOr(rotate90Flag, editor.selectedTileId)
		elseif (panel.highlightTile.rotation == 180) then
			editor.selectedTileId = bOr(rotate180Flag, editor.selectedTileId)
		elseif (panel.highlightTile.rotation == 270) then
			editor.selectedTileId = bOr(rotate270Flag, editor.selectedTileId)
		end

		-- flipping
		if (panel.highlightTile.xScale == -1) then
			editor.selectedTileId = bOr(flipHorizontalFlag, editor.selectedTileId)
		end

		if (panel.highlightTile.yScale == -1) then
			editor.selectedTileId = bOr(flipVerticalFlag, editor.selectedTileId)
		end
	end

	-- create overlay grid
	for i = 1, panel.xCount do
		for j = 1, panel.yCount do
			overlay[#overlay + 1] = display.newRect(0, 0, 31, 31)
			overlay[#overlay].strokeWidth = 1
			overlay[#overlay]:setFillColor(0, 0, 0, 0.01)
			overlay[#overlay]:setStrokeColor(1, 1, 1, 0.5)
			overlay[#overlay].x = (i * editor.tileWidth) - (panel.width * 0.5)
			overlay[#overlay].y = (j * editor.tileHeight) - (panel.height * 0.5) + 3
			panel:insert(overlay[#overlay])
		end
	end

	-- create the display groups
	for i = 1, 10 do
		groups[i] = display.newGroup()
	end

	-- insert the groups into the panel in reverse order (to line up with layer ordering)
	for i = #groups, 1, -1 do
		panel:insert(groups[i])
	end

	local function onEditorEvent(event)
		local name = event.name

		-- tool changed events
		if (name == eventList.toolChanged) then
			local tool = event.tool
			local newTool = tool
			
			if (tool == toolList.brush) then
			elseif (tool == toolList.bucket) then
			elseif (tool == toolList.eraser) then
			elseif (tool == toolList.clearAll) then
				newTool = editor.previousTool
				editor.selectedTool = newTool

				local function onClearLayer(event)
					if (event.action == "clicked") then
						local index = event.index
						
						if (index == 1) then
							for i = 1, gridRows do
								for j = 1, gridColumns do
									editor.layers[editor.selectedLayer].data[i][j] = 0
								end
							end
						end
					end
				end
				  
				native.showAlert("Clear Layer?", "Are you sure you want to clear all tiles on this layer?", {"Yes", "No"}, onClearLayer)
			elseif (tool == toolList.rotate) then
				newTool = editor.previousTool
				editor.selectedTool = newTool
				panel.highlightTile.rotation = ((panel.highlightTile.rotation + 90) % 360)
			elseif (tool == toolList.flipHorizontal) then
				newTool = editor.previousTool
				editor.selectedTool = newTool

				if (panel.highlightTile.rotation == 0 or panel.highlightTile.rotation == 180) then
					panel.highlightTile.rotation = panel.highlightTile.rotation + 180
				end
			elseif (tool == toolList.flipVertical) then
				newTool = editor.previousTool
				editor.selectedTool = newTool
				panel.highlightTile.yScale = (panel.highlightTile.yScale > 0) and -1 or 1
			end

			editor.previousTool = newTool
		end

		return true
	end

	local function flood4(x, y, startTileId)
		if x < 1 or y < 1 then return end
		if x > gridRows or y > gridColumns then return end
		if not editor.layers[editor.selectedLayer].data[x][y] then return end

		local currentTileId = editor.layers[editor.selectedLayer].data[x][y]
		
		if (currentTileId and (currentTileId == startTileId)) then
			editor.layers[editor.selectedLayer].data[x][y] = editor.selectedTileId
			flood4(x + 1, y, startTileId)
			flood4(x - 1, y, startTileId)
			flood4(x, y + 1, startTileId)
			flood4(x, y - 1, startTileId)
		end
	end

	local function placeTileTouch(event)
		local target = event.target
		local phase = event.phase
		local tileIndex = target.tileIndex

		if (phase == "began" or phase == "moved") then
			panel.highlightTile:handleRotationAndFlipping()

			-- normal 'paint' mode (nil) or eraser
			if (editor.selectedTool == toolList.brush or editor.selectedTool == toolList.eraser) then
				editor.layers[editor.selectedLayer].data[tileIndex.x][tileIndex.y] = editor.selectedTileId
			end

			panel.refresh = true
		end

		return true
	end

	local function placeTileTap(event)
		local target = event.target
		local tileIndex = target.tileIndex

		-- paint bucket
		if (editor.selectedTool == toolList.bucket) then
			if (editor.layers[editor.selectedLayer].data[tileIndex.x][tileIndex.y] ~= editor.selectedTileId) then
				panel.highlightTile:handleRotationAndFlipping()
				flood4(tileIndex.x, tileIndex.y, editor.layers[editor.selectedLayer].data[tileIndex.x][tileIndex.y])
			end
		end

		panel.refresh = true

		return true
	end

	local function mouseTile(event)
		local target = event.target
		local phase = event.type
		panel.highlightTile.isVisible = true

		if (editor.selectedTool == nil) then
			panel.highlightTile.isVisible = false
		elseif (editor.selectedTool == toolList.brush) or
		 	(editor.selectedTool == toolList.bucket) then
			if (editor.selectedTileId > 0) then
				panel.highlightTile:setFrame(bAnd(tileMask, editor.selectedTileId))
				panel.highlightTile.fill.effect = nil
			else
				panel.highlightTile.isVisible = false
			end
		elseif (editor.selectedTool == toolList.eraser) then
			panel.highlightTile.fill.effect = "generator.linearGradient"
			panel.highlightTile.fill.effect.color1 = {0.8, 0, 0.2, 0.4}
			panel.highlightTile.fill.effect.position1 = {0, 0}
			panel.highlightTile.fill.effect.color2 = {0.2, 0.2, 0.2, 0.4}
			panel.highlightTile.fill.effect.position2 = {1, 1}
		end

		if (panel.highlightTile.isVisible) then
			panel.highlightTile.x = target.x
			panel.highlightTile.y = target.y
		end
	
		return true
	end

	function panel:render()
		for i = 1, #groups do
			for j = groups[i].numChildren, 1, -1 do
				display.remove(groups[i][j])
			end			
		end

		for layerNo = #editor.layers, 1, -1 do
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
					local tileData = editor.layers[layerNo].data[i][j]
					local tileIndex = bAnd(tileMask, tileData)
					local currentTile = nil

					if (tileIndex > 0) then
						currentTile = display.newImageRect(imageSheet, tileIndex, editor.tileWidth, editor.tileHeight)
					else
						currentTile = display.newRect(0, 0, editor.tileWidth, editor.tileHeight)
						currentTile:setFillColor(0.25, 0.25, 0.25, 0.01)
					end

					-- handle tile rotation
					if (bRShift(tileData, 24) == rotate90Value) then
						currentTile.rotation = 90
					elseif (bRShift(tileData, 24) == rotate180Value) then
						currentTile.rotation = 180
					elseif (bRShift(tileData, 24) == rotate270Value) then
						currentTile.rotation = 270
					-- handle tile flipping
					elseif (bRShift(tileData, 23) == flipHorizontalValue) then
						currentTile.xScale = -1
					elseif (bRShift(tileData, 23) == flipVerticalValue) then
						--currentTile.rotation = -currentTile.rotation
						currentTile.yScale = -1
						print("LOL")
					end
						
					currentTile.x = (iX * editor.tileWidth) - (panel.width * 0.5)
					currentTile.y = (jY * editor.tileHeight) - (panel.height * 0.5) + 3
					currentTile.tileIndex = {x = i, y = j}	
					currentTile:addEventListener("tap", placeTileTap)
					currentTile:addEventListener("touch", placeTileTouch)
					currentTile:addEventListener("mouse", mouseTile)
					groups[layerNo]:insert(currentTile)
				end
			end
		end

		for i = 1, #overlay do
			overlay[i]:toFront()
		end

		panel.highlightTile:toFront()
		self.refresh = false
	end

	function panel:onKeyEvent(event)
		local keyName = event.keyName
		local phase = event.phase
		
		if (keyName:lower() == "a") then
			self.startX = self.startX - 1
			panel.refresh = true

			if (self.startX <= 1) then
				self.startX = 1
			end
		elseif (keyName:lower() == "d") then
			self.startX = self.startX + 1
			panel.refresh = true

			if (self.startX >= gridRows) then
				self.startX = gridRows
			end
		elseif (keyName:lower() == "w") then
			self.startY = self.startY - 1
			panel.refresh = true

			if (self.startY <= 1) then
				self.startY = 1
			end
		elseif (keyName:lower() == "s") then
			self.startY = self.startY + 1
			panel.refresh = true

			if (self.startY > gridColumns) then
				self.startY = gridColumns
			end
		end
	end

	Runtime:addEventListener(eventList.toolChanged, onEditorEvent)

	return panel
end

return M
