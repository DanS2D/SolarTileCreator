local theme = require("theme")
local buttonLib = require("button")
local titleFont = "fonts/Jost-500-Medium.ttf"
local subTitleFont = "fonts/Jost-400-Book.ttf"
local M = {}

function M:new(options)
	local title = options.title or error("floating-panel:new(options) title (string) expected, got", type(options.title))
	local width = options.width or (display.contentWidth / 3)
	local height = options.height or (display.contentHeight / 3)
	local useVerticalScrollbar = options.verticalScrollbar
	local buttons = options.buttons
	local onScrollUpClick = options.onScrollUpClick
	local onScrollDownClick = options.onScrollDownClick
	local panel = display.newGroup()
	local content = display.newContainer(width - 2, height - 2)
	local panelButtons = {}

	local menuBar = display.newRect(0, 0, width, 20)
	menuBar.y = -(height * 0.5) - 10
	menuBar.fill = theme:get().panelColor.primary
	panel:insert(menuBar)

	local background = display.newRect(0, 0, width, height)
	background.fill = options.backgroundColor or theme:get().backgroundColor.primary
	background.strokeWidth = 1
	background.stroke = theme:get().backgroundColor.outline
	background:addEventListener("tap", function() return true end)
	background:addEventListener("touch", function() return true end)
	panel:insert(background)

	local titleText = display.newText({
		text = title,
		font = titleFont,
		fontSize = 14,
		align = "left"
	})
	titleText.anchorX = 0 
	titleText.x = -(background.width * 0.5) + 4
	titleText.y = (menuBar.y - 1)
	titleText.fill = theme:get().textColor.primary
	panel:insert(titleText)

	if (type(buttons) == "table" and #buttons > 0) then
		for i = 1, #buttons do
			panelButtons[i] = buttonLib.new({
				iconName = buttons[i].icon,
				fontSize = 14,
				fillColor = theme:get().textColor.primary,
				onClick = function(event)
					local target = event.target
					target.action()
				end
			})
			panelButtons[i].x = (background.width * 0.5) + 5 - (i * 20)
			panelButtons[i].y = (menuBar.y - 1)
			panelButtons[i].id = i
			panelButtons[i].name = buttons[i].name
			panelButtons[i].action = buttons[i].action
			panel:insert(panelButtons[i])
		end
	end

	-- vertical scrollbar
	if (useVerticalScrollbar) then
		local scrollBackground = display.newRect(0, 0, 11, height)
		scrollBackground.anchorX = 1
		scrollBackground.anchorY = 0
		scrollBackground.x = ((panel.width * 0.5) - 2)
		scrollBackground.y = (menuBar.y + (menuBar.height * 0.5))
		scrollBackground.fill = {0.2, 0.2, 0.2}
		panel:insert(scrollBackground)

		local scrollUpButton = buttonLib.new({
			iconName = os.isLinux and "" or "arrow-up",
			fontSize = 12,
			fillColor = theme:get().textColor.primary,
			onClick = function(event)
				if (type(panel.onScrollUpClick) == "function") then
					panel:onScrollUpClick(event)
				end
			end
		})
		scrollUpButton.x = (panel.width * 0.5) - (scrollUpButton.width * 0.5)
		scrollUpButton.y = (menuBar.y + menuBar.height)
		scrollUpButton.fill = theme:get().iconColor.primary
		panel:insert(scrollUpButton)

		local scrollDownButton = buttonLib.new({
			iconName = os.isLinux and "" or "arrow-down",
			fontSize = 12,
			fillColor = theme:get().textColor.primary,
			onClick = function(event)
				if (type(panel.onScrollDownClick) == "function") then
					panel:onScrollDownClick(event)
				end
			end
		})
		scrollDownButton.anchorY = 1
		scrollDownButton.x = scrollUpButton.x
		scrollDownButton.y = ((panel.height * 0.5) - scrollDownButton.height) 
		scrollDownButton.fill = theme:get().iconColor.primary
		panel:insert(scrollDownButton)
	end

	panel.anchorChildren = false
	content.anchorChildren = false
	panel:insert(content)
	panel.oldInsert = panel.insert
	panel.content = content
	panel.x = display.contentCenterX
	panel.y = display.contentCenterY

	function panel:insert(...)
		content:insert(...)
	end

	function panel:onScrollUpClick(event)
	end

	function panel:onScrollDownClick(event)
	end

	return panel
end

return M
