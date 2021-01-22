local M = 
{
	selectedTileId = 0,
	selectedTool = nil,
	toolList = {
		undo = "undo",
		redo = "redo",
		brush = "brush",
		bucket = "bucket",
		eraser = "eraser",
		clearAll = "clearAll",
		rotateRight = "rotateRight",
		rotateLeft = "rotateLeft",
		flipHorizontal = "flipHorizontal",
		flipVertical = "flipVertical"
	},
}

return M
