local floatingPanel = require("floating-panel")
local buttonLib = require("button")
local theme = require("theme")
local editor = require("editor")
local M = {}

function M:new()
	local panel = floatingPanel:new({
		width = (display.contentWidth * 0.4),
		height = 30,
		title = "Tools",
	})
	panel.x = (display.contentWidth - (panel.width * 0.5))
	panel.y = ((panel.height * 0.5) + 35)

	local buttons = {}
	local previousTileId = 0

	local tools = {
		{name = "Eraser", icon = os.isLinux and "" or "eraser", action = function() 
			editor.selectedTileId = 0
			editor.selectedTool = "eraser"
		end},
		{name = "Clear", icon = os.isLinux and "" or "trash", action = function() 
			editor.selectedTileId = previousTileId
			editor.selectedTool = "clear"
		end},
		{name = "Bucket", icon = os.isLinux and "" or "fill", action = function() 
			editor.selectedTileId = previousTileId
			editor.selectedTool = "bucket"
		end},
	}

	for i = 1, #tools do
		buttons[i] = buttonLib.new({
			iconName = tools[i].icon,
			fontSize = 14,
			fillColor = theme:get().textColor.primary,
			onClick = function(event)
				local target = event.target
				target.on = not target.on

				for j = 1, #buttons do
					if (j ~= target.id) then
						buttons[j].fill = theme:get().iconColor.primary
						buttons[j].on = false
					end
				end

				if (editor.selectedTileId > 0) then
					previousTileId = editor.selectedTileId
				end

				if (target.on) then
					editor.selectedTool = nil
					target.fill = {0, 1, 1}
					tools[i].action()
				else
					editor.selectedTool = nil
					editor.selectedTileId = previousTileId
					target.fill = theme:get().iconColor.primary
				end
			end
		})
		buttons[i].x = (i * 20) - (panel.width * 0.5)
		buttons[i].y = 0
		buttons[i].id = i
		buttons[i].on = false
		panel:insert(buttons[i])
	end

	function panel:render()
	end

	function panel:onKeyEvent(event)
		local keyName = event.keyName
		local phase = event.phase
		
		if (keyName:lower() == "p") then
		elseif (keyName:lower() == "o") then
		end
	end

	return panel
end

return M
