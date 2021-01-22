local M = 
{
	selectedTileId = 0,
	selectedTool = nil,
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
