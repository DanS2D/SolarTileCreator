local M = 
{
	selectedTileId = 0,
	selectedTool = nil,
	previousTool = nil,
	selectedLayer = 1,
	gridRows = 100,
	gridColumns = 100,
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

for i = 1, M.gridRows do
	M.layers[1].data[i] = {}

	for j = 1, M.gridColumns do
		M.layers[1].data[i][j] = 0
	end
end

return M
