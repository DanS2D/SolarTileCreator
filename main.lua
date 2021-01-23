
local solarTiled = require("solarTilesCreator")
--solarTiled:loadMap("data/tiles/largeTest.json")
local luaExt = require("lua-ext")
local mainMenuBar = require("main-menu-bar")
local editor = require("editor")
local toolPanelWidget = require("tool-panel")
local layerPanelWidget = require("layer-panel")
local tilesheetPanelWidget = require("tilesheet-panel")
local mapPanelWidget = require("map-panel")
local titleFont = "fonts/Jost-500-Medium.ttf"
local subTitleFont = "fonts/Jost-400-Book.ttf"
local fontAwesomeBrandsFont = "fonts/FA5-Brands-Regular.ttf"
local applicationMainMenuBar = nil
local toolPanel = nil
local layerPanel = nil
local tilePanel = nil
local mapPanel = nil

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
						title = "Rotate Left",
						iconName = os.isLinux and "" or "reply-all",
						onClick = function(event)
						end
					},
					{
						title = "Rotate Right",
						iconName = os.isLinux and "" or "share-all",
						onClick = function(event)
						end
					},
					{
						title = "Flip Horizontal",
						iconName = os.isLinux and "" or "arrows-h",
						onClick = function(event)
						end
					},
					{
						title = "Flip Vertical",
						iconName = os.isLinux and "" or "arrows-v",
						onClick = function(event)
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

-- create the panels
toolPanel = toolPanelWidget:new()
layerPanel = layerPanelWidget:new()
mapPanel = mapPanelWidget:new(topGroup, 100, 100)
tilePanel = tilesheetPanelWidget:new()

local function onKeyEvent(event)
	tilePanel:onKeyEvent(event)
	mapPanel:onKeyEvent(event)
	toolPanel:onKeyEvent(event)

	return true
end

local function mainLoop(event)
	mapPanel:render()
	tilePanel:render()
end

Runtime:addEventListener("enterFrame", mainLoop)
Runtime:addEventListener("key", onKeyEvent)
