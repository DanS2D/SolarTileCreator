local popupWindow = require("popup-window")
local buttonLib = require("button")
local theme = require("theme")
local M = {}
local titleFont = "fonts/Jost-500-Medium.ttf"
local subTitleFont = "fonts/Jost-400-Book.ttf"

function M:new()
	local window = popupWindow:new({
		title = "Create Map"
	})

	local textfieldWidth = 150
	local textFields = {}
	local map = {
		name = nil,
		width = 10,
		height = 10,
		tileWidth = 32,
		tileHeight = 32
	}

	local function newTextField(options)
		local field = display.newGroup()
		local fontSize = options.fontSize or 12

		local fieldPrefix = display.newText({
			text = options.prefix or error("no prefix supplied"),
			font = titleFont,
			fontSize = fontSize,
		})
		field:insert(fieldPrefix)
	
		local textField = native.newTextField(0, 0, 150, 18)
		textField.text = options.fieldText or nil
		textField.anchorX = 0
		textField.x = (fieldPrefix.x + (fieldPrefix.width * 0.5) + 2)
		textField.y = fieldPrefix.y
		textField.size = (fontSize + 1)
		textField.inputType = options.inputType or "number"
		textFields[#textFields + 1] = textField
		field:insert(textField)

		if (type(options.onUserInput) == "function") then
			textField:addEventListener("userInput", options.onUserInput)
		end

		field.anchorChildren = true

		return field
	end

	local mapNameField = newTextField({
		prefix = "Map Name:",
		inputType = "default",
		onUserInput = function(event)
			local phase = event.phase
			local text = event.target.text
			
			if (phase == "ended" or phase == "submitted") then
				map.name = text
			end
		end,
	})
	mapNameField.y = -(window.content.height * 0.5) + mapNameField.height
	window:insert(mapNameField)

	local mapWidthField = newTextField({
		prefix = "Map Width:",
		fieldText = ("%d tiles"):format(map.width),
		onUserInput = function(event)
			local phase = event.phase
			local text = event.target.text

			if (phase == "began") then
				if (text:len() > 6) then
					event.target.text = text:sub(1, -7)
				end
			elseif (phase == "ended" or phase == "submitted") then
				map.width = tonumber(text)

				if (map.width ~= nil) then
					event.target.text = ("%d tiles"):format(map.width)
				end
			end
		end,
	})
	mapWidthField.y = mapNameField.y + mapWidthField.height + 5
	window:insert(mapWidthField)

	local mapHeightField = newTextField({
		prefix = "Map Height:",
		fieldText = ("%d tiles"):format(map.height),
		onUserInput = function(event)
			local phase = event.phase
			local text = event.target.text

			if (phase == "began") then
				if (text:len() > 6) then
					event.target.text = text:sub(1, -7)
				end
			elseif (phase == "ended" or phase == "submitted") then
				map.height = tonumber(text)

				if (map.height ~= nil) then
					event.target.text = ("%d tiles"):format(map.height)
				end
			end
		end,
	})
	mapHeightField.y = mapWidthField.y + mapHeightField.height + 5
	window:insert(mapHeightField)

	local tileWidthField = newTextField({
		prefix = "Tile Width:",
		fieldText = ("%d px"):format(map.tileWidth),
		onUserInput = function(event)
			local phase = event.phase
			local text = event.target.text

			if (phase == "began") then
				if (text:len() > 3) then
					event.target.text = text:sub(1, -4)
				end
			elseif (phase == "ended" or phase == "submitted") then
				map.tileWidth = tonumber(text)

				if (map.tileWidth ~= nil) then
					event.target.text = ("%d px"):format(map.tileWidth)
				end
			end
		end,
	})
	tileWidthField.y = mapHeightField.y + tileWidthField.height + 5
	window:insert(tileWidthField)

	local tileHeightField = newTextField({
		prefix = "Tile Height:",
		fieldText = ("%d px"):format(map.tileHeight),
		onUserInput = function(event)
			local phase = event.phase
			local text = event.target.text

			if (phase == "began") then
				if (text:len() > 3) then
					event.target.text = text:sub(1, -4)
				end
			elseif (phase == "ended" or phase == "submitted") then
				map.tileHeight = tonumber(text)

				if (map.tileHeight ~= nil) then
					event.target.text = ("%d px"):format(map.tileHeight)
				end
			end
		end,
	})
	tileHeightField.y = tileWidthField.y + tileHeightField.height + 5
	window:insert(tileHeightField)

	local createMapButton = buttonLib.new({
		iconName = "Create Map",
		font = titleFont,
		fontSize = fontSize,
		fillColor = theme:get().textColor.primary,
		onClick = function(event)
			window:close()
		end
	})
	createMapButton.y = (window.content.height * 0.5) - createMapButton.height
	window:insert(createMapButton)

	function window:close()
		for i = 1, #textFields do
			textFields[i].isVisible = false
		end

		self.isVisible = false
	end

	function window:show()
		for i = 1, #textFields do
			textFields[i].isVisible = true
		end

		self.isVisible = true
	end

	return window
end

return M
