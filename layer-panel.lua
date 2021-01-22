local floatingPanel = require("floating-panel")
local editor = require("editor")
local M = {}

function M:new()
	local panel = floatingPanel:new({
		width = (display.contentWidth * 0.4),
		height = (display.contentHeight * 0.24),
		title = "Layers",
	})
	panel.x = (display.contentWidth - (panel.width * 0.5))
	panel.y = ((panel.height * 0.5) + 85)

	local function tileTap(event)
		local target = event.target

		target.strokeWidth = 1
		target:setStrokeColor(1, 0, 0)
		target.stroke.effect = "generator.marchingAnts"

		return true
	end

	function panel:render()
	end

	function panel:onKeyEvent(event)
		local keyName = event.keyName
		local phase = event.phase
		
		if (keyName:lower() == "l") then
		elseif (keyName:lower() == "m") then
		end
	end

	return panel
end

return M
