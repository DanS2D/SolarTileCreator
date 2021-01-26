local floatingPanel = require("floating-panel")
local editor = require("editor")
local tfd = require("plugin.tinyFileDialogs")
local M = {}

function M:new()
	local tileSheetOptions =
	{
		width = 32,
		height = 32,
		numFrames = 8640,
		sheetContentWidth = 3456, -- width of original 1x size of entire sheet
		sheetContentHeight = 2560 -- height of original 1x size of entire sheet
	}

	local panel = floatingPanel:new({
		width = (display.contentWidth * 0.4) - 8,
		height = (display.contentHeight * 0.5) + 10,
		title = ("Tiles (%d Tiles)"):format(tileSheetOptions.numFrames),
		buttons = {
			{icon = os.isLinux and "" or "folder-open", 
				action = function()
					local foundFile = tfd.openFileDialog(
						{
							title = "Select Tilesheet",
							initialPath = os.homePath,
							filters = {"*.png", "*.jpg"},
							singleFilterDescription = "Image Files| *.png;*.jpg etc",
							multiSelect = false
						}
					)

					if (foundFile ~= nil) then
						-- if path is relative to the CWD, it will return
						-- say data/tiles/x.png, rather than /Users/X/Documents/...
						print("found file:", foundFile)
					end
				end
			},
		},
	})
	panel.x = (display.contentWidth - (panel.width * 0.5))
	panel.y = (display.contentHeight - (panel.height * 0.5) + 12)
	panel.tiles = {}
	panel.startX = 1
	panel.xCount = 7
	panel.startY = 1
	panel.yCount = 7
	panel.refresh = true
	panel.tileGroup = display.newGroup()

	local imageSheet = graphics.newImageSheet("data/tiles/tilesheet_complete_2X.png", tileSheetOptions)

	local function tileTap(event)
		local target = event.target
	
		for i = 1, #panel.tiles do
			panel.tiles[i].strokeWidth = 0
			panel.tiles[i].stroke.effect = nil
		end
	
		editor.selectedTileId = target.tileIndex
		target.strokeWidth = 1
		target:setStrokeColor(1, 0, 0)
		target.stroke.effect = "generator.marchingAnts"
		panel.refresh = true

		return true
	end

	function panel:render()
		for i = 1, #self.tiles do
			display.remove(self.tiles[i])
			self.tiles[i] = nil
		end
	
		display.remove(self.tileGroup)
		self.tileGroup = nil
		self.tileGroup = display.newGroup()
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
	
				local tileIndex = (i + (108 * j)) -- math: (x + (#mapRows * y))
	
				self.tiles[#self.tiles + 1] = display.newImageRect(imageSheet, tileIndex, 32, 32)
				self.tiles[#self.tiles].x = (iX * 34) - (panel.width * 0.5) - 12
				self.tiles[#self.tiles].y = (jY * 34) - (panel.height * 0.5)
				self.tiles[#self.tiles].tileIndex = tileIndex
	
				if (editor.selectedTileId == tileIndex) then
					self.tiles[#self.tiles].strokeWidth = 1
					self.tiles[#self.tiles]:setStrokeColor(1, 0, 0)
					self.tiles[#self.tiles].stroke.effect = "generator.marchingAnts"
				end
	
				self.tiles[#self.tiles]:addEventListener("tap", tileTap)
				self.tileGroup:insert(self.tiles[#self.tiles])
			end
		end
	
		panel:insert(self.tileGroup)
		display.getCurrentStage():insert(panel)
		panel.refresh = false
	end

	function panel:onKeyEvent(event)
		local keyName = event.keyName
		local phase = event.phase
		
		if (keyName:lower() == "left") then
			self.startX = self.startX - 1
			panel.refresh = true

			if (self.startX <= 1) then
				self.startX = 1
			end
		elseif (keyName:lower() == "right") then
			self.startX = self.startX + 1
			panel.refresh = true

			if (self.startX > 102) then
				self.startX = 102
			end
		elseif (keyName:lower() == "up") then
			self.startY = self.startY - 1
			panel.refresh = true

			if (self.startY <= 1) then
				self.startY = 1
			end
		elseif (keyName:lower() == "down") then
			self.startY = self.startY + 1
			panel.refresh = true

			if (self.startY > 73) then
				self.startY = 73
			end
		end
	end

	return panel
end

return M
