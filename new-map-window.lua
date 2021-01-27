local popupWindow = require("popup-window")
local M = {}

function M:new()
	local window = popupWindow:new({
		title = "Create Map"
	})

	return window
end

return M
