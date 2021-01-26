local floatingPanel = require("floating-panel")
local desktopTableView = require("desktop-table-view")
local buttonLib = require("button")
local editor = require("editor")
local theme = require("theme")
local json = require("json") --tmp
local M = {}
local fontAwesomeSolidFont = "fonts/FA5-Solid.ttf"
local titleFont = "fonts/Jost-500-Medium.ttf"
local subTitleFont = "fonts/Jost-400-Book.ttf"

function M:new()
	local buttonWidth = 15
	local buttonFontSize = 12
	local recreateList = nil
	local tableView = nil

	local panel = floatingPanel:new({
		width = (display.contentWidth * 0.4) - 8,
		height = (display.contentHeight * 0.24) - 5,
		title = "Layers",
		verticalScrollbar = true,
		buttons = {
			{icon = os.isLinux and "" or "layer-plus", 
				action = function() 
						if (#editor.layers >= 10) then
							native.showAlert("Layer limit reached!", "There can 10 layers at a maximum", {"Ok"})
							return
						end

						editor.layers[#editor.layers + 1] = {
						name = "New Layer", -- the map layer name
						index = #editor.layers + 1, -- the layer rendering index (1 = top)
						data = {}, -- the map layer data for this layer
					}

					-- create the data structure for the tiles
					for i = 1, editor.gridRows do
						editor.layers[#editor.layers].data[i] = {}
					
						for j = 1, editor.gridColumns do
							editor.layers[#editor.layers].data[i][j] = 0
						end
					end

					recreateList()
					tableView.y = tableView.origY
				end
			},
		},
	})
	panel.x = (display.contentWidth - (panel.width * 0.5))
	panel.y = ((panel.height * 0.5) + 85)

	recreateList = function()
		tableView:deleteAllRows()
		tableView:createRows()
		tableView:setRowLimit(#editor.layers)
		tableView:setRowSelected(editor.selectedLayer)
	end

	local function sortLayers(a, b)
		return a.index < b.index
	end

	local function onRowTextInput(event)
		local phase = event.phase
		local target = event.target

		if (phase == "began") then
		elseif (phase == "ended" or phase == "submitted") then
			-- update layer text and recreate tableView
			editor.layers[editor.selectedLayer].name = target.text
			display.remove(target)
			target = nil
			recreateList()
		end
	end

	local function createRowTextField()
		local textField = native.newTextField(0, 0, panel.width * 0.55, 20)
		textField:addEventListener("userInput", onRowTextInput)

		return textField
	end

	tableView = desktopTableView.new({
		left = -(panel.width * 0.5) + 4,
		top = -(panel.height * 0.5) + 14,
		width = (panel.width - 20),
		height = panel.height,
		rowHeight = 34,
		rowLimit = 10,
		rowColorDefault = {
			default = theme:get().rowColor.primary, 
			over = theme:get().rowColor.over
		},
		useSelectedRowHighlighting = true,
		onRowRender = function(event)
			local phase = event.phase
			local row = event.row
			local rowContentWidth = row.contentWidth
			local rowContentHeight = row.contentHeight

			if (row.index > #editor.layers) then
				row.isVisible = false
			end

			local moveUpButton = buttonLib.new({
				y = (rowContentHeight * 0.5),
				iconName = os.isLinux and "" or "arrow-up",
				fontSize = buttonFontSize,
				fillColor = theme:get().textColor.primary,
				onClick = function(event)
					local target = event.target

					if (target.index <= 1) then
						return
					end

					if (target.index == editor.selectedLayer) then
						editor.selectedLayer = editor.selectedLayer - 1
					end

					editor.layers[target.index].index = editor.layers[target.index].index - 1
					editor.layers[target.index - 1].index = editor.layers[target.index - 1].index + 1
					table.sort(editor.layers, sortLayers)
					recreateList()
				end
			})
			moveUpButton.index = row.index
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

					if (target.index >= #editor.layers) then
						return
					end

					if (target.index == editor.selectedLayer) then
						editor.selectedLayer = editor.selectedLayer + 1
					end

					editor.layers[target.index].index = editor.layers[target.index].index + 1
					editor.layers[target.index + 1].index = editor.layers[target.index + 1].index - 1
					table.sort(editor.layers, sortLayers)
					recreateList()

					return true
				end
			})
			moveDownButton.index = row.index
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

					if (target.index <= 1) then
						return
					end

					for i = target.index, 1, -1 do
						editor.layers[i].index = editor.layers[i].index + 1
					end

					editor.selectedLayer = 1
					editor.layers[target.index].index = 1
					table.sort(editor.layers, sortLayers)
					recreateList()
				end
			})
			moveToTopButton.index = row.index
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

					if (target.index == #editor.layers) then
						return
					end

					for i = target.index, #editor.layers do
						editor.layers[i].index = editor.layers[i].index - 1
					end

					editor.selectedLayer = #editor.layers
					editor.layers[target.index].index = #editor.layers
					table.sort(editor.layers, sortLayers)
					recreateList()
				end
			})
			moveToBottomButton.index = row.index
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

					local function onDeleteLayer(event)
						if (event.action == "clicked") then
							local index = event.index

							if (index == 1) then
								table.remove(editor.layers, target.index)
								recreateList()
							end
						end

						return true
					end

					if (#editor.layers > 1) then
						native.showAlert("Delete Layer?", "Are you sure you want to delete this layer?\n\nWARNING: This action cannot be undone!", {"Yes", "No"}, onDeleteLayer)
					else
						native.showAlert("I can't let you do that!", "There has to be at least one layer on a map!", {"FINE"})
					end
				end
			})
			deleteButton.index = row.index
			deleteButton.x = moveToBottomButton.x + buttonWidth
			deleteButton.fill = theme:get().iconColor.primary
			row:insert(deleteButton)

			local subItemText = display.newText({
				x = 0,
				y = (rowContentHeight * 0.5),
				text = #editor.layers >= row.index and editor.layers[row.index].name or "",
				font = titleFont,
				fontSize = 14,
				align = "left"
			})
			subItemText.anchorX = 0
			subItemText.x = deleteButton.x + buttonWidth
			subItemText.fill = theme:get().textColor.primary
			row:insert(subItemText)
		end,
		onRowClick = function(event)
			local phase = event.phase
			local row = event.row
			local rowContentWidth = row.contentWidth
			local rowContentHeight = row.contentHeight
			local numClicks = event.numClicks

			if (row.index > #editor.layers) then
				return
			end

			if (numClicks == 1) then
				editor.selectedLayer = row.index
				tableView:setRowSelected(row.index)
			else
				local textField = createRowTextField()
				row:insert(textField)
				textField.x = row.x + (row.contentWidth * 0.65)
				textField.y = row.contentHeight * 0.5
				textField.text = editor.layers[row.index].name
			end

			return true
		end
	})
	tableView.origY = tableView.y
	tableView:createRows()
	tableView:setRowSelected(1)
	panel.content:insert(tableView)

	function panel:render()
	end

	function panel:onScrollUpClick(event)
		local rowHeight = tableView.rowHeight
		local limit = (tableView.origY - rowHeight)

		if (tableView.y > limit) then
			return
		end

		tableView.y = (tableView.y + rowHeight)
	end

	function panel:onScrollDownClick(event)
		local rowHeight = tableView.rowHeight
		local limit = (tableView.origY - (rowHeight * #editor.layers) + (rowHeight * 3))

		if (tableView.y <= limit) then
			return
		end

		tableView.y = (tableView.y - rowHeight)
	end

	return panel
end

return M
