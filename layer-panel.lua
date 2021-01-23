local floatingPanel = require("floating-panel")
local desktopTableView = require("desktop-table-view")
local buttonLib = require("button")
local editor = require("editor")
local theme = require("theme")
local M = {}
local fontAwesomeSolidFont = "fonts/FA5-Solid.ttf"
local titleFont = "fonts/Jost-500-Medium.ttf"
local subTitleFont = "fonts/Jost-400-Book.ttf"

function M:new()
	local buttonWidth = 15
	local buttonFontSize = 12

	local panel = floatingPanel:new({
		width = (display.contentWidth * 0.4) - 8,
		height = (display.contentHeight * 0.24) - 5,
		title = "Layers",
		buttons = {
			{icon = os.isLinux and "" or "layer-plus", 
				action = function() 
				
				end
			},
		},
	})
	panel.x = (display.contentWidth - (panel.width * 0.5))
	panel.y = ((panel.height * 0.5) + 85)

	local tableView = desktopTableView.new({
		left = -(panel.width * 0.5) + 4,
		top = -(panel.height * 0.5) + 14,
		width = panel.width - 20,
		height = panel.height,
		rowHeight = 34,
		rowLimit = 0,
		rowColorDefault = {
			default = theme:get().rowColor.primary, 
			over = theme:get().rowColor.over
		},
		useSelectedRowHighlighting = false,
		onRowRender = function(event)
			local phase = event.phase
			local row = event.row
			local rowContentWidth = row.contentWidth
			local rowContentHeight = row.contentHeight
			--local params = tableViewParams[row.index]

			local moveUpButton = buttonLib.new({
				y = (rowContentHeight * 0.5),
				iconName = os.isLinux and "" or "arrow-up",
				fontSize = buttonFontSize,
				fillColor = theme:get().textColor.primary,
				onClick = function(event)
					local target = event.target
				end
			})
			moveUpButton.x = 8
			moveUpButton.fill = theme:get().iconColor.primary
			row:insert(moveUpButton)

			local moveDownButton = buttonLib.new({
				y = (rowContentHeight * 0.5),
				iconName = os.isLinux and "" or "arrow-down",
				fontSize = buttonFontSize,
				fillColor = theme:get().textColor.primary,
				onClick = function(event)
					local target = event.target
				end
			})
			moveDownButton.x = moveUpButton.x + buttonWidth
			moveDownButton.fill = theme:get().iconColor.primary
			row:insert(moveDownButton)

			local moveToTopButton = buttonLib.new({
				y = (rowContentHeight * 0.5),
				iconName = os.isLinux and "" or "arrow-to-top",
				fontSize = buttonFontSize,
				fillColor = theme:get().textColor.primary,
				onClick = function(event)
					local target = event.target
				end
			})
			moveToTopButton.x = moveDownButton.x + buttonWidth
			moveToTopButton.fill = theme:get().iconColor.primary
			row:insert(moveToTopButton)

			local moveToBottomButton = buttonLib.new({
				y = (rowContentHeight * 0.5),
				iconName = os.isLinux and "" or "arrow-to-bottom",
				fontSize = buttonFontSize,
				fillColor = theme:get().textColor.primary,
				onClick = function(event)
					local target = event.target
				end
			})
			moveToBottomButton.x = moveToTopButton.x + buttonWidth
			moveToBottomButton.fill = theme:get().iconColor.primary
			row:insert(moveToBottomButton)

			local deleteButton = buttonLib.new({
				y = (rowContentHeight * 0.5),
				iconName = os.isLinux and "" or "trash",
				fontSize = buttonFontSize,
				fillColor = theme:get().textColor.primary,
				onClick = function(event)
					local target = event.target
				end
			})
			deleteButton.x = moveToBottomButton.x + buttonWidth
			deleteButton.fill = theme:get().iconColor.primary
			deleteButton.isVisible = (row.index > 1)
			row:insert(deleteButton)

			local subItemText =
				display.newText(
				{
					x = 0,
					y = (rowContentHeight * 0.5),
					text = "Layer " .. row.index,
					font = titleFont,
					fontSize = 14,
					align = "left"
				}
			)
			subItemText.anchorX = 0
			subItemText.x = deleteButton.x + buttonWidth
			subItemText.fill = theme:get().textColor.primary
			row:insert(subItemText)
		end,
		onRowClick = function(event)
			local phase = event.phase
			local row = event.row
			--local params = tableViewParams[row.index]

			return true
		end
	})

	tableView:setMaxRows(1)
	tableView:createRows()
	panel.content:insert(tableView)

	-- START LAYER DATA STRUCTURE TEST--

	--[[
		data layout
		{
			name = "one", -- the map layer name (shown in layer panel for this layer)
			index = 1, -- the layer rendering index (1 = top) - matches the order of the layer in the layers panel
			data = {}, -- the map layer data for this layer
		}
	--]]

	local test = {
		{
			name = "one",
			index = 1,
			data = {},
		},
		{
			name = "Three",
			index = 3,
			data = {},
		},
		{
			name = "five",
			index = 5,
			data = {},
		},
		{
			name = "Four",
			index = 4,
			data = {},
		},
		{
			name = "two",
			index = 2,
			data = {},
		},
	}

	local function sort(a, b)
		return a.index < b.index
	end

	local json = require("json")

	print("------ OLD -------")
	print(json.prettify(test))
	print("------ NEW -------")
	local startSec = os.time(os.date("*t"))
	table.sort(test, sort)
	local endSec = os.time(os.date("*t"))
	print(json.prettify(test))
	print(startSec, endSec)
	print("sort time:", endSec - startSec)
	-- sorting seems really fast. Looks like this system will work nicely.
	-- END LAYER DATA STRUCTURE TEST--

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
