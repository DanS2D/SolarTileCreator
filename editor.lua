local M = 
{
	selectedTileId = 0,
	selectedTool = nil,
	previousTool = nil,
	selectedLayer = 1,
	gridRows = 100,
	gridColumns = 100,
	tileWidth = 32,
	tileHeight = 32,
	createdOrLoadedMap = false,
	reloadEditor = false,
	mapName = nil,
	mapPanel = nil,
	tilePanel = nil,
	layers = {
		{
			name = "Tile Layer", -- the map layer name
			index = 1, -- the layer rendering index (1 = top)
			data = {}, -- the map layer data for this layer
		}
	},
	toolList = {
		brush = "brush",
		bucket = "bucket",
		eraser = "eraser",
		clearAll = "clearAll",
		rotate = "rotate",
		flipHorizontal = "flipHorizontal",
		flipVertical = "flipVertical"
	},
	eventList = {
		toolChanged = "toolChanged",
	}
}

function M:init()
	self.layers = nil
	self.layers = {
		{
			name = "Tile Layer", -- the map layer name
			index = 1, -- the layer rendering index (1 = top)
			data = {}, -- the map layer data for this layer
		}
	}

	for i = 1, self.gridRows do
		self.layers[1].data[i] = {}
	
		for j = 1, self.gridColumns do
			self.layers[1].data[i][j] = 0
		end
	end
end

return M
