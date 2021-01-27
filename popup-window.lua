local theme = require("theme")
local buttonLib = require("button")
local titleFont = "fonts/Jost-500-Medium.ttf"
local subTitleFont = "fonts/Jost-400-Book.ttf"
local M = {}

function M:new(options)
	local window = display.newGroup()
	local title = options.title or error("floating-panel:new(options) title (string) expected, got", type(options.title))
	local width = options.width or (display.contentWidth - 40)
	local height = options.height or (display.contentHeight - 40)
	local content = display.newContainer(width - 2, height - 2)

	local background = display.newRect(0, 0, width, height)
	background.fill = options.backgroundColor or theme:get().backgroundColor.primary
	background.strokeWidth = 1
	background.stroke = theme:get().backgroundColor.outline
	background:addEventListener("tap", function() return true end)
	background:addEventListener("touch", function() return true end)
	window:insert(background)

	local menuBar = display.newRect(0, 0, width, 20)
	menuBar.y = -(height * 0.5) - 10
	menuBar.fill = theme:get().windowColor.primary
	window:insert(menuBar)

	local titleText = display.newText({
		text = title,
		font = titleFont,
		fontSize = 14,
		align = "left"
	})
	titleText.anchorX = 0 
	titleText.x = -(titleText.width * 0.5)
	titleText.y = (menuBar.y - 1)
	titleText.fill = theme:get().textColor.primary
	window:insert(titleText)

	local closeButton = buttonLib.new({
		iconName = os.isLinux and "" or "window-close",
		fontSize = 14,
		fillColor = theme:get().textColor.primary,
		onClick = function(event)
			window:close()
		end
	})
	closeButton.x = (background.width * 0.5) - (closeButton.width * 0.5) - 2
	closeButton.y = (menuBar.y - 1)
	window:insert(closeButton)

	function window:visible()
		return self.isVisible
	end

	function window:close()
		self.isVisible = false
	end

	function window:show()
		self.isVisible = true
	end

	window.anchorChildren = false
	content.anchorChildren = false
	window:insert(content)
	window.oldInsert = window.insert
	window.content = content
	window.x = display.contentCenterX
	window.y = (display.contentCenterY + 10)
	window.isVisible = false

	function window:insert(...)
		content:insert(...)
	end

	return window
end

return M
