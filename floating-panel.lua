
local M = {}
local theme = require("theme")
local buttonLib = require("button")
local titleFont = "fonts/Jost-500-Medium.ttf"
local subTitleFont = "fonts/Jost-400-Book.ttf"

function M:new(options)
	local title = options.title or error("floating-panel:new(options) title (string) expected, got", type(options.title))
	local panel = display.newGroup()
	local content = display.newGroup()
	local width = options.width or (display.contentWidth / 3)
	local height = options.height or (display.contentHeight / 3)

	local menuBar = display.newRect(0, 0, width, 20)
	menuBar.y = -(height * 0.5) - 10
	menuBar.fill = theme:get().backgroundColor.secondary
	panel:insert(menuBar)

	local background = display.newRect(0, 0, width, height)
	background.fill = options.backgroundColor or theme:get().backgroundColor.primary
	background:addEventListener("tap", function() return true end)
	background:addEventListener("touch", function() return true end)
	content:insert(background)

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

	local closeButton = buttonLib.new({
		iconName = os.isLinux and "" or "window-close",
		fontSize = 14,
		fillColor = theme:get().textColor.primary,
		onClick = function(event)
			panel:open(false)
		end
	})
	closeButton.x = (background.width * 0.5) - 10
	closeButton.y = (menuBar.y - 1)
	panel:insert(closeButton)

	local minimizeButton = buttonLib.new({
		iconName = os.isLinux and "" or "window-minimize",
		fontSize = 14,
		fillColor = theme:get().textColor.primary,
		onClick = function(event)
			panel.minimized = not panel.minimized
			panel:minimize(panel.minimized)
		end
	})
	minimizeButton.x = (closeButton.x - (closeButton.width * 0.5) - 10)
	minimizeButton.y = closeButton.y
	panel:insert(minimizeButton)

	function panel:open(isOpen)
		self.isVisible = isOpen
		self.closed = (not self.isVisible)
	end

	function panel:minimize(isMinimized)
		local outTime = 150

		if (self.closed) then
			self.minimized = false
			return
		end

		self.minimized = isMinimized

		if (self.minimized) then
			content.isVisible = false

			if (panel.oldY == nil) then
				panel.oldY = panel.y
			end

			panel.y = (display.contentHeight + (panel.contentHeight / 2) - (menuBar.contentHeight / 2))
		else
			content.isVisible = true
			panel.y = panel.oldY
		end
	end

	content.allowMinimize = true
	content.anchorChildren = true
	panel:insert(content)
	panel.oldInsert = panel.insert
	panel.closed = false
	panel.minimized = false
	panel.content = content
	panel.x = display.contentCenterX
	panel.y = display.contentCenterY

	function panel:insert(...)
		content:insert(...)
	end

	return panel
end

return M
