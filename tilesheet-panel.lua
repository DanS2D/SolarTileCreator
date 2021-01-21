local floatingPanel = require("floating-panel")
local editor = require("editor")

local M = {}

function M:new()
	local panel = floatingPanel:new({
		width = (display.contentWidth * 0.4),
		height = (display.contentHeight * 0.5) + 10,
		title = "Tiles",
	})
	panel.x = (display.contentWidth - (panel.width * 0.5))
	panel.y = (display.contentHeight - (panel.height * 0.5) + 12)
	panel.tiles = {}
	panel.tileGroup = display.newGroup()

	local tileSheetOptions =
	{
		width = 32,
		height = 32,
		numFrames = 8640,
		sheetContentWidth = 3456, -- width of original 1x size of entire sheet
		sheetContentHeight = 2560 -- height of original 1x size of entire sheet
	}

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

		return true
	end

	function panel:render(parentGroup, startX, xCount, startY, yCount)
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
	
		for i = startX, startX + (xCount - 1) do
			iX = iX + 1
		
			if (iX > xCount) then
				iX = 1
			end
	
			for j = startY, startY + (yCount - 1) do
				jY = jY + 1
	
				if (jY > yCount) then
					jY = 1
				end
	
				local tileIndex = (i + (108 * j)) -- math: (x + (#mapRows * y))
	
				self.tiles[#self.tiles + 1] = display.newImageRect(imageSheet, tileIndex, 32, 32)
				self.tiles[#self.tiles].x = (iX * 34) - (panel.width * 0.5) - 8
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
	end

	return panel
end

return M
