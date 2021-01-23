local M = 
{
	selectedTileId = 0,
	selectedTool = nil,
	previousTool = nil,
	layers = {
		{
			name = "", -- the map layer name
			index = 1, -- the layer rendering index (1 = top)
			data = {}, -- the map layer data for this layer
		}
	},
	toolList = {
		brush = "brush",
		bucket = "bucket",
		eraser = "eraser",
		clearAll = "clearAll",
		rotateRight = "rotateRight",
		rotateLeft = "rotateLeft",
		flipHorizontal = "flipHorizontal",
		flipVertical = "flipVertical"
	},
	eventList = {
		toolChanged = "toolChanged",
	}
}

return M
