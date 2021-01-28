
local luaExt = require("lua-ext")
local mainMenuBar = require("main-menu-bar")
local editor = require("editor")
local toolPanelWidget = require("tool-panel")
local layerPanelWidget = require("layer-panel")
local tilesheetPanelWidget = require("tilesheet-panel")
local mapPanelWidget = require("map-panel")
local newMapWindowWidget = require("new-map-window")
local titleFont = "fonts/Jost-500-Medium.ttf"
local subTitleFont = "fonts/Jost-400-Book.ttf"
local fontAwesomeBrandsFont = "fonts/FA5-Brands-Regular.ttf"
local eventList = editor.eventList
local toolList = editor.toolList
local applicationMainMenuBar = nil
local toolPanel = nil
local layerPanel = nil
local welcomeText = nil
local newMapWindow = nil

math.randomseed(os.time())

-- create the main menu bar
applicationMainMenuBar =
	mainMenuBar:new(
	{
		font = titleFont,
		items = {
			{
				title = "File",
				subItems = {
					{
						title = "New Map",
						iconName = os.isLinux and "" or "map",
						onClick = function()
							welcomeText.isVisible = false
							newMapWindow:show()
						end
					},
					{
						title = "Load Map",
						iconName = os.isLinux and "" or "folder-open",
						onClick = function()
						end
					},
					{
						title = "Save Map",
						iconName = os.isLinux and "" or "save",
						onClick = function()
						end
					},
					{
						title = "Exit",
						iconName = os.isLinux and "" or "power-off",
						onClick = function()
							native.requestExit()
						end
					}
				}
			},
			{
				title = "Edit",
				subItems = {
					{
						title = "Undo",
						iconName = os.isLinux and "" or "undo-alt",
						onClick = function(event)
						end
					},
					{
						title = "Redo",
						iconName = os.isLinux and "" or "redo-alt",
						onClick = function(event)
						end
					},
					{
						title = "Rotate",
						iconName = os.isLinux and "" or "sync-alt",
						onClick = function(event)
							local toolEvent = {
								name = eventList.toolChanged,
								tool = toolList.rotate
							}
							Runtime:dispatchEvent(toolEvent)
						end
					},
					{
						title = "Flip Horizontal",
						iconName = os.isLinux and "" or "arrows-h",
						onClick = function(event)
							local toolEvent = {
								name = eventList.toolChanged,
								tool = toolList.flipHorizontal
							}
							Runtime:dispatchEvent(toolEvent)
						end
					},
					{
						title = "Flip Vertical",
						iconName = os.isLinux and "" or "arrows-v",
						onClick = function(event)
							local toolEvent = {
								name = eventList.toolChanged,
								tool = toolList.flipVertical
							}
							Runtime:dispatchEvent(toolEvent)
						end
					},
					{
						title = "Preferences",
						iconName = os.isLinux and "" or "tools",
						onClick = function(event)
						end
					},
				}
			},
			{
				title = "View",
				subItems = {
					{
						title = "TODO",
						iconName = os.isLinux and "" or "th-large",
						onClick = function(event)
						end
					}
				}
			},
			{
				title = "Help",
				subItems = {
					{
						title = "Support Me On Patreon",
						iconName = os.isLinux and "" or "patreon",
						font = fontAwesomeBrandsFont,
						onClick = function(event)
							system.openURL("https://www.patreon.com/dannyglover")
						end
					},
					{
						title = "Report Bug",
						iconName = os.isLinux and "" or "github",
						font = fontAwesomeBrandsFont,
						onClick = function(event)
							system.openURL("https://github.com/DannyGlover/SDC")
						end
					},
					{
						title = "Submit Feature Request",
						iconName = os.isLinux and "" or "trello",
						font = fontAwesomeBrandsFont,
						onClick = function(event)
							system.openURL("https://github.com/DannyGlover/SDC")
						end
					},
					{
						title = "Visit Website",
						iconName = os.isLinux and "" or "browser",
						onClick = function(event)
							system.openURL("https://dannyglover.uk")
						end
					},
					{
						title = "About",
						iconName = os.isLinux and "" or "info-circle",
						onClick = function(event)
						end
					}
				}
			}
		}
	}
)

local bottomGroup = display.newGroup()
local topGroup = display.newGroup()
newMapWindow = newMapWindowWidget:new()
welcomeText = display.newText({
	text = "Welcome to SolarTilesCreator!\n\nGo to 'File > Create Map' or 'File > Load Map' to get started.",
	font = titleFont,
	align = "center",
	fontSize = 14,
})
welcomeText.x = display.contentCenterX
welcomeText.y = display.contentCenterY

local function onKeyEvent(event)
	editor.tilePanel:onKeyEvent(event)
	editor.mapPanel:onKeyEvent(event)
	toolPanel:onKeyEvent(event)

	return true
end

local function mainLoop(event)
	-- initial panel creation after startup action (new map, load map etc)
	if (editor.createdOrLoadedMap) then
		-- create the panels
		if (editor.mapPanel == nil) then
			editor.mapPanel = mapPanelWidget:new(topGroup, 100, 100)
			editor.tilePanel = tilesheetPanelWidget:new()
			toolPanel = toolPanelWidget:new()
			layerPanel = layerPanelWidget:new()
			Runtime:addEventListener("key", onKeyEvent)
			welcomeText.isVisible = false
			editor.createdOrLoadedMap = false
		end
	
		-- refresh the panels
		if (editor.mapPanel.refresh) then
			editor.mapPanel:render()
		end

		if (editor.tilePanel.refresh) then
			editor.tilePanel:render()
		end
	end
end

Runtime:addEventListener("enterFrame", mainLoop)
