local floatingPanel = require("floating-panel")
local buttonLib = require("button")
local theme = require("theme")
local editor = require("editor")
local M = {}

function M:new()
	local panel = floatingPanel:new({
		width = (display.contentWidth * 0.4) - 8,
		height = 27,
		title = "Tools",
	})
	panel.x = (display.contentWidth - (panel.width * 0.5))
	panel.y = ((panel.height * 0.5) + 36)

	local buttons = {}
	local previousTileId = 0
	local toolList = editor.toolList
	local eventList = editor.eventList
	local tools = {
		{name = toolList.brush, icon = os.isLinux and "" or "paint-brush-alt",
			action = function()
				editor.selectedTool = toolList.brush

				if (editor.selectedTileId == 0) then
					editor.selectedTileId = previousTileId
				end
			end
		},
		{name = toolList.bucket, icon = os.isLinux and "" or "fill-drip",
			action = function()
				editor.selectedTileId = previousTileId
				editor.selectedTool = toolList.bucket
			end
		},
		{name = toolList.eraser, icon = os.isLinux and "" or "eraser",
			action = function()
				previousTileId = editor.selectedTileId
				editor.selectedTileId = 0
				editor.selectedTool = toolList.eraser
			end
		},
		{name = toolList.clearAll, icon = os.isLinux and "" or "trash"},
		{name = toolList.rotate, icon = os.isLinux and "" or "sync-alt"},
		{name = toolList.flipHorizontal, icon = os.isLinux and "" or "arrows-h"},
		{name = toolList.flipVertical, icon = os.isLinux and "" or "arrows-v"},
	}

	local function resetButtons(target)
		for j = 1, #buttons do
			if (j ~= target.id) then
				buttons[j].fill = theme:get().iconColor.primary
			end
		end
	end

	for i = 1, #tools do
		buttons[i] = buttonLib.new({
			iconName = tools[i].icon,
			fontSize = 14,
			fillColor = theme:get().textColor.primary,
			onClick = function(event)
				local target = event.target
				editor.selectedTool = target.name

				local toolEvent = {
					name = eventList.toolChanged,
					tool = target.name
				}
				Runtime:dispatchEvent(toolEvent)

				if (not target.action) then
					return
				end

				resetButtons(target)

				if (editor.selectedTileId > 0) then
					previousTileId = editor.selectedTileId
				end

				target.fill = {0, 1, 1}
				target.action()
			end
		})
		buttons[i].x = (i * 20) - (panel.width * 0.5) - 6
		buttons[i].y = 0
		buttons[i].id = i
		buttons[i].name = tools[i].name
		buttons[i].action = tools[i].action
		panel:insert(buttons[i])
	end

	local function getButton(name)
		for i = 1, #buttons do
			if (buttons[i].name == name) then
				return buttons[i]
			end
		end

		return nil
	end

	function panel:render()
	end

	function panel:onKeyEvent(event)
		local keyName = event.keyName
		local phase = event.phase
		local isCtrlDown = event.isCtrlDown
		
		if (isCtrlDown) then
			if (phase == "up") then
				local selectedButton = nil
				local newTool = nil

				if (keyName:lower() == "b") then
					newTool = toolList.brush
				elseif (keyName:lower() == "f") then
					newTool = toolList.bucket
				elseif (keyName:lower() == "e") then
					newTool = toolList.eraser
				elseif (keyName:lower() == "r") then
					local toolEvent = {
						name = eventList.toolChanged,
						tool = toolList.rotate
					}
					Runtime:dispatchEvent(toolEvent)
				end

				if (newTool ~= nil) then
					local selectedButton = getButton(newTool)

					if (selectedButton ~= nil) then
						resetButtons(selectedButton)

						if (editor.selectedTileId > 0) then
							previousTileId = editor.selectedTileId
						end

						editor.selectedTool = nil
						selectedButton.fill = {0, 1, 1}
						selectedButton.action()
					end
				end
			end
		end
	end

	return panel
end

return M
